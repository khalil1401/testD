public with sharing class BatchFrecuenciaSemaforo implements Database.Batchable<sObject>{
    public static Boolean isRunningFromBatch = false;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT	Id,';
		query += '				Frecuencia__c,';
        query += '				Aun_Quedan_Meses__c,';
        query += '				Inicio_de_Frecuencia__c,';
        query += '				Fin_de_Frecuencia__c,';
		query += '				Profesional__c,';
		query += '				VisMed_APM__c,';        
        query += '				Segmenta_Por__c,';
        query += '				VisMed_Semaforo__c,';
        query += '				Visitas_Realizadas__c,';
        query += '				Visitas_acumuladas__c,';
        query += '				Estado__c,';
        query += '				Segmenta_Anterior__c';
		query += '		FROM	VisMed_Contacto_Cuenta_Usuario__c';
		query += '		WHERE	Estado__c = \'Activo\'';	
        query += '		OR    Estado__c = \'Baja Temporal\'';
        System.debug('ficheros aprobados el mes pasado: '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<VisMed_Contacto_Cuenta_Usuario__c> scope){
        System.debug('Ficheros '+ scope);
        // Seteo de frecuencia y visitas realizadas a 0  
        isRunningFromBatch = true;      
        List<VisMed_Contacto_Cuenta_Usuario__c> updateSemaforo = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : scope) {
            if (seguimiento.Estado__c == 'Activo') {                
                if (seguimiento.Frecuencia__c != null) {
                    System.debug('Tiene frecuencia: '+ seguimiento.Frecuencia__c);
                    System.debug('Id: '+ seguimiento.Id);
                    // frecuencia es entera 
                    if (String.ValueOf(seguimiento.Frecuencia__c).endsWith('.00') || String.ValueOf(seguimiento.Frecuencia__c).endsWith(',00') || String.ValueOf(seguimiento.Frecuencia__c).endsWith('.0') || String.ValueOf(seguimiento.Frecuencia__c).endsWith(',0')) {
                        System.debug('Frecuencia Entera: '+ seguimiento.Frecuencia__c);
                        System.debug('Id: '+ seguimiento.Id);
                        seguimiento.Aun_Quedan_Meses__c = false;
                        seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                        seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
                        seguimiento.Visitas_Realizadas__c = 0;
                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                        updateSemaforo.add(seguimiento);
                    } else {  
                        //  frecuencia con decimal
                        System.debug('Frecuencia Decimal');
                        System.debug('Id: '+ seguimiento.Id);
                        Integer mesInicio = seguimiento.Inicio_de_Frecuencia__c.Month();
                        Integer mesFinal = seguimiento.Fin_de_Frecuencia__c.Month();
                        Integer mesActual = System.today().month();
                        if (mesActual == mesInicio ) {
                            System.debug('Mes Inicial');
                            System.debug('Mes Inicial= '+seguimiento.Inicio_de_Frecuencia__c);
                            System.debug('Id: '+ seguimiento.Id);
                            seguimiento.Aun_Quedan_Meses__c = true;                                        
                            seguimiento.Visitas_Realizadas__c = 0;
                            seguimiento.Visitas_acumuladas__c = 0;
                            seguimiento.VisMed_Semaforo__c = 'Rojo';
                            updateSemaforo.add(seguimiento);                    
                        }else if( mesInicio < mesActual && mesActual < mesFinal) {
                            System.debug('Mes del medio');
                            System.debug('Id: '+ seguimiento.Id);
                            seguimiento.Aun_Quedan_Meses__c = true;                    
                            seguimiento.Visitas_acumuladas__c +=  seguimiento.Visitas_Realizadas__c;
                            seguimiento.Visitas_Realizadas__c = 0;
                            updateSemaforo.add(seguimiento);
                        }else if( mesFinal == mesActual) {
                            System.debug('Mes final');
                            System.debug('Mes final= '+ seguimiento.Fin_de_Frecuencia__c);
                            System.debug('visitas totales en la frecuencia = '+ seguimiento.Visitas_acumuladas__c);
                            System.debug('Id: '+ seguimiento.Id);
                            seguimiento.Aun_Quedan_Meses__c = false;                    
                            seguimiento.Visitas_acumuladas__c +=  seguimiento.Visitas_Realizadas__c;
                            seguimiento.Visitas_Realizadas__c = 0;
                            updateSemaforo.add(seguimiento);
                        }else {
                            System.debug('Fin periodo de frecuencia se resetea todo+ '+ seguimiento.Fin_de_Frecuencia__c);
                            System.debug('Id: '+ seguimiento.Id);
                            Decimal frecuenciaDecimal = seguimiento.Frecuencia__c;
                            frecuenciaDecimal = Math.abs(frecuenciaDecimal - frecuenciaDecimal.intValue());                           
                            Decimal meses = 1/frecuenciaDecimal;
                            System.debug('frecuencia decimal: '+1/frecuenciaDecimal);
                            seguimiento.Aun_Quedan_Meses__c = true;
                            seguimiento.Visitas_acumuladas__c = 0;
                            seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                            seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(meses.intValue()).addDays(-1);
                            seguimiento.Visitas_Realizadas__c = 0;
                            seguimiento.VisMed_Semaforo__c = 'Rojo';
                            updateSemaforo.add(seguimiento);
                        }
                    }           
                } else {  
                    // sin frecuencia  
                    System.debug('sin frecuencia');       
                    System.debug('Id: '+ seguimiento.Id);
                    seguimiento.Aun_Quedan_Meses__c = false;
                    seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                    seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
                    seguimiento.Visitas_Realizadas__c = 0;
                    seguimiento.VisMed_Semaforo__c = 'Gris';
                    updateSemaforo.add(seguimiento);
                }            
            }
            if (seguimiento.Estado__c == 'Baja Temporal') {
                seguimiento.Visitas_Realizadas__c = 0;
                seguimiento.VisMed_Semaforo__c = 'Gris';
                updateSemaforo.add(seguimiento);
            }
        }

        System.debug(updateSemaforo);
        if (updateSemaforo.size() > 0 && !updateSemaforo.isEmpty() ) {
            System.debug('Update de ficheros');
            Database.update(updateSemaforo, false);
        }         
        
    }

    public void finish(Database.BatchableContext context) {
	}
}