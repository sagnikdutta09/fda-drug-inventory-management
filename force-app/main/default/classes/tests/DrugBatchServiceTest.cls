@isTest
public with sharing class DrugBatchServiceTest {
    @TestSetup
    static void makeData(){
        Drug__c drug = TestDataFactory.createDrug();
        insert drug;
    }
    
    private static Id getDrugId(){
        return
            [SELECT Id
        FROM Drug__c].Id;
    }
    
    @isTest
    static void testPositive_baseValidations(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        40,
        null);
        
        Test.startTest();
        insert drugBatch;
        Test.stopTest();

        Drug_Batch__c insertedDrugBatch = [
            SELECT Id
            FROM Drug_Batch__c
            LIMIT 1
        ];

        System.assertEquals(drugBatch.Id, insertedDrugBatch.Id);
    }

    @isTest
    static void testNegative_validateManufactureDate(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today().addMonths(1),
        Date.today().addMonths(2),
        40,
        null);

        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Manufacture Date cannot be in the future.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNegative_validateExpiryDate_PastCheck(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today().addMonths(-2),
        Date.today().addMonths(-1),
        40,
        null);

        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Expiry Date cannot be in the past.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNegative_validateExpiryDate_ManufactureDateCheck(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today(),
        Date.today().addDays(-1),
        40,
        null);

        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Expiry Date cannot be before the manufacture date.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNegative_validateDrugBatchQuantity(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        -20,
        null);

        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Quantity must be greater than 0.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testPositive_validateRecallReason(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Quarantined',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        null);

        insert drugBatch;
        drugBatch.Batch_Status__c='Recalled';
        drugBatch.Recall_Reason__c='Contamination';

        Test.startTest();
        update drugBatch;
        Test.stopTest();

        Drug_Batch__c recalledDrugBatch = [
            SELECT Id, Batch_Status__c, Recall_Reason__c
            FROM Drug_Batch__c
            LIMIT 1
        ];
        System.assertEquals(drugBatch.Id, recalledDrugBatch.Id);
        System.assert(recalledDrugBatch.Batch_Status__c=='Recalled');
        System.assert(recalledDrugBatch.Recall_Reason__c=='Contamination');
    }

    @isTest
    static void testNegative_validateRecallReason(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Quarantined',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        null);

        insert drugBatch;
        drugBatch.Batch_Status__c='Recalled';

        Test.startTest();
        try{
            update drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Recall Reason is required when batch is recalled.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_validateRecallReason_NotRecalled(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        'Contamination');


        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Recall Reason should be blank unless batch is recalled.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNegative_batchStatus(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Disposed',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        null);


        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('New Batch cannot be created with the Disposed status.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_FDAApproved(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        false,
        'Active',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        null);


        Test.startTest();
        try{
            insert drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Batch cannot be marked as Active if not FDA Approved.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNegative_BatchStatusUpdate(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Active',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        null);

        insert drugBatch;
        drugBatch.Batch_Status__c='Disposed';

        Test.startTest();
        try{
            update drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Invalid Transition.'));
        }
        Test.stopTest();    
    }

    @isTest
    static void testNegative_validateSupplier(){
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(
        getDrugId(),
        true,
        'Quarantined',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        50,
        null);

        insert drugBatch;
        drugBatch.Batch_Status__c='Recalled';
        drugBatch.Recall_Reason__c='Supplier Issue';

        Test.startTest();
        try{
            update drugBatch;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('When Recall Reason is "Supplier Issue", provide either Supplier Name or Supplier Email.'));
        }
        Test.stopTest();    
    }
}