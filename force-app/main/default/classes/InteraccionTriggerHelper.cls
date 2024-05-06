public with sharing class InteraccionTriggerHelper {
/*
    public static void insertInteraccion (List<Dan360_Interacciones__c> interacciones) {
        System.debug(interacciones);
        Date fechaActual = System.today();
        Date inicioDeMes = fechaActual.toStartOfMonth();
        Date finDeMes = fechaActual.toStartOfMonth().addMonths(1).addDays(-1);
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        Map<Decimal, List<Dan360_Interacciones__c>> interaccionesFueraDeLaEfectividadActual  = new Map<Decimal, List<Dan360_Interacciones__c>>();
        Map<Dan360_Interacciones__c, Dan360_Efectividad__c> efectividadPorInteraccion = new Map<Dan360_Interacciones__c, Dan360_Efectividad__c>();
        List<Dan360_Efectividad__c> newEfectividades = new List<Dan360_Efectividad__c>();
        List<Id> domiciliosDeLasInteracciones = New List<Id>();
        List<Id> profesionalesDeLasInteracciones = New List<Id>();
        List<Id> visitadoresDeLasInteracciones = New List<Id>();
        Limite_de_retraso__mdt limiteDeRetraso = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Cantidad_de_Dias_de_Retraso__c
                                                  FROM Limite_de_retraso__mdt
                                                  WHERE DeveloperName = 'Retraso_para_interaccion'
                                                  LIMIT 1];
        List<Dan360_Efectividad__c> efectividades = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c
                                                     FROM Dan360_Efectividad__c
                                                     WHERE Fecha_de_inicio__c <= : inicioDeMes AND Fecha_de_Fin__c >= : finDeMes];      
        List<VisMed_Ciclo__c> ciclos = [SELECT id, Name, Numero_de_mes__c
                                        FROM VisMed_Ciclo__c];  
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
                                        
        for (Dan360_Interacciones__c interaccion : interacciones) {
            domiciliosDeLasInteracciones.add(interaccion.VisMed_Domicilio_de_la_Visita__c);
            profesionalesDeLasInteracciones.add(interaccion.Profesional__c);
            visitadoresDeLasInteracciones.add(interaccion.VisMed_APM__c);
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, Name, Institucion__c, Profesional__c, VisMed_APM__c, Ultima_Visita__c 
                                                            FROM VisMed_Contacto_Cuenta_Usuario__c
                                                            WHERE Institucion__c IN :domiciliosDeLasInteracciones AND Profesional__c IN :profesionalesDeLasInteracciones
                                                            AND VisMed_APM__c IN :visitadoresDeLasInteracciones];
        for (Dan360_Interacciones__c interaccion : interacciones) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (interaccion.Estado__c == 'Aprobada' && interaccion.VisMed_Domicilio_de_la_Visita__c == seguimiento.Institucion__c && interaccion.Profesional__c == seguimiento.Profesional__c && interaccion.VisMed_APM__c == seguimiento.VisMed_APM__c) {
                    if (seguimiento.Ultima_Visita__c < interaccion.VisMed_Fecha__c || seguimiento.Ultima_Visita__c == null) {
                        seguimiento.Ultima_Visita__c = interaccion.VisMed_Fecha__c;
                        seguimientosToUpdate.add(seguimiento);
                    }
                }
            }
        }

        update seguimientosToUpdate;

        for (Dan360_Efectividad__c efectividad : efectividades) { //Asigno a la interaccion a su efectividad correspondiente.
            for (Dan360_Interacciones__c interaccion : interacciones) {
                Date fechaDeLaInteraccion = interaccion.VisMed_Fecha__c;
                interaccion.VisMed_Codigo_de_duplicidad__c = interaccion.VisMed_APM__c + ' - ' + interaccion.Profesional__c + ' - ' + interaccion.VisMed_Domicilio_de_la_Visita__c + ' - ' + fechaDeLaInteraccion;
                if (efectividad.VisMed_APM__c == interaccion.VisMed_APM__c) {
                    if (math.abs(fechaActual.daysBetween(fechaDeLaInteraccion)) <= limiteDeRetraso.Cantidad_de_Dias_de_Retraso__c) {
                        if (efectividad.Fecha_de_inicio__c <= fechaDeLaInteraccion && efectividad.Fecha_de_Fin__c >= fechaDeLaInteraccion) {
                            interaccion.VisMed_Efectividad__c = efectividad.Id;
                            interaccion.Estado__c = 'Aprobada';
                        } else {
                            List<Dan360_Interacciones__c> listInteracciones = interaccionesFueraDeLaEfectividadActual.containsKey(fechaDeLaInteraccion.month()) ? interaccionesFueraDeLaEfectividadActual.get(fechaDeLaInteraccion.month()) : new List<Dan360_Interacciones__c>();
                            interaccion.VisMed_Efectividad__c = null;
                            listInteracciones.add(interaccion);
                            interaccionesFueraDeLaEfectividadActual.put(fechaDeLaInteraccion.month(), listInteracciones);
                        } 
                    } else {
                        if (efectividad.Fecha_de_inicio__c <= fechaDeLaInteraccion && efectividad.Fecha_de_Fin__c >= fechaDeLaInteraccion) {
                            interaccion.VisMed_Efectividad__c = efectividad.Id;
                            interaccion.Estado__c = 'Pendiente';
                        } else {
                            List<Dan360_Interacciones__c> listInteracciones = interaccionesFueraDeLaEfectividadActual.containsKey(fechaDeLaInteraccion.month()) ? interaccionesFueraDeLaEfectividadActual.get(fechaDeLaInteraccion.month()) : new List<Dan360_Interacciones__c>();
                            interaccion.VisMed_Efectividad__c = null;
                            listInteracciones.add(interaccion);                        
                            interaccionesFueraDeLaEfectividadActual.put(fechaDeLaInteraccion.month(), listInteracciones);
                        }
                    }   
                }
            }
        }

        if (!interaccionesFueraDeLaEfectividadActual.isEmpty()) {
            List<Dan360_Efectividad__c> efectividadesFueraDeLaAcutal = [SELECT Id, Name, VisMed_Ciclo__c, VisMed_Ciclo__r.Numero_de_mes__c, VisMed_APM__c
                                                                        FROM Dan360_Efectividad__c
                                                                        WHERE VisMed_Ciclo__r.Numero_de_mes__c IN : interaccionesFueraDeLaEfectividadActual.keySet()];
            for (Dan360_Efectividad__c efectividad : efectividadesFueraDeLaAcutal)  {
                for (Dan360_Interacciones__c interaccion : interaccionesFueraDeLaEfectividadActual.get(efectividad.VisMed_Ciclo__r.Numero_de_Mes__c)) {
                    if (efectividad.VisMed_APM__c == interaccion.VisMed_APM__c) {
                        interaccion.VisMed_Efectividad__c = efectividad.Id;
                        interaccion.Estado__c = 'Pendiente';
                    }
                }
            }
            for (Dan360_Interacciones__c interaccion : interacciones) { // Valido que todas las interacciones tengan una efectividad. Si no la tiene entonces se crea automaticamente.
                if (interaccion.VisMed_Efectividad__c == null) {
                    for (VisMed_Ciclo__c ciclo : ciclos) {
                        Date fechaDeLaInteraccion = interaccion.VisMed_Fecha__c;
                        if (ciclo.Numero_de_mes__c == fechaDeLaInteraccion.month()) {
                            Dan360_Efectividad__c newEfectividad = new Dan360_Efectividad__c(
                                Fecha_de_inicio__c = fechaDeLaInteraccion.toStartOfMonth(),
                                Fecha_de_Fin__c = (fechaDeLaInteraccion.toStartOfMonth()).addMonths(1).addDays(-1),
                                VisMed_APM__c = interaccion.VisMed_APM__c,
                                VisMed_Ciclo__c = ciclo.Id
                            );
                            newEfectividades.add(newEfectividad);
                            efectividadPorInteraccion.put(interaccion, newEfectividad);
                        }
                    }
                }
            }
            insert newEfectividades;
            for (Dan360_Interacciones__c interaccion : efectividadPorInteraccion.keySet()) {
                interaccion.VisMed_Efectividad__c = efectividadPorInteraccion.get(interaccion).id;
                interaccion.Estado__c = 'Pendiente';
            }
        }
    }

    public static void changeCodigoDeDuplicidad (List<Dan360_Interacciones__c> interacciones) {
        for (Dan360_Interacciones__c interaccion : interacciones) {
            Date fechaDeLaInteraccion = interaccion.VisMed_Fecha__c;
            interaccion.VisMed_Codigo_de_duplicidad__c = interaccion.VisMed_APM__c + ' - ' + interaccion.Profesional__c + ' - ' + interaccion.VisMed_Domicilio_de_la_Visita__c + ' - ' + fechaDeLaInteraccion;
        }
    }
    */
    

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static void hacerOwnerDelRegistroAlAPM (List<Dan360_Interacciones__c> interacciones) {
        Set<Id> contactId = new Set<Id>();
        List<User> users = new List<User>();
        Map<Id,Id> userIdXcontactId = new Map<Id,Id>();

        for (Dan360_Interacciones__c interaccion : interacciones) {
            contactId.add(interaccion.VisMed_APM__c);
        }

        users = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactId];
        for (User usuario : users) {
            for (Dan360_Interacciones__c interaccion : interacciones) {
                if (usuario.ContactId == interaccion.VisMed_APM__c) {
                    interaccion.OwnerId = usuario.Id;
                }
            }
        }
    }
    
    public static void checkDuplicates(List<Dan360_Interacciones__c> interacciones){
        List<String> profesionalIds = new List<String>();
        List<String> apmIds = new List<String>();
        List<Date> fechas = new List<Date>();
        Map<String, Map<String, List<Dan360_Interacciones__c>>> mapApmProfesionalInteraccion = new Map<String, Map<String, List<Dan360_Interacciones__c>>>();
        for(Dan360_Interacciones__c interaccion : interacciones){
            profesionalIds.add(interaccion.Profesional__c);
            apmIds.add(interaccion.VisMed_APM__c);
            fechas.add(interaccion.VisMed_Fecha__c);
        }
        for(Dan360_Interacciones__c interaccion : [SELECT Id, VisMed_Fecha__c, VisMed_APM__c, Profesional__c
                                                    FROM Dan360_Interacciones__c 
                                                    WHERE Profesional__c IN :profesionalIds 
                                                        AND VisMed_APM__c IN :apmIds 
                                                        AND VisMed_Fecha__c IN :fechas
                                                            AND (Estado__c = 'Aprobada' OR Estado__c = 'Pendiente')]){
            if(!mapApmProfesionalInteraccion.containsKey(interaccion.VisMed_APM__c)){
                mapApmProfesionalInteraccion.put(interaccion.VisMed_APM__c, new Map<String,List<Dan360_Interacciones__c>>());
            }
            if(!mapApmProfesionalInteraccion.get(interaccion.VisMed_APM__c).containsKey(interaccion.Profesional__c)){
                mapApmProfesionalInteraccion.get(interaccion.VisMed_APM__c).put(interaccion.Profesional__c, new List<Dan360_Interacciones__c>());
            }
            mapApmProfesionalInteraccion.get(interaccion.VisMed_APM__c).get(interaccion.Profesional__c).add(interaccion);
        }
        System.debug(mapApmProfesionalInteraccion);
        for(Dan360_Interacciones__c interaccion : interacciones){
            System.debug('Interaccion a insertar:');
            System.debug(interaccion);
            if(mapApmProfesionalInteraccion.containsKey(interaccion.VisMed_APM__c)){
                System.debug('mapApmProfesionalInteraccion contiene APM');
                if(mapApmProfesionalInteraccion.get(interaccion.VisMed_APM__c).containsKey(interaccion.Profesional__c)){
                    System.debug('mapApmProfesionalInteraccion contiene Profesional');
                    List<Dan360_Interacciones__c> interaccionesToCheck = mapApmProfesionalInteraccion.get(interaccion.VisMed_APM__c).get(interaccion.Profesional__c);
                    for(Dan360_Interacciones__c interaccionToCheck : interaccionesToCheck){
                        System.debug('Fecha SF: ' + interaccionToCheck.VisMed_Fecha__c);
                        System.debug('Fecha Insert: ' + interaccion.VisMed_Fecha__c);
                        if(interaccionToCheck.VisMed_Fecha__c == interaccion.VisMed_Fecha__c){

                            // Call Queueable
                            // AsyncUpdateInteraccion.inputInteractionId();
                            AsyncUpdateInteraccion asyncInteraction = new AsyncUpdateInteraccion();
                            asyncInteraction.setVariable(interaccionToCheck.Id);
                            ID jobID = System.enqueueJob(asyncInteraction);

                            interaccion.addError('Ya existe una visita para este Profesional para esta fecha.');
                        }
                    }
                }
            }
        }
    }

    public static void validarQueLaInteraccionNoSeCreeElMismoDiaQueUnaLicencia (List<Dan360_Interacciones__c> interacciones) {
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        List<Dan360_Licencia__c> licencias;
        Date fechaMinima = System.today();
        Date fechaMaxima = Date.newInstance(1960, 2, 17);

        for (Dan360_Interacciones__c interaccion : interacciones) {
            fechaMinima = fechaMinima > interaccion.VisMed_Fecha__c ? interaccion.VisMed_Fecha__c : fechaMinima;
            fechaMaxima = fechaMaxima < interaccion.VisMed_Fecha__c ? interaccion.VisMed_Fecha__c : fechaMaxima;
        }

        licencias = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_fin__c, VisMed_APM__c
                     FROM Dan360_Licencia__c
                     WHERE Fecha_de_inicio__c <= :fechaMinima AND Fecha_de_fin__c >= :fechaMinima AND RecordTypeId = :recordTypeLicencia 
                     AND Estado__c != 'Rechazada'];

        for (Dan360_Interacciones__c interaccion : interacciones) {
            for (Dan360_Licencia__c licencia : licencias) {
                if (interaccion.VisMed_APM__c == licencia.VisMed_APM__c && licencia.Fecha_de_inicio__c <= interaccion.VisMed_Fecha__c && licencia.Fecha_de_Fin__c >= interaccion.VisMed_Fecha__c) {
                    interaccion.addError('No se puede cargar una interacción sobre un dia con licencia agendada');
                }
            }
        }
    }

    public static void validarQueExistaRelacionProfesionalInstitucionAPM (List<Dan360_Interacciones__c> interacciones) {
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        Id recordTypeNoVisita = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('No_Visita').getRecordTypeId();
        Set<Id> profesionalesId = new Set<Id>();
        Set<Id> institucionesId = new Set<Id>();
        Set<Id> apmsId = new Set<Id>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos;
        Map<Id,Dan360_Interacciones__c> interaccionSinSeguimiento = new Map<Id,Dan360_Interacciones__c>();

        for (Dan360_Interacciones__c interaccion : interacciones) {
            if (interaccion.RecordTypeId == recordTypeVisitaMedica || interaccion.RecordTypeId == recordTypeNoVisita) {
                if (interaccion.VisMed_Tipo_de_Visita__c != 'Presencial') {
                    profesionalesId.add(interaccion.Profesional__c);
                    institucionesId.add(interaccion.VisMed_Domicilio_de_la_Visita__c);
                    apmsId.add(interaccion.VisMed_APM__c);
                    interaccionSinSeguimiento.put(interaccion.Id, interaccion); // Agrego todas las interacciones para despues quitarlas del mapa si encuentro un seguimiento.
                }                
            }
        }

        seguimientos = [SELECT Id, Profesional__c, Institucion__c, VisMed_Apm__c
                        FROM VisMed_Contacto_Cuenta_Usuario__c
                        WHERE Profesional__c IN :profesionalesId AND Institucion__c IN :institucionesId AND VisMed_Apm__c IN :apmsId AND Estado__c = 'Activo'];

        for (Dan360_Interacciones__c interaccion : interaccionSinSeguimiento.values()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (interaccion.Profesional__c == seguimiento.Profesional__c && interaccion.VisMed_Domicilio_de_la_Visita__c == seguimiento.Institucion__c && interaccion.VisMed_APM__c == seguimiento.VisMed_APM__c) {
                    interaccionSinSeguimiento.remove(interaccion.Id);
                }
            }
        }

        for (Dan360_Interacciones__c interaccion : interacciones) {
            if (interaccionSinSeguimiento.containsKey(interaccion.Id) && interaccion.VisMed_Tipo_de_Visita__c == 'Presencial') {
                interaccion.addError('No existe la relacion Visitador-Profesional-institucion');
            }
        }
    }

    public static void generarCodigoDeDuplicidad (List<Dan360_Interacciones__c> interacciones) {
        for (Dan360_Interacciones__c interaccion : interacciones) {
            List<String> listaFecha = new List<String>();
            listaFecha.add(String.valueOf(interaccion.VisMed_Fecha__c.year()));
            listaFecha.add(String.valueOf(interaccion.VisMed_Fecha__c.month()));
            listaFecha.add(String.valueOf(interaccion.VisMed_Fecha__c.day()));
            String fecha = String.join(listaFecha, '-');
            interaccion.VisMed_Codigo_de_duplicidad__c = interaccion.VisMed_APM__c + ' - ' + interaccion.Profesional__c + ' - ' + interaccion.VisMed_Domicilio_de_la_Visita__c + ' - ' + fecha;
        }
    }

    public static void determinarSiLaInteraccionPasaPorProcesoDeAprobacion (List<Dan360_Interacciones__c> interacciones) {
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        Id recordTypeNoVisita = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('No_Visita').getRecordTypeId();
        Limite_de_retraso__mdt limiteDeRetraso = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Cantidad_de_Dias_de_Retraso__c
                                                  FROM Limite_de_retraso__mdt
                                                  WHERE DeveloperName = 'Retraso_para_interaccion'
                                                  LIMIT 1];
        Date fechaActual = System.today();

        for (Dan360_Interacciones__c interaccion : interacciones) {
            // Si la interaccion esta por fuera del periodo de retraso o del mes actual -> estado = 'pendiente'.
            if ((interaccion.RecordTypeId == recordTypeVisitaMedica || interaccion.RecordTypeId == recordTypeNoVisita) && (interaccion.VisMed_Fecha__c.daysBetween(fechaActual) > limiteDeRetraso.Cantidad_de_Dias_de_Retraso__c || interaccion.VisMed_Fecha__c.monthsBetween(fechaActual) > 0)) {
                interaccion.Estado__c = 'Pendiente';
            } else if (interaccion.RecordTypeId == recordTypeVisitaMedica || interaccion.RecordTypeId == recordTypeNoVisita) {
                interaccion.Estado__c = 'Aprobada';
            }
        }
    }

    public static void asignarInteraccionALaEfectividadCorrespondiente (List<Dan360_Interacciones__c> interacciones) {
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        Id recordTypeNoVisita = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('No_Visita').getRecordTypeId();
        Set<Id> apmsId = new Set<Id>();
        List<Dan360_Efectividad__c> efectividades = new List<Dan360_Efectividad__c>();

        for (Dan360_Interacciones__c interaccion : interacciones) {
            if (interaccion.RecordTypeId == recordTypeVisitaMedica || interaccion.RecordTypeId == recordTypeNoVisita) {
                apmsId.add(interaccion.VisMed_APM__c);
            }
        }

        if (!apmsId.isEmpty()) {
            System.debug(apmsId);
            efectividades = [SELECT Id, VisMed_APM__c, Fecha_de_inicio__c, Fecha_de_Fin__c
                             FROM Dan360_Efectividad__c
                             WHERE VisMed_APM__c IN :apmsId];
        }
        if (!efectividades.isEmpty()) {
            for (Dan360_Interacciones__c interaccion : interacciones) {
                for (Dan360_Efectividad__c efectividad : efectividades) {
                    if (interaccion.VisMed_APM__c == efectividad.VisMed_APM__c && interaccion.VisMed_Fecha__c >= efectividad.Fecha_de_inicio__c && interaccion.VisMed_Fecha__c <= efectividad.Fecha_de_Fin__c) {
                        interaccion.VisMed_Efectividad__c = efectividad.Id;
                    }
                }
            }
        }
    }

    public static void updateInteraccionesRelatedToEfectividad (Dan360_Interacciones__c[] interacciones) {
        // Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        // List<Dan360_Interacciones__c> interacciones = [SELECT Id, Name, Estado__c, RecordTypeId, VisMed_Efectividad__c
        //                                                FROM Dan360_Interacciones__c
        //                                                WHERE Estado__c = 'Aprobada' AND RecordTypeId = :recordTypeVisitaMedica];
        // System.debug('Interacciones de la query: ' + interacciones);
        // if (!interacciones.isEmpty()) {
        //     List<Dan360_Efectividad__c> efectividadesToUpdate = New List<Dan360_Efectividad__c>();        
        //     Map<Id, List<Dan360_Interacciones__c>> interaccionesByEfectividad = New Map<id, List<Dan360_Interacciones__c>>();
        //     for (Dan360_Interacciones__c interaccion : interacciones) {
        //         if (interaccion.Estado__c == 'Aprobada' && interaccion.RecordTypeId == recordTypeVisitaMedica) {
        //             List<Dan360_Interacciones__c> listInteracciones;
        //             listInteracciones = interaccionesByEfectividad.containsKey(interaccion.VisMed_Efectividad__c) ? interaccionesByEfectividad.get(interaccion.VisMed_Efectividad__c) : New List<Dan360_Interacciones__c>();
        //             listInteracciones.add(interaccion);
        //             interaccionesByEfectividad.put(interaccion.VisMed_Efectividad__c, listInteracciones);
        //         }
        //     }
        //     for (Id efectividad : interaccionesByEfectividad.keySet()) {
        //         Dan360_Efectividad__c newEfectividad = New Dan360_Efectividad__c(Id = efectividad);
        //         newEfectividad.VisMed_Visitas_realizadas__c = interaccionesByEfectividad.get(efectividad).size();
        //         System.debug('size: ' + interaccionesByEfectividad.get(efectividad).size());
        //         System.debug('interacciones: ' + interaccionesByEfectividad.get(efectividad));
        //         efectividadesToUpdate.add(newEfectividad);
        //     }
        //     update efectividadesToUpdate;
        // }
        //-----------------------------------------------------------------------
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        Id[] efectividadIds = new List<Id>();
        Dan360_Efectividad__c[] efectividadesToUpdate = new List<Dan360_Efectividad__c>();
        
        for(Dan360_Interacciones__c interaccion : interacciones) {
            if(String.isNotBlank(interaccion.VisMed_Efectividad__c) 
                && interaccion.RecordTypeId == recordTypeVisitaMedica
            ) {
                efectividadIds.add(interaccion.VisMed_Efectividad__c);
            }
        }

        if(!efectividadIds.isEmpty()) {
            efectividadesToUpdate = getEfectividadWithInteracciones(efectividadIds, recordTypeVisitaMedica);

            for(Dan360_Efectividad__c efectividad : efectividadesToUpdate) {
                efectividad.VisMed_Visitas_realizadas__c = efectividad.Interacciones__r.size();
                
                for(Dan360_Interacciones__c interaccion : efectividad.Interacciones__r) {
                    System.debug('****interaccion.Estado__c: ' + interaccion.Estado__c);
                }
            }

            update efectividadesToUpdate;
        }

    }

    public static Dan360_Efectividad__c[] getEfectividadWithInteracciones(Id[] efectividadIds, Id recordTypeId) {
        return [
            SELECT Id, (
                    SELECT Id, Estado__c
                    FROM Interacciones__r 
                    WHERE RecordTypeId = :recordTypeId AND Estado__c = 'Aprobada'
                )
            FROM Dan360_Efectividad__c
            WHERE Id IN :efectividadIds
        ];
    }

    public static void updateInteraccionesRelatedToSeguimiento () {
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, VisMed_APM__c, Profesional__c, Ultima_Visita__c, Inicio_de_Frecuencia__c, Visitas_Realizadas__c
                                                                FROM VisMed_Contacto_Cuenta_Usuario__c
                                                                WHERE Predeterminada__c = true AND Estado__c = 'Activo'];
        List<Dan360_Interacciones__c> interacciones = [SELECT Id, Name, Estado__c, RecordTypeId, Profesional__c, VisMed_APM__c, VisMed_Fecha__c
                                                       FROM Dan360_Interacciones__c
                                                       WHERE Estado__c = 'Aprobada' AND RecordTypeId = :recordTypeVisitaMedica];

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            System.debug('Aca');
            seguimiento.Visitas_Realizadas__c = 0;
            for (Dan360_Interacciones__c interaccion : interacciones) {
                If (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c && (interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c || interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth())) {
                    seguimiento.Visitas_Realizadas__c ++;
                    if (seguimiento.Ultima_Visita__c < interaccion.VisMed_Fecha__c || seguimiento.Ultima_Visita__c == null) {
                        seguimiento.Ultima_Visita__c = interaccion.VisMed_Fecha__c;
                    }
                }
            }
        }
        update seguimientos;
    }

    public static void cambiarEfectividad (List<Dan360_Interacciones__c> interacciones) {
        Set<Id> apmIds = new Set<Id>();
        Date minDate = Date.today();
        for (Dan360_Interacciones__c interaccion : interacciones) {
            apmIds.add(interaccion.VisMed_APM__c);
            if (interaccion.VisMed_Fecha__c < minDate) {
                minDate = interaccion.VisMed_Fecha__c;
            }
        }
        List<Dan360_Efectividad__c> efectividades = [
            SELECT Id, Fecha_de_inicio__c, Fecha_de_Fin__c
            FROM Dan360_Efectividad__c
            WHERE VisMed_APM__c in : apmIds
            AND Fecha_de_inicio__c >= :minDate.toStartOfMonth()            
        ];

        for (Dan360_Interacciones__c interaccion : interacciones) {
            for (Dan360_Efectividad__c efectividad : efectividades) {
                if (interaccion.VisMed_Fecha__c >= efectividad.Fecha_de_inicio__c 
                && interaccion.VisMed_Fecha__c <= efectividad.Fecha_de_Fin__c) {
                    interaccion.VisMed_Efectividad__c = efectividad.Id;
                }
            }
        }
    }
    public static void createNotification (List<Dan360_Interacciones__c> interacciones) {
        List<Notificacion__c> notificaciones = new List<Notificacion__c>();
        String titulo;
        String cuerpo;
        String redireccion = 'interaccion';
        for (Dan360_Interacciones__c objeto : interacciones) {
                titulo = objeto.Estado__c == 'Aprobada' ? 'Su Visita fue APROBADA' : 'Su Visita fue RECHAZADA';
                cuerpo = objeto.Estado__c == 'Aprobada' ? 'Aprobada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c : 'Rechazada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c;
                Notificacion__c notificacion = new Notificacion__c(
                    APM__c = objeto.VisMed_APM__c,
                    Name = titulo,
                    Cuerpo__c = cuerpo,
                    Leido__c = false,
                    Relacion__c = redireccion,
                    Id_del_Objeto__c = objeto.Id
                );
                notificaciones.add(notificacion);            
        }
        if (Schema.sObjectType.Notificacion__c.isCreateable()) {
            insert notificaciones;
        }
    }

    public static void createObjetivoyAcciondelProfesional (List<Dan360_Interacciones__c> interacciones){
        System.debug('createObjetivoyAcciondelProfesional');
        //Se crea un Mapa con el Id de la accion por cuenta y la interaccion correspondiente
        Map<Id, List<Dan360_Interacciones__c>> mapAccionPorCuentaInteraccion = new Map<Id, List<Dan360_Interacciones__c>>();
        for(Dan360_Interacciones__c interacion: interacciones){
            if(!mapAccionPorCuentaInteraccion.containsKey(interacion.Accion_por_cuenta__c)){
                mapAccionPorCuentaInteraccion.put(interacion.Accion_por_cuenta__c, new List<Dan360_Interacciones__c>());
            }
            mapAccionPorCuentaInteraccion.get(interacion.Accion_por_cuenta__c).add(interacion);
        }
        System.debug('mapAccionPorCuentaInteraccion');
        System.debug(mapAccionPorCuentaInteraccion);
        //Se crea un mapa con el Id de la accion por cuenta y la accion correspondiente
        Map<Id,VisMed_AccionPorCuenta__c> mapAccionPorCuentaAccion = new Map<Id,VisMed_AccionPorCuenta__c>();
        for(VisMed_AccionPorCuenta__c accionPorCuenta : [SELECT Id, VisMed_Accion__c,VisMed_Objetivo__c FROM VisMed_AccionPorCuenta__c WHERE Id IN: mapAccionPorCuentaInteraccion.keySet()]){
            if(!mapAccionPorCuentaAccion.containsKey(accionPorCuenta.Id)){
                mapAccionPorCuentaAccion.put(accionPorCuenta.Id, accionPorCuenta);
            }
        }
        System.debug('mapAccionPorCuentaAccion');
        System.debug(mapAccionPorCuentaAccion);
        //Se recorre el mapa de las interaciones, se busca dentro del mapa de mapAccionPorCuentaAccion la accion por cuenta q corresponda
        //y se crea un obj VisMed_Objetivo_Accion_Profesional__c por cada interaccion
        List<VisMed_Objetivo_Accion_Profesional__c> objetivoAccionList = new List<VisMed_Objetivo_Accion_Profesional__c>();
        for(Id accionPorCuentaID : mapAccionPorCuentaInteraccion.keySet()){
            if(mapAccionPorCuentaAccion.containsKey(accionPorCuentaID)){
                VisMed_AccionPorCuenta__c accionPorAccount = mapAccionPorCuentaAccion.get(accionPorCuentaID);
                List<Dan360_Interacciones__c> interaccionIdList = mapAccionPorCuentaInteraccion.get(accionPorCuentaID);
                for(Dan360_Interacciones__c interaccion : interaccionIdList){
                    VisMed_Objetivo_Accion_Profesional__c objetivoAccion = new VisMed_Objetivo_Accion_Profesional__c(
                        Interaccion__c = interaccion.Id,
                        Accion__c = accionPorAccount.VisMed_Accion__c,
                        Profesional__c = interaccion.Profesional__c,
                        Objetivo__c = accionPorAccount.VisMed_Objetivo__c
                    );
                    objetivoAccionList.add(objetivoAccion);
                }
                System.debug('objetivoAccionList');
                System.debug(objetivoAccionList);
            }
        }
        if(objetivoAccionList.size() > 0) {
            System.debug('objetivoAccionList.size() > 0');
            System.debug(objetivoAccionList.size() > 0);
            Database.insert(objetivoAccionList,false);
        }

    }
}