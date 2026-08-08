@isTest
public with sharing class DispenseServiceTest {
    @TestSetup
    static void makeData(){
        Doctor__c doctor = TestDataFactory.createDoctor();
        Drug__c drug = TestDataFactory.createDrug();
        Patient__c patient = TestDataFactory.createPatient('Active');
        insert new List<SObject>{ doctor, drug, patient };
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(drug.Id);
        insert drugBatch;
        Prescription__c prescription = TestDataFactory.createPrescription(doctor.Id, drug.Id, patient.Id, Date.today().addDays(-14));
        insert prescription;
        Inventory__c inventory = TestDataFactory.createInventory(drugBatch.Id);
        insert inventory;
    }
    private static Id getPrescriptionId(){
        return [
            SELECT Id
            FROM Prescription__c
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
    private static Id getInventoryId() {
        return [
            SELECT Id
            FROM Inventory__c
            LIMIT 1
        ].Id;
    }
    
    @isTest
    static void TestPositive_baseValidations(){
        Dispense__c dispense = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        50,
        Date.today());
        
        Test.startTest();
        insert dispense;
        Test.stopTest();
        
        Dispense__c insertedDispense = [
            SELECT Id
            FROM Dispense__c
            WHERE Id = :dispense.Id
        ];
        System.assertEquals(dispense.Id, insertedDispense.Id);
    }
    @isTest
    static void TestNegative_baseValidations_dispenseDate(){
        Dispense__c dispense = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        50,
        Date.today().addMonths(1));
        
        Test.startTest();
        try{
            insert dispense;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Dispense Date cannot be in the future.'));
        }
        Test.stopTest();
    }
    @isTest
    static void TestNegative_baseValidations_dispenseQuantity(){
        Dispense__c dispense = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        0,
        Date.today());
        
        Test.startTest();
        try{
            insert dispense;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Dispensed Quantity must be greater than 0.'));
        }
        Test.stopTest();
    }
    @isTest
    static void TestNegative_prescriptionValidations_dateCheck(){
        Dispense__c dispense = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        50,
        Date.today().addMonths(-2));
        
        Test.startTest();
        try{
            insert dispense;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Dispense date cannot be prior to prescription date.'));
        }
        Test.stopTest();
    }
    @isTest
    static void TestNegative_baseValidations_prescriptionStatus(){
        Id prescId = getPrescriptionId();
        Prescription__c prescription = [
            SELECT Id, Status__c
            FROM Prescription__c
            WHERE Id = :prescId
        ];
        prescription.Status__c='Completed';
        update prescription;
        
        Dispense__c dispense = TestDataFactory.createDispense(
            prescription.Id,
        getPatientId(),
        getInventoryId(),
        50,
        Date.today());
        
        Test.startTest();
        try{
            insert dispense;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Dispense cannot be authorized because the selected prescription is not in Pending or Partially Dispensed status.'));
        }
        Test.stopTest();
    }
    @isTest
    static void TestNegative_prescriptionValidations_patientMismatch(){
        Patient__c secondPatient = TestDataFactory.createPatient('Active');
        insert secondPatient;
        Dispense__c dispense = TestDataFactory.createDispense(
            getPrescriptionId(),
        secondPatient.Id,
        getInventoryId(),
        50,
        Date.today());
        
        Test.startTest();
        try{
            insert dispense;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Selected patient does not match the patient on the prescription.'));
        }
        Test.stopTest();
    }
    @isTest
    static void TestPositive_validateDispenseOverflow(){
        Dispense__c dispense1 = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        20,
        Date.today());
        
        insert dispense1;
        
        Dispense__c dispense2 = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        29,
        Date.today());
        
        Test.startTest();
        insert dispense2;
        Test.stopTest();
        
        AggregateResult ar = [
            SELECT SUM(Dispensed_Quantity__c) total
            FROM Dispense__c
            WHERE Prescription__c = :getPrescriptionId()
        ];
        
        Decimal totalDispensed = (Decimal) ar.get('total');
        
        System.assertEquals(49, totalDispensed);
        Dispense__c insertedDispense = [
                SELECT Id, Prescription__c
                FROM Dispense__c
                WHERE Id = :dispense2.Id
            ];
        System.assertEquals(dispense2.Id, insertedDispense.Id);
        System.assertEquals(49, totalDispensed);
        
    }
    @isTest
    static void TestNegative_validateDispenseOverflow() {
        
        Dispense__c dispense1 = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        24,
        Date.today()
            );
        
        insert dispense1;
        
        Dispense__c dispense2 = TestDataFactory.createDispense(
            getPrescriptionId(),
        getPatientId(),
        getInventoryId(),
        30,
        Date.today()
            );
        
        Test.startTest();
        try {
            insert dispense2;
            System.assert(false, 'Expected DMLException');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains(
                'This dispense would exceed the prescribed quantity of 50.'
                )
                );
        }
        Test.stopTest();
    }
}