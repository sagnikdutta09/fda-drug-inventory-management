public with sharing class DispenseService {
    public static void baseValidations(List<Dispense__c> newDispenses){
        for(Dispense__c disp: newDispenses){
            if(disp.Dispensed_Date__c != null && disp.Dispensed_Date__c > Date.today()){
                disp.Dispensed_Date__c.addError('Dispense Date cannot be in the future.');
            }
            if(disp.Dispensed_Quantity__c<=0){
                disp.Dispensed_Quantity__c.addError('Dispensed Quantity must be greater than 0.');
            }
        }
    }
    public static void prescriptionValidations(List<Dispense__c> newDispenses){
        Set<Id> prescriptionIds = new Set<Id>();
        for(Dispense__c disp: newDispenses){
            if(disp.Prescription__c!=null){
                prescriptionIds.add(disp.Prescription__c);
            }
        }
        if(prescriptionIds.isEmpty()){
            return;
        }
        Map<Id, Prescription__c> prescMap = new Map<Id, Prescription__c>(
            [SELECT Prescribed_Quantity__c, 
            Patient__c, Status__c, Prescription_Date__c FROM Prescription__c WHERE ID in :prescriptionIds]);
        
        for(Dispense__c disp: newDispenses){
            if(disp.Prescription__c==null){
                continue;
            }
            
            Prescription__c pres = prescMap.get(disp.Prescription__c);
            if(pres==null){
                disp.Prescription__c.addError('The selected prescription no longer exists.');
            } else {
                if(pres.Status__c!='Pending' && pres.Status__c!='Partially Dispensed'){
                    disp.Prescription__c.addError('Dispense cannot be authorized because the selected prescription is not in Pending or Partially Dispensed status.');
                }
                if(disp.Dispensed_Date__c!=null && pres.Prescription_Date__c!=null && disp.Dispensed_Date__c<pres.Prescription_Date__c){
                    disp.Dispensed_Date__c.addError('Dispense date cannot be prior to prescription date.');
                }
                if(disp.Patient__c != pres.Patient__c){
                    disp.Patient__c.addError('Selected patient does not match the patient on the prescription.');
                }
            }
        }
    }
    public static void validateDispenseOverflow(List<Dispense__c> newDispenses){
        
        Set<Id> prescriptionIds = new Set<Id>();
        
        for(Dispense__c disp : newDispenses){
            if(disp.Prescription__c != null){
                prescriptionIds.add(disp.Prescription__c);
            }
        }
        
        if(prescriptionIds.isEmpty()){
            return;
        }
        
        Map<Id, Prescription__c> prescMap = new Map<Id, Prescription__c>(
            [SELECT Prescribed_Quantity__c FROM Prescription__c WHERE Id IN :prescriptionIds]);
        
        Map<Id, Decimal> existingDispenseMap = new Map<Id, Decimal>();
        
        for(AggregateResult ar : [ SELECT Prescription__c, SUM(Dispensed_Quantity__c) totalDispensed
            FROM Dispense__c
            WHERE Prescription__c IN :prescriptionIds
            GROUP BY Prescription__c])
        {
            existingDispenseMap.put(
                (Id) ar.get('Prescription__c'),
            (Decimal) ar.get('totalDispensed'));
        }
        
        for(Dispense__c disp : newDispenses){
            
            if(disp.Prescription__c == null || disp.Dispensed_Quantity__c == null){
                continue;
            }
            
            Prescription__c presc = prescMap.get(disp.Prescription__c);
            
            if(presc == null || presc.Prescribed_Quantity__c == null){
                continue;
            }
            
            Decimal totalDispensed = disp.Dispensed_Quantity__c;
            
            if(existingDispenseMap.containsKey(disp.Prescription__c)){
                totalDispensed += existingDispenseMap.get(disp.Prescription__c);
            }
            
            if(totalDispensed > presc.Prescribed_Quantity__c){
                disp.Dispensed_Quantity__c.addError(
                    'This dispense would exceed the prescribed quantity of '
                    + presc.Prescribed_Quantity__c + '.'
                    );
            }
        }
    }
    public static void prescriptionStatusUpdate(List<Dispense__c> newDispenses){
        Set<Id> prescriptionIds = new Set<Id>();
        for(Dispense__c disp: newDispenses){
            if(disp.Prescription__c!=null){
                prescriptionIds.add(disp.Prescription__c);
            }
        }
        if(prescriptionIds.isEmpty()){
            return;
        }
        Map<Id, Prescription__c> prescMap = new Map<Id, Prescription__c>(
            [SELECT Status__c, Prescribed_Quantity__c FROM Prescription__c WHERE ID in :prescriptionIds]);
        Map<Id, Decimal> existingDispenseMap = new Map<Id, Decimal>();
        Map<Id, Prescription__c> prescriptionUpdates = new Map<Id, Prescription__c>();
        
        for(AggregateResult ar: [SELECT SUM(Dispensed_Quantity__c) existingDispense, Prescription__c
                               FROM Dispense__c 
                               WHERE Prescription__c in :prescriptionIds
                               GROUP BY Prescription__c])
        {
            existingDispenseMap.put((Id)ar.get('Prescription__c'),
            (Decimal)ar.get('existingDispense'));
        }
        
        for(Dispense__c disp: newDispenses){
            if(disp.Prescription__c==null){continue;}
            
            Decimal totalDispense=0.0;
            if(existingDispenseMap.get(disp.Prescription__c)!=null && existingDispenseMap.get(disp.Prescription__c)>0)
            {
                totalDispense = existingDispenseMap.get(disp.Prescription__c);
            }
            
            Prescription__c presc = prescMap.get(disp.Prescription__c);
            if(presc.Prescribed_Quantity__c!=null && presc.Status__c!='Completed'){
                if(totalDispense<presc.Prescribed_Quantity__c){
                    prescriptionUpdates.put(
                        disp.Prescription__c, new Prescription__c(Id = disp.Prescription__c, Status__c = 'Partially Dispensed'));
                }
                else if(totalDispense==presc.Prescribed_Quantity__c){
                    prescriptionUpdates.put(
                        disp.Prescription__c, new Prescription__c(Id = disp.Prescription__c, Status__c = 'Completed'));
                }
            }
        }
        
        if(!prescriptionUpdates.isEmpty()){
            update prescriptionUpdates.values();
        }
    }
    
    public static void inventoryQuantityUpdate(List<Dispense__c> newDispenses) {
        
        Set<Id> inventoryIds = new Set<Id>();
        
        for (Dispense__c disp : newDispenses) {
            if (disp.Inventory__c != null) {
                inventoryIds.add(disp.Inventory__c);
            }
        }
        
        if (inventoryIds.isEmpty()) {
            return;
        }
        
        Map<Id, Inventory__c> inventoryMap = new Map<Id, Inventory__c>(
            [
            SELECT Id,
                   Quantity_On_Hand__c
            FROM Inventory__c
            WHERE Id IN :inventoryIds
        ]
            );
        
        // Sum total quantity dispensed per Inventory
        Map<Id, Decimal> quantityDeductionMap = new Map<Id, Decimal>();
        
        for (Dispense__c disp : newDispenses) {
            
            if (disp.Inventory__c == null) {
                continue;
            }
            
            Decimal currentTotal = quantityDeductionMap.containsKey(disp.Inventory__c)
                ? quantityDeductionMap.get(disp.Inventory__c)
                : 0;
            
            quantityDeductionMap.put(disp.Inventory__c, currentTotal + disp.Dispensed_Quantity__c);
        }
        
        List<Inventory__c> inventoryUpdates = new List<Inventory__c>();
        
        for (Id inventoryId : quantityDeductionMap.keySet()) {
            
            Inventory__c inventory = inventoryMap.get(inventoryId);
            
            if (inventory == null) {
                continue;
            }
            
            inventoryUpdates.add(
                new Inventory__c(
                Id = inventoryId,
            Quantity_On_Hand__c =
                inventory.Quantity_On_Hand__c - quantityDeductionMap.get(inventoryId)
                )
                );
        }
        
        if (!inventoryUpdates.isEmpty()) {
            update inventoryUpdates;
        }
    }
    
    public static void inventoryStatusUpdate(List<Dispense__c> newDispenses){
        Set<Id> inventoryIds = new Set<Id>();
        
        for(Dispense__c disp:  newDispenses){
            if(disp.Inventory__c!=null){
                inventoryIds.add(disp.Inventory__c);
            }
        }
        
        if(inventoryIds.isEmpty()){
            return;
        }
        
        Map<Id, Inventory__c> inventoryMap = new Map<Id, Inventory__c>
            ([SELECT Quantity_On_Hand__c, Reorder_Threshold__c, Is_Frozen__c FROM Inventory__c WHERE Id in :inventoryIds]);
        Map<Id, Inventory__c> inventoryUpdateMap = new Map<Id, Inventory__c>();
        
        for(Id index: inventoryIds){
            if(!inventoryMap.containsKey(index)){
                continue;
            }
            Inventory__c inv = inventoryMap.get(index);
            Decimal quantityOnHand = inv.Quantity_On_Hand__c, reorderThresh = inv.Reorder_Threshold__c;
            String status='';
            if (inv.Is_Frozen__c) {
                status = 'Frozen';
            }
            else if (quantityOnHand == 0) {
                status = 'Out of Stock';
            }
            else if (quantityOnHand <= reorderThresh) {
                status = 'Low Stock';
            }
            else {
                status = 'Available';
            }
            inventoryUpdateMap.put(index, new Inventory__c(
                Id = index, Inventory_Status__c = status));
        }

        if(!inventoryUpdateMap.isEmpty()){
                update inventoryUpdateMap.values();
            }
    }
}