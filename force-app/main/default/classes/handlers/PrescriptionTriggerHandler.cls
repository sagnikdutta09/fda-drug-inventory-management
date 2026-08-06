public with sharing class PrescriptionTriggerHandler {
    public void beforeInsert(List<Prescription__c> newRecords) {
        PrescriptionService.dateValidation(newRecords);
        PrescriptionService.validatePatientStatus(newRecords);
        PrescriptionService.validatePrescriptionQuantity(newRecords);
        PrescriptionService.validateRefills(newRecords);
        PrescriptionService.validateDoctorLicense(newRecords);
    }

    public void beforeUpdate(List<Prescription__c> newRecords, Map<Id,Prescription__c> oldMap, List<Prescription__c> oldRecords) {

    }

    public void beforeDelete() {

    }

    public void afterInsert(List<Prescription__c> newRecords) {

    }

    public void afterUpdate(List<Prescription__c> newRecords, Map<Id, Prescription__c> oldMap) {

    }

    public void afterDelete() {

    }
}