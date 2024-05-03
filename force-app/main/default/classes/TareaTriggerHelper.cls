public class TareaTriggerHelper {  
    public static void setPacientFields (List<Task> tasks) {
        Set<Id> accountIds = new Set<id>();
        for(Task t : tasks){
            if (t.whatId != null && String.valueOf(t.whatId.getSObjectType()) == 'Account') {
                accountIds.add(t.whatId);
            }
        }
        
        
        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id,Obra_social__c,Name,Area_terapeutica__c,PersonContactId 
            FROM Account
            WHERE Id IN :accountIds
        ]);
        
        for(Task t : tasks){
            if(accountsById.containsKey(t.whatId)) {
                Account ac =  accountsById.get(t.whatId);
                t.Paciente__c = ac.id;
                t.Nombre_de_la_obra_social__c = ac.Obra_social__c;
                t.Nombre_y_Apellido_del_Paciente__c = ac.Name;
                t.Area_terap_utica__c = ac.Area_terapeutica__c;
                if(String.isBlank(t.WhoId) && String.isNotBlank(ac.PersonContactId)){
                    t.WhoId = ac.PersonContactId;
                }
            }
        }    
    }
    
    public static void updateFechaUltimaActividadEnCuenta(List<Task> tareas) {
        Set<Id> tasksIds = new Set<Id>();
        for (Task tsk : tareas) {
            tasksIds.add(tsk.Id);
        }
        
        Map<Id, List<Date>> acctsByDate = groupAccountsByDate(tasksIds);
        
        List<Account> accList = setAcctsLastActivityDate(acctsByDate);
        
        if(!accList.isEmpty()) update accList;
        
    }
    
    private static Map<Id, List<Date>> groupAccountsByDate(Set<Id> taskIds){
        Map<Id, List<Date>> acctsRecentTasksDates = new Map<Id, List<Date>>();
        Id acctId;
        Date createdDate;
        
        for(Task tsk : [
            SELECT CreatedDate,
            TYPEOF What
            WHEN Account THEN Id
            WHEN Modulo_de_paciente__c THEN Cuenta__c
            END
            FROM Task
            WHERE Id IN :taskIds
            AND What.Type IN ('Account', 'Modulo_de_paciente__c')
        ]
           ) {
               createdDate = tsk.CreatedDate.date();
               if (tsk.What.getSObjectType() == Account.getSObjectType()) acctId = (Id)tsk.What.get('Id');
               
               
               if (tsk.What.getSObjectType() == Modulo_de_paciente__c.getSObjectType()) acctId = (Id)tsk.What.get('Cuenta__c');
               
               
               if(!acctsRecentTasksDates.containsKey(acctId)) acctsRecentTasksDates.put(acctId, new List<Date>());
               
               
               acctsRecentTasksDates.get(acctId).add(createdDate);
           }
        
        
        return acctsRecentTasksDates;
    }
    
    private static List<Account> setAcctsLastActivityDate(Map<Id, List<Date>> acctsRecentTasksDates){
        List<Account> accList = [
            SELECT Id, Fecha_de_ultima_actividad__c
            FROM Account 
            WHERE Id IN :acctsRecentTasksDates.keySet()
        ];
        Date taskCreateDate;
        
        for (Account acct : accList) {
            if (acctsRecentTasksDates.containsKey(acct.Id)) {
                acctsRecentTasksDates.get(acct.Id).sort();
                taskCreateDate = acctsRecentTasksDates.get(acct.Id).get(0);
                
                if (taskCreateDate < acct.Fecha_de_ultima_actividad__c) {
                    acct.Fecha_de_ultima_actividad__c = taskCreateDate;
                }
            }
        }
        
        return accList;
    }
    
    public static void setPaciente(Task oldTask, Task t){
        if (
            oldTask.whatId != t.whatId && 
            oldTask.whatId != null &&
            String.ValueOf(oldTask.whatId.getSObjectType()).contains('Account')
        ) {
            t.Paciente__c = oldTask.whatId;
        }
        
    }
    
    public static void updateCasePaciente (List<Task> tasks, Set<Id> casesIds) {
        Id RTVisita = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Visita').getRecordTypeId();
        Map<Id, Case> casesById = new map<Id, Case> ([
            SELECT id, AccountId, Type, Subtipo__c, Motivo__c
            FROM Case 
            WHERE Id IN :casesIds
        ]);
        for (Task t : tasks){
            Case c = casesById.get(t.whatId);
            if(c != null && c.AccountId != null) t.Paciente__c = c.AccountId;
            
            
            if( t.RecordTypeId == RTVisita && 
               (c.Type != 'Gestión' || c.Subtipo__c != 'Profesionales de la salud' || c.Motivo__c != 'Visita')
              ){
                  t.addError(	'Solo se puede usar el Tipo de Registro de Tarea Visita '+
                             'para Casos de Motivo Visita');
              }
            
        }
    }
    
    
    public static void updateFechaVencimiento(List<Task> taskList){
        Datetime next = System.now();
        BusinessHours bHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE IsDefault = true
        ];
        if(!isWorkingDay(bHours.Id,system.now())){
            next = getNextWorkingDay(bHours.Id,system.now());
        }
        
        for(Task t : taskList){
            t.ActivityDate = date.newinstance(next.year(), next.month(), next.day());
        }
    }
    
    
    public static Boolean isWorkingDay(Id bHours,Datetime d){
        return BusinessHours.isWithin(bHours, d);
    }
    
    public static Datetime getNextWorkingDay(Id bHours,Datetime d){
        return BusinessHours.nextStartDate(bHours, d);
    }

    public static void setCuentaListaParaJitterbit(List<Task> tareas, Set<Id> idPacientes) {

        List<Account> pacientes = [
            SELECT  Id, Listo_para_Jitterbit__c, Phone, Referencia__c, Direccion__c, NombreSAP__c, FirstName, LastName
            FROM    Account
            WHERE   Id IN: idPacientes
                AND Listo_para_Jitterbit__c =: false
        ];

        for (Account paciente : pacientes) {

            if (paciente.Phone != null) {
                paciente.Phone = eliminarCaracteresInvalidos(paciente.Phone);
            }
            if (paciente.Referencia__c != null) {
                paciente.Referencia__c = eliminarCaracteresInvalidos(paciente.Referencia__c);
            }
            if (paciente.Direccion__c != null) {
                paciente.Direccion__c = eliminarCaracteresInvalidos(paciente.Direccion__c);
            }
            if (paciente.FirstName != null) {
                paciente.FirstName = eliminarCaracteresInvalidos(paciente.FirstName);
            }
            if (paciente.LastName != null) {
                paciente.LastName = eliminarCaracteresInvalidos(paciente.LastName);
            }
            //Se debería hacer lo mismo con firstname y lastname pero quedaría cambiado también en sf
            paciente.Listo_para_Jitterbit__c = true;

        }

        update pacientes;

    }

    public static String eliminarCaracteresInvalidos(String campo) {

        String stringValido = '';

        for(String part : campo.split(' ')){
            if(String.isNotBlank(part)){
                stringValido += part.trim() + ' ';
            }
        }

        stringValido = stringValido.trim();

        stringValido = stringValido.replace('á', 'a');
        stringValido = stringValido.replace('é', 'e');
        stringValido = stringValido.replace('í', 'i');
        stringValido = stringValido.replace('ó', 'o');
        stringValido = stringValido.replace('ú', 'u');
        stringValido = stringValido.replace('ñ', 'n');
        stringValido = stringValido.replace('Á', 'A');
        stringValido = stringValido.replace('É', 'E');
        stringValido = stringValido.replace('Í', 'I');
        stringValido = stringValido.replace('Ó', 'O');
        stringValido = stringValido.replace('Ú', 'U');
        stringValido = stringValido.replace('Ñ', 'N');
        stringValido = stringValido.replaceAll('[¡!”#$%&~°/"|()*¿?]*', '');

        return stringValido;

    }

    public static void setKitsEnReservados(List<Task> tareas, Set<Id> idPacientes) {

        Set<Id> idsPacientesConShipTo = (new Map<Id, Account>([
            SELECT  Id
            FROM    Account
            WHERE   Id In: idPacientes
                AND (N_SHIP_TO__c != null OR N_SHIP_TO__c != '')
        ])).keySet();

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c IN: idsPacientesConShipTo
                AND Es_De_Portal_Pacientes__c =: true
                AND Estado_del_envio__c = 'Ingresado'
        ];

        for(Envio_sin_Cargo__c kit : kits) {
            kit.Estado_del_envio__c = 'Reservado';
            kit.Xml_ya_generado__c = true;
            kit.Fecha_de_despacho__c = System.today();
        }

        if (!kits.isEmpty()) {
            update Kits;
        }

    }

    public static Set<Id> getPacientesRegularesYBestCare(List<Task> tareas) {

        Set<Id> idPacientes = new Set<Id>();
        Set<Id> idPacientesRegulares = new Set<Id>();
        Id recordtypePacientesRegulares = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        Id recordtypePacientesBestCare = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;

        for (Task tarea : tareas) {
            idPacientes.add(tarea.WhatId);
        }

        List<Account> pacientesRegulares = [
            SELECT  Id
            FROM    Account
            WHERE   Id In: idPacientes
                AND (RecordTypeId =: recordtypePacientesRegulares OR RecordTypeId =: recordtypePacientesBestCare)
        ];

        for (Account paciente : pacientesRegulares) {
            idPacientesRegulares.add(paciente.Id);
        }

        return idPacientesRegulares;

    }

    public static void reservarKitsEYN (List<Task> tareas) {
        Set<Id> tareasIds = new Set<Id>();

        for (Task aTarea : tareas) {
            tareasIds.add(aTarea.WhatId);
        }
        List<Envio_Sin_Cargo__c> kitsEYN= [
            SELECT id, Estado_del_envio__c
            FROM Envio_Sin_Cargo__c
            WHERE Paciente__c IN : tareasIds
            AND Estado_del_envio__c = 'Ingresado'
            AND Area_terapeutica__c = 'Metabólicos'
        ];

        if(!kitsEYN.isEmpty()){
            for (Envio_Sin_Cargo__c kit : kitsEYN) {
                kit.Estado_del_envio__c='Reservado';
            }
            update kitsEYN;
        }
    }

    public static void setKitsEnRechazados(List<Task> tareas, Set<Id> idPacientes) {

        Set<Id> idKits = new Set<Id>();

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c IN: idPacientes
                AND Es_De_Portal_Pacientes__c =: true
                AND Estado_del_envio__c = 'Ingresado'
        ];

        for(Envio_sin_Cargo__c kit : kits) {
            kit.Estado_del_envio__c = 'Rechazado';
            kit.Fecha_de_despacho__c = null;
            idKits.add(kit.Id);
        }

        if (!kits.isEmpty()) {
            update Kits;
        }

    }

    public static void rechazarKitsDeTareasEynRechazadas(List<Task> tareas) {
        Set<id> idsDeCuentas = new Set<Id>();

        for(Task tarea: tareas){
            if(tarea.Status =='Rechazada'){
                idsDeCuentas.add(tarea.WhatId);
            }
        }

        if(!idsDeCuentas.isEmpty()){

            List<Envio_sin_Cargo__c> kits = [
                SELECT Id, Estado_del_envio__c
                FROM  Envio_sin_Cargo__c
                WHERE Paciente__c IN: idsDeCuentas
            ];
            
            if (!kits.isEmpty()) {
                for(Envio_sin_Cargo__c kit : kits) {
                    kit.Estado_del_envio__c = 'Rechazado';
                }
                update Kits;
            }
        }
    }

    public static void addErrorPacienteSinShipTo(Map<Id, Id> idPacienteTarea){

        List<Account> pacientes = [
            SELECT  Id, N_SHIP_TO__c
            FROM    Account
            WHERE   Id IN: idPacienteTarea.keySet()
        ];

        for(Account paciente : pacientes){
            if(String.isBlank(paciente.N_SHIP_TO__c)){
                Id idTarea = idPacienteTarea.get(paciente.Id);
                SObject tarea = Trigger.NewMap.get(idTarea);
                tarea.addError('No se puede cerrar la tarea porque el paciente no tiene Ship To');
            }
        }

    }

}