/**
 * @description       : 
 * @author            : sebastian.fondovila@globant.com
 * @group             : 
 * @last modified on  : 09-13-2022
 * @last modified by  : sebastian.fondovila@globant.com
**/
public with sharing class ficheroController {

    @AuraEnabled(cacheable=true)
    public static List<User> getSupervisores () {
        List<User> supervisores = [SELECT Id, Name, ContactId FROM User WHERE Profile.Name  = 'Supervisores' AND IsActive = TRUE ORDER BY Name];
        return supervisores;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUserList (List<Id> supervisores) {
        List<User> users;
        if (supervisores.size() > 0) {
            users = [SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True AND ManagerId IN :supervisores ORDER BY Name];
        } else {
            users = [SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True ORDER BY Name];
        }
        System.debug('users');
        System.debug(users);
        Return users;
    }
    @AuraEnabled(cacheable=true)
    public static List<User> getUserApm (List<Id> apms) {
        List<User> usersApms = new List<User>();
        if (apms.size() > 0) {
            usersApms = [SELECT Id FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True AND ContactId IN :apms ORDER BY Name];        
            System.debug('usersApms');
            System.debug(usersApms);
        }
        Return usersApms;            
    }
    @AuraEnabled(cacheable=true)
    public static List<AccountTeamMember> getAccountTeam (List<Id> users) {
        List<AccountTeamMember> accountTeam = new List<AccountTeamMember>();
        if (users.size() > 0) {
            accountTeam = [SELECT AccountId FROM AccountTeamMember WHERE UserId in :users];        
            System.debug('accountTeam');
            System.debug(accountTeam);
        }
        Return accountTeam;            
    }

    @AuraEnabled(cacheable=true)
    public static String getData (List<String> usuariosHabiles, List<String> usuariosSeleccionados, String profesional, String institucionSeleccionada, String ultimaVisita, String especialidad, String provincia, String localidad, String codigoPostal) {
        List<FicheroWrapper> data = new List<FicheroWrapper>();
        System.debug('usuariosHabiles');
        System.debug(usuariosHabiles);
        String querySeguimiento;
        String condicionSeguimiento = ' (Estado__c = ' + '\'' + 'Activo' + '\' OR Estado__c = ' + '\'' + 'Baja Temporal' + '\')';
        String queryEquipos;
        String condicionEquipos = '';
        
        String usersList;
        if (!usuariosSeleccionados.isEmpty()) {
            for (String user : usuariosSeleccionados) {
                if (String.isNotBlank(usersList)) {
                    usersList += ', ' + '\'' + user + '\'';
                } else {
                    usersList = '(' + '\'' + user + '\'';
                }
            }
        } else if (!usuariosHabiles.isEmpty()) {
            for (String user : usuariosHabiles) {
                if (String.isNotBlank(usersList)) {
                    usersList += ', ' + '\'' + user + '\'';
                } else {
                    usersList = '(' + '\'' + user + '\'';
                }
            }
        }
        usersList += ')';

        if (String.isNotBlank(ultimaVisita)) {    
            //List<VisMed_Contacto_Cuenta_Usuario__c> listaAuxiliar = new List<VisMed_Contacto_Cuenta_Usuario__c>();      
            switch on ultimaVisita {
                when '30' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:30 AND Ultima_Visita__c = LAST_N_DAYS:45';
                }
                when '45' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:45 AND Ultima_Visita__c = LAST_N_DAYS:60';
                }
                when '60' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:60 AND Ultima_Visita__c = LAST_N_DAYS:90';
                }
                when '90' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:90 AND Ultima_Visita__c = LAST_N_DAYS:180';
                }
                when '180' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:180 AND Ultima_Visita__c = LAST_N_DAYS:365';
                }
                when '365' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:365';
                }
            }
        }

        condicionSeguimiento += (String.isNotBlank(ultimaVisita) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + condicionEquipos : '');
        condicionSeguimiento += (String.isNotBlank(usersList) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' VisMed_APM__c IN ' + usersList : '');
        condicionSeguimiento += (String.isNotBlank(profesional) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Profesional__c = \'' + profesional + '\'' : '');
        condicionSeguimiento += (String.isNotBlank(institucionSeleccionada) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__c = \'' + institucionSeleccionada + '\'' : '');
        condicionSeguimiento += (String.isNotBlank(especialidad) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Profesional__r.Primera_especialidad__c = \'' + especialidad + '\'' : '');
        //condicionSeguimiento += (String.isNotBlank(provincia) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__r.Provincia__c = \'' + provincia + '\'' : '');
        //condicionSeguimiento += (String.isNotBlank(localidad) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__r.Localidad__c = \'' + localidad + '\'' : '');
        //condicionSeguimiento += (String.isNotBlank(codigoPostal) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__r.Codigo_postal__c = \'' + codigoPostal + '\'' : '');
        condicionSeguimiento += (String.isNotBlank(provincia) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__r.BillingState = \'' + provincia + '\'' : '');
        condicionSeguimiento += (String.isNotBlank(localidad) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__r.BillingCity = \'' + localidad + '\'' : '');
        condicionSeguimiento += (String.isNotBlank(codigoPostal) ? (String.isNotBlank(condicionSeguimiento) ? + ' AND ' : '') + ' Institucion__r.BillingPostalCode = \'' + codigoPostal + '\'' : '');

        if (String.isNotBlank(condicionSeguimiento)) {
            querySeguimiento = 'SELECT Id, Name, Profesional__c, Institucion__c, Ultima_Visita__c, VisMed_APM__c, Predeterminada__c, Estado__c, OwnerId, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE ' +
            condicionSeguimiento;
        } else {
            querySeguimiento = 'SELECT Id, Name, Profesional__c, Institucion__c, Ultima_Visita__c, VisMed_APM__c, Predeterminada__c, Estado__c, OwnerId, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c ';
        }
        System.debug('@@QUERT SEGUIMIENTOS ' + querySeguimiento);
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = Database.query(querySeguimiento);
        System.debug('seguimientos');
        System.debug(seguimientos);
        /*if (String.isNotBlank(ultimaVisita)) {    
            List<VisMed_Contacto_Cuenta_Usuario__c> listaAuxiliar = new List<VisMed_Contacto_Cuenta_Usuario__c>();      
            switch on ultimaVisita {
                when '30' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:30 AND Ultima_Visita__c = LAST_N_DAYS:45';
                }
                when '45' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:45 AND Ultima_Visita__c = LAST_N_DAYS:60';
                }
                when '60' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:60 AND Ultima_Visita__c = LAST_N_DAYS:90';
                }
                when '90' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:90 AND Ultima_Visita__c = LAST_N_DAYS:180';
                }
                when '180' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:180 AND Ultima_Visita__c = LAST_N_DAYS:365';
                }
                when '365' {
                    condicionEquipos = ' Ultima_Visita__c < LAST_N_DAYS:365';
                }
            }
            queryEquipos = 'SELECT Id, AccountId, UserId, Ultima_Visita__c, Dan360_Areas_Terapeuticas__c FROM AccountTeamMember WHERE ' + condicionEquipos;
            System.debug(queryEquipos);
            List<AccountTeamMember> equipos = Database.query(queryEquipos);
            for (AccountTeamMember equipo : equipos) {
                for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                    if (equipo.AccountId == seguimiento.Profesional__c && equipo.UserId == seguimiento.OwnerId) {
                        listaAuxiliar.add(seguimiento);
                    }
                }
            }
            seguimientos = listaAuxiliar;
        }*/

        //List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, Name, Profesional__c, Institucion__c, Ultima_Visita__c, VisMed_APM__c, Predeterminada__c, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        Map<Id,Map<Id,List<Id>>> mapaAPMxProfesionalesXInstituciones = new Map<Id,Map<Id,List<Id>>>();
        List<Id> profesionalesId = new List<Id>();
        List<Id> institucionesId = new List<Id>();
        System.debug('@@LST seguimientos ' + seguimientos);

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profesionalesId.add(seguimiento.Profesional__c);
            institucionesId.add(seguimiento.Institucion__c);
            Map<Id,List<Id>> profesionalXInstituciones = mapaAPMxProfesionalesXInstituciones.containsKey(seguimiento.VisMed_APM__c) ? mapaAPMxProfesionalesXInstituciones.get(seguimiento.VisMed_APM__c) : new Map<Id,List<Id>>(); 
            List<Id> instituciones = profesionalXInstituciones.containsKey(seguimiento.Profesional__c) ? profesionalXInstituciones.get(seguimiento.Profesional__c) : new List<Id>();
            instituciones.add(seguimiento.Institucion__c);
            profesionalXInstituciones.put(seguimiento.Profesional__c, instituciones);
            mapaAPMxProfesionalesXInstituciones.put(seguimiento.VisMed_APM__c, profesionalXInstituciones);
        }
        for(id ids : profesionalesId){
            System.debug('ids');
            System.debug(ids);
        }
        
        Map<Id, Account> profesioanlesMap = new Map<Id, Account>([SELECT Id, Name, Primera_especialidad__c FROM Account WHERE Id IN :profesionalesId]);
        System.debug('profesioanlesMap');
        for(Id key : profesioanlesMap.keySet()){
            System.debug(key);
            System.debug(profesioanlesMap.get(key));
        }
        
        Map<Id, Account> institucionesMap = new Map<Id, Account>([SELECT Id, Name, Provincia__c, Localidad__c, Codigo_postal__c, BillingState, BillingCity, BillingPostalCode FROM Account WHERE Id IN :institucionesId]);
        Id recordTypeMatriculaNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
        Map<Id, Dan360_Matricula__c> matriculasXProfesional = new Map<Id, Dan360_Matricula__c>();
        List<Dan360_Matricula__c> matriculas = [SELECT Id, Name, RecordTypeId, Provincia__c, Numero_de_matricula__c, Profesional__c, Municipios__c FROM Dan360_Matricula__c WHERE Profesional__c IN :profesionalesId AND RecordTypeId = :recordTypeMatriculaNacional];
        System.debug(matriculas);
        for (Dan360_Matricula__c matricula : matriculas) {
            matriculasXProfesional.put(matricula.Profesional__c, matricula);
        }
        System.debug(matriculasXProfesional);

        for (Id APM : mapaAPMxProfesionalesXInstituciones.keySet()) {
            String apmId = APM;
                for (Id profesionalId : mapaAPMxProfesionalesXInstituciones.get(APM).keySet()) {
                    System.debug(profesionalId);
                    List<InstitucionesWrapper> instituciones = new List<InstitucionesWrapper>();
                    FicheroWrapper fichero = new FicheroWrapper();
                    fichero.mostrar = false;
                    fichero.apm = apmId;
                    fichero.idFichero = apmId + '-' + profesionalId;
                    fichero.profesionalId = profesionalId;
                    fichero.profesional = profesioanlesMap.get(profesionalId).Name;
                    fichero.profesionalURL = '/' + profesionalId;
                    if (matriculasXProfesional.containsKey(profesionalId)) {
                        fichero.matricula = matriculasXProfesional.get(profesionalId).Numero_de_matricula__c;
                        fichero.matriculaURL = '/' + matriculasXProfesional.get(profesionalId).Id;
                    }
                    fichero.especialidad = profesioanlesMap.get(profesionalId).Primera_especialidad__c;
                    for (Id institucionId : mapaAPMxProfesionalesXInstituciones.get(APM).get(profesionalId)) {
                        InstitucionesWrapper institucion = new InstitucionesWrapper();
                        institucion.idInstitucion = institucionId;
                        institucion.institucion = institucionesMap.get(institucionId).Name;
                        institucion.institucionURL = '/' + institucionId;
                        // institucion.provincia = institucionesMap.get(institucionId).Provincia__c;
                        // institucion.localidad = institucionesMap.get(institucionId).Localidad__c;
                        // institucion.codigoPostal = institucionesMap.get(institucionId).Codigo_postal__c;
                        institucion.provincia = institucionesMap.get(institucionId).BillingState;
                        institucion.localidad = institucionesMap.get(institucionId).BillingCity;
                        institucion.codigoPostal = institucionesMap.get(institucionId).BillingPostalCode;
                        instituciones.add(institucion);
                    }
                    fichero.instituciones = instituciones;
                    data.add(fichero);
                }
        }
        return JSON.serialize(data);
    }

    @AuraEnabled
    public static Boolean transferirProfesional (Map<String, List<String>> ficheros, List<String> apms, String comentario) {
        System.debug('****ficheros: ' + ficheros);
        System.debug(apms);
        Map<Id, Contact> mapaApm = new Map<Id, Contact>([SELECT Id, Sub_Equipo__c FROM Contact WHERE Id IN :apms]);
        System.debug(mapaApm);
        List<VisMed_Bajas__c> newBajas = new List<VisMed_Bajas__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosToUpsert = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();

        seguimientos = [SELECT Id, Profesional__c, Institucion__c, VisMed_APM__c, Segmenta_Por__c, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE VisMed_APM__c IN :apms ];

        //Logica para agregar el TIPO__C
        List<String> profesionales = new List<String>();
        List<String> apmss = new List<String>();
        List<String> instituciones = new List<String>();
        for (String fichero : ficheros.keySet()) {
            profesionales.add(fichero.substringAfter('-'));
            apmss.add(fichero.substringBefore('-'));
            instituciones.addall(ficheros.get(fichero));
        }
    
        Map<String,Map<String, Map<String,String>>> mapInstitucionProfesionalApm = new  Map<String,Map<String, Map<String,String>>>();
        Map<String,Map<String, Map<String,Boolean>>> mapInstitucionProfesionalApmPredeterminado = new  Map<String,Map<String, Map<String,Boolean>>>();

        for(VisMed_Contacto_Cuenta_Usuario__c segmentacionSF : [SELECT id, Profesional__c, Institucion__c, VisMed_APM__c, Tipo__c, Predeterminada__c FROM VisMed_Contacto_Cuenta_Usuario__c 
                                                                WHERE Profesional__c IN: profesionales
                                                                    AND Institucion__c IN :instituciones 
                                                                    AND VisMed_APM__c IN :apmss]){
            if(!mapInstitucionProfesionalApm.containsKey(segmentacionSF.Institucion__c)){
                mapInstitucionProfesionalApm.put(segmentacionSF.Institucion__c, new Map<String, Map<String,String>>());
            }
            if(!mapInstitucionProfesionalApm.get(segmentacionSF.Institucion__c).containsKey(segmentacionSF.Profesional__c)){
                mapInstitucionProfesionalApm.get(segmentacionSF.Institucion__c).put(segmentacionSF.Profesional__c, new Map<String,String>());
            }
            if(!mapInstitucionProfesionalApm.get(segmentacionSF.Institucion__c).get(segmentacionSF.Profesional__c).containsKey(segmentacionSF.VisMed_APM__c)){
                mapInstitucionProfesionalApm.get(segmentacionSF.Institucion__c).get(segmentacionSF.Profesional__c).put(segmentacionSF.VisMed_APM__c, segmentacionSF.Tipo__c);
            }
            if(!mapInstitucionProfesionalApmPredeterminado.containsKey(segmentacionSF.Institucion__c)){
                mapInstitucionProfesionalApmPredeterminado.put(segmentacionSF.Institucion__c, new Map<String, Map<String,Boolean>>());
            }
            if(!mapInstitucionProfesionalApmPredeterminado.get(segmentacionSF.Institucion__c).containsKey(segmentacionSF.Profesional__c)){
                mapInstitucionProfesionalApmPredeterminado.get(segmentacionSF.Institucion__c).put(segmentacionSF.Profesional__c, new Map<String,Boolean>());
            }
            if(!mapInstitucionProfesionalApmPredeterminado.get(segmentacionSF.Institucion__c).get(segmentacionSF.Profesional__c).containsKey(segmentacionSF.VisMed_APM__c)){
                mapInstitucionProfesionalApmPredeterminado.get(segmentacionSF.Institucion__c).get(segmentacionSF.Profesional__c).put(segmentacionSF.VisMed_APM__c, segmentacionSF.Predeterminada__c);
            }
        }

        //// TERMINA Logica para agregar el TIPO__C

        System.debug('****size: ' + seguimientos.size());
        System.debug('@@seguimientos: ' + seguimientos);
        System.debug('@@ficheros: ' + ficheros);
        for (String fichero : ficheros.keySet()) {
            VisMed_Bajas__c newBaja = new VisMed_Bajas__c(
                Profesional__c = fichero.substringAfter('-'),
                VisMed_APM__c = fichero.substringBefore('-'),
                RecordTypeId = recordTypeBajaProfesional,
                Fecha_de_Desactivacion__c = System.Today(),
                Estado__c = 'Aprobada',
                Motivo_de_la_Baja__c = 'Transferido a otro Visitador',
                Comentario__c = comentario               
            );
            System.debug('@@newBaja: ' + newBaja);
            
            for (String institucion : ficheros.get(fichero)) {
                Map<String, Map<String,String>> mapProfesionalApmTipo = mapInstitucionProfesionalApm.get(institucion);
                String tipo =  mapInstitucionProfesionalApm.get(institucion).get(fichero.substringAfter('-')).get(fichero.substringBefore('-'));
                Boolean predeterminada = mapInstitucionProfesionalApmPredeterminado.get(institucion).get(fichero.substringAfter('-')).get(fichero.substringBefore('-'));
                for (String apm : apms) {
                    VisMed_Contacto_Cuenta_Usuario__c seguimientoAux = new VisMed_Contacto_Cuenta_Usuario__c(
                        Profesional__c = fichero.substringAfter('-'),
                        Institucion__c = institucion,
                        VisMed_APM__c = apm,
                        Estado__c = 'Activo',
                        Tipo__c = tipo,
                        Motivo_de_la_Baja__c = '',
                        Predeterminada__c = predeterminada
                        );
                        String subEquipo = mapaApm.get(apm).Sub_Equipo__c.substringBefore(';');
                        if (subEquipo == 'Adultos General') {
                            seguimientoAux.Segmenta_Por__c = 'Adultos General Institucion';
                        }
                        if (subEquipo == 'Adultos Oncologia') {
                            seguimientoAux.Segmenta_Por__c = 'Adultos Oncologia';
                        }
                        if (subEquipo == 'Metabolicos') {
                            seguimientoAux.Segmenta_Por__c = 'Metabolicos';
                        }
                        if (subEquipo == 'Dieta') {
                            seguimientoAux.Segmenta_Por__c = 'Epilepsia';
                        }
                        if (subEquipo == 'Metabólicos y Dieta') {
                            seguimientoAux.Segmenta_Por__c = 'Metabolicos y Epilepsia';
                        }
                        if (subEquipo == 'Pediatricos General') {
                            seguimientoAux.Segmenta_Por__c = 'Pediatricos General';
                        }
                        if (subEquipo == 'Alergia') {
                            seguimientoAux.Segmenta_Por__c = 'Alergia';
                        }
                        seguimientosToUpsert.add(seguimientoAux);
                        // se coloca en la baja a que apm fue transferido
                        newBaja.Transferido_a__c = apm;
                }     
            }
            newBajas.add(newBaja);
                
        }
        insert newBajas;

        for (VisMed_Contacto_Cuenta_Usuario__c seguimientoToUpsert : seguimientosToUpsert) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (seguimientoToUpsert.Profesional__c == seguimiento.Profesional__c && seguimientoToUpsert.Institucion__c == seguimiento.Institucion__c && seguimientoToUpsert.VisMed_APM__c == seguimiento.VisMed_APM__c) {
                    seguimientoToUpsert.Id = seguimiento.Id;
                }
            }
        }

        System.debug('****size: ' + seguimientosToUpsert.size());
        System.debug('setgTest');
        for(VisMed_Contacto_Cuenta_Usuario__c setgTest :seguimientosToUpsert){
            System.debug(setgTest);
            System.debug(setgTest.Tipo__c);
            System.debug(setgTest.Predeterminada__c);
        }
        System.debug('****seguimientosToUpsert: ' + seguimientosToUpsert);
        upsert seguimientosToUpsert;

        return true;
    }

    @AuraEnabled
    public static Boolean compartirProfesional (Map<String, List<String>> ficheros, List<String> apms, String comentario) {
        Map<Id, Contact> mapaApm = new Map<Id, Contact>([SELECT Id, Sub_Equipo__c FROM Contact WHERE Id IN :apms]);
        System.debug(mapaApm);
        List<VisMed_Bajas__c> newBajas = new List<VisMed_Bajas__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosToUpsert = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();

        seguimientos = [SELECT Id, Profesional__c, Institucion__c, VisMed_APM__c, Segmenta_Por__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE VisMed_APM__c IN :apms ];
        System.debug(seguimientos);

        for (String fichero : ficheros.keySet()) {
            for (String institucion : ficheros.get(fichero)) {
                for (String apm : apms) {
                    VisMed_Contacto_Cuenta_Usuario__c seguimientoAux = new VisMed_Contacto_Cuenta_Usuario__c(
                        Profesional__c = fichero.substringAfter('-'),
                        Institucion__c = institucion,
                        VisMed_APM__c = apm,
                        Estado__c = 'Activo',
                        Comentario_de_Aprobacion__c = comentario
                    );
                    String subEquipo = mapaApm.get(apm).Sub_Equipo__c.substringBefore(';');
                    if (subEquipo == 'Adultos General') {
                        seguimientoAux.Segmenta_Por__c = 'Adultos General Institucion';
                    }
                    if (subEquipo == 'Adultos Oncologia') {
                        seguimientoAux.Segmenta_Por__c = 'Adultos Oncologia';
                    }
                    if (subEquipo == 'Metabolicos') {
                        seguimientoAux.Segmenta_Por__c = 'Metabolicos';
                    }
                    if (subEquipo == 'Dieta') {
                        seguimientoAux.Segmenta_Por__c = 'Epilepsia';
                    }
                    if (subEquipo == 'Pediatricos General') {
                        seguimientoAux.Segmenta_Por__c = 'Pediatricos General';
                    }
                    if (subEquipo == 'Alergia') {
                        seguimientoAux.Segmenta_Por__c = 'Alergia';
                    }
                    seguimientosToUpsert.add(seguimientoAux);
                }     
            }               
        }

        System.debug(seguimientosToUpsert);

        for (VisMed_Contacto_Cuenta_Usuario__c seguimientoToUpsert : seguimientosToUpsert) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (seguimientoToUpsert.Profesional__c == seguimiento.Profesional__c && seguimientoToUpsert.Institucion__c == seguimiento.Institucion__c && seguimientoToUpsert.VisMed_APM__c == seguimiento.VisMed_APM__c) {
                    seguimientoToUpsert.Id = seguimiento.Id;
                }
            }
        }

        System.debug(seguimientosToUpsert);
        List<String> idseg = new List<String>();
        for(VisMed_Contacto_Cuenta_Usuario__c id : seguimientosToUpsert){
            idseg.add(id.id);
        }
        System.debug(idseg);
        upsert seguimientosToUpsert;

        return true;
    }

    @AuraEnabled
    public static Boolean bajaProfesional (Map<String, List<String>> ficheros, String comentario, Date fechaDesactivacion, Date fechaReactivacion, String motivoDeBaja) {
        List<VisMed_Bajas__c> newBajas = new List<VisMed_Bajas__c>();
        Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        System.debug(ficheros);
        for (String fichero : ficheros.keySet()) {
            VisMed_Bajas__c newBaja = new VisMed_Bajas__c(
                Profesional__c = fichero.substringAfter('-'),
                VisMed_APM__c = fichero.substringBefore('-'),
                RecordTypeId = recordTypeBajaProfesional,
                Fecha_de_Desactivacion__c = fechaDesactivacion,
                Fecha_de_Reactivacion__c = fechaReactivacion,
                Estado__c = 'Aprobada',
                Motivo_de_la_Baja__c = motivoDeBaja,
                Comentario__c = comentario
            );
            newBajas.add(newBaja);
        }
        System.debug(newBajas);
        insert newBajas;                

        return true;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getMetadataInfo(String MtdLabel){
        System.debug(MtdLabel);
        Configuracion_de_motivos_para_la_Baja__mdt aMtd = [SELECT Id, Baja_Temporal__c
            FROM Configuracion_de_motivos_para_la_Baja__mdt
            WHERE Label = :MtdLabel
            LIMIT 1];
        System.debug(aMtd.Baja_Temporal__c);
            return aMtd.Baja_Temporal__c;
            
    }
    
    @testVisible
    private class FicheroWrapper {
        @AuraEnabled
        public Boolean mostrar                         {get;set;}
        @AuraEnabled
        public String idFichero                         {get;set;}
        @AuraEnabled
        public String apm                               {get;set;}
        @AuraEnabled
        public String profesionalId                       {get;set;}
        @AuraEnabled
        public String profesional                       {get;set;}
        @AuraEnabled
        public String profesionalURL                    {get;set;}
        @AuraEnabled
        public String matricula                         {get;set;}
        @AuraEnabled
        public String matriculaURL                     {get;set;}
        @AuraEnabled
        public String especialidad                     {get;set;}
        @AuraEnabled
        public List<InstitucionesWrapper> instituciones {get;set;}
    }

    private class InstitucionesWrapper {
        @AuraEnabled
        public String idInstitucion     {get;set;}
        @AuraEnabled
        public String institucion       {get;set;}
        @AuraEnabled
        public String institucionURL    {get;set;}
        @AuraEnabled
        public String provincia         {get;set;}
        @AuraEnabled
        public String localidad         {get;set;}
        @AuraEnabled
        public String codigoPostal      {get;set;}
    }

}