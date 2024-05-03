trigger ProductoDeInternacionTrigger on Producto_de_Internacion__c (after insert,after delete) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ProductoDeInternacionTriggerHelper.autoCompleteModuloAndTipoDeServicio(Trigger.new);
        }
        
    }
    if(Trigger.isAfter){
        if(Trigger.isDelete){
            ProductoDeInternacionTriggerHelper.autoCompleteModuloAndTipoDeServicio(Trigger.old);
        }
    }
}