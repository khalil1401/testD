public without sharing class SeguimientoTriggerHelper {
    public static Boolean isFirstTime = true;
    public static void asignarSeguimientoAlAPM (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        Set<Id> contactId = new Set<Id>();
        List<User> users = new List<User>();
        Map<Id,Id> userIdXcontactId = new Map<Id,Id>();

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            contactId.add(seguimiento.VisMed_APM__c);
        }

        users = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactId];
        for (User usuario : users) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (usuario.ContactId == seguimiento.VisMed_APM__c) {
                    seguimiento.OwnerId = usuario.Id;
                }
            }
        }
    }
    public static void verificharSiHayFicheroActivoParaCopiarValores (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos, boolean blanquearCampos) {
        Set<Id> apmsId = new Set<Id>();
        Set<Id> profesionalesId = new Set<Id>();
        Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> profesionalPorApm = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaBlanquearUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profesionalesId.add(seguimiento.Profesional__c);
            apmsId.add(seguimiento.VisMed_APM__c);            
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> otrosSeguimientos = 
            [SELECT Id, Frecuencia__c, Fin_de_Frecuencia__c, Inicio_de_Frecuencia__c,Visitas_acumuladas__c, 
            Categoria__c, VisMed_Semaforo__c, Ultima_Visita__c, Visitas_Realizadas__c, Plan__c, VisMed_APM__c, Profesional__c, Segmenta_Por__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Predeterminada__c = true 
            AND Profesional__c IN :profesionalesId 
            AND VisMed_APM__c IN :apmsId 
            AND Estado__c = 'Activo'
            AND Predeterminada__c = true];
        
        if(!otrosSeguimientos.isEmpty()){
            for (VisMed_Contacto_Cuenta_Usuario__c otroSeguimiento : otrosSeguimientos) {
                for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                    if (seguimiento.Id != otroSeguimiento.Id && seguimiento.Profesional__c == otroSeguimiento.Profesional__c && seguimiento.VisMed_APM__c == otroSeguimiento.VisMed_APM__c) {
                        seguimiento.Frecuencia__c = otroSeguimiento.Frecuencia__c;
                        seguimiento.Inicio_de_Frecuencia__c = otroSeguimiento.Inicio_de_Frecuencia__c;
                        seguimiento.Fin_de_Frecuencia__c = otroSeguimiento.Fin_de_Frecuencia__c;
                        seguimiento.Visitas_acumuladas__c = otroSeguimiento.Visitas_acumuladas__c;
                        seguimiento.Categoria__c = otroSeguimiento.Categoria__c;
                        seguimiento.Ultima_Visita__c = otroSeguimiento.Ultima_Visita__c;
                        seguimiento.Visitas_Realizadas__c = otroSeguimiento.Visitas_Realizadas__c;
                        seguimiento.Plan__c = otroSeguimiento.Plan__c;
                        seguimiento.VisMed_Semaforo__c = otroSeguimiento.VisMed_Semaforo__c;
                        seguimiento.Segmenta_Por__c = otroSeguimiento.Segmenta_Por__c;
                        seguimiento.Actualizar_Frecuencia__c = false;        
                    } else {
                        seguimientosParaBlanquearUpdate.add(seguimiento);
                    }
                }
            }
        } else {
            seguimientosParaBlanquearUpdate.addAll(seguimientos);
        }
        
        if(blanquearCampos){
            blankCamposDeFrecuencia(seguimientosParaBlanquearUpdate);
        }
    }

    public static void hacerPredeterminadoAlNuevoSeguimiento (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        System.debug('Seguimientos para hacer predeterminados: ' + seguimientos.size());
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosConSegmentacion = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Map<Id,VisMed_Contacto_Cuenta_Usuario__c> seguimientoXprofesional = new Map<Id,VisMed_Contacto_Cuenta_Usuario__c>(); //Este mapa solo guardara un seguimiento para el profesional y lo hara predeterminado.
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            if (seguimiento.Estado__c == 'Activo') {
                seguimientoXprofesional.put(seguimiento.Profesional__c, seguimiento);
                if (seguimiento.Segmenta_Por__c != null) {
                    seguimientosConSegmentacion.add(seguimiento);
                }
            }
        }
        // for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientoXprofesional.values()) {
        //     seguimiento.Predeterminada__c = true;
        // }
        if (!seguimientosConSegmentacion.isEmpty() && seguimientosConSegmentacion.size() > 0) {
            SeguimientoTriggerHelper.crearSegmentacion(seguimientosConSegmentacion);
            SeguimientoTriggerHelper.setFrecuencia(seguimientosConSegmentacion, false, false);            
        }
    }

    public static void quitarPredeterminadoALosOtrosSeguimientos (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientoToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Set<Id> idDeSeguimientos = new Set<Id>();
        Set<Id> idDeProfesionales = new Set<Id>();
        Set<Id> idDeAPMs = new Set<Id>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            idDeSeguimientos.add(seguimiento.Id);
            idDeProfesionales.add(seguimiento.Profesional__c);
            idDeAPMs.add(seguimiento.VisMed_APM__c);
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> otrosSeguimientos = [SELECT Id, Predeterminada__c, Profesional__c, VisMed_APM__c
                                                                        FROM VisMed_Contacto_Cuenta_Usuario__c
                                                                        WHERE Predeterminada__c = true AND Profesional__c IN :idDeProfesionales 
                                                                            AND VisMed_APM__c IN :idDeAPMs AND Predeterminada__c = true];
        if (!otrosSeguimientos.isEmpty()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                for (VisMed_Contacto_Cuenta_Usuario__c otroSeguimiento : otrosSeguimientos) {
                    if (seguimiento.Id != otroSeguimiento.Id && seguimiento.Profesional__c == otroSeguimiento.Profesional__c && seguimiento.VisMed_APM__c == otroSeguimiento.VisMed_APM__c) {
                        otroSeguimiento.Predeterminada__c = false;
                        seguimientoToUpdate.add(otroSeguimiento);
                    }
                }
            }
            update seguimientoToUpdate;
            System.debug('Seguimientos actualizados: ' + seguimientoToUpdate);
        }                                                                      
    }

    // public static void reemplazarSeguimientoPredeterminado (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) { 
    //     List<VisMed_Contacto_Cuenta_Usuario__c> seguimientoToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
    //     Set<Id> idDeSeguimientos = new Set<Id>();
    //     Set<Id> idDeProfesionales = new Set<Id>();
    //     Set<Id> idDeAPMs = new Set<Id>();
    //     for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
    //         idDeSeguimientos.add(seguimiento.Id);
    //         idDeProfesionales.add(seguimiento.Profesional__c);
    //         idDeAPMs.add(seguimiento.VisMed_APM__c);
    //     }
    //     List<VisMed_Contacto_Cuenta_Usuario__c> otrosSeguimientos = [SELECT Id 
    //                                                                     FROM VisMed_Contacto_Cuenta_Usuario__c 
    //                                                                     WHERE Predeterminada__c = true AND Profesional__c IN :idDeProfesionales 
    //                                                                         AND VisMed_APM__c IN :idDeAPMs AND Id NOT IN :idDeSeguimientos AND Predeterminada__c = false 
    //                                                                         AND Estado__c = 'Activo'];
    //     if (!otrosSeguimientos.isEmpty()) {
    //         for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
    //             for (VisMed_Contacto_Cuenta_Usuario__c otroSeguimiento : otrosSeguimientos) {
    //                 if (seguimiento.Profesional__c == otroSeguimiento.Profesional__c && seguimiento.VisMed_APM__c == otroSeguimiento.VisMed_APM__c) {
    //                     otroSeguimiento.Predeterminada__c = true;
    //                     seguimientoToUpdate.add(otroSeguimiento);
    //                     break;
    //                 }
    //             }
    //         }
    //         update seguimientoToUpdate;
    //         System.debug('Seguimientos actualizados: ' + seguimientoToUpdate);
    //     }  
    // }

    public static void activateProfesional (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        List<Id> profeisonalesFromSeguimientos= new List<Id>();
        List<Account> profeisonalesToUpdate = new List<Account>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profeisonalesFromSeguimientos.add(seguimiento.Profesional__c);
        }
        profeisonalesToUpdate = [SELECT Id, Profesional_Activo__c FROM Account WHERE Id IN :profeisonalesFromSeguimientos AND Profesional_Activo__c = false];
        for (Account profesional : profeisonalesToUpdate) {
            profesional.Profesional_Activo__c = true;
        }
        update profeisonalesToUpdate;
    }

    public static void createAccountTeam (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        List<AccountTeamMember> accountsTeams;
        Map<Id,Set<Id>> accountTeamsXUser = new Map<Id,Set<Id>>();
        Set<Id> profesionalesId = new Set<Id>();
        Set<Id> institucionesId = new Set<Id>();
        Set<Id> contactsId = new Set<Id>();
        List<User> usersId = new List<User>();
        Map<Id,Id> userIdXcontactId = new Map<Id,Id>();
        List<AccountTeamMember> accountsTeamMembersToInsert = new List<AccountTeamMember>();
        AccountTeamMember accountTeamForUserANDProfesional;
        AccountTeamMember accountTeamForUserANDInstitucion;

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profesionalesId.add(seguimiento.Profesional__c);
            institucionesId.add(seguimiento.Institucion__c);
            contactsId.add(seguimiento.VisMed_APM__c);
        }

        usersId = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactsId];
        for (User usuario : usersId) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (usuario.ContactId == seguimiento.VisMed_APM__c) {
                    userIdXcontactId.put( usuario.ContactId, usuario.Id);
                }
            }
        }

        accountsTeams = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId IN :userIdXcontactId.values() AND (AccountId IN :profesionalesId OR AccountId IN :institucionesId)];
        for (AccountTeamMember accountTeam : accountsTeams) {
            Set<Id> accountsId;
            accountsId = accountTeamsXUser.containsKey(accountTeam.UserId) ? accountTeamsXUser.get(accountTeam.UserId) : new Set<Id>();
            accountsId.add(accountTeam.AccountId);
            accountTeamsXUser.put(accountTeam.UserId, accountsId);
        }
        System.debug(accountTeamsXUser);

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            //seguimiento.OwnerId = userIdXcontactId.get(seguimiento.VisMed_APM__c);
            // Si el mapa no contiene al usuario o si la lista del usuario no contiene los id del profesional o institucion ==> creo el AccountTeamMember
            if (!accountTeamsXUser.containsKey(userIdXcontactId.get(seguimiento.VisMed_APM__c))) {
                accountTeamForUserANDProfesional = new AccountTeamMember(
                    UserId = userIdXcontactId.get(seguimiento.VisMed_APM__c),
                    AccountId = seguimiento.Profesional__c,
                    TeamMemberRole = 'Sales Rep'
                );
                accountTeamForUserANDInstitucion = new AccountTeamMember(
                    UserId = userIdXcontactId.get(seguimiento.VisMed_APM__c),
                    AccountId = seguimiento.Institucion__c,
                    TeamMemberRole = 'Sales Rep'
                );
                accountsTeamMembersToInsert.add(accountTeamForUserANDProfesional);
                accountsTeamMembersToInsert.add(accountTeamForUserANDInstitucion);
                System.debug(accountsTeamMembersToInsert);
            } else if (!accountTeamsXUser.get(userIdXcontactId.get(seguimiento.VisMed_APM__c)).contains(seguimiento.Profesional__c)) {
                accountTeamForUserANDProfesional = new AccountTeamMember(
                    UserId = userIdXcontactId.get(seguimiento.VisMed_APM__c),
                    AccountId = seguimiento.Profesional__c,
                    TeamMemberRole = 'Sales Rep'
                );
                accountsTeamMembersToInsert.add(accountTeamForUserANDProfesional);
                System.debug(accountsTeamMembersToInsert);
            } else if (!accountTeamsXUser.get(userIdXcontactId.get(seguimiento.VisMed_APM__c)).contains(seguimiento.Institucion__c)) {
                accountTeamForUserANDInstitucion = new AccountTeamMember(
                    UserId = userIdXcontactId.get(seguimiento.VisMed_APM__c),
                    AccountId = seguimiento.Institucion__c,
                    TeamMemberRole = 'Sales Rep'
                );
                accountsTeamMembersToInsert.add(accountTeamForUserANDInstitucion);
                System.debug(accountsTeamMembersToInsert);
            }
        }
        System.debug('Account teams creados en el seguimiento: ' + accountsTeamMembersToInsert);
        insert accountsTeamMembersToInsert;
    }
    public static void blankFieldMotivo (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            seguimiento.Motivo_de_la_Baja__c = '';
        }
    }

    public static void createLugarDeTrabajo (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        Set<Id> profesionalesId = new Set<Id>();
        Set<Id> institucionesId = new Set<Id>();
        Map<Id,Set<Id>> institucionesXprofesional = new Map<Id,Set<Id>>();
        Map<String,Id> profesional_institucion_domicilioId = new Map<String,Id>();
        List<Dan360_Lugar_de_Trabajo__c> domicilios;
        List<Dan360_Lugar_de_Trabajo__c> domicioliosToInsert = new List<Dan360_Lugar_de_Trabajo__c>();
        Set<Id> idAgregados = new Set<Id>();

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profesionalesId.add(seguimiento.Profesional__c);
            institucionesId.add(seguimiento.Institucion__c);
        }
        List<String> contactsAccountIds = new List<String>();
        Map<String,String> mapAccountContactId = new Map<String,String>();
        for(Account contactId : [SELECT Id, PersonContactId FROM Account WHERE Id IN :profesionalesId]){
            contactsAccountIds.add(contactId.PersonContactId);
            if(!mapAccountContactId.containsKey(contactId.Id)){
                mapAccountContactId.put(contactId.Id,contactId.PersonContactId);
            }
        }
        System.debug(contactsAccountIds);
        System.debug(mapAccountContactId);
        domicilios = [SELECT Id, Profesional__c, Institucion__c FROM Dan360_Lugar_de_Trabajo__c WHERE Profesional__c IN :contactsAccountIds AND Institucion__c IN :institucionesId];
        System.debug(domicilios);
        for (Dan360_Lugar_de_Trabajo__c domicilio : domicilios) {
            Set<Id> instituciones;
            instituciones = institucionesXprofesional.containsKey(domicilio.Profesional__c) ? institucionesXprofesional.get(domicilio.Profesional__c) : new Set<Id>();
            instituciones.add(domicilio.Institucion__c);
            institucionesXprofesional.put(domicilio.Profesional__c, instituciones);
            String key = domicilio.Profesional__c + '-' + domicilio.Institucion__c;
            profesional_institucion_domicilioId.put(key,domicilio.Id);
        }

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            String profesional = mapAccountContactId.get(seguimiento.Profesional__c);
            System.debug(profesional);
            Dan360_Lugar_de_Trabajo__c domicilio = new Dan360_Lugar_de_Trabajo__c(
                    Profesional__c = profesional,
                    Institucion__c = seguimiento.Institucion__c,
                    Estado__c = 'Activo'
                );
            if (institucionesXprofesional.containsKey(profesional) && institucionesXprofesional.get(profesional).contains(seguimiento.Institucion__c)) {
                String key = profesional + '-' + seguimiento.Institucion__c;
                if (!idAgregados.contains(profesional_institucion_domicilioId.get(key))) {
                    domicilio.Id = profesional_institucion_domicilioId.get(key);
                    idAgregados.add(profesional_institucion_domicilioId.get(key));
                    domicioliosToInsert.add(domicilio);
                }
            } else {
                domicioliosToInsert.add(domicilio);
            }
        }
        System.debug('domicilios creados en el seguimiento: ' + domicioliosToInsert);
        upsert domicioliosToInsert;
    }

    public static void crearSegmentacion(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        Set<Id> profesionalesId = new Set<Id>();
        List<VisMed_Segmentacion__c> segmentacionesToInsert = new List<VisMed_Segmentacion__c>();
        List<VisMed_Segmentacion__c> segmentacionesToDelete = new List<VisMed_Segmentacion__c>();
        Map<id, List<String>> tipoDeSegmentacionesPorProfesional = new Map<id, List<String>>();
        Map<id, List<VisMed_Segmentacion__c>> segmentacionesPorProfesional = new Map<id, List<VisMed_Segmentacion__c>>();
        Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            //System.debug(seguimiento.Profesional__r.RecordTypeId);
            System.debug(recordTypeProfesional);
            seguimiento.Actualizar_Frecuencia__c = true;
            profesionalesId.add(seguimiento.Profesional__c);
        }
        List<VisMed_Segmentacion__c> segmentaciones = [SELECT Id, Profesional__c, Institucion__c, Categoria__c, RecordTypeId, RecordType.Name
                            FROM VisMed_Segmentacion__c
                            WHERE Profesional__c IN :profesionalesId ];// segmentaciones asociadas al profesional
                            //AND Profesional__r.RecordTypeId = :recordTypeProfesional
        
        for (VisMed_Segmentacion__c segmentacion : segmentaciones) {
            if(!tipoDeSegmentacionesPorProfesional.containsKey(segmentacion.Profesional__c)){
                tipoDeSegmentacionesPorProfesional.put(segmentacion.Profesional__c, new List<String>());
                segmentacionesPorProfesional.put(segmentacion.Profesional__c, new List<VisMed_Segmentacion__c>());
            }
                segmentacionesPorProfesional.get(segmentacion.Profesional__c).add(segmentacion);
                tipoDeSegmentacionesPorProfesional.get(segmentacion.Profesional__c).add(segmentacion.RecordType.Name);
        }

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {          
            if (tipoDeSegmentacionesPorProfesional.containsKey(seguimiento.Profesional__c)) {
                if (!tipoDeSegmentacionesPorProfesional.get(seguimiento.Profesional__c).contains(seguimiento.Segmenta_Por__c)) {
                    if (!seguimiento.Segmenta_Por__c.contains('Adultos' )) {
                        Id tipoSegmentacion = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByName().get(seguimiento.Segmenta_Por__c).getRecordTypeId();
                        VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
                             recordTypeId = tipoSegmentacion,
                             Profesional__c = seguimiento.Profesional__c
                         );
                        segmentacionesToInsert.add(segmentacionNueva);
                        // se elimina la segmentacion anterior
                        // for (VisMed_Segmentacion__c segmentacion : segmentacionesPorProfesional.get(seguimiento.Profesional__c)) {
                        //     if (segmentacion.RecordType.Name == seguiminetosOld.get(seguimiento.Id).Segmenta_Por__c) {
                        //         System.debug('segmentacion a eliminar '+segmentacion.RecordType.Name);
                        //         segmentacionesToDelete.add(segmentacion);
                        //     }
                        // }                        
                    } //else { // si el tipo de segmentacion es alguna de Adultos solo elimino la anterior                        
                    //     for (VisMed_Segmentacion__c segmentacion : segmentacionesPorProfesional.get(seguimiento.Profesional__c)) {                           
                    //         if (segmentacion.RecordType.Name == seguiminetosOld.get(seguimiento.Id).Segmenta_Por__c) {
                    //             System.debug('segmentacion a eliminar '+segmentacion.RecordType.Name);
                    //             segmentacionesToDelete.add(segmentacion);
                    //         }
                    //     }   
                    // }
                }               
            } else {// si no existe ninguna segmentacion realacionada al profesional y no es de tipo adultos se crea una
                if (!seguimiento.Segmenta_Por__c.contains('Adultos')) {
                    Id tipoSegmentacion = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByName().get(seguimiento.Segmenta_Por__c).getRecordTypeId();
                    VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
                         recordTypeId = tipoSegmentacion,
                         Profesional__c = seguimiento.Profesional__c
                     );
                     segmentacionesToInsert.add(segmentacionNueva);
                 }
            }
        }
        // if (!segmentacionesToDelete.isEmpty()) {
        //     delete segmentacionesToDelete;
        // }
        if (!segmentacionesToInsert.isEmpty()) {
            insert segmentacionesToInsert;
        }        
    }

    public static void dejarUnSoloSeguimientoComoPrincipal(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos){
        Set<Id> apmsId = new Set<Id>();
        Set<Id> profesionalesId = new Set<Id>();
        Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> profesionalPorApm = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaQuitarComoPrincipal = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profesionalesId.add(seguimiento.Profesional__c);
            apmsId.add(seguimiento.VisMed_APM__c);            
           
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosComoPrincipal = [
            SELECT Id, Name, Predeterminada__c, Profesional__c, VisMed_APM__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE VisMed_APM__c IN :(apmsId) AND Profesional__c IN :(profesionalesId) AND Estado__c = 'Activo' AND Predeterminada__c = true
        ];

        System.debug(seguimientosComoPrincipal);
        if (!seguimientosComoPrincipal.isEmpty()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientosComoPrincipal) {
                System.debug('seguimiento: '+ seguimiento);             
                for (VisMed_Contacto_Cuenta_Usuario__c seguimientoPorApm : seguimientos) {
                    if(seguimiento.Profesional__c == seguimientoPorApm.Profesional__c && seguimiento.VisMed_APM__c == seguimientoPorApm.VisMed_APM__c && seguimiento.Predeterminada__c == true){
                        System.debug('Seguimiento para quitar de principal = '+ seguimiento);
                        seguimiento.Predeterminada__c = false;
                        seguimientosParaQuitarComoPrincipal.add(seguimiento);
                    }                        
                }
                
            }            
        }
        if (!seguimientosParaQuitarComoPrincipal.isEmpty()) {
            update seguimientosParaQuitarComoPrincipal;            
        }        
    }

    public static void copiarCambiosALosSeguimientosConMismoApmYProfesional(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos, Map<Id,VisMed_Contacto_Cuenta_Usuario__c> seguimientoAntiguo){
        Set<Id> apmsId = new Set<Id>();
        Set<Id> profesionalesId = new Set<Id>();
        Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> profesionalPorApm = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Set<Id> seguimientoIds = new Set<Id>();
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            profesionalesId.add(seguimiento.Profesional__c);
            apmsId.add(seguimiento.VisMed_APM__c);
            seguimientoIds.add(seguimiento.Id);

            if(!profesionalPorApm.containsKey(seguimiento.VisMed_APM__c)){                
                profesionalPorApm.put(seguimiento.VisMed_APM__c, new List<VisMed_Contacto_Cuenta_Usuario__c>());
            }
            profesionalPorApm.get(seguimiento.VisMed_APM__c).add(seguimiento);            
            System.debug(profesionalPorApm);
        }
        List<VisMed_Contacto_Cuenta_Usuario__c> otrosSeguimientos = [
            SELECT Id, Name, Predeterminada__c, Profesional__c,Frecuencia__c, Categoria__c, Visitas_acumuladas__c, VisMed_Semaforo__c, Ultima_Visita__c, VisMed_APM__c, Segmenta_Por__c, Tipo__c, Inicio_de_Frecuencia__c, Fin_de_Frecuencia__c, Visitas_Realizadas__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE VisMed_APM__c IN :(apmsId) 
            AND Profesional__c IN :(profesionalesId) 
            AND Estado__c = 'Activo'
            AND Id NOT IN :seguimientoIds
        ];
        Map<String, VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaCopiar = new Map<String, VisMed_Contacto_Cuenta_Usuario__c>();

        if (!otrosSeguimientos.isEmpty()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                System.debug('seguimiento: '+ seguimiento);
                System.debug('seguimiento Estado: '+ seguimientoAntiguo.get(seguimiento.Id).Estado__c);
                if (seguimientoAntiguo.get(seguimiento.Id).Estado__c != 'Inactivo' && seguimientoAntiguo.get(seguimiento.Id).Estado__c != 'Baja Temporal' && seguimientoAntiguo.get(seguimiento.Id).Estado__c != 'Rechazado') {
                    for (VisMed_Contacto_Cuenta_Usuario__c seguimientoPorApm : otrosSeguimientos) {
                        if(seguimiento.Profesional__c == seguimientoPorApm.Profesional__c && seguimiento.VisMed_APM__c == seguimientoPorApm.VisMed_APM__c && seguimiento.Id != seguimientoPorApm.Id && !seguimientoIds.contains(seguimientoPorApm.Id)){
                            System.debug('Seguimiento para copiar = '+ seguimientoPorApm);
                            seguimientoPorApm.Segmenta_Por__c = seguimiento.Segmenta_Por__c;
                            // seguimientoPorApm.Tipo__c = seguimiento.Tipo__c;
                            // seguimientoPorApm.Inicio_de_Frecuencia__c = seguimiento.Inicio_de_Frecuencia__c;
                            // seguimientoPorApm.Fin_de_Frecuencia__c = seguimiento.Fin_de_Frecuencia__c;
                            seguimientoPorApm.Visitas_Realizadas__c = seguimiento.Visitas_Realizadas__c;
                            seguimientoPorApm.Ultima_Visita__c = seguimiento.Ultima_Visita__c;
                            seguimientoPorApm.Visitas_acumuladas__c = seguimiento.Visitas_acumuladas__c;
                            seguimientoPorApm.VisMed_Semaforo__c = seguimiento.VisMed_Semaforo__c;
                            if (!seguimientosParaCopiar.containsKey(seguimientoPorApm.Id)) {
                                seguimientosParaCopiar.put(seguimientoPorApm.Id, seguimientoPorApm);                                
                            }
                        }                        
                    }                
                }else {
                    for (Integer i = 0; i < otrosSeguimientos.size(); i++) {
                        if(seguimiento.Profesional__c == otrosSeguimientos[i].Profesional__c && seguimiento.VisMed_APM__c == otrosSeguimientos[i].VisMed_APM__c && seguimiento.Id != otrosSeguimientos[i].Id && !seguimientoIds.contains(otrosSeguimientos[i].Id)){
                            System.debug('Seguimiento para copiar = '+ otrosSeguimientos[i]);
                            VisMed_Contacto_Cuenta_Usuario__c segui = new VisMed_Contacto_Cuenta_Usuario__c( Id = seguimiento.Id);
                            segui.Segmenta_Por__c = otrosSeguimientos[i].Segmenta_Por__c;
                            segui.Frecuencia__c = otrosSeguimientos[i].Frecuencia__c;
                            segui.Inicio_de_Frecuencia__c = otrosSeguimientos[i].Inicio_de_Frecuencia__c;
                            segui.Fin_de_Frecuencia__c = otrosSeguimientos[i].Fin_de_Frecuencia__c;
                            segui.Visitas_Realizadas__c = otrosSeguimientos[i].Visitas_Realizadas__c;
                            segui.Ultima_Visita__c = otrosSeguimientos[i].Ultima_Visita__c;
                            segui.VisMed_Semaforo__c = otrosSeguimientos[i].VisMed_Semaforo__c;
                            segui.Visitas_acumuladas__c = otrosSeguimientos[i].Visitas_acumuladas__c;
                            segui.Categoria__c = otrosSeguimientos[i].Categoria__c;

                            if (!seguimientosParaCopiar.containsKey(seguimiento.Id)) {
                                seguimientosParaCopiar.put(seguimiento.Id, segui);                                
                            }                            
                            i = otrosSeguimientos.size() + 1;                            
                        }
                    }                 
                }          
            }                              
        }
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientosParaCopiar.values()) {
            seguimientosParaUpdate.add(seguimiento);
        }
        
        if (!seguimientosParaUpdate.isEmpty()) {           
            isFirstTime = false;
            System.debug('Total seguimientos para copiar: '+seguimientosParaCopiar);            
            //setFrecuencia(seguimientosParaCopiar);
            update seguimientosParaUpdate;
        }
    }
    
    public static void GuardarSegmentacionAnterior(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos, map<Id,VisMed_Contacto_Cuenta_Usuario__c> seguimientosAnteriores){
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            seguimiento.Segmenta_Anterior__c = seguimientosAnteriores.get(seguimiento.Id).Segmenta_Por__c;
            seguimiento.Actualizar_Frecuencia__c = true;
        }
    }
    public static void UpdateSemaforo(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos){
        // recibo los ficheros que se les actulizo las visitas realizadas
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosConFrecuenciaMayorAUnoConDecimal = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosConFrecuenciaMenorAUnoConDecimal = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosConFrecuenciaEnteraSinDecimal = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosSinFrecuencia = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Set<Id> apmId = new Set<Id>();
        Set<Id> profesionalId = new Set<Id>();
        List<VisMed_Contacto_Cuenta_Usuario__c> updateSemaforos = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        Decimal frecuencia;
        Decimal frecuenciaDecimalPart;
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            apmId.add(seguimiento.VisMed_APM__c);
            profesionalId.add(seguimiento.Profesional__c);
            if (seguimiento.Frecuencia__c != null) {
                frecuencia = seguimiento.Frecuencia__c;
                frecuenciaDecimalPart = frecuencia - frecuencia.intValue();
                if (String.ValueOf(seguimiento.Frecuencia__c).endsWith('.00') || String.ValueOf(seguimiento.Frecuencia__c).endsWith(',00') || String.ValueOf(seguimiento.Frecuencia__c).endsWith('.0') || String.ValueOf(seguimiento.Frecuencia__c).endsWith(',0')){
                    ficherosConFrecuenciaEnteraSinDecimal.add(seguimiento);
                }
                if (frecuenciaDecimalPart > 0) {
                    if (frecuencia > 1) {
                        ficherosConFrecuenciaMayorAUnoConDecimal.add(seguimiento);
                    } else {
                        ficherosConFrecuenciaMenorAUnoConDecimal.add(seguimiento);
                    }
                }
            }            
            if (seguimiento.Frecuencia__c == null && seguimiento.Segmenta_Por__c == null) {
                ficherosSinFrecuencia.add(seguimiento);
            }
        }
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        List<Dan360_Interacciones__c> interaccionesRealizadas = [
            SELECT Id, Name, Estado__c, RecordTypeId, Profesional__c, VisMed_APM__c, VisMed_Fecha__c
            FROM Dan360_Interacciones__c
            WHERE Estado__c = 'Aprobada'
            AND Profesional__c IN :profesionalId
            AND VisMed_APM__c IN :apmId
            AND RecordTypeId = :recordTypeVisitaMedica                                                      
        ];
        if (ficherosConFrecuenciaEnteraSinDecimal.size() > 0 && !ficherosConFrecuenciaEnteraSinDecimal.isEmpty()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : ficherosConFrecuenciaEnteraSinDecimal) {
               
                if (seguimiento.Visitas_Realizadas__c == 0) {
                    if (seguimiento.VisMed_Semaforo__c != 'Rojo') {
                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                        updateSemaforos.add(seguimiento);
                    }
                }
                if(seguimiento.Frecuencia__c > seguimiento.Visitas_Realizadas__c && seguimiento.Visitas_Realizadas__c != 0){
                    if (seguimiento.VisMed_Semaforo__c != 'Amarillo') {
                        seguimiento.VisMed_Semaforo__c = 'Amarillo';
                        updateSemaforos.add(seguimiento);
                    }
                }
                if (seguimiento.Frecuencia__c <= seguimiento.Visitas_Realizadas__c) {
                    if (seguimiento.VisMed_Semaforo__c != 'Verde') {
                        seguimiento.VisMed_Semaforo__c = 'Verde';
                        updateSemaforos.add(seguimiento);
                    }
                }              
            }            
        }
        //hasta que no haya visita el semaforo es rojo luego cada visita es amarillo hasta completar el total de visitas y se cumpla con el minimo por mes
        // si yo guardo visita del mes anterior si el mes anterior no hay  visita y este mes se carga una es amarillo
        Integer mesInicio;
        Integer mesFinal;
        Integer mesActual = System.today().month();
        Boolean visitasOk = false;
        Decimal totalVisitas;
        Integer minimoVisitas = 0;
        Integer mesesEntreInicioFrecuenciaYHoy;
        if (ficherosConFrecuenciaMenorAUnoConDecimal.size() > 0 && !ficherosConFrecuenciaMenorAUnoConDecimal.isEmpty()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : ficherosConFrecuenciaMenorAUnoConDecimal) {
                mesInicio = seguimiento.Inicio_de_Frecuencia__c.Month();
                mesFinal = seguimiento.Fin_de_Frecuencia__c.Month();
                minimoVisitas = seguimiento.Frecuencia__c.intValue();
                //Se elimina visita o se modifica fecha la visitas realizadas vuelve a 0 semaforo vuelve a rojo
                if (seguimiento.Visitas_Realizadas__c == 0 || seguimiento.Visitas_acumuladas__c < seguimiento.Frecuencia__c) {
                    if (seguimiento.VisMed_Semaforo__c != 'Rojo') {
                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                        updateSemaforos.add(seguimiento);
                    }                    
                }
                // se carga una visita se pasa semaforo a Verde
                if (seguimiento.Visitas_Realizadas__c > seguimiento.Frecuencia__c || seguimiento.Visitas_acumuladas__c > seguimiento.Frecuencia__c) {
                    if (seguimiento.VisMed_Semaforo__c != 'Verde') {
                        seguimiento.VisMed_Semaforo__c = 'Verde';
                        //seguimiento.Visitas_Realizadas__c = 1;
                        updateSemaforos.add(seguimiento);
                    }                    
                }
               
            }        
        }

        Decimal frecuenciaDecimal;
        Decimal meses;
        Decimal totalFrecuencia;
        if (ficherosConFrecuenciaMayorAUnoConDecimal.size() > 0 && !ficherosConFrecuenciaMayorAUnoConDecimal.isEmpty()) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : ficherosConFrecuenciaMayorAUnoConDecimal) {
                mesInicio = seguimiento.Inicio_de_Frecuencia__c.Month();
                mesFinal = seguimiento.Fin_de_Frecuencia__c.Month();
                minimoVisitas = seguimiento.Frecuencia__c.intValue();
                mesesEntreInicioFrecuenciaYHoy = seguimiento.Inicio_de_Frecuencia__c.monthsBetween(Date.today());


                // Si Aun_Quedan_Meses__c es true significa que no estamos en el mes final semaforo solo puede ser amarillo o rojo
                if (seguimiento.Aun_Quedan_Meses__c ) {
                    // el primer mes realizando una visita ya pasa a amarillo
                    if (mesInicio == mesActual && seguimiento.VisMed_Semaforo__c != 'Amarillo' && seguimiento.Visitas_Realizadas__c >= 1) {
                        seguimiento.VisMed_Semaforo__c = 'Amarillo';
                        updateSemaforos.add(seguimiento);
                    }  
                    // a partir del segundo mes para pasar a amrillo debe realizar mas de una visita
                    if (mesesEntreInicioFrecuenciaYHoy >= 1 && (seguimiento.Visitas_Realizadas__c > minimoVisitas  || seguimiento.Visitas_acumuladas__c >= minimoVisitas )&& seguimiento.VisMed_Semaforo__c != 'Amarillo' ) {
                        seguimiento.VisMed_Semaforo__c = 'Amarillo';
                        updateSemaforos.add(seguimiento);
                    }                  
                }
               
                // Es el ultimo mes del periodo de frecuencia
                if (mesActual == mesFinal && !seguimiento.Aun_Quedan_Meses__c ) {
                    System.debug('if mes final');
                    
                    visitasOk = checkSiMesesAnterioresHayVisitasNecesarias(seguimiento, interaccionesRealizadas);
                    System.debug('visitasOK '+ visitasOk);
                    totalVisitas = seguimiento.Visitas_Realizadas__c + seguimiento.Visitas_acumuladas__c;
                    System.debug('Total visitas '+ totalVisitas);
                    frecuenciaDecimal = seguimiento.Frecuencia__c;
                    frecuenciaDecimal = Math.abs(frecuenciaDecimal - frecuenciaDecimal.intValue());
                    meses = 1/frecuenciaDecimal;  
                    totalFrecuencia = seguimiento.Frecuencia__c * meses;            
                    System.debug('Total frecuencia '+ totalFrecuencia);
                    // si visitasOk es true cumplio con el minimo de visitas por mes y  total de visitas es mayor o igual al total frecuencia semaforo es verde
                    if (visitasOk  && totalVisitas >= totalFrecuencia && seguimiento.Visitas_Realizadas__c >= minimoVisitas ) {
                        if (seguimiento.VisMed_Semaforo__c != 'Verde') {
                            seguimiento.VisMed_Semaforo__c = 'Verde';
                            updateSemaforos.add(seguimiento);                            
                        }
                    }else { // no alcanzaron las visitas el semaforo es amarillo si cumple con el minimo de visitas
                        System.debug('Else del mes final');
                        mesesEntreInicioFrecuenciaYHoy = seguimiento.Inicio_de_Frecuencia__c.monthsBetween(Date.today());
                        if (seguimiento.VisMed_Semaforo__c != 'Amarillo'  && (seguimiento.Visitas_Realizadas__c > minimoVisitas  || seguimiento.Visitas_acumuladas__c >= minimoVisitas ) ) {
                            seguimiento.VisMed_Semaforo__c = 'Amarillo';
                            System.debug('Semaforo Amarillo');
                            updateSemaforos.add(seguimiento);
                        }                        
                    }
                }
                // seteo de semaforo a rojo si se eliminan o modifican visitas
                if ( mesActual == mesInicio && seguimiento.Visitas_Realizadas__c == 0 && seguimiento.VisMed_Semaforo__c != 'Rojo') {
                    seguimiento.VisMed_Semaforo__c = 'Rojo';
                    updateSemaforos.add(seguimiento);
                }
                if (seguimiento.VisMed_Semaforo__c != 'Rojo' && mesesEntreInicioFrecuenciaYHoy >= 1 && seguimiento.Visitas_Realizadas__c <= minimoVisitas && seguimiento.Visitas_acumuladas__c == 0) {
                    seguimiento.VisMed_Semaforo__c = 'Rojo';
                    updateSemaforos.add(seguimiento);
                }
                if (seguimiento.VisMed_Semaforo__c != 'Rojo' && seguimiento.Visitas_Realizadas__c == 0 && seguimiento.Visitas_acumuladas__c == 0) {
                    seguimiento.VisMed_Semaforo__c = 'Rojo';
                    updateSemaforos.add(seguimiento);
                }
                             
            }
        }
    }


    public static Boolean checkSiMesesAnterioresHayVisitasNecesarias (VisMed_Contacto_Cuenta_Usuario__c seguimiento, List<Dan360_Interacciones__c> interaccionesRealizadas) {
        Integer mesesEntreInicioFrecuenciaYHoy = seguimiento.Inicio_de_Frecuencia__c.monthsBetween(Date.today());
        Date inicioDeMes;
        Date finalDeMes;
        integer sacarFinalMes;
        Integer cantidadVisitas;
        Integer minimoVisitasPorMes = seguimiento.Frecuencia__c.intValue();
        Map<Integer, Boolean> visitasPorMes = new Map<Integer, Boolean>();
        List<Dan360_Interacciones__c> visitasParaElFichero = new List<Dan360_Interacciones__c>();
        for (Dan360_Interacciones__c interaccion : interaccionesRealizadas) {
            if (seguimiento.VisMed_APM__c == interaccion.VisMed_APM__c && interaccion.Profesional__c == seguimiento.Profesional__c) {
                visitasParaElFichero.add(interaccion);
            }
        }
        for (Integer i = mesesEntreInicioFrecuenciaYHoy; i > 0; i--) {
            cantidadVisitas = 0;
            sacarFinalMes = i - 1; // se saca el inicio de mes del mes siguiente y se le descuenta un dia para obtener el final de mes
            inicioDeMes = Date.today().addMonths(-i).toStartOfMonth();
            finalDeMes = Date.today().addMonths(-sacarFinalMes).toStartOfMonth().addDays(-1);
            for (Dan360_Interacciones__c visita : visitasParaElFichero) {
                if (visita.VisMed_Fecha__c >= inicioDeMes && visita.VisMed_Fecha__c <= finalDeMes) {
                   cantidadVisitas++;
                }
            }
            System.debug(cantidadVisitas);
            if (cantidadVisitas >= minimoVisitasPorMes) {
                visitasPorMes.put(i, true);      
            }else {
                visitasPorMes.put(i, false);
            }
        }
        Boolean allTrue = true;
        for(Boolean visita : visitasPorMes.values()) {
            if(!visita) {
                allTrue = false;                
            }
        }
        return allTrue;
    }

    public static void rechazarLugaresDeTrabajo (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) { //REFACTORIZAR....
        List<Dan360_Lugar_De_Trabajo__c> domicilios;
       for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            System.debug('Profesional: ' + seguimiento.Profesional__c);
            System.debug('Institucion: ' + seguimiento.Institucion__c);
            domicilios = [SELECT Id, Estado__c, Profesional__c, Institucion__c FROM Dan360_Lugar_De_Trabajo__c WHERE Estado__c = 'Pendiente' AND Profesional__c = :seguimiento.Profesional__c AND Institucion__c = :seguimiento.Institucion__c];
            system.debug('Domicilios encontrados: ' + domicilios);
        }
        if (!domicilios.isEmpty()) {
            for (Dan360_Lugar_De_Trabajo__c domicilio : domicilios) {
                domicilio.Estado__c = 'Rechazada';
            }
        }
        update domicilios;
    }

    public static void setFrecuencia (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos, boolean batch, Boolean updateSegmentaAnterior) {
        System.debug('Seguimientos para hacer setFrecuencia: ' + seguimientos.size());
        Id recordTypeAI= Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Institucion').getRecordTypeId();
        Id recordTypeAG = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Comunidad').getRecordTypeId();
        Id recordTypeAO = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_Oncologia').getRecordTypeId();
        Id recordTypeM = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Metabolicos').getRecordTypeId();
        Id recordTypeE = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Epilepsia').getRecordTypeId();
        Id recordTypeMyE = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Metabolicos_y_Epilepsia').getRecordTypeId();
        Id recordTypeP = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Pediatricos_General').getRecordTypeId();
        Id recordTypeA = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Alergia').getRecordTypeId();
        Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> seguimientosDeAdultosGeneralInstitucion = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();
        Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> seguimientosQueNoSonDeAdultosGeneralInstitucion = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();
        Map<Id,List<VisMed_Contacto_Cuenta_Usuario__c>> accountsQueNecesitanSegmentacion = new Map<Id,List<VisMed_Contacto_Cuenta_Usuario__c>>();
        List<VisMed_Segmentacion__c> segmentaciones = new List<VisMed_Segmentacion__c>();

        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            System.debug('seguimiento Id: ' +seguimiento.Id);
            System.debug(seguimiento.Segmenta_Por__c);
            if (seguimiento.Segmenta_Por__c != null) {
                if (seguimiento.Segmenta_Por__c.toLowerCase() != 'adultos general institucion') {
                    List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosConProfesional;
                    seguimientosConProfesional = seguimientosQueNoSonDeAdultosGeneralInstitucion.containsKey(seguimiento.Profesional__c) ? seguimientosQueNoSonDeAdultosGeneralInstitucion.get(seguimiento.Profesional__c) : new List<VisMed_Contacto_Cuenta_Usuario__c>();
                    seguimientosConProfesional.add(seguimiento);
                    seguimientosQueNoSonDeAdultosGeneralInstitucion.put(seguimiento.Profesional__c, seguimientosConProfesional);
                    //accountsQueNecesitanSegmentacion.put(seguimiento.Profesional__c, seguimientosConProfesional);
                } else {
                    List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosConInstitucion;
                    seguimientosConInstitucion = seguimientosDeAdultosGeneralInstitucion.containsKey(seguimiento.Institucion__c) ? seguimientosDeAdultosGeneralInstitucion.get(seguimiento.Institucion__c) : new List<VisMed_Contacto_Cuenta_Usuario__c>();
                    seguimientosConInstitucion.add(seguimiento);
                    seguimientosDeAdultosGeneralInstitucion.put(seguimiento.Institucion__c, seguimientosConInstitucion);
                    //accountsQueNecesitanSegmentacion.put(seguimiento.Institucion__c, seguimientosConInstitucion);
                }                
            }
        }
        System.debug(seguimientosQueNoSonDeAdultosGeneralInstitucion);
        segmentaciones = [SELECT Id, Profesional__c, Institucion__c, Categoria__c, RecordTypeId, Frecuencia__C
                            FROM VisMed_Segmentacion__c
                            WHERE Profesional__c IN :seguimientosQueNoSonDeAdultosGeneralInstitucion.keySet() OR Institucion__c IN :seguimientosDeAdultosGeneralInstitucion.keySet()]; 
        System.debug('segmentaciones encontradas: ' + segmentaciones);

        if (!segmentaciones.isEmpty()) { //Si encuentro segmentacion para la cuenta entonces la quito del mapa. Este mapa lo usaremos para crear segmentaciones.
            // for (VisMed_Segmentacion__c segmentacion : segmentaciones) {
            //     if (accountsQueNecesitanSegmentacion.containsKey(segmentacion.Profesional__c)) {
            //         accountsQueNecesitanSegmentacion.remove(segmentacion.Profesional__c);
            //     } else if (accountsQueNecesitanSegmentacion.containsKey(segmentacion.Institucion__c)) {
            //         accountsQueNecesitanSegmentacion.remove(segmentacion.Institucion__c);
            //     }
            // }
        }

        System.debug('cuentas que necesitan segmentacion: ' + accountsQueNecesitanSegmentacion.size());
        List<VisMed_Segmentacion__c> segmentacionesToInsert = new List<VisMed_Segmentacion__c>();
        Map<Id,Map<String,VisMed_Segmentacion__c>> segmentacionesXcategoriaXprofesional = new Map<Id,Map<String,VisMed_Segmentacion__c>>();
        //if (!accountsQueNecesitanSegmentacion.isEmpty()) { //Si la lista contiene algo quiere decir que es necesario crear segmentaciones.
            // for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            //     Map<String,VisMed_Segmentacion__c> segmentacionXcategoria;
            //     if (accountsQueNecesitanSegmentacion.containsKey(seguimiento.Profesional__c)) {
            //         if (segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c)) {
            //             segmentacionXcategoria = segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c);
            //         } else {
            //             segmentacionXcategoria = new Map<String,VisMed_Segmentacion__c>();
            //         }
            //             //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         if (seguimiento.Segmenta_Por__c == 'Adultos General Comunidad' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Adultos General Comunidad'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeAG,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Adultos General Comunidad', segmentacionNueva);
            //         }   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         else if (seguimiento.Segmenta_Por__c == 'Adultos Oncologia' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Adultos Oncologia'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeAO,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Adultos Oncologia', segmentacionNueva);
            //         }   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         else if (seguimiento.Segmenta_Por__c == 'Metabolicos' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Metabolicos'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeM,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Metabolicos', segmentacionNueva);
            //         }   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         else if (seguimiento.Segmenta_Por__c == 'Epilepsia' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Epilepsia'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeE,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Epilepsia', segmentacionNueva);
            //         }   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         else if (seguimiento.Segmenta_Por__c == 'Metabolicos y Epilepsia' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Metabolicos y Epilepsia'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeMyE,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Metabolicos y Epilepsia', segmentacionNueva);
            //         }   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         else if (seguimiento.Segmenta_Por__c == 'Pediatricos General' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Pediatricos General'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeP,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Pediatricos General', segmentacionNueva);
            //         }   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         else if (seguimiento.Segmenta_Por__c == 'Alergia' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Profesional__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Profesional__c).containsKey('Alergia'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeA,
            //                 Profesional__c = seguimiento.Profesional__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Alergia', segmentacionNueva);
            //             System.debug('segmenta por alergia');
            //         }
            //             //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //         segmentacionesXcategoriaXprofesional.put(seguimiento.Profesional__c, segmentacionXcategoria);

            //     } else if (accountsQueNecesitanSegmentacion.containsKey(seguimiento.Institucion__c)) {
            //         if (segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Institucion__c)) {
            //             segmentacionXcategoria = segmentacionesXcategoriaXprofesional.get(seguimiento.Institucion__c);
            //         } else {
            //             segmentacionXcategoria = new Map<String,VisMed_Segmentacion__c>();
            //         }
            //         if (seguimiento.Segmenta_Por__c == 'Adultos General Institucion' && (!segmentacionesXcategoriaXprofesional.containsKey(seguimiento.Institucion__c) || !segmentacionesXcategoriaXprofesional.get(seguimiento.Institucion__c).containsKey('Adultos General Institucion'))) {
            //             VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            //                 recordTypeId = recordTypeAI,
            //                 Institucion__c = seguimiento.Institucion__c
            //             );
            //             segmentacionesToInsert.add(segmentacionNueva);
            //             segmentacionXcategoria.put('Adultos General Institucion', segmentacionNueva);
            //         }
            //         segmentacionesXcategoriaXprofesional.put(seguimiento.Institucion__c, segmentacionXcategoria);
            //     }
            //}

        //     System.debug('Segmentaciones para insertar: ' + segmentacionesToInsert.size());
        //     if (!segmentacionesToInsert.isEmpty()) {
        //         insert segmentacionesToInsert;
        //     }
            

        //     segmentaciones = [SELECT Id, Profesional__c, Institucion__c, Categoria__c, RecordTypeId, Frecuencia__C
        //                     FROM VisMed_Segmentacion__c
        //                     WHERE Profesional__c IN :seguimientosQueNoSonDeAdultosGeneralInstitucion.keySet() OR Institucion__c IN :seguimientosDeAdultosGeneralInstitucion.keySet()];
        // }
        
        System.debug('segmentaciones para setear campos: ' + segmentaciones);
        if (!segmentaciones.isEmpty()) { //Si hay segmentaciones entonces seteo los campos de la frecuencia en el fichero/seguimiento.
            if(!batch){
                for (VisMed_Segmentacion__c segmentacion : segmentaciones) {
                    if (segmentacion.RecordTypeId != recordTypeAI) { //Segmentaciones que no son de institucion.
                        if (seguimientosQueNoSonDeAdultosGeneralInstitucion.containsKey(segmentacion.Profesional__c)) {
                            setCamposDeFrecuencia(seguimientosQueNoSonDeAdultosGeneralInstitucion.get(segmentacion.Profesional__c), segmentacion);
                                                   
                        }
                    } 
                    // else if (segmentacion.RecordTypeId == recordTypeAI) {//Segmentaciones que son de institucion.
                    //     if (seguimientosDeAdultosGeneralInstitucion.containsKey(segmentacion.Institucion__c)) {
                    //         setCamposDeFrecuencia(seguimientosDeAdultosGeneralInstitucion.get(segmentacion.Institucion__c), segmentacion);
                    //     }
                    // }              
                }
            } else {
                setCamposDeFrecuenciaBatch(seguimientosQueNoSonDeAdultosGeneralInstitucion, segmentaciones, updateSegmentaAnterior);
            }
        }
    }

    public static void setCamposDeFrecuencia (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos, VisMed_Segmentacion__c segmentacion) {
        System.debug('seguimientos.size()');
        System.debug(seguimientos.size());
        System.debug('Seguimientos '+ seguimientos);
        System.debug('Segmentacion '+ segmentacion);
        segmentacion.Frecuencia__C = segmentacion.Frecuencia__C != null ? segmentacion.Frecuencia__C : 0;
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosById();
        Decimal frecuenciaDecimal;                               
        Decimal meses;
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
            if (seguimiento.Segmenta_Por__c.toLowerCase() == rtMap.get(segmentacion.RecordTypeId).getName().toLowerCase()) {
                System.debug('seguimiento.Segmenta_Por__c');
                System.debug(seguimiento.Segmenta_Por__c.toLowerCase());
                System.debug('frecuencia segmentacion: '+segmentacion.Frecuencia__c);
                seguimiento.Frecuencia__c = segmentacion.Frecuencia__C;
                seguimiento.Categoria__c = segmentacion.Categoria__c;
                if (String.ValueOf(segmentacion.Frecuencia__c).endsWith('.00') || String.ValueOf(segmentacion.Frecuencia__c).endsWith(',00')) {
                    seguimiento.Aun_Quedan_Meses__c = false;
                    seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                    seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
                    seguimiento.Visitas_Realizadas__c = 0;
                    if (seguimiento.VisMed_Semaforo__c != 'Rojo') {
                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                    }
                } else {
                    frecuenciaDecimal = seguimiento.Frecuencia__c;
                    frecuenciaDecimal = Math.abs(frecuenciaDecimal - frecuenciaDecimal.intValue());                           
                    meses = 1/frecuenciaDecimal;
                    seguimiento.Aun_Quedan_Meses__c = true;
                    seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                    seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(meses.intValue()).addDays(-1);
                    seguimiento.Visitas_Realizadas__c = 0;
                    seguimiento.Visitas_acumuladas__c = 0;
                    if (seguimiento.VisMed_Semaforo__c != 'Rojo') {
                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                    }
                }          
            }
            System.debug('seguimiento actualizado');
            System.debug(seguimiento);
        }
    }
    
    public static void setCamposDeFrecuenciaBatch (Map<Id,List<VisMed_Contacto_Cuenta_Usuario__c>> seguimientos, List<VisMed_Segmentacion__c> segmentaciones, Boolean updateSegmentaAnterior) {
        System.debug('seguimientos.size()');
        System.debug(seguimientos.size());
        System.debug('Seguimientos '+ seguimientos);
        System.debug('Segmentacion '+ segmentaciones);
        Id recordTypeAI= Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Institucion').getRecordTypeId();        
        Map<String, VisMed_Contacto_Cuenta_Usuario__c> ficherosMap = new Map<String,VisMed_Contacto_Cuenta_Usuario__c>();
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosById();
        for (VisMed_Segmentacion__c segmentacion : segmentaciones) {
            segmentacion.Frecuencia__C = segmentacion.Frecuencia__C != null ? segmentacion.Frecuencia__C : 0;
            if (segmentacion.RecordTypeId != recordTypeAI) { //Segmentaciones que no son de institucion.
                if (seguimientos.containsKey(segmentacion.Profesional__c)) {  
                    List<VisMed_Contacto_Cuenta_Usuario__c> ficherosParaLaSegmentacion = seguimientos.get(segmentacion.Profesional__c);
                    Decimal frecuenciaDecimal;                                               
                    Decimal meses;
                    for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : ficherosParaLaSegmentacion) {
                        if (segmentacion.Categoria__c != null){
                            if (seguimiento.Segmenta_Por__c.toLowerCase() == rtMap.get(segmentacion.RecordTypeId).getName().toLowerCase()) {
                                System.debug('seguimiento.Segmenta_Por__c');
                                System.debug(seguimiento.Segmenta_Por__c.toLowerCase());
                                seguimiento.Frecuencia__c = segmentacion.Frecuencia__C;
                                seguimiento.Categoria__c = segmentacion.Categoria__c;
                                if (updateSegmentaAnterior) {
                                    seguimiento.Segmenta_Anterior__c = seguimiento.Segmenta_Por__c;
                                    seguimiento.Actualizar_Frecuencia__c = false; // Para que no vuelva  a calcular la frencia el ciclo siguiente (BatchSetFrecuencia)
                                }
                                if (string.ValueOf(segmentacion.Frecuencia__c).endsWith('.00') || string.ValueOf(segmentacion.Frecuencia__c).endsWith(',00')) {
                                    seguimiento.Aun_Quedan_Meses__c = false;
                                    seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                                    seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
                                    seguimiento.Visitas_Realizadas__c = 0;
                                    if (seguimiento.VisMed_Semaforo__c != 'Rojo') {
                                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                                    }
                                    if (!ficherosMap.containsKey(seguimiento.Id)) {
                                        ficherosMap.put(seguimiento.Id, seguimiento);                                
                                    }                                    
                                } else {
                                    frecuenciaDecimal = seguimiento.Frecuencia__c;
                                    frecuenciaDecimal = Math.abs(frecuenciaDecimal - frecuenciaDecimal.intValue());                           
                                    meses = 1/frecuenciaDecimal;
                                    seguimiento.Aun_Quedan_Meses__c = true;
                                    seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                                    seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(meses.intValue()).addDays(-1);
                                    seguimiento.Visitas_Realizadas__c = 0;
                                    seguimiento.Visitas_acumuladas__c = 0;
                                    if (seguimiento.VisMed_Semaforo__c != 'Rojo') {
                                        seguimiento.VisMed_Semaforo__c = 'Rojo';
                                    }
                                    if (!ficherosMap.containsKey(seguimiento.Id)) {
                                        ficherosMap.put(seguimiento.Id, seguimiento);                                
                                    }
                                }          
                            }

                        }else {
                            // sin frecuencia  
                            System.debug('sin frecuencia');       
                            System.debug('Id: '+ seguimiento.Id);
                            seguimiento.Aun_Quedan_Meses__c = false;
                            seguimiento.Inicio_de_Frecuencia__c = System.today().toStartOfMonth();
                            seguimiento.Fin_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
                            seguimiento.Visitas_Realizadas__c = 0;
                            seguimiento.VisMed_Semaforo__c = 'Gris';
                            if (!ficherosMap.containsKey(seguimiento.Id)) {
                                ficherosMap.put(seguimiento.Id, seguimiento);                                
                            }
                        }
                        System.debug('seguimiento actualizado');
                        System.debug(seguimiento);
                        // listFicheros.add(seguimiento);
                    }                                           
                }
            } 
        }
        // Set<VisMed_Contacto_Cuenta_Usuario__c> setListaSeguimientos = new Set<VisMed_Contacto_Cuenta_Usuario__c>(listFicheros); //Se saca los duplicados del bug.
         List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
         for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : ficherosMap.values()) {
            ficherosToUpdate.add(seguimiento);
        }
        if(ficherosToUpdate.size() > 0 && !ficherosToUpdate.isEmpty()){
            Database.update(ficherosToUpdate,false);
        }
        
    }

    public static void blankCamposDeFrecuencia(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos){
        for(VisMed_Contacto_Cuenta_Usuario__c fichero : seguimientos){
            fichero.Frecuencia__c = null;
            fichero.Categoria__c = null;
            fichero.Aun_Quedan_Meses__c = false ;
            fichero.Inicio_de_Frecuencia__c = null;
            fichero.Fin_de_Frecuencia__c = null;
            fichero.Visitas_Realizadas__c = 0;
            fichero.Visitas_acumuladas__c = 0;
            fichero.Actualizar_Frecuencia__c = true;  
        }
    }

    //NOTIFICACION ALTAS: Altas Profesional - Altas Domicilio
    public static void createNotification (List<VisMed_Contacto_Cuenta_Usuario__c> altas) {
        Set<String> profesionalesId = new Set<String>();
        Set<String> institucionesId = new Set<String>();
        for(VisMed_Contacto_Cuenta_Usuario__c alta : altas){
                profesionalesId.add(alta.Profesional__c);
                institucionesId.add(alta.Institucion__c);
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
        // Map<String,String> mapInstitucionesNombre = new Map<String,String>();
        // for(Account acc : [SELECT Id, PersonContactId, Name FROM Account WHERE Id IN :institucionesId]){
        //     if(!mapInstitucionesNombre.containsKey(acc.Id)){                
        //         mapInstitucionesNombre.put(acc.Id, acc.Name);
        //     }
        // }
        List<Notificacion__c> notificaciones = new List<Notificacion__c>();
        String titulo;
        String cuerpo;
        String redireccion = 'altas';
        for (VisMed_Contacto_Cuenta_Usuario__c objeto : altas) {
            String profesional = mapAccountContactId.get(objeto.Profesional__c);
            String nombreProfesional = mapProfesionalNombre.get(objeto.Profesional__c);
            System.debug(nombreProfesional);
            //String nombreInstitucion = mapInstitucionesNombre.get(objeto.Institucion__c);
            //System.debug(nombreInstitucion);
            System.debug(profesional);
                titulo = objeto.Estado__c == 'Activo' ? 'Su Alta fue APROBADA' : 'Su Alta fue RECHAZADA';
                // list<Dan360_Lugar_de_Trabajo__c> acc = [SELECT id, Profesional__r.Name, Institucion__r.Name
                // FROM Dan360_Lugar_de_Trabajo__c 
                // WHERE Profesional__c =: profesional AND Institucion__c =: objeto.Institucion__c
                // LIMIT 1];
                cuerpo = objeto.Estado__c == 'Activo' ? 'Aprobada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_Aprobacion__c +'. Profesional: '+ nombreProfesional : 'Rechazada por: ' + objeto.Aprobador_Final_Name__c + '. Comentarios: ' + objeto.Comentario_de_aprobacion__c + '. Profesional: '+ nombreProfesional;
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
    // sincronizamos ficheros para que  tengan los mismos valores en la misma relacion de apm profesional
    // public static void sincronizarFicheros (List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
    //     // Obtenemos los IDs de los Ficheros, APM y Profesionales
    //     Set<Id> apmsId = new Set<Id>();
    //     Set<Id> profesionalesId = new Set<Id>();
    //     Set<Id> seguimientoIds = new Set<Id>();
    //     for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
    //         profesionalesId.add(seguimiento.Profesional__c);
    //         apmsId.add(seguimiento.VisMed_APM__c); 
    //         seguimientoIds.add(seguimiento.Id);                 
    //     }
    //     // Obtenemos todos los ficheros relacionados
    //     List<VisMed_Contacto_Cuenta_Usuario__c> otrosSeguimientos = 
    //         [SELECT Id, Frecuencia__c, Fin_de_Frecuencia__c, Inicio_de_Frecuencia__c,Visitas_acumuladas__c, 
    //         Categoria__c, VisMed_Semaforo__c, Ultima_Visita__c, Visitas_Realizadas__c, Plan__c, VisMed_APM__c, Profesional__c
    //         FROM VisMed_Contacto_Cuenta_Usuario__c
    //         WHERE Profesional__c IN :profesionalesId 
    //         AND VisMed_APM__c IN :apmsId 
    //         AND Estado__c = 'Activo' 
    //         AND Id NOT IN :seguimientoIds];
        
    //     // Mapeamos los ficheros por ID del APM
    //     Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> ficherosPorApm = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();
    //     for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : otrosSeguimientos) {
    //         if(!ficherosPorApm.containsKey(seguimiento.VisMed_APM__c)){                
    //             ficherosPorApm.put(seguimiento.VisMed_APM__c, new List<VisMed_Contacto_Cuenta_Usuario__c>());
    //         }
    //         ficherosPorApm.get(seguimiento.VisMed_APM__c).add(seguimiento);            
    //         System.debug(ficherosPorApm);
    //     }

    //     // Creamos una lista de ficheros relacionados para actualizar
    //     List<VisMed_Contacto_Cuenta_Usuario__c> relatedFicheroToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        
    //     // Actualizamos los campos en todos los ficheros relacionados para que esten sincronizados
    //     Boolean syncFichero;
    //     for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
    //         syncFichero = false;
    //         if (ficherosPorApm.containsKey(seguimiento.VisMed_APM__c)) {
    //             List<VisMed_Contacto_Cuenta_Usuario__c> relatedFichero = ficherosPorApm.get(seguimiento.VisMed_APM__c);
    //             for (VisMed_Contacto_Cuenta_Usuario__c seguimientoToUpdate : relatedFichero) {
    //                 if (seguimiento.Frecuencia__c != seguimientoToUpdate.Frecuencia__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Frecuencia__c = seguimiento.Frecuencia__c;
    //                 }
    //                 if (seguimiento.Inicio_de_Frecuencia__c != seguimientoToUpdate.Inicio_de_Frecuencia__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Inicio_de_Frecuencia__c = seguimiento.Inicio_de_Frecuencia__c;
    //                 }
    //                 if (seguimiento.Fin_de_Frecuencia__c != seguimientoToUpdate.Fin_de_Frecuencia__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Fin_de_Frecuencia__c = seguimiento.Fin_de_Frecuencia__c;
    //                 }
    //                 if (seguimiento.Visitas_acumuladas__c != seguimientoToUpdate.Visitas_acumuladas__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Visitas_acumuladas__c = seguimiento.Visitas_acumuladas__c;
    //                 }
    //                 if (seguimiento.Categoria__c != seguimientoToUpdate.Categoria__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Categoria__c = seguimiento.Categoria__c;
    //                 }
    //                 if (seguimiento.Ultima_Visita__c != seguimientoToUpdate.Ultima_Visita__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Ultima_Visita__c = seguimiento.Ultima_Visita__c;
    //                 }
    //                 if (seguimiento.Visitas_Realizadas__c != seguimientoToUpdate.Visitas_Realizadas__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Visitas_Realizadas__c = seguimiento.Visitas_Realizadas__c;
    //                 }
    //                 if (seguimiento.Plan__c != seguimientoToUpdate.Plan__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.Plan__c = seguimiento.Plan__c;
    //                 }
    //                 if (seguimiento.VisMed_Semaforo__c != seguimientoToUpdate.VisMed_Semaforo__c) {
    //                     syncFichero = true;
    //                     seguimientoToUpdate.VisMed_Semaforo__c = seguimiento.VisMed_Semaforo__c;
    //                 }
    //                 if (syncFichero) {
    //                     relatedFicheroToUpdate.add(seguimientoToUpdate);                        
    //                 }
    //             }
    //         }
    //     }
    //     update relatedFicheroToUpdate;
    // }
    

}