public with sharing class DrugBatchService {
    
    // Validates business rules before a Drug Batch is committed to the database.
    
    public static void validateManufactureDate(List<Drug_Batch__c> newBatches) {
        for(Drug_Batch__c dr: newBatches){
            if(dr.Manufacture_Date__c!=null && dr.Manufacture_Date__c > Date.today()){
                dr.Manufacture_Date__c.addError('Manufacture Date cannot be in the future.');
            }
        }
    }
    
    public static void validateExpiryDate(List<Drug_Batch__c> newBatches){
        for(Drug_Batch__c dr: newBatches){
            if(dr.Expiry_Date__c!=null && dr.Expiry_Date__c < Date.today()){
                dr.Expiry_Date__c.addError('Expiry Date cannot be in the past.');
            }
            if(dr.Expiry_Date__c!=null && dr.Manufacture_Date__c!=null && dr.Expiry_Date__c<dr.Manufacture_Date__c){
                dr.Expiry_Date__c.addError('Expiry Date cannot be before the manufacture date');
            }
        }
    }
    
    public static void validateDrugBatchQuantity(List<Drug_Batch__c> newBatches){
        for(Drug_Batch__c dr: newBatches){
            if(dr.Quantity_Received__c != null && dr.Quantity_Received__c <= 0){
                dr.Quantity_Received__c.addError('Quantity must be greater than 0.');
            }
        }
    }
    
    public static void validateRecallReason(List<Drug_Batch__c> newBatches){
        for(Drug_Batch__c dr: newBatches){
            if(dr.Batch_Status__c=='Recalled' && dr.Recall_Reason__c==null){
                dr.Recall_Reason__c.addError('Recall Reason is required when batch is recalled.');
            }
            if(dr.Batch_Status__c!='Recalled' && dr.Recall_Reason__c!=null){
                dr.Recall_Reason__c.addError('Recall Reason should be blank unless batch is recalled.');
            }
        }
    }
    
    public static void validateBatchStatus(List<Drug_Batch__c> newBatches){
        for(Drug_Batch__c dr: newBatches){
            if(dr.FDA_Approved__c==false && dr.Batch_Status__c == 'Active'){
                dr.Batch_Status__c.addError('Batch cannot be marked as Active if not FDA Approved.');
            }
            Set<String> invalidStatuses = new Set<String>{'Recalled', 'Disposed', 'Expired', 'Consumed'};
            if(invalidStatuses.contains(dr.Batch_Status__c)){
                dr.Batch_Status__c.addError('New Batch cannot be created with the '+dr.Batch_Status__c+' status.');
            }
        }
    }
    
    public static void validateStatusProgression(List<Drug_Batch__c> newBatches, Map<Id, Drug_Batch__c> oldMap){
        if(oldMap==null){
            return;
        }
        
        // Defines the only valid lifecycle transitions for a Drug Batch.
        Map<String, Set<String>> allowedStatuses = new Map<String, Set<String>>{
            'Pending Approval' => new Set<String>{'Active'},
            'Active'           => new Set<String>{'Quarantined', 'Expired', 'Consumed'},
            'Quarantined'      => new Set<String>{'Active', 'Recalled'},
            'Recalled'         => new Set<String>{'Disposed'},
            'Expired'          => new Set<String>{'Disposed'},
            'Consumed'         => new Set<String>{'Disposed'},
            'Disposed'         => new Set<String>()
        };
        
        for(Drug_Batch__c dr: newBatches){
            String oldStatus = oldMap.get(dr.Id).Batch_Status__c;
            
            if(dr.Batch_Status__c==oldStatus){
                continue;
            }
            
            if(String.isNotBlank(oldStatus) && oldStatus!=null){
                Set<String> possibleStatusValues = allowedStatuses.get(oldStatus);
                
                if(possibleStatusValues!=null && !possibleStatusValues.contains(dr.Batch_Status__c)){
                    String allowedStatusValues = String.join(possibleStatusValues,' , ');
                    dr.Batch_Status__c.addError('Invalid Transition. \r\nAllowed next status(s) : '+allowedStatusValues);
                }
            }
        }
    }
    
    public static void validateSupplier(List<Drug_Batch__c> newBatches){
        for(Drug_Batch__c dr: newBatches){
            if(dr.Recall_Reason__c=='Supplier Issue' && String.isBlank(dr.Supplier_Name__c) && String.isBlank(dr.Supplier_Email__c)){
                dr.addError('When Recall Reason is "Supplier Issue", provide either Supplier Name or Supplier Email.');
            }
        }
    }
    
    public static void initializeLastStatusUpdateDate(List<Drug_Batch__c> newBatches){
        for(Drug_Batch__c dr: newBatches){
            if(String.isNotBlank(dr.Batch_Status__c)){
                dr.Status_Last_Updated_Date__c=Date.today();
            }
        }
    }
    public static void enforceQuantityForActiveRecords(List<Drug_Batch__c> newBatches, Map<Id, Drug_Batch__c> oldMap){
        if(oldMap==null){
            return;
        }
        for(Drug_Batch__c dr: newBatches){
            Drug_Batch__c oldDr = oldMap.get(dr.Id);
            // Identifying active drug batch records with changed quantities.
            Boolean changeDisallowed = OldDr.Batch_Status__c=='Active' &&
                dr.Quantity_Received__c!=null &&
                oldDr.Quantity_Received__c!=null &&
                dr.Quantity_Received__c!=oldDr.Quantity_Received__c;
            
            if(changeDisallowed){
                dr.Quantity_Received__c.addError('Quantity received cannot be modified for active batches');
            }
        }
    }
    public static void automationDrugBatchInventory(List<Drug_Batch__c> newBatches, Map<Id, Drug_Batch__c> oldMap)
    {
        Set<Id> drugIds = new Set<Id>();
        List<Drug_Batch__c> eligibleRecords = new List<Drug_Batch__c>();
        // Identify only batches that should contribute to inventory. Collect eligible records.
        for (Drug_Batch__c dr : newBatches) {
            
            Boolean shouldUpdateInventory = false;
            
            if (oldMap == null) {
                // New Active batch created.
                shouldUpdateInventory =
                    dr.Drug__c != null &&
                    dr.Batch_Status__c == 'Active';
            } else {
                // Existing batch transitioned into Active.
                Drug_Batch__c oldRecord = oldMap.get(dr.Id);
                
                shouldUpdateInventory =
                    dr.Drug__c != null &&
                    oldRecord.Batch_Status__c != 'Active' &&
                    dr.Batch_Status__c == 'Active';
            }
            
            if (shouldUpdateInventory) {
                drugIds.add(dr.Drug__c);
                eligibleRecords.add(dr);
            }
        }
        
        if (drugIds.isEmpty()) {
            return;
        }
        
        Map<Id, Inventory__c> inventoryMap = new Map<Id, Inventory__c>();
        
        // Retrieve existing inventory records in a single SOQL query.
        for (Inventory__c inv : [
            SELECT Id, Drug_Name__c, Quantity_On_Hand__c
            FROM Inventory__c
            WHERE Drug_Name__c IN :drugIds
        ]) {
            inventoryMap.put(inv.Drug_Name__c, inv);
        }
        
        Set<Inventory__c> inventoryDMLUpdate = new Set<Inventory__c>();
        Set<Inventory__c> inventoryDMLInsert = new Set<Inventory__c>();
        
        for (Drug_Batch__c dr : eligibleRecords) {
            
            Inventory__c inv = inventoryMap.get(dr.Drug__c);
            
            if (inv != null) {
                inv.Quantity_On_Hand__c += dr.Quantity_Received__c;
                inventoryDMLUpdate.add(inv);
            } else {
                Inventory__c newInv = new Inventory__c(
                    Drug_Name__c = dr.Drug__c,
                Quantity_On_Hand__c = dr.Quantity_Received__c,
                Drug_Batch__c = dr.Id
                    );
                inventoryDMLInsert.add(newInv);
            }
        }
        
        // Perform bulk DML operations outside of loops.
        if (!inventoryDMLUpdate.isEmpty()) {
            update new List<Inventory__c>(inventoryDMLUpdate);
        }
        
        if (!inventoryDMLInsert.isEmpty()) {
            insert new List<Inventory__c>(inventoryDMLInsert);
        }
    }
    
    public static void activeBatchCountByDrug(List<Drug_Batch__c> newBatches, Map<Id, Drug_Batch__c> oldMap){
        Set<Id> drugIds = new Set<Id>();
        
        for(Drug_Batch__c dr: newBatches){
            Boolean updateDrug = false;
            if(oldMap==null){// Identifying new created active drug batches
                updateDrug = dr.Batch_Status__c=='Active' && dr.Quantity_Received__c>0;
            } else {
                Drug_Batch__c oldDr = oldMap.get(dr.Id); //Identifying existing batches that changed from or to active status.
                updateDrug = ((dr.Batch_Status__c == 'Active' && oldDr.Batch_Status__c!='Active') ||
                    (dr.Batch_Status__c != 'Active' && oldDr.Batch_Status__c=='Active'))  &&
                    dr.Quantity_Received__c>0;
            }
            if(updateDrug){
                drugIds.add(dr.Drug__c);
            }
        }
        if(drugIds.isEmpty()){
            return;
        }
        Map<Id, Decimal> quantityByDrugMap = new Map<Id, Decimal>();
        for(AggregateResult ar: [SELECT SUM(Quantity_Received__c) TotalQuantity , Drug__c
                                 FROM Drug_Batch__c 
                                 WHERE Drug__c IN :drugIds 
                                 AND Batch_Status__c = 'Active'
                                 GROUP BY Drug__c])
        {
            quantityByDrugMap.put(
                (Id)ar.get('Drug__c'),
            (Decimal)ar.get('TotalQuantity')
                );
        }
        Set<Drug__c> updatedDrugs = new Set<Drug__c>();
        for(Id index: drugIds){
            Decimal activeQuantities = 0.0;
            if(quantityByDrugMap.containsKey(index)){
                activeQuantities=quantityByDrugMap.get(index);
            }
            Drug__c newDrug = new Drug__c(
                Id = index,
            Total_Active_Quantities__c = activeQuantities
                );
            
            updatedDrugs.add(newDrug);
        }
        if(!updatedDrugs.isEmpty()){
            update new List<Drug__c>(updatedDrugs);
        }
    }

    public static void batchInventoryFreeze(List<Drug_Batch__c> newBatches, Map<Id, Drug_Batch__c> oldMap){
        Set<Id> batchIds = new Set<Id>();
        for(Drug_Batch__c dr: newBatches){
            Drug_Batch__c olddr = oldMap.get(dr.Id);
            if(olddr!=null && dr.Batch_Status__c=='Recalled' && olddr.Batch_Status__c!='Recalled'){
                batchIds.add(dr.Id);
            }
        }

        if(batchIds.isEmpty()){
            return;
        }
        Map<Id, Inventory__c> inventoryUpdateMap = new Map<Id, Inventory__c>();
        for(Inventory__c inv : [SELECT Id, Is_Frozen__c, Inventory_Status__c FROM
                                Inventory__c WHERE Drug_Batch__c in :batchIds])
        {
            if(!inv.Is_Frozen__c){
                inventoryUpdateMap.put(inv.Id, new Inventory__c(Id=inv.Id, Is_Frozen__c=true, Inventory_Status__c = 'Frozen'));
            }
        }
        if(!inventoryUpdateMap.isEmpty()){
            update inventoryUpdateMap.values();
        }
    }
}