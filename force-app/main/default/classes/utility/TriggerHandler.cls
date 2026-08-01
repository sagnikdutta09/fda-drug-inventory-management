public interface TriggerHandler{
    void beforeInsert();
    void afterInsert();
    void beforeUpdate();
    void afterUpdate();
    void beforeDelete();
    void afterDelete();
}