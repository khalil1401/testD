public without sharing class ServiciosDeModuloYTareasTriggerHelper {
    
    public static void insertaTareasDeServicios(List<Servicios_del_Modulo__c> nuevosServicios){
        Set<Id> idsServicios = new Set<Id>();
        
        for(Servicios_del_Modulo__c unServicio : nuevosServicios){
            idsServicios.add(unServicio.id);
        }
        List<Servicios_del_Modulo__c> servicios = [
            SELECT id, Modulo_de_paciente__r.Cuenta__c,Servicios_disponibles__c,
            Modulo_de_paciente__r.Cuenta__r.Enfermero_Asignado__c,CreatedBy.Id,
            Modulo_de_paciente__r.Cuenta__r.Enfermero_Asignado__r.Title,
            Modulo_de_paciente__r.Cuenta__r.Nutricionista_Asignado__c,
            Modulo_de_paciente__r.Cuenta__r.Nutricionista_Asignado__r.Title,
            Modulo_de_paciente__r.Cuenta__r.Kinesiologo_asignado__c,
            Modulo_de_paciente__r.Cuenta__r.Kinesiologo_asignado__r.Title,
            Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__c,
            Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__r.Title,Cantidad__c,Modulo_de_paciente__r.Renovacion__c
            FROM Servicios_del_Modulo__c
            WHERE id IN :idsServicios
        ];
        
        Set<Id> idCuentaEnServicios = new Set<Id>();
        Map<id, Account> idConCuentas = new Map<Id,Account>();
        Map<id, Servicios_del_Modulo__c> cuentaConServicio = new Map<Id,Servicios_del_Modulo__c>();
        Map<String, String> servicioConProfesionalMtd = new Map<String,String>();
        Map<Id, String> cuentaConProfesional = new Map<Id,String>();
        List<Task> tareasParaInsertar = new List<Task>();
        
        for(Servicios_del_Modulo__c unServicio :  servicios){
            idCuentaEnServicios.add(unServicio.Modulo_de_paciente__r.Cuenta__c);
            cuentaConServicio.put(unServicio.Modulo_de_paciente__r.Cuenta__c, unServicio);
            String profesionalAsignado = servicioConProfesionalMtd.get(unServicio.Servicios_disponibles__c);
            cuentaConProfesional.put(unServicio.Modulo_de_paciente__r.Cuenta__c, profesionalAsignado);
        }
        List<Account> cuentasDeServicios = [
            SELECT id , LastName, FirstName, Enfermero_Asignado__c, Medico_Asignado__c,Kinesiologo_asignado__c	,Nutricionista_Asignado__c
            FROM Account 
            WHERE id IN : idCuentaEnServicios
        ];
        for(Account unaCuenta :  cuentasDeServicios){
            idConCuentas.put(unaCuenta.id, unaCuenta);
        }
        
        for(Servicios_del_Modulo__c unServicio: servicios){
            tareasParaInsertar.addAll(generaTareasDeServicios(unServicio,idConCuentas));
        }
        
        if(!tareasParaInsertar.isEmpty()){
            insert tareasParaInsertar;
        }
    }
    public static List<Task> generaTareasDeServicios(Servicios_del_Modulo__c unServicio,Map<id, Account> idConCuentas){
        /**Itero dependiendo de la cantidad de servicios**/
        decimal cantidadDeServicios  = unServicio.Cantidad__c == null ? 1: unServicio.Cantidad__c;
        List<Task> tareasParaInsertar = new List<Task>();
        
        for(integer j=0;j < cantidadDeServicios ;j++){
            Servicios_generales_y_especialidades__mdt servicioSeleccionado;
            
            List<Servicios_generales_y_especialidades__mdt> serviciosMtd =[
                SELECT id,Nombre_de_servicio__c,Numero_de_Jerarquia__c,Tipo_de_servicio_en_MDP__c,
                Cantidad_de_tareas_enfermero__c,Cantidad_de_tareas_kinesiologo__c,Cantidad_de_tareas_medica__c,Cantidad_de_tareas_nutricionista__c
                FROM Servicios_generales_y_especialidades__mdt
                ORDER BY Numero_de_Jerarquia__c DESC
            ];
            
            for(Servicios_generales_y_especialidades__mdt meta : serviciosMtd){
                if(unServicio.Servicios_disponibles__c == meta.Nombre_de_servicio__c){
                    servicioSeleccionado = meta;
                }   
            }
            
            if(servicioSeleccionado!=null){
                if(servicioSeleccionado.Cantidad_de_tareas_enfermero__c>0){
                    for(integer i =0 ;i <servicioSeleccionado.Cantidad_de_tareas_enfermero__c;i++ ){               
                        tareasParaInsertar.add(generaTareaBase(unServicio, idConCuentas, 'Enfermero'));
                    }
                }
                if(servicioSeleccionado.Cantidad_de_tareas_kinesiologo__c>0 ){
                    for(integer i =0 ; i <servicioSeleccionado.Cantidad_de_tareas_kinesiologo__c;i++ ){              
                        tareasParaInsertar.add(generaTareaBase(unServicio, idConCuentas, 'Kinesiologo'));
                    }
                }
                if(servicioSeleccionado.Cantidad_de_tareas_medica__c>0 ){
                    for(integer i =0 ;i <servicioSeleccionado.Cantidad_de_tareas_medica__c;i++ ){               
                        tareasParaInsertar.add(generaTareaBase(unServicio, idConCuentas, 'Medico'));
                    }
                }
                if(servicioSeleccionado.Cantidad_de_tareas_nutricionista__c>0 ){
                    for(integer i =0 ;i <servicioSeleccionado.Cantidad_de_tareas_nutricionista__c;i++ ){              
                        tareasParaInsertar.add(generaTareaBase(unServicio, idConCuentas, 'Nutricionista'));
                    }
                }
            }
        }
        return tareasParaInsertar;
    }
    public static Task generaTareaBase(Servicios_del_Modulo__c unServicio,Map<id, Account> idConCuentas, String nombreDeEspecialidad){
        Task nuevaTarea = new Task();
        nuevaTarea.Subject = 'Visita de '+ nombreDeEspecialidad;
        nuevaTarea.Paciente__c = idConCuentas.get(unServicio.Modulo_de_paciente__r.Cuenta__c) != null ? idConCuentas.get(unServicio.Modulo_de_paciente__r.Cuenta__c).id : null;   
        nuevaTarea.WhatId = unServicio.Modulo_de_paciente__c;
        nuevaTarea.Priority = 'Normal';
        nuevaTarea.Status = 'Abierta';
        Id idDelPropietario= validarProfesionalAsignado(unServicio, nombreDeEspecialidad);
        nuevaTarea.OwnerId =  idDelPropietario != null ? idDelPropietario : unServicio.CreatedBy.Id;
        Integer hoy= System.today().day();

        if(unServicio.Modulo_de_paciente__r.Renovacion__c == 'Alta'){
            nuevaTarea.ActivityDate= excluirFinDeSemana(System.today(),3);
        }
        else if(hoy <=10){
           nuevaTarea.ActivityDate= tareaParaViernes(0); 
        }
        else{
            nuevaTarea.ActivityDate= tareaParaViernes(1); 
        }

        return nuevaTarea;
    }
    
    public static Id validarProfesionalAsignado(Servicios_del_Modulo__c unServicio,String nombreDeEspecialidad){
        
        id idDeProfesional = null;
        
        Id usuarioPorDefecto = [
            SELECT Id
            FROM User
            WHERE userName = :Label.Default_username_motora
        ]?.id;
        
        idDeProfesional = usuarioPorDefecto;
        
        if (nombreDeEspecialidad== 'Nutricionista' &&
            unServicio.Modulo_de_paciente__r.Cuenta__r.Nutricionista_Asignado__c!=null &&
            unServicio.Modulo_de_paciente__r.Cuenta__r.Nutricionista_Asignado__r.Title!=null &&
            unServicio.Modulo_de_paciente__r.Cuenta__r.Nutricionista_Asignado__r.Title.containsIgnoreCase('Nutricionis')){
                idDeProfesional =unServicio.Modulo_de_paciente__r.Cuenta__r.Nutricionista_Asignado__c;
            }
        if(nombreDeEspecialidad== 'Kinesiologo' &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Kinesiologo_asignado__c!=null &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Kinesiologo_asignado__r.Title!=null &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Kinesiologo_asignado__r.Title.containsIgnoreCase('Kinesiol')){
               idDeProfesional =unServicio.Modulo_de_paciente__r.Cuenta__r.Kinesiologo_asignado__c;
           }
        if(nombreDeEspecialidad== 'Enfermero' &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Enfermero_Asignado__c!=null &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Enfermero_Asignado__r.Title!=null &&  
           unServicio.Modulo_de_paciente__r.Cuenta__r.Enfermero_Asignado__r.Title.containsIgnoreCase('Enferme')){
               idDeProfesional =unServicio.Modulo_de_paciente__r.Cuenta__r.Enfermero_Asignado__c;
           }
        if(nombreDeEspecialidad== 'Medico' &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__c!=null &&
           unServicio.Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__r.Title!=null &&
           (unServicio.Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__r.Title.containsIgnoreCase('Medic')|| 
            unServicio.Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__r.Title.containsIgnoreCase('Médic'))){
                idDeProfesional =unServicio.Modulo_de_paciente__r.Cuenta__r.Medico_Asignado__c;
            }
        return idDeProfesional;
        
    }
    public static Date excluirFinDeSemana( date fechaInicial, Integer cantidadDeDias){

        fechaInicial= system.today().addDays(cantidadDeDias);
        DateTime currDate = DateTime.newInstance(fechaInicial.year(), fechaInicial.month(), fechaInicial.day());  
        String todayDay = currDate.format('EEEE');  
        integer workingDays=0;

        if(todayDay == 'Saturday' )  
            {  
                workingDays = workingDays + 2;  
            } else if(todayDay =='Sunday'){
                workingDays = workingDays + 1;  
            }                   
    
        return System.today().addDays(cantidadDeDias+workingDays);
    }

    public static Date tareaParaViernes(Integer mes){

        Date last = Date.newInstance(
            System.today().year(),
            System.today().month()+mes,
            Date.daysInMonth(System.today().year(), System.today().month()+mes)
            );

       Date viernes = last.toStartOfWeek().addDays(5);
       if (viernes > last) viernes = viernes.addDays(-8);

       return viernes;
    }
}