@isTest
private class InventoryServiceTest {
    @TestSetup
    static void makeData(){
        Drug__c batch = TestDataFactory.createDrug();
        insert batch;
        Drug_Batch__c drugBatch = TestDataFactory.createDrugBatch(batch.Id);
        insert drugBatch;
    }
    
    @isTest
    static void testPositive_inventoryValidations() {
        Drug_Batch__c batch = [
            SELECT Id
            FROM Drug_Batch__c
            LIMIT 1
        ];
        Inventory__c inv = TestDataFactory.createInventory(50, 20, 'Available', batch.Id);
        Test.startTest();
        insert inv;
        Test.stopTest();
        Inventory__c createdInventory = [
            SELECT Id, Quantity_On_Hand__c, Reorder_Threshold__c, Inventory_Status__c, Drug_Batch__c
            FROM Inventory__c
            WHERE Id = :inv.Id];
        
        System.assertEquals(inv.Id, createdInventory.Id);
        System.assertEquals(50, createdInventory.Quantity_On_Hand__c);
        System.assertEquals(20, createdInventory.Reorder_Threshold__c);
        System.assertEquals('Available', createdInventory.Inventory_Status__c);
        System.assertEquals(batch.Id, createdInventory.Drug_Batch__c);
    }
    @isTest
    static void testNegative_inventoryValidations_QuantityOnHand(){
        Drug_Batch__c batch = [
            SELECT Id
            FROM Drug_Batch__c
            LIMIT 1
        ];
        Inventory__c inv = TestDataFactory.createInventory(-4, 20, 'Available', batch.Id);
        Test.startTest();
        try{
            insert inv;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Quantity on hand cannot be less than 0.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_inventoryValidations_ReorderThreshold() {
        Drug_Batch__c batch = [
            SELECT Id
            FROM Drug_Batch__c
            LIMIT 1
        ];
        
        Inventory__c inv = TestDataFactory.createInventory(
            50, -30, 'Available', batch.Id);
        Test.startTest();
        try{
            insert inv;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Reorder Threshold cannot be less than 0.'));
        }
        Test.stopTest();
    }
    @isTest
    static void testNegative_inventoryValidations_QuantityOnHand_ReorderThresholdCheck(){
        Drug_Batch__c batch = [
            SELECT Id
            FROM Drug_Batch__c
            LIMIT 1
        ];
        Inventory__c inv = TestDataFactory.createInventory(10, 20, 'Available', batch.Id);
        Test.startTest();
        try{
            insert inv;
            System.assert(false,'Expected DMLException');
        }catch(DmlException e){
            System.assert(e.getMessage().contains('Reorder Threshold cannot exceed the Quantity on hand.'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testPositive_inventoryDrugMatch() {
        Drug_Batch__c batch = [
        SELECT Id, Drug__c
        FROM Drug_Batch__c
        LIMIT 1
    ];
        
        Inventory__c inv = TestDataFactory.createInventory(20, 10, 'Available', batch.Id);
        
        Test.startTest();
        insert inv;
        Test.stopTest();
        
        Inventory__c createdInventory = [
        SELECT Drug_Batch__c, Drug_Name__c
        FROM Inventory__c
        WHERE Id = :inv.Id
    ];
        
        System.assertEquals(batch.Id, createdInventory.Drug_Batch__c);
        System.assertEquals(batch.Drug__c, createdInventory.Drug_Name__c);
    }
}