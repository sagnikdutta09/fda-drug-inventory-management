public with sharing class InventoryService {
    public static void inventoryValidations(List<Inventory__c> newInventory) {
        for(Inventory__c inv : newInventory){
            if(inv.Quantity_On_Hand__c<0){
                inv.Quantity_On_Hand__c.addError('Quantity on hand cannot be less than 0.');
            }
            if(inv.Reorder_Threshold__c<0){
                inv.Reorder_Threshold__c.addError('Reorder Threshold cannot be less than 0.');
            }
            if(inv.Reorder_Threshold__c>inv.Quantity_On_Hand__c){
                inv.Reorder_Threshold__c.addError('Reorder Threshold cannot exceed the Quantity on hand.');
            }
        }
    }
    public static void inventoryDrugMatch(List<Inventory__c> newInventory){
        Set<Id> drugBatchIds = new Set<Id>();
        for(Inventory__c inv: newInventory){
            if(inv.Drug_Batch__c!=null){
                drugBatchIds.add(inv.Drug_Batch__c);
            }
        }
        if(drugBatchIds.isEmpty()){
            return;
        }
        Map<Id, Drug_Batch__c> drugBatchMap = new Map<Id, Drug_Batch__c>(
            [SELECT Drug__c, Drug__r.Name FROM Drug_Batch__c
            WHERE Id in :drugBatchIds]
            );
        
        for (Inventory__c inv : newInventory) {
            if (inv.Drug_Batch__c == null) continue;
            
            Drug_Batch__c batch = drugBatchMap.get(inv.Drug_Batch__c);
            
            if (batch != null) {
                inv.Drug_Name__c = batch.Drug__c;
            }
        }
    }
}