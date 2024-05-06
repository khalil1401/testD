public with sharing class EfectividadTriggerHelper {
   
    public static void insertEfectividad (List<Dan360_Efectividad__c> newEfectividades) {
        Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
        List<Target_Diario__mdt> targets = [SELECT DeveloperName, Sub_Equipo__c, Numero_de_mes__c, Target__c FROM Target_Diario__mdt];
        Map<Id, Map<Decimal, Decimal>> targetXAPM = new Map<Id, Map<Decimal, Decimal>>();
        List<Id> ciclosId = new List<Id>();
        List<Id> apmsId = new List<Id>();
        for (Dan360_Efectividad__c efectividad : newEfectividades) {
            if (efectividad.VisMed_Ciclo__c == null)  {
                efectividad.addError('La efectividad debe pertenecer a un Ciclo');
            } else {
                ciclosId.add(efectividad.VisMed_Ciclo__c);
                apmsId.add(efectividad.VisMed_APM__c);
            }
        }
        Map<Id, VisMed_Ciclo__c> ciclos  = new Map<Id, VisMed_Ciclo__c>(
            [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, Numero_de_mes__c	
            FROM  VisMed_Ciclo__c
            WHERE Id IN : ciclosId]
        );
        List<Contact> apms = 
            [SELECT Id, Name, VisMed_Equipo__c, Sub_Equipo__c
            FROM Contact
            WHERE Id IN : apmsId AND RecordTypeId = :recordTypeVisitadorMedico];
        for (Contact apm : apms) {
            List<String> subEquiposAux = new List<String>();
            System.debug('apm: '+apm.Sub_Equipo__c);
            if (String.isNotBlank(apm.Sub_Equipo__c)){
                subEquiposAux.addAll(apm.Sub_Equipo__c.split(';'));
                Map<Decimal, Decimal> targetXCiclo = new Map<Decimal, Decimal>();
                Decimal numeroDelMesDecimal;
                Integer numeroDelMesInt;
                for (String subEquipo : subEquiposAux) {
                    Decimal targetAux = 0;
                    for (Target_Diario__mdt target : targets) {
                        numeroDelMesDecimal = target.Numero_de_mes__c;
                        numeroDelMesInt = numeroDelMesDecimal.intValue();
                        System.debug('target: '+ target);
                        if (target.Sub_Equipo__c == subEquipo && targetXCiclo.containsKey(target.Numero_de_mes__c) && targetXCiclo.get(target.Numero_de_mes__c) < target.Target__c) {
                            targetXCiclo.put(numeroDelMesInt, target.Target__c);
                        } else if (!targetXCiclo.containsKey(target.Numero_de_mes__c)) {
                            targetXCiclo.put(numeroDelMesInt, target.Target__c);
                        }
                    }
                }
                targetXAPM.put(apm.Id, targetXCiclo);  
                System.debug(targetXAPM);        
            } 
            
        }
        for (Dan360_Efectividad__c efectividad : newEfectividades) {
            System.debug(efectividad);
            if (ciclos.containsKey(efectividad.VisMed_Ciclo__c) && targetXAPM.containsKey(efectividad.VisMed_APM__c)) {
                System.debug(targetXAPM.get(efectividad.VisMed_APM__c).get(ciclos.get(efectividad.VisMed_Ciclo__c).Numero_de_mes__c));
                efectividad.VisMed_Target_Diario__c = targetXAPM.get(efectividad.VisMed_APM__c).get(ciclos.get(efectividad.VisMed_Ciclo__c).Numero_de_mes__c);
                system.debug('target diario: ' + efectividad.VisMed_Target_Diario__c);
                if (efectividad.VisMed_Target_Diario__c == null) {
                    efectividad.addError('No existe metadata para el equipo del APM y el Ciclo que se selecciono.');
                    System.debug(efectividad);
                }
                /*
                if (apms.get(efectividad.VisMed_APM__c).VisMed_Equipo__c == 'Nicho') {
                    efectividad.VisMed_Target_Diario__c = targetPorEquipo.get(ciclos.get(efectividad.VisMed_Ciclo__c).Numero_de_mes__c).get(apms.get(efectividad.VisMed_APM__c).VisMed_Equipo__c);
                } else {
                    efectividad.VisMed_Target_Diario__c = targetPorEquipo.get(ciclos.get(efectividad.VisMed_Ciclo__c).Numero_de_mes__c).get(apms.get(efectividad.VisMed_APM__c).VisMed_Areas_Terap_uticas__c);
                }*/
                efectividad.Fecha_de_inicio__c = ciclos.get(efectividad.VisMed_Ciclo__c).Fecha_de_inicio__c;
                efectividad.Fecha_de_Fin__c  = ciclos.get(efectividad.VisMed_Ciclo__c).Fecha_de_fin__c;
                efectividad.VisMed_Codigo_de_duplicidad__c = ciclos.get(efectividad.VisMed_Ciclo__c).Name + ' - ' + efectividad.VisMed_APM__c;
                efectividad.VisMed_Efectividad__c = 0;
                efectividad.VisMed_Visitas_realizadas__c = 0;
                efectividad.VisMed_Visitas_restantes__c = 0;
                efectividad.VisMed_Dias_de_Licencia_Unicos__c  = 0;
                efectividad.Dias_de_Licencia_Transcurridos__c = 0;
            }
        }
        calculateFields(newEfectividades);
    }

    public static void calculateFields (List<Dan360_Efectividad__c> efectividadesToUpdate) {
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Map<Id, Dan360_Efectividad__c> mapaDeEfectividades = New Map<Id, Dan360_Efectividad__c>();
        Map<Id, List<Dan360_Licencia__c>> licenciasPorEfectividad = New Map<Id, List<Dan360_Licencia__c>>();
        Map<Date, Dan360_Licencia__c> diasPorLicencia = new Map<Date, Dan360_Licencia__c>();
        Set<Id> apmsId = New Set<id>();
        for (Dan360_Efectividad__c efectividad : efectividadesToUpdate) {
            mapaDeEfectividades.put(efectividad.id, efectividad);
            apmsId.add(efectividad.VisMed_APM__c);
        }
        List<Dan360_Licencia__c> licencias = [SELECT Id, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c, Efectividad__c
                                                  FROM Dan360_Licencia__c 
                                                  WHERE Estado__c = 'Aprobada' AND VisMed_APM__c IN :apmsId AND Efectividad__c IN :mapaDeEfectividades.keySet() AND RecordTypeId = :recordTypeLicencia];
        for (Dan360_Licencia__c licencia : licencias) { //ARMO LA LISTA DE LICENCIAS PARA LA EFECTIVIDAD
            List<Dan360_Licencia__c> listLicencias;
            listLicencias = licenciasPorEfectividad.containsKey(licencia.Efectividad__c) ? licenciasPorEfectividad.get(licencia.Efectividad__c) : New List<Dan360_Licencia__c>();
            listLicencias.add(licencia);
            licenciasPorEfectividad.put(licencia.Efectividad__c, listLicencias);

            // CALCULO LOS DIAS DE LICENCIAS UNICOS PARA LA EFECTIVIDAD
            Integer daysBetweenNew = licencia.Fecha_de_inicio__c.daysBetween(licencia.Fecha_de_Fin__c);
            Date auxFechaNew = licencia.Fecha_de_inicio__c;
            for (Integer i = 0; i <= daysBetweenNew; i++) {
                Datetime dt = (Datetime)auxFechaNew;
                String dayOfWeek = dt.format('EEEE');
                if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                    diasPorLicencia.put(auxFechaNew, licencia);
                }
                auxFechaNew = auxFechaNew.addDays(1);
            }
        }
        for (Dan360_Efectividad__c efectividad : efectividadesToUpdate) {
            //efectividad.VisMed_Dias_de_Licencia_Unicos__c = diasPorLicencia.keySet().size();
            //(dias totales * target)-(dias de licencia unicos * target ) - (target * tiempo no promo) - visitas realizadas
            System.debug('efectividad '+ efectividad);
            System.debug('efectividad.Dias_Totales_del_Ciclo__c');
            System.debug(efectividad.Dias_Totales_del_Ciclo__c);

            System.debug('efectividad.VisMed_Target_Diario__c');
            System.debug(efectividad.VisMed_Target_Diario__c);

            System.debug('efectividad.VisMed_Dias_de_Licencia_Unicos__c');
            System.debug(efectividad.VisMed_Dias_de_Licencia_Unicos__c);    
            
            System.debug('efectividad.Tiempo_no_promocional__c');
            System.debug(efectividad.Tiempo_no_promocional__c); 

            System.debug('efectividad.VisMed_Visitas_realizadas__c');
            System.debug(efectividad.VisMed_Visitas_realizadas__c); 
            System.debug('efectividad.Dias_de_campo_efectivo__c');
            System.debug(efectividad.Dias_de_campo_efectivo__c); 
            efectividad.VisMed_Visitas_restantes__c = (efectividad.Dias_Totales_del_Ciclo__c * efectividad.VisMed_Target_Diario__c)//TARGET DIARIO
                                                        - (efectividad.VisMed_Dias_de_Licencia_Unicos__c * efectividad.VisMed_Target_Diario__c) 
                                                        - (efectividad.VisMed_Target_Diario__c * efectividad.Tiempo_no_promocional__c)
                                                        - efectividad.VisMed_Visitas_realizadas__c;
            if (efectividad.VisMed_Visitas_realizadas__c >= 1) {
                efectividad.VisMed_Efectividad__c = (efectividad.VisMed_Visitas_realizadas__c / (efectividad.VisMed_Target_Diario__c * efectividad.Dias_de_campo_efectivo__c)) * 100;
            } else {
                efectividad.VisMed_Efectividad__c = 0;
            }
        }
    }

    public class TargetWrapper {
        Decimal numeroDeMes;
        String subEquipo;
        Decimal cantidadDeVisitas;
    }

}