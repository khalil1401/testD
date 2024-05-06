public with sharing class CicloTriggerHelper {
    
    public static void createCiclo (List<VisMed_Ciclo__c> ciclos) {
        System.debug('Entre al trigger de ciclo');
        Compensatorio_Tiempo_no_Promocional__mdt Compensatorio_Tiempo_no_Promocional = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Compensatorio__c 
                                                                                        FROM Compensatorio_Tiempo_no_Promocional__mdt 
                                                                                        WHERE DeveloperName = 'Compensatorio_General'
                                                                                        LIMIT 1];
        for (VisMed_Ciclo__c ciclo : ciclos) {
            DateTime fecha = dateTime.newInstance(ciclo.Fecha_de_Inicio__c.year(), ciclo.Fecha_de_Inicio__c.month(), ciclo.Fecha_de_Inicio__c.day());
            String monthName = getMes(fecha.month());
            String yearName = fecha.format('YYYY');
            ciclo.name = monthName + ' - ' + yearName;
            ciclo.VisMed_Cmpt_Tiempo_no_promocional__c = Compensatorio_Tiempo_no_Promocional.Compensatorio__c;
        }      
    }
    
    
    public static String getMes (Integer mesNumber) {
        Map<Integer, String> fechaEnEspanol = new Map<Integer, String>();
        fechaEnEspanol.put(1, 'Enero');
        fechaEnEspanol.put(2, 'Febrero');
        fechaEnEspanol.put(3, 'Marzo');
        fechaEnEspanol.put(4, 'Abril');
        fechaEnEspanol.put(5, 'Mayo');
        fechaEnEspanol.put(6, 'Junio');
        fechaEnEspanol.put(7, 'Julio');
        fechaEnEspanol.put(8, 'Agosto');
        fechaEnEspanol.put(9, 'Septiembre');
        fechaEnEspanol.put(10, 'Octubre');
        fechaEnEspanol.put(11, 'Noviembre');
        fechaEnEspanol.put(12, 'Diciembre');
        return fechaEnEspanol.containsKey(mesNumber) ? fechaEnEspanol.get(mesNumber) : 'Error';
    }
}