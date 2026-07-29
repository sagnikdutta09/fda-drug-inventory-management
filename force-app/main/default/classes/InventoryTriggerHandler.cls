public with sharing class InventoryTriggerHandler {

    public void beforeInsert(List<Inventory__c> newRecords) {
        InventoryService.inventoryValidations(newRecords);
        InventoryService.inventoryDrugMatch(newRecords);
    }

    public void beforeUpdate(
        List<Inventory__c> newRecords,
        Map<Id, Inventory__c> oldMap,
        List<Inventory__c> oldRecords
    ) {
        InventoryService.inventoryValidations(newRecords);
        InventoryService.inventoryDrugMatch(newRecords);
    }
}