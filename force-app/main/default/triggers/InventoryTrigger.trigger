trigger InventoryTrigger on Inventory__c (before insert, before update, before delete, after insert, after update, after delete) {
    InventoryTriggerHandler handler = new InventoryTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.beforeUpdate(Trigger.new, Trigger.oldMap, Trigger.old);
        }
    }
}