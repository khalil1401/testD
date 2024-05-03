trigger ServiciosDeModuloTrigger on Servicios_del_Modulo__c (before insert,before delete,after insert,after delete) {
    
    if(Trigger.isBefore && Trigger.isInsert){       
        ServiciosDeModuloTriggerHelper.completaTipoDeServicio(Trigger.new);        
    }
    
    if(Trigger.isAfter && Trigger.isDelete){      
        ServiciosDeModuloTriggerHelper.completaTipoDeServicioDespuesDeEliminar(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isInsert){    
    /*    List<Servicios_del_Modulo__c>  serviciosParaGenerarTareas = new List<Servicios_del_Modulo__c>();
        for(Servicios_del_Modulo__c nuevoServicio : Trigger.new){
            if(nuevoServicio.Tarea_motora_generada__c){
                serviciosParaGenerarTareas.add(nuevoServicio);
            }
       }
       if(!serviciosParaGenerarTareas.isEmpty()){
        ServiciosDeModuloYTareasTriggerHelper.insertaTareasDeServicios(serviciosParaGenerarTareas);        
        }*/
    }
}