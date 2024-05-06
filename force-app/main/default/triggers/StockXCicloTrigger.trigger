trigger StockXCicloTrigger on Stock_x_Ciclo__c (before insert, after insert) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            StockXCicloTriggerHelper.asignarStockAlAPM(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            StockXCicloTriggerHelper.createStockXMM(Trigger.new);
        }
    }

}