trigger DispenseTrigger on Dispense__c (
    before insert,
    after insert
) {
    DispenseTriggerHandler handler = new DispenseTriggerHandler();

    if (Trigger.isBefore && Trigger.isInsert) {
        handler.beforeInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }
}