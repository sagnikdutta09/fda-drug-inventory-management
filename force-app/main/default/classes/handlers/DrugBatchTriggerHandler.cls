public class DrugBatchTriggerHandler {

    public void beforeInsert(List<Drug_Batch__c> newRecords) {
        DrugBatchService.validateManufactureDate(newRecords);
        DrugBatchService.validateExpiryDate(newRecords);
        DrugBatchService.validateRecallReason(newRecords);
        DrugBatchService.validateDrugBatchQuantity(newRecords);
        DrugBatchService.validateBatchStatusFDA(newRecords);
        DrugBatchService.validateSupplier(newRecords);
        DrugBatchService.initializeLastStatusUpdateDate(newRecords);
        
    }

    public void beforeUpdate(List<Drug_Batch__c> newRecords, Map<Id,Drug_Batch__c> oldMap, List<Drug_Batch__c> oldRecords) {
        DrugBatchService.validateStatusProgression(newRecords, oldMap);
        DrugBatchService.validateExpiryDate(newRecords);
        DrugBatchService.validateRecallReason(newRecords);
        DrugBatchService.validateDrugBatchQuantity(newRecords);
        DrugBatchService.validateBatchStatusFDA(newRecords);
        DrugBatchService.validateSupplier(newRecords);
        DrugBatchService.enforceQuantityForActiveRecords(newRecords, oldMap);
    }

    public void beforeDelete() {
        
    }

    public void afterInsert(List<Drug_Batch__c> newRecords) {
        DrugBatchService.automationDrugBatchInventory(newRecords,null);
        DrugBatchService.activeBatchCountByDrug(newRecords, null);
    }

    public void afterUpdate(List<Drug_Batch__c> newRecords, Map<Id, Drug_Batch__c> oldMap) {
        DrugBatchService.automationDrugBatchInventory(newRecords,oldMap);
        DrugBatchService.activeBatchCountByDrug(newRecords, oldMap);
    }

    public void afterDelete() {

    }

}