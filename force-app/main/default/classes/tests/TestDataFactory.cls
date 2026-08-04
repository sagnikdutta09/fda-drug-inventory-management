@IsTest
public with sharing class TestDataFactory {

    public static Clinic__c createClinic(Boolean openForBusiness) {
        return new Clinic__c(
            Name = 'Apollo Clinic',
            Region__c = 'East',
            Open_For_Business__c = openForBusiness
        );
    }

    public static Doctor__c createDoctor(Id clinicId) {
        return new Doctor__c(
            Name = 'Dr. Strange',
            Clinic__c = clinicId,
            Licensed__c = true,
            License_Number__c = 'LIC-100000',
            License_Expiry__c = Date.today().addYears(2),
            Specialization__c = 'General Medicine'
        );
    }

    public static Drug__c createDrug() {
        return new Drug__c(
            Name = 'Paracetamol',
            Drug_Category__c = 'Analgesic',
            Dosage_Form__c = 'Tablet',
            Strength__c = '500 mg',
            Manufacturer__c = 'Pfizer',
            Active__c = true,
            Controlled_Substance__c = false
        );
    }

    public static Drug_Batch__c createDrugBatch(Id drugId) {
        return createDrugBatch(
            drugId,
            12345,
            true,
            'Pending Approval',
            Date.today().addMonths(-2),
            Date.today().addMonths(2),
            100
        );
    }

    public static Drug_Batch__c createDrugBatch(
        Id drugId,
        Integer lotNumber,
        Boolean fdaApproved,
        String batchStatus,
        Date manufactureDate,
        Date expiryDate,
        Integer quantityReceived
    ) {
        return new Drug_Batch__c(
            Lot_Number__c = lotNumber,
            Manufacture_Date__c = manufactureDate,
            Expiry_Date__c = expiryDate,
            FDA_Approved__c = fdaApproved,
            Batch_Status__c = batchStatus,
            Drug__c = drugId,
            Quantity_Received__c = quantityReceived
        );
    }

    public static Inventory__c createInventory(
        Integer quantityOnHand,
        Integer reorderThreshold,
        String inventoryStatus,
        Id drugBatchId
    ) {
        return new Inventory__c(
        Quantity_On_Hand__c = quantityOnHand,
        Reorder_Threshold__c = reorderThreshold,
        Inventory_Status__c = inventoryStatus,
        Drug_Batch__c = drugBatchId
        );
    }
}