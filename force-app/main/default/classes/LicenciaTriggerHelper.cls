public class LicenciaTriggerHelper {
    public static void completarCampos(List<Dan360_Licencia__c> newLicencias){
        Id recordTypeTNP = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
        List<Id> APMIds = new List<id>();
        for(Dan360_Licencia__c lic : newLicencias){
            if(lic.RecordTypeId == recordTypeTNP){
                lic.Tipo_de_Registro__c = 'Tiempo_no_Promocional';
            }
            APMIds.add(lic.VisMed_APM__c);
        }
        
        List<User> usuarios = [
            SELECT Id, Manager.Email, ContactId
            FROM User 
            WHERE ContactId IN :APMIds
        ];
        
    }
    
    public static void validaciones (List<Dan360_Licencia__c> newLicencias) {
        Id recordTypeTNP = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
        List<Id> apmsToValidate = new List<Id>();
        List<Dan360_Licencia__c> licenciasToValidate = new List<Dan360_Licencia__c>();
        List<Dan360_Licencia__c> oldLicencias = [SELECT Id, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c FROM Dan360_Licencia__c WHERE Estado__c = 'Aprobada'];
        for (Dan360_Licencia__c newLicencia : newLicencias) {
             if (newLicencia.RecordTypeId == recordTypeTNP) {
                apmsToValidate.add(newLicencia.VisMed_APM__c);
                newLicencia.Fecha_de_Fin__c = newLicencia.Fecha_de_inicio__c;
                licenciasToValidate.add(newLicencia);
            }    
            
            if (newLicencia.Motivo__c != 'Festivo') {
                newLicencia.Estado__c = 'Pendiente'; //todas las licencias (salvo las festivas) deben pasar por proceso de aprobación.
            } else {
                newLicencia.isApprobed__c = false;
            }
            Map<Date, Dan360_Licencia__c> diasPorLicencia = new Map<Date, Dan360_Licencia__c>();
            Integer daysBetweenNew = newLicencia.Fecha_de_inicio__c.daysBetween(newLicencia.Fecha_de_Fin__c);
            Date auxFechaNew = newLicencia.Fecha_de_inicio__c;
            for (Integer i = 0; i <= daysBetweenNew; i++) {
                diasPorLicencia.put(auxFechaNew, newLicencia);
                auxFechaNew = auxFechaNew.addDays(1);
            }
            for (Dan360_Licencia__c oldLicencia : oldLicencias) {
                if (newLicencia.VisMed_APM__c == oldLicencia.VisMed_APM__c) {
                    Integer daysBetweenOld = oldLicencia.Fecha_de_inicio__c.daysBetween(oldLicencia.Fecha_de_Fin__c);
                    Date auxFechaOld = oldLicencia.Fecha_de_inicio__c;
                    for (Integer i = 0; i <= daysBetweenOld; i++) {
                        if (diasPorLicencia.containsKey(auxFechaOld) && newLicencia.Motivo__c != 'Festivo' &&  newLicencia.RecordTypeId != recordTypeTNP) { // Si la licencia es por dia festivo o TNP se carga igual.
                            diasPorLicencia.get(auxFechaOld).addError('Esta licencia se superpone con otras');
                        }
                        auxFechaOld.addDays(1);
                    }
                }
            }
           
        }
        
        List<Dan360_Licencia__c> tiemposNoPromocionalesExistentes = [
            SELECT id,Fecha_de_inicio__c,Estado__c, Fecha_de_Fin__c,VisMed_Cantidad_de_Horas_Numerico__c,VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE VisMed_APM__c IN :apmsToValidate
            AND RecordTypeId = :recordTypeTNP
            //AND Estado__c != 'Rechazada' // Deben ser solo en estado pendiente o aprobadas
        ];
        
        system.debug(tiemposNoPromocionalesExistentes);
        
        Map<id, List<Dan360_Licencia__c>> mapTNP = new Map<id, List<Dan360_Licencia__c>>();
        for(Dan360_Licencia__c lic : tiemposNoPromocionalesExistentes){
            List<Dan360_Licencia__c> lista = new List<Dan360_Licencia__c>();
            if(mapTNP.containsKey(lic.VisMed_APM__c)){
                lista = mapTNP.get(lic.VisMed_APM__c);
            }
            lista.add(lic);
            mapTNP.put(lic.VisMed_APM__c, lista);
        }
        
        
        for(Dan360_Licencia__c lic : licenciasToValidate){
            system.debug(lic);
            if(mapTNP.containsKey(lic.VisMed_APM__c)){
                List<Dan360_Licencia__c> lista = mapTNP.get(lic.VisMed_APM__c);
                Double sumador = lic.VisMed_Cantidad_de_Horas_Numerico__c;
                Integer contador = 0;
                for(Dan360_Licencia__c licenciasInsertadas : lista){
                    if(licenciasInsertadas.Fecha_de_inicio__c == lic.Fecha_de_inicio__c){
                        contador +=1;
                        if (licenciasInsertadas.Estado__c != 'Rechazada') {
                            sumador += licenciasInsertadas.VisMed_Cantidad_de_Horas_Numerico__c;
                                                    
                        }
                        /* if(licenciasInsertadas.Estado__c == 'Rechazada'){
                            contador -=1;  
                        } */
                    }
                }
                if(sumador>8){
                    lic.addError('No se puede cargar más de 8 horas de Tiempo no promocional en un día.');
                }
                else{
                    contador += 1;
                    lic.VisMed_Codigo_de_duplicidad__c =  lic.Fecha_de_inicio__c + ' - ' + lic.Fecha_de_Fin__c + ' - ' + lic.VisMed_APM__c + ' - TNP - '+contador;
                }
            }
        }
    }
    
    public static void splitLicencias (List<Dan360_Licencia__c> licencias) {
        Id recordTypeTNP = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
        List<Dan360_Licencia__c> nuevasLicencias = New List<Dan360_Licencia__c>();
        for (Dan360_Licencia__c licencia : licencias) {
            if (licencia.Motivo__c != 'Festivo') {
                Integer monthsBetween = licencia.Fecha_de_inicio__c.monthsBetween(licencia.Fecha_de_Fin__c);
                System.debug(monthsBetween);
                for (Integer i = 0; i <= monthsBetween; i++) { // Si la licencia creada por el usuario ocupa meses distintos, se devera crear una licencia por cada mes distinto.

                    if (i >= 0 && ((monthsBetween - i) > 0)) { // Si es la primera licencia creada o una del medio...                   
                        nuevasLicencias.add(createLicencia(licencia));
                        licencia.Fecha_de_inicio__c = (licencia.Fecha_de_inicio__c.toStartOfMonth()).addMonths(1); 
                    }
                    if ((i > 0 && ((monthsBetween - i) == 0)) || monthsBetween == 0) { // Si es la ultima licencia a crear [(monthsBetween - i) == 1]...
                        licencia.Efectividad__c = searchEfectividadCorrespondiente(licencia).Id;
                        licencia.Estado__c = 'Pendiente';
                        system.debug('por que entra aca');
                        if(licencia.RecordTypeId != recordTypeTNP){
                            licencia.VisMed_Codigo_de_duplicidad__c =  licencia.Fecha_de_inicio__c + ' - ' + licencia.Fecha_de_Fin__c + ' - ' + licencia.VisMed_APM__c + ' - LIC - 1';
                        }
                    }
                }
            } else { // Si es una licencia con motivo festivo, se completa el codigo de duplicidad
                licencia.VisMed_Codigo_de_duplicidad__c =  licencia.Fecha_de_inicio__c + ' - ' + licencia.Fecha_de_Fin__c + ' - ' + licencia.VisMed_APM__c + ' - FESTIVO - 1';
            }    
        }
        insert nuevasLicencias;
    }
    
    public static Dan360_Licencia__c createLicencia (Dan360_Licencia__c licencia){
        Dan360_Licencia__c newLicencia = New Dan360_Licencia__c(
            Fecha_de_inicio__c = licencia.Fecha_de_inicio__c,
            Fecha_de_Fin__c = (licencia.Fecha_de_inicio__c.toStartOfMonth()).addMonths(1).addDays(-1), // Fin del mes.
            Estado__c = 'Pendiente',
            VisMed_APM__c = licencia.VisMed_APM__c,
            Motivo__c = licencia.Motivo__c,
            VisMed_Codigo_de_duplicidad__c =  licencia.Fecha_de_inicio__c + ' - ' + licencia.Fecha_de_Fin__c + ' - ' + licencia.VisMed_APM__c
        );
        system.debug(newLicencia.VisMed_Codigo_de_duplicidad__c);
        newLicencia.Efectividad__c = searchEfectividadCorrespondiente(newLicencia).Id;
        return newLicencia;
    }
    
    public static Dan360_Efectividad__c searchEfectividadCorrespondiente (Dan360_Licencia__c licencia) {
        Date fechaDeinicio = licencia.Fecha_de_inicio__c;
        Date fechaDeFin = licencia.Fecha_de_Fin__c;
        System.debug('Fecha Inicio: ' + fechaDeinicio);
        System.debug('Fecha Fin: ' + fechaDeFin);
        System.debug(licencia.VisMed_APM__c);
        List<Dan360_Efectividad__c> efectividades = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c, VisMed_Ciclo__c
                                                     FROM Dan360_Efectividad__c
                                                     WHERE Fecha_de_inicio__c <= :fechaDeinicio AND Fecha_de_Fin__c >= :fechaDeFin AND VisMed_APM__c = :licencia.VisMed_APM__c];
        List<VisMed_Ciclo__c> ciclos = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c
                                        FROM VisMed_Ciclo__c
                                        WHERE Fecha_de_inicio__c <= :fechaDeinicio AND Fecha_de_Fin__c >= :fechaDeFin];
        Dan360_Efectividad__c efectividadToReturn;
        if (!efectividades.isEmpty()) {
            efectividadToReturn = efectividades[0];
        } else {
            efectividadToReturn = new Dan360_Efectividad__c(
                Fecha_de_inicio__c = (licencia.Fecha_de_inicio__c).toStartOfMonth(),
                Fecha_de_Fin__c = (licencia.Fecha_de_inicio__c.toStartOfMonth()).addMonths(1).addDays(-1),
                VisMed_APM__c = licencia.VisMed_APM__c,
                VisMed_Ciclo__c = ciclos[0].Id
            );
            insert efectividadToReturn;
        }                   
        return efectividadToReturn;
    }
    
    public static void calculateDiasTranscurridos (List<Dan360_Licencia__c> licencias) {
        System.debug(licencias);
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Map<Id, List<Dan360_Licencia__c>> licenciasPorEfectividad = New Map<Id, List<Dan360_Licencia__c>>();
        // Map<Date, Dan360_Licencia__c> diasPorLicenciaNoFestivo = new Map<Date, Dan360_Licencia__c>(); //Cuenta solo las licencias que NO sean Festivos.
        // Map<Date, Dan360_Licencia__c> diasPorLicenciaFestivos = new Map<Date, Dan360_Licencia__c>(); //Cuenta solo las licencias que sean Festivos.
        // Map<Date, Dan360_Licencia__c> diasPorLicenciaUnicos = new Map<Date, Dan360_Licencia__c>(); //Cuenta todas las licencias.
        
        
        for (Dan360_Licencia__c licencia : licencias) {
            List<Dan360_Licencia__c> listLicencias;
            listLicencias = licenciasPorEfectividad.containsKey(licencia.Efectividad__c) ? licenciasPorEfectividad.get(licencia.Efectividad__c) : New List<Dan360_Licencia__c>();
            if (licencia.Estado__c == 'Aprobada') {
                listLicencias.add(licencia);
                licenciasPorEfectividad.put(licencia.Efectividad__c, listLicencias);
            }
        }
        
        Map<Id, Dan360_Efectividad__c> efectividadesToUpdate = new Map<Id, Dan360_Efectividad__c>([SELECT Id, Name, Dias_de_Licencia_Transcurridos__c, VisMed_Dias_de_Licencia_Unicos__c
                                                                                                   FROM Dan360_Efectividad__c
                                                                                                   WHERE Id IN :licenciasPorEfectividad.keySet()]); 
        
        List<Dan360_Licencia__c> licenciasDB = [SELECT Id, Fecha_de_inicio__c, Fecha_de_Fin__c, isDeleted, Estado__c, Efectividad__c, Motivo__c FROM Dan360_Licencia__c WHERE Estado__c = 'Aprobada' AND RecordTypeId = :recordTypeLicencia AND Efectividad__c IN :efectividadesToUpdate.keySet()];
        System.debug(licenciasDB);
        System.debug(efectividadesToUpdate);
        //licenciasPorEfectividad.clear();
        for (Dan360_Licencia__c licencia : licenciasDB) {
            List<Dan360_Licencia__c> listLicencias;
            listLicencias = licenciasPorEfectividad.containsKey(licencia.Efectividad__c) ? licenciasPorEfectividad.get(licencia.Efectividad__c) : New List<Dan360_Licencia__c>();
            if (licencia.Estado__c == 'Aprobada') {
                listLicencias.add(licencia);
                licenciasPorEfectividad.put(licencia.Efectividad__c, listLicencias);
            }
        }        
        
        for (Dan360_Efectividad__c efectividad : efectividadesToUpdate.values()) {
            System.debug(efectividad);
            Map<Date, Dan360_Licencia__c> diasPorLicenciaNoFestivo = new Map<Date, Dan360_Licencia__c>(); //Cuenta solo las licencias que NO sean Festivos.
            Map<Date, Dan360_Licencia__c> diasPorLicenciaFestivos = new Map<Date, Dan360_Licencia__c>(); //Cuenta solo las licencias que sean Festivos.
            Map<Date, Dan360_Licencia__c> diasPorLicenciaUnicos = new Map<Date, Dan360_Licencia__c>(); //Cuenta todas las licencias.
            if (!licenciasPorEfectividad.isEmpty())  {
                for (Dan360_Licencia__c licencia : licenciasPorEfectividad.get(efectividad.Id)){
                    System.debug('licencia');
                    System.debug(licencia);
                    Integer daysBetweenNew;
                    if (licencia.Fecha_de_Fin__c > System.today()) {
                        daysBetweenNew = licencia.Fecha_de_inicio__c.daysBetween(System.today());
                        System.debug('daysBetweenNew');
                        System.debug(daysBetweenNew);
                    } else {
                        daysBetweenNew = licencia.Fecha_de_inicio__c.daysBetween(licencia.Fecha_de_Fin__c);
                        System.debug('daysBetweenNew');
                        System.debug(daysBetweenNew);
                    }
                    Date auxFechaNew = licencia.Fecha_de_inicio__c;
                    for (Integer i = 0; i <= daysBetweenNew; i++) {
                        Datetime dt = (Datetime)auxFechaNew;
                        String dayOfWeek = dt.format('EEEE', 'Europe/Jersey'); //Salesforce me toma la zona horaria defasada por 3 horas asi que los dias se defasaban.
                        System.debug('borrada? :' + licencia.isDeleted);
                        if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday' && !licencia.IsDeleted) {
                            if (licencia.Motivo__c != 'Festivo') {
                                diasPorLicenciaNoFestivo.put(auxFechaNew, licencia);
                            } else {
                                diasPorLicenciaFestivos.put(auxFechaNew, licencia);
                            }
                            diasPorLicenciaUnicos.put(auxFechaNew, licencia);
                        }
                        auxFechaNew = auxFechaNew.addDays(1);
                    }
                }
            }
            System.debug(diasPorLicenciaNoFestivo.keySet().size());
            System.debug(diasPorLicenciaFestivos.keySet().size());
            System.debug(diasPorLicenciaUnicos.keySet().size());
            efectividad.Dias_de_Licencia_Transcurridos__c = diasPorLicenciaNoFestivo.keySet().size();
            efectividad.Dias_feriados_Transcurridos__c = diasPorLicenciaFestivos.keySet().size();
            efectividad.VisMed_Dias_de_Licencia_Unicos__c = diasPorLicenciaUnicos.keySet().size();
        }
        update efectividadesToUpdate.values();
    }
    
    public static void createNotification (List<Dan360_Licencia__c> licencias) {
        List<Notificacion__c> notificaciones = new List<Notificacion__c>();
        String titulo;
        String cuerpo;
        String redireccion;
        Id recordTypeTNP = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
        for (Dan360_Licencia__c objeto : licencias) {
            if (objeto.RecordTypeId != recordTypeTNP) {
                titulo = objeto.Estado__c == 'Aprobada' ? 'Su Licencia fue APROBADA' : 'Su Licencia fue RECHAZADA';
                cuerpo = objeto.Estado__c == 'Aprobada' ? 'Aprobada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Motivo de ausencia: ' + objeto.Motivo__c : 'Rechazada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c;
                redireccion = 'licencias';
            } else {
                titulo = objeto.Estado__c == 'Aprobada' ? 'Su Tiempo no Promocional fue APROBADO' : 'Su Tiempo no Promocional fue RECHAZADO';
                cuerpo = objeto.Estado__c == 'Aprobada' ? 'Aprobado por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Motivo de ausencia: ' + objeto.Motivo__c : 'Rechazado por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c;
                redireccion = 'tnp';
            }
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
        insert notificaciones;
    }
    
}