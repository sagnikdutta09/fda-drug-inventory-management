public with sharing class DispenseTriggerHandler {
    public void beforeInsert(List<Dispense__c> newRecords) {
        DispenseService.baseValidations(newRecords);
        DispenseService.prescriptionValidations(newRecords);
        DispenseService.validateDispenseOverflow(newRecords);
        DispenseService.validateDispenseOverflow(newRecords);
    }

    public void afterInsert(List<Dispense__c> newRecords) {
        DispenseService.inventoryQuantityUpdate(newRecords);
        DispenseService.prescriptionStatusUpdate(newRecords);
        DispenseService.inventoryStatusUpdate(newRecords);
    }
}