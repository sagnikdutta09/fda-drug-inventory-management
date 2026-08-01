trigger DoctorTrigger on Doctor__c (before insert, before update, before delete, after insert, after update, after delete) {
    DoctorTriggerHandler handler = new DoctorTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.beforeUpdate(Trigger.new, Trigger.oldMap, Trigger.old);
        }
    }
}