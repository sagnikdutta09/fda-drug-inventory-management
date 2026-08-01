public with sharing class DoctorTriggerHandler {
    public void beforeInsert(List<Doctor__c>  newRecords) {
        DoctorService.openForBusinessValidation(newRecords);
    }

    public void beforeUpdate(List<Doctor__c>  newRecords, Map<Id,Doctor__c> oldMap, List<Doctor__c> oldRecords) {
        DoctorService.openForBusinessValidation(newRecords);
    }
}