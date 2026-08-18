@IsTest
public with sharing class TestDataFactory {
    
    public static Clinic__c createClinic(Boolean openForBusiness) {
        return new Clinic__c(
        Name = 'Apollo Clinic',
        Region__c = 'East',
        Open_For_Business__c = openForBusiness
            );
    }
    
    public static Doctor__c createDoctor(Id clinicId,
    Boolean islicensed) {
        Integer randomNumber = Math.mod(Math.abs(Crypto.getRandomInteger()), 1000000);
        String licenseNumber = 'LIC-' + String.valueOf(randomNumber).leftPad(6, '0');
        return new Doctor__c(
        Name = 'Dr. Strange',
        Clinic__c = clinicId,
        Licensed__c = islicensed,
        License_Number__c = licenseNumber,
        License_Expiry__c = Date.today().addYears(2),
        Specialization__c = 'General Medicine'
            );
    }
    
    public static Doctor__c createDoctor(){
        Clinic__c clinic = createClinic(true);
        insert clinic;
        
        return createDoctor(clinic.Id, True);
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
        true,
        'Pending Approval',
        Date.today().addMonths(-2),
        Date.today().addMonths(2),
        100,
        null
            );
    }
    
    public static Drug_Batch__c createDrugBatch(
    Id drugId,
    Boolean fdaApproved,
    String batchStatus,
    Date manufactureDate,
    Date expiryDate,
    Integer quantityReceived,
    String recallReason
    ) {
        return new Drug_Batch__c(
        Lot_Number__c = 12345,
        Manufacture_Date__c = manufactureDate,
        Expiry_Date__c = expiryDate,
        FDA_Approved__c = fdaApproved,
        Batch_Status__c = batchStatus,
        Drug__c = drugId,
        Quantity_Received__c = quantityReceived,
        Recall_Reason__c = recallReason
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
    
    public static Inventory__c createInventory(Id drugBatchId){
        return createInventory(
        50,
        10,
        'Active',
        drugBatchId);
    }
    public static Patient__c createPatient(String patStatus){
        return new Patient__c(
        Name='Test Patient',
        Date_Of_Birth__c=Date.today().addYears(-20),
        Gender__c='Male',
        Patient_Phone__c='9123927881',
        Email__c='patient' + DateTime.now().getTime() + '@test.com',
        Blood_Group__c='A+',
        Status__c=patStatus
            );
    }
    
    public static Patient__c createPatient(){
        return createPatient('Active');
    }
    
    public static Prescription__c createPrescription(
        Id doctorId,
    Id drugId,
    Id patientId,
    Date expiryDate,
    Integer prescribedQuantity,
    Integer refillsAllowed
    ){
        return new Prescription__c(
            Status__c='Pending',
        Expiry_Date__c=expiryDate,
        Prescription_Date__c = Date.today(),
        Patient__c=patientId,
        Prescribed_Quantity__c=prescribedQuantity,
        Refills_Allowed__c=refillsAllowed,
        Doctor__c=doctorId,
        Drug__c=drugId
            );
    }
    public static Prescription__c createPrescription(
    Id doctorId,
    Id drugId,
    Id patientId,
    Date prescriptionDate
    ){
        return new Prescription__c(
        Status__c='Pending',
        Expiry_Date__c=Date.today().addMonths(3),
        Prescription_Date__c = prescriptionDate,
        Patient__c=patientId,
        Prescribed_Quantity__c=50,
        Refills_Allowed__c=10,
        Doctor__c=doctorId,
        Drug__c=drugId
            );
    }
    public static Dispense__c createDispense(
    Id prescriptionId,
    Id patientId,
    Id inventoryId,
    Integer dispQuantity,
    Date dispenseDate
    ){
        return new Dispense__c(
            Prescription__c=prescriptionId,
        Patient__c=patientId,
        Dispensed_Quantity__c=dispQuantity,
        Dispensed_Date__c=dispenseDate,
        Inventory__c=inventoryId
            );
    }
}