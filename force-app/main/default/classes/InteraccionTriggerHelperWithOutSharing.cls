public without sharing class InteraccionTriggerHelperWithOutSharing {
    public static void updateInteraccionesRelatedToSeguimiento (List<Dan360_Interacciones__c> interacciones) {
        System.debug('updateInteraccionesRelatedToSeguimiento');
        Set<Id> apmId = new Set<Id>();
        Set<Id> profesionalId = new Set<Id>();
        Set<Id> interaccionesNuevas = new Set<Id>();
        Map<String, Map<string, List<Dan360_Interacciones__c>>> profesionalApmInteracionMap = new Map<String, Map<string, List<Dan360_Interacciones__c>>>();
        Map<String, map<String, Integer>> profesionalApmVisitasRealizadas = new Map<String, map<String, Integer>>();
        Map<String, map<String, Date>> profesionalApmUltimaVisita = new Map<String, map<String, Date>>();
        for (Dan360_Interacciones__c interaccion : interacciones) {
            apmId.add(interaccion.VisMed_APM__c);
            profesionalId.add(interaccion.Profesional__c);
            interaccionesNuevas.add(interaccion.Id);
        }
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, VisMed_APM__c, Profesional__c, Frecuencia__c, Ultima_Visita__c, Inicio_de_Frecuencia__c, Fin_de_Frecuencia__c, Visitas_acumuladas__c, Visitas_Realizadas__c
                                                                FROM VisMed_Contacto_Cuenta_Usuario__c
                                                                WHERE Predeterminada__c = true 
                                                                AND Estado__c = 'Activo'
                                                                AND Profesional__c IN :profesionalId
                                                                AND VisMed_APM__c IN :apmId
                                                                ];        
        List<Dan360_Interacciones__c> interaccionesRealizadas = [SELECT Id, Name, Estado__c, RecordTypeId, Profesional__c, VisMed_APM__c, VisMed_Fecha__c
                                                       FROM Dan360_Interacciones__c
                                                       WHERE Estado__c = 'Aprobada'
                                                       AND Profesional__c IN :profesionalId
                                                       AND VisMed_APM__c IN :apmId 
                                                       AND RecordTypeId = :recordTypeVisitaMedica
                                                       //AND VisMed_Fecha__c >= :System.today().toStartOfMonth()
                                                       ];//AND Id NOT IN :interaccionesNuevas];
        // Armo relacion profesional-apm-visita
        if (interaccionesRealizadas.size() > 0 && !interaccionesRealizadas.isEmpty()) {
            for (Dan360_Interacciones__c interaccion : interaccionesRealizadas) {
                if (!profesionalApmInteracionMap.containsKey(interaccion.Profesional__c)) {
                    profesionalApmInteracionMap.put(interaccion.Profesional__c, new Map<String, List<Dan360_Interacciones__c>>());
                }
                if (!profesionalApmInteracionMap.get(interaccion.Profesional__c).containsKey(interaccion.VisMed_APM__c)) {
                    profesionalApmInteracionMap.get(interaccion.Profesional__c).put(interaccion.VisMed_APM__c, new List<Dan360_Interacciones__c>());
                }
                profesionalApmInteracionMap.get(interaccion.Profesional__c).get(interaccion.VisMed_APM__c).add(interaccion);
            }
             // obtener fecha de ultima visita
             for (String profesional : profesionalApmInteracionMap.keySet()) {
                for (String apm : profesionalApmInteracionMap.get(profesional).keySet()) {
                    for (Dan360_Interacciones__c interaccion : profesionalApmInteracionMap.get(profesional).get(apm)) {
                        if (!profesionalApmUltimaVisita.containsKey(profesional)) {
                            profesionalApmUltimaVisita.put(profesional, new Map<String, Date>());
                        }
                        if (!profesionalApmUltimaVisita.get(profesional).containsKey(apm)) {
                            profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                        }
                        if (profesionalApmUltimaVisita.get(profesional).get(apm)!= null) {
                            if (interaccion.VisMed_Fecha__c > profesionalApmUltimaVisita.get(profesional).get(apm)) {
                                profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                            }
                        }else {
                            profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                        }
                    }
                }
            }
            Integer visitasRealizadas;
            for (String profesional : profesionalApmInteracionMap.keySet()) {
                for (String apm : profesionalApmInteracionMap.get(profesional).keySet()) {
                    visitasRealizadas = 0;
                    for (Dan360_Interacciones__c interaccion : profesionalApmInteracionMap.get(profesional).get(apm)) {
                        if (interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth()) {
                            if (!profesionalApmVisitasRealizadas.containsKey(profesional)) {
                                profesionalApmVisitasRealizadas.put(profesional, new Map<String, Integer>());
                            }
                            if (!profesionalApmVisitasRealizadas.get(profesional).containsKey(apm)) {
                                profesionalApmVisitasRealizadas.get(profesional).put(apm, 0);
                            }                        
                            visitasRealizadas ++;
                            profesionalApmVisitasRealizadas.get(profesional).put(apm, visitasRealizadas);                            
                        }                          
                    }
                    System.debug('total visitas '+visitasRealizadas);
                }
            }
        } 
        Integer mesInicio;
        Integer mesFinal;
        Integer mesActual = Date.today().Month();
        Integer mesVisita;
        Integer cantidadVisitasDelPasado = 0;   
        // Se detecta visita que se carga del pasado y no es del mes actual 
        // se cuenta la cantidad de visitas del pasado  
        Map<id, Integer> visitaDelPasado = new Map<id, Integer>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            if (seguimiento.Inicio_de_Frecuencia__c != null && seguimiento.Fin_de_Frecuencia__c != null) {
                mesInicio = seguimiento.Inicio_de_Frecuencia__c.Month();
                mesFinal = seguimiento.Fin_de_Frecuencia__c.Month();                
                for (Dan360_Interacciones__c interaccion : interaccionesRealizadas ) {
                    mesVisita = interaccion.VisMed_Fecha__c.Month();
                    if (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c && mesActual != mesVisita && interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c && interaccion.VisMed_Fecha__c <= seguimiento.Fin_de_Frecuencia__c) {
                        cantidadVisitasDelPasado ++;                        
                        visitaDelPasado.put(seguimiento.Id, cantidadVisitasDelPasado);                       
                    }
                }            
            }
            System.debug('fichero: '+ seguimiento.Id);
            System.debug('cantidad visitas del pasado: '+ cantidadVisitasDelPasado);
        }
        // se suma en el fichero las visitas del pasado y se coloca ultima visita
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            if (visitaDelPasado.containsKey(seguimiento.Id)) {
                if (!String.ValueOf(seguimiento.Frecuencia__c).endsWith('.00') || !String.ValueOf(seguimiento.Frecuencia__c).endsWith(',00') || !String.ValueOf(seguimiento.Frecuencia__c).endsWith('.0') || !String.ValueOf(seguimiento.Frecuencia__c).endsWith(',0')) {
                    seguimiento.Visitas_acumuladas__c = visitaDelPasado.get(seguimiento.Id); 
                                    
                }
            }
            if (profesionalApmUltimaVisita.containsKey(seguimiento.Profesional__c)) {
                if (profesionalApmUltimaVisita.get(seguimiento.Profesional__c).containsKey(seguimiento.VisMed_APM__c)) {                            
                    seguimiento.Ultima_Visita__c = profesionalApmUltimaVisita.get(seguimiento.Profesional__c).get(seguimiento.VisMed_APM__c);
                }
            } else {
                seguimiento.Ultima_Visita__c = null;
            }
            System.debug('ultima visita'+ seguimiento.Ultima_Visita__c);
        }        

        // se registra en el fichero las visitas de este mes y la fecha de ultima visita
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            seguimiento.Visitas_Realizadas__c = 0;
            for (Dan360_Interacciones__c interaccion : interacciones) {
                If (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c && (interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c || interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth())) {
                    //seguimiento.Visitas_Realizadas__c ++;
                    System.debug(seguimiento.Id);                 
                    if (seguimiento.Ultima_Visita__c < interaccion.VisMed_Fecha__c || seguimiento.Ultima_Visita__c == null) {
                        seguimiento.Ultima_Visita__c = interaccion.VisMed_Fecha__c;
                    }
                }
            }
            System.debug('No hay visita');
            if (profesionalApmVisitasRealizadas.containsKey(seguimiento.Profesional__c)) {
                System.debug('Hay  visita para el  profesional');
                
                if (profesionalApmVisitasRealizadas.get(seguimiento.Profesional__c).containsKey(seguimiento.VisMed_APM__c)) {
                    System.debug('hay visita para el profesional- apm');
                    seguimiento.Visitas_Realizadas__c = profesionalApmVisitasRealizadas.get(seguimiento.Profesional__c).get(seguimiento.VisMed_APM__c);
                    System.debug('visitas realizadas '+ seguimiento.Visitas_Realizadas__c);
                    System.debug('ultima visita '+ seguimiento.Ultima_Visita__c);
                }                    
            }
        }
        System.debug('Seguimientos interaccion: '+ seguimientos);
        update seguimientos;
    }
    public static void updateSeguimientoRelatedToInteraccionDeleted (List<Dan360_Interacciones__c> interacciones) {
        System.debug('updateSeguimientoRelatedToInteraccionDeleted After delete');
        Set<Id> apmId = new Set<Id>();
        Set<Id> profesionalId = new Set<Id>();
        Set<Id> interaccionesEliminadas = new Set<Id>();
        Map<String, Map<string, List<Dan360_Interacciones__c>>> profesionalApmInteracionMap = new Map<String, Map<string, List<Dan360_Interacciones__c>>>();
        Map<String, map<String, Date>> profesionalApmUltimaVisita = new Map<String, map<String, Date>>();
        for (Dan360_Interacciones__c interaccion : interacciones) {
            apmId.add(interaccion.VisMed_APM__c);
            profesionalId.add(interaccion.Profesional__c);
            interaccionesEliminadas.add(interaccion.Id);
        }
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, VisMed_APM__c, Profesional__c, Ultima_Visita__c, Inicio_de_Frecuencia__c, Visitas_acumuladas__c, Visitas_Realizadas__c
                                                                FROM VisMed_Contacto_Cuenta_Usuario__c
                                                                WHERE Predeterminada__c = true 
                                                                AND Estado__c = 'Activo'
                                                                AND Profesional__c IN :profesionalId
                                                                AND VisMed_APM__c IN :apmId
                                                                ];
                                                                
        List<Dan360_Interacciones__c> interaccionesNoEliminadas = [SELECT Id, Name, Estado__c, RecordTypeId, Profesional__c, VisMed_APM__c, VisMed_Fecha__c
                                                        FROM Dan360_Interacciones__c
                                                        WHERE Estado__c = 'Aprobada'
                                                        AND Profesional__c IN :profesionalId
                                                        AND VisMed_APM__c IN :apmId 
                                                        AND RecordTypeId = :recordTypeVisitaMedica
                                                        AND Id NOT IN :interaccionesEliminadas];

        if (interaccionesNoEliminadas.size() > 0 && !interaccionesNoEliminadas.isEmpty()) {
            for (Dan360_Interacciones__c interaccion : interaccionesNoEliminadas) {
                if (!profesionalApmInteracionMap.containsKey(interaccion.Profesional__c)) {
                    profesionalApmInteracionMap.put(interaccion.Profesional__c, new Map<String, List<Dan360_Interacciones__c>>());
                }
                if (!profesionalApmInteracionMap.get(interaccion.Profesional__c).containsKey(interaccion.VisMed_APM__c)) {
                    profesionalApmInteracionMap.get(interaccion.Profesional__c).put(interaccion.VisMed_APM__c, new List<Dan360_Interacciones__c>());
                }
                profesionalApmInteracionMap.get(interaccion.Profesional__c).get(interaccion.VisMed_APM__c).add(interaccion);
            }
            
            for (String profesional : profesionalApmInteracionMap.keySet()) {
                for (String apm : profesionalApmInteracionMap.get(profesional).keySet()) {
                    for (Dan360_Interacciones__c interaccion : profesionalApmInteracionMap.get(profesional).get(apm)) {
                        if (!profesionalApmUltimaVisita.containsKey(profesional)) {
                            profesionalApmUltimaVisita.put(profesional, new Map<String, Date>());
                        }
                        if (!profesionalApmUltimaVisita.get(profesional).containsKey(apm)) {
                            profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                        }
                        if (profesionalApmUltimaVisita.get(profesional).get(apm)!= null) {
                            if (interaccion.VisMed_Fecha__c > profesionalApmUltimaVisita.get(profesional).get(apm)) {
                                profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                            }
                        }else {
                            profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                        }
                    }
                }
            }
        }
        Integer mesActual = Date.today().month();
        Integer mesVisita;

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            if (interaccionesNoEliminadas.size() > 0 && !interaccionesNoEliminadas.isEmpty()) {
                for (Dan360_Interacciones__c interaccion : interacciones) {
                    mesVisita = interaccion.VisMed_Fecha__c.month();
                    If (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c && (interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c || interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth())) {
                        if(mesActual == mesVisita) {
                            if (profesionalApmUltimaVisita.containsKey(interaccion.Profesional__c)) {
                                if (profesionalApmUltimaVisita.get(interaccion.Profesional__c).containsKey(interaccion.VisMed_APM__c)) {
                                    if (seguimiento.Visitas_Realizadas__c > 0) {
                                        seguimiento.Visitas_Realizadas__c --;
                                    }                                    
                                    seguimiento.Ultima_Visita__c = profesionalApmUltimaVisita.get(interaccion.Profesional__c).get(interaccion.VisMed_APM__c);                            
                                }
                            }                           
                        } else {
                            if (profesionalApmUltimaVisita.containsKey(interaccion.Profesional__c)) {
                                if (profesionalApmUltimaVisita.get(interaccion.Profesional__c).containsKey(interaccion.VisMed_APM__c) && seguimiento.Visitas_acumuladas__c > 0) {
                                    if (seguimiento.Visitas_acumuladas__c > 0) {
                                        seguimiento.Visitas_acumuladas__c --;
                                    }                                    
                                    seguimiento.Ultima_Visita__c = profesionalApmUltimaVisita.get(interaccion.Profesional__c).get(interaccion.VisMed_APM__c);                            
                                }
                            } else {
                                seguimiento.Visitas_acumuladas__c --;
                                seguimiento.Ultima_Visita__c = null;  
                            }     
                        }
                    } 
                }
            }else {
                for (Dan360_Interacciones__c interaccion : interacciones) {
                    mesVisita = interaccion.VisMed_Fecha__c.month();
                    if (mesActual == mesVisita) {
                        if (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c 
                        && interaccion.Profesional__c == seguimiento.Profesional__c
                        && (interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c || interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth())) {
                            System.debug('entro al  else debe limpiar campo visita');
                            seguimiento.Visitas_Realizadas__c = 0;
                            seguimiento.Ultima_Visita__c = null;
                        }                       
                    }else {
                        if (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c 
                        && interaccion.Profesional__c == seguimiento.Profesional__c){
                            seguimiento.Visitas_acumuladas__c = 0;
                            seguimiento.Ultima_Visita__c = null;
                        }
                    }
                }
                
            }            
        }
        System.debug('Seguimientos interaccion: '+ seguimientos);
        update seguimientos;
    }  
    // cuando se cambia el profesional de una visita se debe descontar la visita en el fichero relacionado
    public static void updateInteraccionesRelatedToSeguimientoWhenChangeProfesional (List<Dan360_Interacciones__c> interacciones) {
        Set<Id> apmId = new Set<Id>();
        Set<Id> profesionalId = new Set<Id>();
        Set<Id> interaccionesNuevas = new Set<Id>();
        Map<String, map<String, Date>> profesionalApmUltimaVisita = new Map<String, map<String, Date>>();
        Map<Id, VisMed_Contacto_Cuenta_Usuario__c> updateSeguimientos = new Map<Id, VisMed_Contacto_Cuenta_Usuario__c>();
        Map<String, Map<string, List<Dan360_Interacciones__c>>> profesionalApmInteracionMap = new Map<String, Map<string, List<Dan360_Interacciones__c>>>();
        Map<String, map<String, Integer>> profesionalApmVisitasRealizadas = new Map<String, map<String, Integer>>();
        for (Dan360_Interacciones__c interaccion : interacciones) {
            apmId.add(interaccion.VisMed_APM__c);
            profesionalId.add(interaccion.Profesional__c);
            interaccionesNuevas.add(interaccion.Id);
        }
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [
            SELECT Id, VisMed_APM__c, Profesional__c, Ultima_Visita__c, Inicio_de_Frecuencia__c, Fin_de_Frecuencia__c, Visitas_acumuladas__c, Visitas_Realizadas__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Predeterminada__c = true 
            AND Estado__c = 'Activo'
            AND Profesional__c IN :profesionalId
            AND VisMed_APM__c IN :apmId
            ];
        List<Dan360_Interacciones__c> interaccionesRealizadas = [
            SELECT Id, Name, Estado__c, RecordTypeId, Profesional__c, VisMed_APM__c, VisMed_Fecha__c
            FROM Dan360_Interacciones__c
            WHERE Estado__c = 'Aprobada'
            AND Profesional__c IN :profesionalId
            AND VisMed_APM__c IN :apmId 
            AND RecordTypeId = :recordTypeVisitaMedica
            //AND VisMed_Fecha__c >= :System.today().toStartOfMonth()
        ];

        // calculo de interacciones realizadas en el mes y fecha de ultima visita
        if (interaccionesRealizadas.size() > 0 && !interaccionesRealizadas.isEmpty()) {
            for (Dan360_Interacciones__c interaccion : interaccionesRealizadas) {
                if (!profesionalApmInteracionMap.containsKey(interaccion.Profesional__c)) {
                    profesionalApmInteracionMap.put(interaccion.Profesional__c, new Map<String, List<Dan360_Interacciones__c>>());
                }
                if (!profesionalApmInteracionMap.get(interaccion.Profesional__c).containsKey(interaccion.VisMed_APM__c)) {
                    profesionalApmInteracionMap.get(interaccion.Profesional__c).put(interaccion.VisMed_APM__c, new List<Dan360_Interacciones__c>());
                }
                profesionalApmInteracionMap.get(interaccion.Profesional__c).get(interaccion.VisMed_APM__c).add(interaccion);
            }
            // obtener fecha de ultima visita
            for (String profesional : profesionalApmInteracionMap.keySet()) {
                for (String apm : profesionalApmInteracionMap.get(profesional).keySet()) {
                    for (Dan360_Interacciones__c interaccion : profesionalApmInteracionMap.get(profesional).get(apm)) {
                        if (!profesionalApmUltimaVisita.containsKey(profesional)) {
                            profesionalApmUltimaVisita.put(profesional, new Map<String, Date>());
                        }
                        if (!profesionalApmUltimaVisita.get(profesional).containsKey(apm)) {
                            profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                        }
                        if (profesionalApmUltimaVisita.get(profesional).get(apm)!= null) {
                            if (interaccion.VisMed_Fecha__c > profesionalApmUltimaVisita.get(profesional).get(apm)) {
                                profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                            }
                        }else {
                            profesionalApmUltimaVisita.get(profesional).put(apm, interaccion.VisMed_Fecha__c);
                        }
                    }
                }
            }
            // calcular visitas realizadas
            Integer visitasRealizadas;
            for (String profesional : profesionalApmInteracionMap.keySet()) {
                for (String apm : profesionalApmInteracionMap.get(profesional).keySet()) {
                    visitasRealizadas = 0;
                    for (Dan360_Interacciones__c interaccion : profesionalApmInteracionMap.get(profesional).get(apm)) {
                        if(interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth()){
                            if (!profesionalApmVisitasRealizadas.containsKey(profesional)) {
                                profesionalApmVisitasRealizadas.put(profesional, new Map<String, Integer>());
                            }
                            if (!profesionalApmVisitasRealizadas.get(profesional).containsKey(apm)) {
                                profesionalApmVisitasRealizadas.get(profesional).put(apm, 0);
                            }                        
                            visitasRealizadas ++;
                            profesionalApmVisitasRealizadas.get(profesional).put(apm, visitasRealizadas);
                        }
                        
                    }
                    System.debug('total visitas '+visitasRealizadas);
                }
            }
        } 
        Integer mesInicio;
        Integer mesFinal;
        Integer mesActual = Date.today().Month();
        Integer mesVisita;   
        Integer cantidadVisitasDelPasado = 0;   
        // Se detecta visita que se carga del pasado y no es del mes actual 
        // se cuenta la cantidad de visitas del pasado  
        Map<id, Integer> visitaDelPasado = new Map<id, Integer>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            if (seguimiento.Inicio_de_Frecuencia__c != null && seguimiento.Fin_de_Frecuencia__c != null) {
                mesInicio = seguimiento.Inicio_de_Frecuencia__c.Month();
                mesFinal = seguimiento.Fin_de_Frecuencia__c.Month();                
                for (Dan360_Interacciones__c interaccion : interaccionesRealizadas ) {
                    mesVisita = interaccion.VisMed_Fecha__c.Month();
                    if (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c && mesActual != mesVisita && interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c && interaccion.VisMed_Fecha__c <= seguimiento.Fin_de_Frecuencia__c) {
                        cantidadVisitasDelPasado ++;                        
                        visitaDelPasado.put(seguimiento.Id, cantidadVisitasDelPasado);                       
                    }
                }            
            }
            System.debug('fichero: '+ seguimiento.Id);
            System.debug('cantidad visitas del pasado: '+ cantidadVisitasDelPasado);
        }
        // se descuenta en el fichero las visitas del pasado y se coloca ultima visita
        boolean actualizarSeguimientos;
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            actualizarSeguimientos = false;
            if (visitaDelPasado.containsKey(seguimiento.Id) && seguimiento.Visitas_acumuladas__c > 0) {
                seguimiento.Visitas_acumuladas__c = visitaDelPasado.get(seguimiento.Id); 
                actualizarSeguimientos = true;
            }else {
                seguimiento.Visitas_acumuladas__c = 0; 
                actualizarSeguimientos = true;
            }
            if (profesionalApmUltimaVisita.containsKey(seguimiento.Profesional__c)) {
                if (profesionalApmUltimaVisita.get(seguimiento.Profesional__c).containsKey(seguimiento.VisMed_APM__c)) {                            
                    seguimiento.Ultima_Visita__c = profesionalApmUltimaVisita.get(seguimiento.Profesional__c).get(seguimiento.VisMed_APM__c);
                    actualizarSeguimientos = true;
                }
            } else {
                seguimiento.Ultima_Visita__c = null;
                actualizarSeguimientos = true;
            }
            System.debug('ultima visita'+ seguimiento.Ultima_Visita__c);
            if (actualizarSeguimientos) {
               
                updateSeguimientos.put(seguimiento.Id, seguimiento);
                 
            }
            
        }
        // se registra en el fichero las visitas de este mes y la fecha de ultima visita
        for (Dan360_Interacciones__c interaccion : interacciones) {
            mesVisita = interaccion.VisMed_Fecha__c.Month();
            if (mesVisita == mesActual) {
                for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                    seguimiento.Visitas_Realizadas__c = 0;
                    If (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c && (interaccion.VisMed_Fecha__c >= seguimiento.Inicio_de_Frecuencia__c || interaccion.VisMed_Fecha__c >= System.today().toStartOfMonth())) {
                        //seguimiento.Visitas_Realizadas__c ++;
                        System.debug(seguimiento.Id);                 
                        if (profesionalApmUltimaVisita.containsKey(interaccion.Profesional__c)) {
                            if (profesionalApmUltimaVisita.get(interaccion.Profesional__c).containsKey(interaccion.VisMed_APM__c)) {                            
                                seguimiento.Ultima_Visita__c = profesionalApmUltimaVisita.get(interaccion.Profesional__c).get(interaccion.VisMed_APM__c);                            
                            }
                        } else {
                            seguimiento.Ultima_Visita__c = null;
                        }        
                        if (profesionalApmVisitasRealizadas.containsKey(seguimiento.Profesional__c)) {                                                       
                            if (profesionalApmVisitasRealizadas.get(seguimiento.Profesional__c).containsKey(seguimiento.VisMed_APM__c)) {
                                seguimiento.Visitas_Realizadas__c = profesionalApmVisitasRealizadas.get(seguimiento.Profesional__c).get(seguimiento.VisMed_APM__c);                                
                            } 
                            System.debug('ultima visita '+ seguimiento.Ultima_Visita__c);              
                        }  
                        
                        updateSeguimientos.put(seguimiento.Id, seguimiento);
                               
                    }                
                }                 
            }
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>(updateSeguimientos.values());
        System.debug('Seguimientos interaccion: '+ seguimientosToUpdate);    
        Database.update(seguimientosToUpdate);
        
    }    
}