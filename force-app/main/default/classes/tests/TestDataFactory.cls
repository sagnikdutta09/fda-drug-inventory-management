@IsTest
public with sharing class TestDataFactory {
    public static Clinic__c createClinic(Boolean openForBusiness){
        Clinic__c newClinic = new Clinic__c(
            Name = 'Apollo Clinic',
        Region__c = 'East',
        Open_For_Business__c = openForBusiness
            );
        
        return newClinic;
    }
    
    public static Doctor__c createDoctor(Id clinicId) {
        
        Doctor__c doctor = new Doctor__c(
            Name = 'Dr. Strange',
        Clinic__c = clinicId,
        Licensed__c = true,
        License_Number__c = 'LIC-100000',
        License_Expiry__c = Date.today().addYears(2),
        Specialization__c = 'General Medicine'
            );
        
        return doctor;
    }
}