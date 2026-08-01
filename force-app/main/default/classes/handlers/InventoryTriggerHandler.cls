public with sharing class InventoryTriggerHandler {
    public void beforeInsert(List<Inventory__c>  newRecords) {
        InventoryService.inventoryDrugMatch(newRecords);
        InventoryService.inventoryValidations(newRecords);
    }

    public void beforeUpdate(List<Inventory__c>  newRecords, Map<Id,Inventory__c> oldMap, List<Inventory__c> oldRecords) {
        InventoryService.inventoryDrugMatch(newRecords);
        InventoryService.inventoryValidations(newRecords);
    }
}