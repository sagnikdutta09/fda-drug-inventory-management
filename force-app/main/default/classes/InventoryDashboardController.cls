public with sharing class InventoryDashboardController {
    public class DashboardData {
        @AuraEnabled public Integer totalInventory;
        @AuraEnabled public Integer lowStock;
        @AuraEnabled public Integer frozenInventory;

        @AuraEnabled public Integer totalPatients;
        @AuraEnabled public Integer activePatients;
        @AuraEnabled public Integer activePresc;

        @AuraEnabled public Integer totalDispense;
        @AuraEnabled public Integer dispensedThisMonth;

        @AuraEnabled public Integer totalBatches;
        @AuraEnabled public Integer activeBatches;
        @AuraEnabled public Integer activeClinics;
    }

    public static Integer getDashboardValue(List<AggregateResult> aggregateResults){
        Integer value = (Integer)aggregateResults[0].get('total');
        return value;
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData() {
        DashboardData data=new DashboardData();
        data.totalInventory = getDashboardValue([
        SELECT COUNT(Id) total
        FROM Inventory__c
        ]);

        data.lowStock= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Inventory__c
            WHERE Quantity_On_Hand__c <=10
        ]);

        data.frozenInventory= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Inventory__c
            WHERE Is_Frozen__c=true
        ]);

        data.totalPatients= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Patient__c
        ]);

        data.activePatients= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Patient__c
            WHERE Status__c = 'Active'
        ]);

        data.activePresc= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Prescription__c
            WHERE Patient__r.Status__c = 'Active'
        ]);

        data.totalDispense= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Dispense__c
        ]);

        data.dispensedThisMonth= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Dispense__c
            WHERE Dispensed_Date__c = THIS_MONTH
        ]);

        data.totalBatches= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Drug_Batch__c
        ]);

        data.activeBatches= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Drug_Batch__c
            WHERE Batch_Status__c = 'Active'
        ]);

        data.activeClinics= getDashboardValue([
            SELECT COUNT(Id) total
            FROM Clinic__c
            WHERE Open_For_Business__c = true
        ]);
        return data;
    }
}