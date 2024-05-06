public without sharing class BajasTriggerHelper {
    private static Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
    /*public static void desvincularProfesional (List<VisMed_Bajas__c> bajasSolicitadas) {
        //Borrar Seguimiento.
        //Borrar Lugar de Trabajo.
        //Desactivar Profesional.
        List<Id> profesionalesParaDesactivar = new List<Id>(); // Profesionales que solo se desvincularan para un APM en particular
        List<Id> profesionalesParaDesactivarATodosLosAPM = new List<Id>(); // Profesionales que se desactivaran para todos los APMs
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Id> APMVinculadosAProfesionalesDesactivados = new List<Id>(); // APM al cual se le desvinculara un Profesional
        List<Id> APMVinculadosAProfesionalesDesactivadosATodosLosAPM = new List<Id>(); // Lista de APM vinculados a los profesionales de la lista profesionalesParaDesactivarATodosLosAPM
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosADesactivarDelAPM = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosADesactivarDeTodosLosAPM = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        list<VisMed_Contacto_Cuenta_Usuario__c> seguimientosToUpdate = new list<VisMed_Contacto_Cuenta_Usuario__c>();
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Dan360_Lugar_de_Trabajo__c> lugaresDeTrabajoAEliminar = new List<Dan360_Lugar_de_Trabajo__c>();
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        Map<Id, Configuracion_de_motivos_para_la_Baja__mdt> mtdBaja = new Map<Id, Configuracion_de_motivos_para_la_Baja__mdt>([SELECT Label, Baja_Total__c, Baja_Temporal__c FROM Configuracion_de_motivos_para_la_Baja__mdt]);
        Map<String, Configuracion_de_motivos_para_la_Baja__mdt> motivoParaLaBaja = new Map<String, Configuracion_de_motivos_para_la_Baja__mdt>();

        for(String accName: mtdBaja.keySet()){
            motivoParaLaBaja.put(mtdBaja.get(accName).Label, mtdBaja.get(accName));
        }
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        for (VisMed_Bajas__c baja : bajasSolicitadas) {
            if (motivoParaLaBaja.get(baja.Motivo_de_la_Baja__c).Baja_Temporal__c) {
               profesionalesParaDesactivar.add(baja.Profesional__c);
               APMVinculadosAProfesionalesDesactivados.add(baja.VisMed_APM__c);
            } 
            if (motivoParaLaBaja.get(baja.Motivo_de_la_Baja__c).Baja_Total__c){                
                profesionalesParaDesactivarATodosLosAPM.add(baja.Profesional__c);
                APMVinculadosAProfesionalesDesactivadosATodosLosAPM.add(baja.VisMed_APM__c);
            }
        }
        Map<Id,User> UsuarioDeLosAPM = new  Map<Id,User>([SELECT Id FROM User WHERE ContactId IN :APMVinculadosAProfesionalesDesactivadosATodosLosAPM]);
        //Map<Id,AccountTeamMember> accountTeamMemberAEliminar = new Map<Id,AccountTeamMember>([SELECT Id FROM AccountTeamMember WHERE AccountId IN :profesionalesParaDesactivar AND UserId IN :UsuarioDeLosAPM.keySet()]);
        Map<Id,AccountTeamMember> accountTeamMemberAEliminarDeTodosLosAPM = new Map<Id,AccountTeamMember>([SELECT Id FROM AccountTeamMember WHERE AccountId IN :UsuarioDeLosAPM.keySet()]);
        seguimientosADesactivarDelAPM = [SELECT Id, Profesional__c, VisMed_APM__c, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE Profesional__c IN :profesionalesParaDesactivar AND VisMed_APM__c IN :APMVinculadosAProfesionalesDesactivados];
        seguimientosADesactivarDeTodosLosAPM = [SELECT Id, Profesional__c, VisMed_APM__c, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE Profesional__c IN :profesionalesParaDesactivarATodosLosAPM];
        lugaresDeTrabajoAEliminar = [SELECT Id FROM Dan360_Lugar_de_Trabajo__c WHERE Profesional__c IN :profesionalesParaDesactivarATodosLosAPM];

        seguimientosToUpdate.addAll(seguimientosADesactivarDelAPM);
        seguimientosToUpdate.addAll(seguimientosADesactivarDeTodosLosAPM);

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientosToUpdate) {
            for (VisMed_Bajas__c baja : bajasSolicitadas) {
                if ((baja.Profesional__c == seguimiento.Profesional__c) && (motivoParaLaBaja.get(baja.Motivo_de_la_Baja__c).Baja_Temporal__c) && (!motivoParaLaBaja.get(baja.Motivo_de_la_Baja__c).Baja_Total__c))  {
                    seguimiento.Estado__c = 'Baja Temporal';
                } else if ((baja.Profesional__c == seguimiento.Profesional__c) && (motivoParaLaBaja.get(baja.Motivo_de_la_Baja__c).Baja_Total__c) && (!motivoParaLaBaja.get(baja.Motivo_de_la_Baja__c).Baja_Temporal__c))  {
                    seguimiento.Estado__c = 'Inactivo';
                }
            }
        }
        
        update seguimientosToUpdate;

        List<Account> profesionales = [SELECT Id, Profesional_Activo__c FROM Account WHERE Id IN :profesionalesParaDesactivarATodosLosAPM];
        for (Account profesional : profesionales) {
            profesional.Profesional_Activo__c = false;
        }
        update profesionales;
        
        System.debug('account APM Member: '+accountTeamMemberAEliminarDeTodosLosAPM.values());
        delete accountTeamMemberAEliminarDeTodosLosAPM.values();
        System.debug('Lugares de trabajo: '+lugaresDeTrabajoAEliminar );
        delete lugaresDeTrabajoAEliminar;
    }*/


    public static void checkDuplicates(List<VisMed_Bajas__c> bajas){
        Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        Id recordTypeBajaOtroProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId();
        Id recordTypeBajaSeguimiento = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Seguimiento').getRecordTypeId();
        List<VisMed_Bajas__c> bajasProfesionales = new List<VisMed_Bajas__c>();
        List<VisMed_Bajas__c> bajasInstituciones = new List<VisMed_Bajas__c>();
        List<String> profesionalesIds = new List<String>();
        List<String> institucionesIds = new List<String>();
        List<String> apmIds = new List<String>();

        for(VisMed_Bajas__c baja : bajas){
            if(baja.RecordTypeId == recordTypeBajaProfesional || baja.RecordTypeId == recordTypeBajaOtroProfesional){
                profesionalesIds.add(baja.Profesional__c);
                apmIds.add(baja.VisMed_APM__c);
                bajasProfesionales.add(baja);
            }
            if(baja.RecordTypeId == recordTypeBajaSeguimiento){
                bajasInstituciones.add(baja);
                profesionalesIds.add(baja.Profesional__c);
                apmIds.add(baja.VisMed_APM__c);
                institucionesIds.add(baja.Institucion__c);
            }
        }

        if(!bajasProfesionales.isEmpty()){
            checkDuplicatesProfesionales(bajasProfesionales,profesionalesIds,apmIds);
        }
        if(!bajasInstituciones.isEmpty()){
            checkDuplicatesInstituciones(bajasInstituciones,profesionalesIds,apmIds,institucionesIds);
        }
    }

    public static void checkDuplicatesProfesionales(List<VisMed_Bajas__c> bajas, List<String> profesionalesIds,  List<String> apmIds){
        Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        Id recordTypeBajaOtroProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId();

        List<MotivosWrapper> motivosWrapper = new List<MotivosWrapper>();
        List<Configuracion_de_motivos_para_la_Baja__mdt> motivosDeBaja = [SELECT Label, Baja_Total__c, Baja_Temporal__c FROM Configuracion_de_motivos_para_la_Baja__mdt];
        Map<VisMed_Bajas__c, String> mapTipoBaja = new Map<VisMed_Bajas__c, String>();
        //Se arma un mapa con la baja y el tipo de baja
        for (Configuracion_de_motivos_para_la_Baja__mdt motivo : motivosDeBaja) {
            MotivosWrapper motivoWrapper = new MotivosWrapper(
                motivo.Label,
                motivo.Baja_Temporal__c,
                motivo.Baja_Total__c
            );
            
            motivosWrapper.add(motivoWrapper);
        }
        
        for(VisMed_Bajas__c baja : bajas) {
            for (MotivosWrapper motivo : motivosWrapper) {
                if (baja.Motivo_de_la_Baja__c == motivo.Label) {
                    if (motivo.total && motivo.temporal) {
                        mapTipoBaja.put(baja,'Temporal');
                    } else if (motivo.total && !motivo.temporal) {
                        mapTipoBaja.put(baja,'Total');
                    } else if (!motivo.total && motivo.temporal) {
                        mapTipoBaja.put(baja,'Temporal');
                    } else if (!motivo.total && !motivo.temporal) {
                        mapTipoBaja.put(baja,'Total');
                    }
                }
            }
        }
        
        //Se arma un mapa del APM, Profesional y Baja de las bajas de salesforce
        Map<String, Map<String, List<VisMed_Bajas__c>>> mapApmProfesionalBaja = new Map<String, Map<String, List<VisMed_Bajas__c>>>();

        for(VisMed_Bajas__c baja : [SELECT Id, Estado__c , Profesional__c, VisMed_APM__c, Fecha_de_Desactivacion__c, Fecha_de_Reactivacion__c, CreatedDate 
                                    FROM VisMed_Bajas__c 
                                        WHERE (Estado__c = 'Aprobada' OR Estado__c = 'Pendiente') 
                                            AND VisMed_APM__c IN :apmIds 
                                            AND Profesional__c IN :profesionalesIds
                                            AND (RecordTypeId = :recordTypeBajaProfesional OR RecordTypeId = :recordTypeBajaOtroProfesional)
                                        ORDER BY Fecha_de_Desactivacion__c ASC
                                    ]){
            if(!mapApmProfesionalBaja.containsKey(baja.VisMed_APM__c)){
                mapApmProfesionalBaja.put(baja.VisMed_APM__c, new Map<String, List<VisMed_Bajas__c>>());
            }
            if(!mapApmProfesionalBaja.get(baja.VisMed_APM__c).containsKey(baja.Profesional__c)){
                mapApmProfesionalBaja.get(baja.VisMed_APM__c).put(baja.Profesional__c, new List<VisMed_Bajas__c>());
            }
            mapApmProfesionalBaja.get(baja.VisMed_APM__c).get(baja.Profesional__c).add(baja);
        }
        for(VisMed_Bajas__c baja : mapTipoBaja.keySet()){
            System.debug('baja');
            System.debug(baja);
            System.debug('motivo');
            System.debug(mapTipoBaja.get(baja));
        }
        
        System.debug('mapApmProfesionalBaja');
        System.debug(mapApmProfesionalBaja);
        //Por cada baja a comparar, se busca si tiene otra para el mismo APM - Profesional
        for(VisMed_Bajas__c baja : bajas){
            String motivo = mapTipoBaja.get(baja);
            
            if(mapApmProfesionalBaja.containsKey(baja.VisMed_APM__c)){
                if(mapApmProfesionalBaja.get(baja.VisMed_APM__c).containsKey(baja.Profesional__c)){
                    List<VisMed_Bajas__c> bajasSF = mapApmProfesionalBaja.get(baja.VisMed_APM__c).get(baja.Profesional__c);
                    for(VisMed_Bajas__c bajaSF : bajasSF){
                        Date fechaSF = date.newinstance(bajaSF.CreatedDate.year(), bajaSF.CreatedDate.month(), bajaSF.CreatedDate.day());
                        Date fechaBaja = Date.today();
                        System.debug(fechaSF);
                        System.debug(fechaBaja);
                        if(motivo == 'Total' && fechaSF == fechaBaja){ // Si es total y coinciden las fechas arroja error, ya que no puede cargarse mas de una baja total el mismo dia.
                            baja.addError('Baja TOTAL duplicada');
                        } else {
                            if(bajaSF.Fecha_de_Reactivacion__c != null && motivo == 'Temporal'){
                                System.debug('Baj SF temporal');
                                System.debug(bajaSF);
                                if((baja.Fecha_de_Desactivacion__c < bajaSF.Fecha_de_Desactivacion__c && baja.Fecha_de_Reactivacion__c > bajaSF.Fecha_de_Desactivacion__c) || // Si la fecha de la baja insertada empieza antes y terrmina sobre la fecha de la baja ya cargada
                                    (baja.Fecha_de_Desactivacion__c >= bajaSF.Fecha_de_Desactivacion__c && baja.Fecha_de_Desactivacion__c < bajaSF.Fecha_de_Reactivacion__c) // Si la fecha de la baja insertada inicia dentro del rango de la fecha de la baja ya cargada
                                ){
                                    baja.addError('Ya hay una baja temporal con fechas similares');
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    public static void checkDuplicatesInstituciones(List<VisMed_Bajas__c> bajas, List<String> profesionalesIds,  List<String> apmIds, List<String> institucionesIds){
        Id recordTypeBajaSeguimiento = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Seguimiento').getRecordTypeId();
        Map<String, Map<String, List<VisMed_Bajas__c>>> mapApmProfesionalInstitucion = new Map<String, Map<String, List<VisMed_Bajas__c>>>();
        for(VisMed_Bajas__c baja : [SELECT Id, Estado__c , Profesional__c, VisMed_APM__c, Institucion__c, CreatedDate
                                    FROM VisMed_Bajas__c 
                                    WHERE (Estado__c = 'Aprobada' OR Estado__c = 'Pendiente') 
                                        AND VisMed_APM__c IN :apmIds 
                                        AND Profesional__c IN :profesionalesIds
                                        AND Institucion__c IN : institucionesIds
                                        AND RecordtypeId = :recordTypeBajaSeguimiento
            ]){
                if(!mapApmProfesionalInstitucion.containsKey(baja.VisMed_APM__c)){
                    mapApmProfesionalInstitucion.put(baja.VisMed_APM__c, new Map<String, List<VisMed_Bajas__c>>());
                }
                if(!mapApmProfesionalInstitucion.get(baja.VisMed_APM__c).containsKey(baja.Profesional__c)){
                    mapApmProfesionalInstitucion.get(baja.VisMed_APM__c).put(baja.Profesional__c, new List<VisMed_Bajas__c>());
                }
                mapApmProfesionalInstitucion.get(baja.VisMed_APM__c).get(baja.Profesional__c).add(baja);
            }
            
            Date fechaBaja = Date.today();
            for(VisMed_Bajas__c baja : bajas){ //Por cada baja a insertar me fijo si ya hay una baja con la misma relacion APM-Profesional-Institucion.
                if(mapApmProfesionalInstitucion.containsKey(baja.VisMed_APM__c)){
                    if(mapApmProfesionalInstitucion.get(baja.VisMed_APM__c).containsKey(baja.Profesional__c)){
                        List<VisMed_Bajas__c> BajasInstitucionesSf = mapApmProfesionalInstitucion.get(baja.VisMed_APM__c).get(baja.Profesional__c);
                        for(VisMed_Bajas__c bajaSF : BajasInstitucionesSf){
                            Date fechaSF = date.newinstance(bajaSF.CreatedDate.year(), bajaSF.CreatedDate.month(), bajaSF.CreatedDate.day());
                            if(baja.Institucion__c == bajaSF.Institucion__c && fechaSF == fechaBaja){ // Si hay una baja como la antes mencionada, se arroja un error ya que solo puede haber una baja aprobada o pendiente por dicha relacion
                                baja.addError('Ya existe una baja de seguimiento para esta institucion');
                            }
                        }
                    }
                }
            }
    }


    public static void asignarBajaAlAPM (List<VisMed_Bajas__c> bajas) {
        Set<Id> contactId = new Set<Id>();
        List<User> users = new List<User>();
        Map<Id,Id> userIdXcontactId = new Map<Id,Id>();

        for (VisMed_Bajas__c baja : bajas) {
            contactId.add(baja.VisMed_APM__c);
        }

        users = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactId];
        for (User usuario : users) {
            for (VisMed_Bajas__c baja : bajas) {
                if (usuario.ContactId == baja.VisMed_APM__c) {
                    baja.OwnerId = usuario.Id;
                }
            }
        }
    }


    public static void desvincularProfesional (List<VisMed_Bajas__c> bajas) {
        List<VisMed_Bajas__c> bajasTotalesTemporales = new List<VisMed_Bajas__c>();
        List<VisMed_Bajas__c> bajasTotalesNOTemporales = new List<VisMed_Bajas__c>();
        List<VisMed_Bajas__c> bajasIndividualesTemporales = new List<VisMed_Bajas__c>();
        List<VisMed_Bajas__c> bajasIndividualesNOTemporales = new List<VisMed_Bajas__c>();
        List<MotivosWrapper> motivosWrapper = new List<MotivosWrapper>();
        List<Configuracion_de_motivos_para_la_Baja__mdt> motivosDeBaja = [SELECT Label, Baja_Total__c, Baja_Temporal__c FROM Configuracion_de_motivos_para_la_Baja__mdt];

        for (Configuracion_de_motivos_para_la_Baja__mdt motivo : motivosDeBaja) {
            MotivosWrapper motivoWrapper = new MotivosWrapper(
                motivo.Label,
                motivo.Baja_Temporal__c,
                motivo.Baja_Total__c
            );
            motivosWrapper.add(motivoWrapper);
        }

        for(VisMed_Bajas__c baja : bajas) {
            for (MotivosWrapper motivo : motivosWrapper) {
                if (baja.Motivo_de_la_Baja__c == motivo.Label) {
                    if (motivo.total && motivo.temporal) {
                        bajasTotalesTemporales.add(baja);
                    } else if (motivo.total && !motivo.temporal) {
                        bajasTotalesNOTemporales.add(baja);
                    } else if (!motivo.total && motivo.temporal) {
                        bajasIndividualesTemporales.add(baja);
                    } else if (!motivo.total && !motivo.temporal) {
                        bajasIndividualesNOTemporales.add(baja);
                    } else {
                        System.debug(baja);
                    }
                }
            }
        }

        if (!bajasTotalesTemporales.isEmpty()) {
            BajasTriggerHelper.bajaTotalTemporal(bajasTotalesTemporales); //desactivo el Profesional, paso los seguimientos de los APM sobre Profesional a 'Baja temporal' y elimino sus relaciones con AccountTeamMember.
        }
        if (!bajasTotalesNOTemporales.isEmpty()) {
            BajasTriggerHelper.bajaTotalNOTemporal(bajasTotalesNOTemporales); //desactivo el Profesional, elimino sus domicilios, paso los seguimientos de los APM sobre Profesional a 'Inactivo' y elimino sus relaciones con AccountTeamMember.
        }
        if (!bajasIndividualesTemporales.isEmpty()) {
            BajasTriggerHelper.bajaIndividualTemporal(bajasIndividualesTemporales); //paso los seguimientos del APM sobre Profesional a 'Baja temporal' y elimino sus relaciones con AccountTeamMember.
        }
        if (!bajasIndividualesNOTemporales.isEmpty()) {
            BajasTriggerHelper.bajaIndividualNOTemporal(bajasIndividualesNOTemporales); //paso los seguimientos del APM sobre Profesional a 'Inactivo' y elimino sus relaciones con AccountTeamMember.
        }
    }


    public static void bajaTotalTemporal (List<VisMed_Bajas__c> bajas) {
        System.debug('Bajas: ' + bajas);
        Set<Id> profesionalesId = new Set<Id>();
        List<Account> profesionales;
        
        for (VisMed_Bajas__c baja : bajas) {
            profesionalesId.add(baja.Profesional__c);
        }

        profesionales = [SELECT Id, Profesional_Activo__c FROM Account WHERE Id IN :profesionalesId];
        for (Account profesional : profesionales) {
            profesional.Profesional_Activo__c = false;
        }
        update profesionales;

        //borrarAccountTeamMember(bajas);
        actualizarSeguimiento(bajas, 'Baja Temporal', false);
    }


    public static void bajaTotalNOTemporal (List<VisMed_Bajas__c> bajas) {
        System.debug('Bajas: ' + bajas);
        Set<Id> profesionalesId = new Set<Id>();
        List<Account> profesionales;
        
        for (VisMed_Bajas__c baja : bajas) {
            profesionalesId.add(baja.Profesional__c);
        }

        profesionales = [SELECT Id, Profesional_Activo__c FROM Account WHERE Id IN :profesionalesId];
        for (Account profesional : profesionales) {
            profesional.Profesional_Activo__c = false;
        }
        update profesionales;

        borrarAccountTeamMember(bajas);
        borrarDomicilios(bajas);
        actualizarSeguimiento(bajas, 'Inactivo', false);
    }


    public static void bajaIndividualTemporal (List<VisMed_Bajas__c> bajas) {
        System.debug('Bajas: ' + bajas);
        //borrarAccountTeamMember(bajas);
        actualizarSeguimiento(bajas, 'Baja Temporal', false);
    }


    public static void bajaIndividualNOTemporal (List<VisMed_Bajas__c> bajas) {
        System.debug('Bajas: ' + bajas);
        borrarAccountTeamMember(bajas);
        actualizarSeguimiento(bajas, 'Inactivo', false);
    }


    public static void borrarAccountTeamMember (List<VisMed_Bajas__c> bajas) {
        Set<Id> profesionalesId = new Set<Id>();
        Set<Id> contactId = new Set<Id>();
        List<User> users = new List<User>();
        Map<Id,Id> userIdXcontactId = new Map<Id,Id>();
        List<AccountTeamMember> accountsTeamMembers;
        List<AccounTeamWrapper> accountsTeamWrapperList = new List<AccounTeamWrapper>();
        List<AccountTeamMember> accountsTeamMembersToDelete = new List<AccountTeamMember>();

        for (VisMed_Bajas__c baja : bajas) {
            profesionalesId.add(baja.Profesional__c);
            contactId.add(baja.VisMed_APM__c);
        }

        users = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactId];
        for (User usuario : users) {
            for (VisMed_Bajas__c baja : bajas) {
                if (usuario.ContactId == baja.VisMed_APM__c) {
                    userIdXcontactId.put(usuario.ContactId, usuario.Id);
                }
            }
        }

        accountsTeamMembers = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId IN :userIdXcontactId.values() AND AccountId IN :profesionalesId];
        for (AccountTeamMember accounTeam : accountsTeamMembers) {
            AccounTeamWrapper accounTeamWraper = new AccounTeamWrapper(
                accounTeam.UserId,
                accounTeam.AccountId,
                accounTeam
            );
            accountsTeamWrapperList.add(accounTeamWraper);
        }

        for (VisMed_Bajas__c baja : bajas) {
            for (AccounTeamWrapper accountTeamWrapper : accountsTeamWrapperList) {
                if (accountTeamWrapper.user == userIdXcontactId.get(baja.VisMed_APM__c) && accountTeamWrapper.account == baja.Profesional__c) {
                    accountsTeamMembersToDelete.add(accountTeamWrapper.accountTeam);
                }
            }
        }
        delete accountsTeamMembersToDelete;
    }


    public static void borrarDomicilios (List<VisMed_Bajas__c> bajas) {
        Set<Id> profesionalesId = new Set<Id>();
        List<Dan360_Lugar_de_Trabajo__c> domicilios;
        
        for (VisMed_Bajas__c baja : bajas) {
            profesionalesId.add(baja.Profesional__c);
        }

        //domicilios = [SELECT Id FROM Dan360_Lugar_de_Trabajo__c WHERE Profesional__c IN :profesionalesId];
        //delete domicilios;
    }

    public static Map<String, String> tipoDeBaja(List<VisMed_Bajas__c> bajas) {
        List<MotivosWrapper> motivosWrapper = new List<MotivosWrapper>();
        List<Configuracion_de_motivos_para_la_Baja__mdt> motivosDeBaja = [SELECT Label, Baja_Total__c, Baja_Temporal__c FROM Configuracion_de_motivos_para_la_Baja__mdt];
        String tipo;
        Map<String, String> tipoDeBaja = new Map<String, String>();
        for (Configuracion_de_motivos_para_la_Baja__mdt motivo : motivosDeBaja) {
            MotivosWrapper motivoWrapper = new MotivosWrapper(
                motivo.Label,
                motivo.Baja_Temporal__c,
                motivo.Baja_Total__c
            );
            motivosWrapper.add(motivoWrapper);
        }

        for(VisMed_Bajas__c baja : bajas) {
            for (MotivosWrapper motivo : motivosWrapper) {
                if (baja.Motivo_de_la_Baja__c == motivo.Label) {
                    if (motivo.total && motivo.temporal) {
                        tipo = 'Baja Temporal';
                        tipoDeBaja.put(baja.Id, tipo);
                    } else if (motivo.total && !motivo.temporal) {
                        tipo = 'Baja Total';
                        tipoDeBaja.put(baja.Id, tipo);
                    } else if (!motivo.total && motivo.temporal) {
                        tipo = 'Baja Temporal';
                        tipoDeBaja.put(baja.Id, tipo);
                    } else if (!motivo.total && !motivo.temporal) {
                        tipo = 'Baja Total';
                        tipoDeBaja.put(baja.Id, tipo);
                    } else {
                        System.debug(baja);
                    }
                }
            }
        }
        return tipoDeBaja;
    }


    public static void actualizarSeguimiento (List<VisMed_Bajas__C> bajas, String estado, Boolean conInstitucion) {
        System.debug(estado);
        System.debug(conInstitucion);
        List<SeguimientosWrapper> wrapperList = new List<SeguimientosWrapper>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos;
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Map<Id, VisMed_Contacto_Cuenta_Usuario__c> seguimientosSetFrecuencia = new Map<Id, VisMed_Contacto_Cuenta_Usuario__c>();
        Set<Id> profesionalesId = new Set<Id>();
        Set<Id> institucionesId = new Set<Id>();
        Set<Id> apmsId = new Set<Id>();
        Map<String, String> motivoBajaPorProfesional = new Map<String, String>();
        for (VisMed_Bajas__C baja : bajas) {
            System.debug(baja);
            System.debug(baja.Profesional__c);
            System.debug(baja.VisMed_APM__c);
            profesionalesId.add(baja.Profesional__c);
            institucionesId.add(baja.Institucion__c);
            motivoBajaPorProfesional.put(baja.Profesional__c, baja.Motivo_de_la_Baja__c);
            apmsId.add(baja.VisMed_APM__c);
            SeguimientosWrapper seguimientoWrapper = new SeguimientosWrapper(
                baja.Profesional__c,
                null,
                baja.VisMed_APM__c
            );
            if (conInstitucion) {
                seguimientoWrapper.institucion = baja.Institucion__c;
            }
            wrapperList.add(seguimientoWrapper);
        }
        if (!conInstitucion) {
            seguimientos = [SELECT Id, OwnerId, Institucion__c, Ultima_Visita__c,Visitas_acumuladas__c, Segmenta_Anterior__c, Segmenta_Por__c, VisMed_Semaforo__c, Motivo_de_la_Baja__c, VisMed_APM__c, Predeterminada__c, Estado__c, Profesional__c, Tipo__c 
                            FROM VisMed_Contacto_Cuenta_Usuario__c
                            WHERE Profesional__c IN :profesionalesId 
                                AND VisMed_APM__c IN :apmsId];
        } else {
            seguimientos = [SELECT Id, OwnerId, Institucion__c, Ultima_Visita__c, Visitas_acumuladas__c, Segmenta_Anterior__c, Segmenta_Por__c, VisMed_Semaforo__c, Motivo_de_la_Baja__c, VisMed_APM__c, Predeterminada__c, Estado__c, Profesional__c, Tipo__c 
                            FROM VisMed_Contacto_Cuenta_Usuario__c
                            WHERE Profesional__c IN :profesionalesId 
                                AND Institucion__c IN :institucionesId
                                AND VisMed_APM__c IN :apmsId];
        }
        System.debug(seguimientos);
        System.debug(wrapperList);
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            for (SeguimientosWrapper seguimientoWrapper : wrapperList) {
                System.debug(seguimientoWrapper);
                if (seguimiento.Profesional__c == seguimientoWrapper.profesional && (seguimiento.Institucion__c == seguimientoWrapper.institucion || String.isBlank(seguimientoWrapper.institucion)) && seguimiento.VisMed_APM__c == seguimientoWrapper.apm) {
                    if (estado == 'Activo') {
                        seguimiento.Estado__c = estado;
                        seguimiento.Motivo_de_la_Baja__c = '';
                        seguimientosToUpdate.add(seguimiento);
                        if (!seguimientosSetFrecuencia.containsKey(seguimiento.Id) && seguimiento.Segmenta_Por__c != null) {
                            seguimientosSetFrecuencia.put(seguimiento.Id, seguimiento);
                        }
                    }else {
                        seguimiento.Estado__c = estado;
                        seguimiento.Motivo_de_la_Baja__c = motivoBajaPorProfesional.get(Seguimiento.Profesional__c);
                        //agregar predeterminado false
                        seguimientosToUpdate.add(seguimiento);                        
                    }
                }
            }
        }
        for(VisMed_Contacto_Cuenta_Usuario__c seg : seguimientos){
            System.debug(seg.Id);
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosSetFrecuenciaList = new List<VisMed_Contacto_Cuenta_Usuario__c>(seguimientosSetFrecuencia.values());
        Set<VisMed_Contacto_Cuenta_Usuario__c> setListaSeguimientos = new Set<VisMed_Contacto_Cuenta_Usuario__c>(seguimientosToUpdate); //Se saca los duplicados del bug.
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosSinDuplicados = new List<VisMed_Contacto_Cuenta_Usuario__c>(setListaSeguimientos);
        update seguimientosSinDuplicados;
        SeguimientoTriggerHelper.setFrecuencia(seguimientosSetFrecuenciaList, true, false);
    }


    public static void createNotification (List<VisMed_Bajas__c> bajas) {
        List<Notificacion__c> notificaciones = new List<Notificacion__c>();
        Set<String> profesionalesId = new Set<String>();
        Set<String> institucionesId = new Set<String>();
        for(VisMed_Bajas__c baja : bajas){
                profesionalesId.add(baja.Profesional__c);
                institucionesId.add(baja.Institucion__c);
        }
        System.debug(profesionalesId);
        Map<String,String> mapAccountContactId = new Map<String,String>();
        Map<String,String> mapProfesionalNombre = new Map<String,String>();
        for(Account contactId : [SELECT Id, PersonContactId, Name FROM Account WHERE Id IN :profesionalesId]){
            if(!mapAccountContactId.containsKey(contactId.Id)){
                mapAccountContactId.put(contactId.Id,contactId.PersonContactId);                
            }
            mapProfesionalNombre.put(contactId.Id, contactId.Name);
        }
        Map<String,String> mapInstitucionesNombre = new Map<String,String>();
        for(Account acc : [SELECT Id, PersonContactId, Name FROM Account WHERE Id IN :institucionesId]){
            if(!mapInstitucionesNombre.containsKey(acc.Id)){                
                mapInstitucionesNombre.put(acc.Id, acc.Name);
            }
        }
        String titulo;
        String cuerpo;
        String redireccion = 'bajas profesional';
        for (VisMed_Bajas__c objeto : bajas) {
            list<Dan360_Lugar_de_Trabajo__c> acc = new list<Dan360_Lugar_de_Trabajo__c>();
            String profesional = mapAccountContactId.get(objeto.Profesional__c);
            titulo = objeto.Estado__c == 'Aprobada' ? 'Su Baja fue APROBADA' : 'Su Baja fue RECHAZADA';
            string recordTypeName = [SELECT Name
                                    FROM RecordType
                                    WHERE Id =: objeto.RecordTypeId].Name;
            if (recordTypeName == 'Seguimiento') {
                 acc = [SELECT id, Profesional__r.Name, Institucion__r.Name
                        FROM Dan360_Lugar_de_Trabajo__c 
                        WHERE Profesional__c =: profesional AND Institucion__c =: objeto.Institucion__c
                        LIMIT 1];
                        
            }else {
                acc = [SELECT id, Profesional__r.Name, Institucion__r.Name
                       FROM Dan360_Lugar_de_Trabajo__c 
                       WHERE Profesional__c =: profesional OR Institucion__c =: objeto.Institucion__c
                       LIMIT 1];                
            }
            System.debug(objeto.RecordTypeId);
            System.debug(objeto.Estado__c);            
            System.debug(titulo); 
            String nombreProfesional = mapProfesionalNombre.get(objeto.Profesional__c);
            System.debug(nombreProfesional);
            String nombreInstitucion = mapInstitucionesNombre.get(objeto.Institucion__c);
            System.debug(nombreInstitucion);
            if (recordTypeName == 'Seguimiento') {
                cuerpo = objeto.Estado__c == 'Aprobada' ? 'Aprobada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Profesional: ' + nombreProfesional + '. Institución: '+ nombreInstitucion : 'Rechazada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Profesional: ' + nombreProfesional + '. Institución: '+ nombreInstitucion;
            } else {cuerpo = objeto.Estado__c == 'Aprobada' ? 'Aprobada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Profesional: ' + nombreProfesional : 'Rechazada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Profesional: ' + nombreProfesional;}
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

    public static void updateInstitucion(VisMed_Bajas__c[] bajas) {
        VisMed_Contacto_Cuenta_Usuario__C[] seguimientos = getSeguimientosPredeterminados();

        for (VisMed_Bajas__c baja : bajas) {
            for (VisMed_Contacto_Cuenta_Usuario__C seguimiento : seguimientos) {
                if (baja.Profesional__c == seguimiento.Profesional__c
                    && baja.VisMed_APM__c == seguimiento.VisMed_APM__c
                ) {
                    baja.Institucion__c = seguimiento.Institucion__c;
                    break;
                }
            }
        }
    }

    public static VisMed_Contacto_Cuenta_Usuario__C[] getSeguimientosPredeterminados() {
        return [
            SELECT Id, Profesional__c, VisMed_APM__c, Institucion__c
            FROM VisMed_Contacto_Cuenta_Usuario__C
            WHERE Predeterminada__c = true
        ]; 
    }

    public static Boolean isProfessionalAndApproved(VisMed_Bajas__c baja) {
        return baja.Estado__c == 'Aprobada' 
                && baja.Fecha_de_Desactivacion__c >= System.today() 
                && baja.RecordTypeId == recordTypeBajaProfesional;
    }

    public static Boolean isProfessionalAndChangesToApproved(VisMed_Bajas__c baja, VisMed_Bajas__c oldBaja) {
        return baja.Estado__c == 'Aprobada' 
                && baja.Estado__c != oldBaja.Estado__c
                && baja.Fecha_de_Desactivacion__c >= System.today() 
                && baja.RecordTypeId == recordTypeBajaProfesional;
    }

    public class SeguimientosWrapper {
        public Id profesional;
        public Id institucion;
        public Id apm;

        public SeguimientosWrapper (Id profesional, Id institucion, Id apm) {
            this.profesional = profesional;
            this.institucion = institucion;
            this.apm = apm;
        }
    }


    public class MotivosWrapper {
        public String label;
        public Boolean temporal;
        public Boolean total;

        public MotivosWrapper (String label, Boolean temporal, Boolean total) {
            this.label = label;
            this.temporal = temporal;
            this.total = total;
        }
    }


    public class AccounTeamWrapper {
        public Id user;
        public Id account;
        public AccountTeamMember accountTeam;

        public AccounTeamWrapper (Id user, Id account, AccountTeamMember accountTeam) {
            this.user = user;
            this.account = account;
            this.accountTeam = accountTeam;
        }
    }

}