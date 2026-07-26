public with sharing class DispenseTriggerHandler {
    public void beforeInsert(List<Dispense__c> newRecords) {
        DispenseService.baseValidations(newRecords);
        DispenseService.prescriptionValidations(newRecords);
        DispenseService.validateDispenseOverflow(newRecords);
        DispenseService.validateDispenseOverflow(newRecords);
    }

    public void beforeUpdate(List<Dispense__c> newRecords, Map<Id,Dispense__c> oldMap, List<Dispense__c> oldRecords) {

    }

    public void beforeDelete() {

    }

    public void afterInsert(List<Dispense__c> newRecords) {
        DispenseService.inventoryQuantityUpdate(newRecords);
        DispenseService.prescriptionStatusUpdate(newRecords);
        DispenseService.inventoryStatusUpdate(newRecords);
    }

    public void afterUpdate(List<Dispense__c> newRecords, Map<Id, Dispense__c> oldMap) {

    }

    public void afterDelete() {

    }
}