@isTest
public with sharing class PrescriptionServiceTest {
    @TestSetup
    static void makeData(){
        Drug__c drug=TestDataFactory.createDrug();
        insert drug;
        Doctor__c doctor=TestDataFactory.createDoctor();
        insert doctor;
        Patient__c patient=TestDataFactory.createPatient('Active');
        insert patient;
    }
    private static Id getDrugId() {
        return [
            SELECT Id
            FROM Drug__c
            LIMIT 1
        ].Id;
    }
    private static Id getDoctorId() {
        return [
            SELECT Id
            FROM Doctor__c
            LIMIT 1
        ].Id;
    }
    private static Id getPatientId() {
        return [
            SELECT Id
            FROM Patient__c
            LIMIT 1
        ].Id;
    }
    @isTest
    static void testPositive_dateValidation(){
        Prescription__c prescription = TestDataFactory.createPrescription(
        getDoctorId(),
        getDrugId(),
        getPatientId(),
        Date.today().addYears(1),
        50,
        10);
        
        Test.startTest();
        insert prescription;
        Test.stopTest();
        
        Prescription__c createdPrescription = [
            SELECT Id
            FROM Prescription__c
            WHERE Id =: prescription.Id
        ];
        
        System.assertEquals(prescription.Id, createdPrescription.Id);
        System.assertNotEquals(null, createdPrescription.Id);
    }
    @isTest
    static void testNegative_dateValidation(){
        Prescription__c prescription = TestDataFactory.createPrescription(
            getDoctorId(),
        getDrugId(),
        getPatientId(),
        Date.today().addYears(-1),
        50,
        10);
        
        Test.startTest();
        try{
            insert prescription;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Expiry Date cannot be in the past.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_validatePrescribedQuantity_Negative(){
        Prescription__c prescription = TestDataFactory.createPrescription(
            getDoctorId(),
        getDrugId(),
        getPatientId(),
        Date.today().addYears(1),
        -10,
        10);
        
        
        Test.startTest();
        try{
            insert prescription;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Prescribed quantity cannot be negative.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_validatePrescribedQuantity_ExceedsLimit(){
        Prescription__c prescription = TestDataFactory.createPrescription(
        getDoctorId(),
        getDrugId(),
        getPatientId(),
        Date.today().addYears(1),
        5000,
        10);
        
        Test.startTest();
        try{
            insert prescription;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Prescribed quantity cannot exceed 1000 units.'));
        }
        Test.stopTest();
        
    }

    @isTest
    static void testNegative_validateRefills(){
        Prescription__c prescription = TestDataFactory.createPrescription(
        getDoctorId(),
        getDrugId(),
        getPatientId(),
        Date.today().addYears(1),
        50,
        -3);
        
        Test.startTest();
        try{
            insert prescription;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Refills Allowed cannot be negative.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_validatePatientStatus(){
        Patient__c inactivePatient = TestDataFactory.createPatient('Inactive');
        insert inactivePatient;
        Prescription__c prescription = TestDataFactory.createPrescription(
        getDoctorId(),
        getDrugId(),
        inactivePatient.Id,
        Date.today().addYears(1),
        100,
        10);

        Test.startTest();
        try{
            insert prescription;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Prescription cannot be created for inactive patient: Test Patient'));
        }
        Test.stopTest();
    }
    @isTest
    static void testPositive_validatePatientStatus(){
        Patient__c activePatient = TestDataFactory.createPatient('Active');
        insert activePatient;
        Prescription__c prescription = TestDataFactory.createPrescription(
        getDoctorId(),
        getDrugId(),
        activePatient.Id,
        Date.today().addYears(1),
        100,
        10);

        Test.startTest();
        insert prescription;
        Test.stopTest();

        Prescription__c createdPrescription = [
            SELECT Id, Status__c
            FROM Prescription__c
            WHERE Id =: prescription.Id
        ];

        System.assertEquals(prescription.Id, createdPrescription.Id);
        System.assertEquals(prescription.Status__c, createdPrescription.Status__c);
    }

    @isTest
    static void testNegative_validateDoctorLicense(){
        Clinic__c clinic = TestDataFactory.createClinic(True);
        insert clinic;
        Doctor__c unlicensedDoctor = TestDataFactory.createDoctor(clinic.Id, false);
        insert unlicensedDoctor;

        Prescription__c prescription = TestDataFactory.createPrescription(
        unlicensedDoctor.Id,
        getDrugId(),
        getPatientId(),
        Date.today().addYears(1),
        100,
        10);

        Test.startTest();
        try{
            insert prescription;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Doctor Dr. Strange is not licensed to prescribe medication.'));
        }
        Test.stopTest();
    }
    
}