trigger DispenseTrigger on Dispense__c (before insert, before update, before delete, after insert, after update, after delete) {
    DispenseTriggerHandler handler = new DispenseTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.beforeUpdate(Trigger.new, Trigger.oldMap, Trigger.old);
        }
        if(Trigger.isDelete){
            handler.beforeDelete();
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}