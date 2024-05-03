trigger TratamientoDeProfesionalTrigger on Tratamiento_de_profesional__c (after insert,after update, after delete) {
    
    if(Trigger.isAfter && Trigger.isInsert){       
        TratamientoDeProfesionalTriggerHelper.actualizarCantidadDeTratamientos(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        TratamientoDeProfesionalTriggerHelper.actualizarCantidadDeTratamientosSiSeEliminaUnTratamiento(Trigger.old);
    }
}