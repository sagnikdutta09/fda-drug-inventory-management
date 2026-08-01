public with sharing class DoctorService {
    public static void openForBusinessValidation(List<Doctor__c> newDoctors) {
        Set<Id> clinicIds = new Set<Id>();
        for(Doctor__c dr: newDoctors){
            if(dr.Clinic__c!=null){
                clinicIds.add(dr.Clinic__c);
            }
        }
        if(clinicIds.isEmpty()){
            return;
        }
        Map<Id, Clinic__c> clinicMap = new Map<Id, Clinic__c>(
            [SELECT Id, Open_For_Business__c FROM Clinic__c
            WHERE Id IN :clinicIds]
            );
        
        for (Doctor__c dr : newDoctors) {
            if (dr.Clinic__c == null || !clinicMap.containsKey(dr.Clinic__c)) {
                continue;
            }

            Clinic__c clinic = clinicMap.get(dr.Clinic__c);
            
            if (!clinic.Open_For_Business__c) {
                dr.Clinic__c.addError('Doctors cannot be assigned to a clinic that is not open for business.');
            }
        }
    }
}