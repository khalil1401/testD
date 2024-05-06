public with sharing class MassApprovalComponentController {
    
    @AuraEnabled(cacheable=true)
    public static List<User> getSupervisores () {
        List<User> supervisores = [SELECT Id, Name, ContactId FROM User WHERE Profile.Name  = 'Supervisores' AND IsActive = TRUE ORDER BY Name ];
        System.debug('Supervisores query');
        for(User sup : supervisores){
            System.debug(supervisores);
        }
        
        return supervisores;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUser (String supervisor) {
        System.debug('Supervisor seleccionado: ' + supervisor);
        String query;
        String condicion =  (String.isNotBlank(supervisor) ? 'ManagerId = \'' + supervisor + '\'' : '');
        System.debug('condition ' + condicion);
        if (String.isNotBlank(condicion)) {
            query =
                'SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True AND ' +
                condicion;
        } else {
            query = 'SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True';
        }
        System.debug('Query: ' + query);
        List<User> users = Database.query(query);
        Return users;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUserList (List<Id> supervisores) {
        System.debug('Supervisor seleccionado: ' + supervisores);
        List<User> users;
        if (supervisores.size() > 0) {
            users = [SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True AND ManagerId IN :supervisores ORDER BY Name];
        } else {
            users = [SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True ORDER BY Name];
        }
        Return users;
    }
    
    // @AuraEnabled(cacheable=true) 
    // public static List<ObjectWrapper> getData (String objeto, String recordTypeName, String estado, String user, List<String> users, String fechaInicio, String fechaFin) {
    //     System.debug('Fecha Inicio: ' + fechaInicio);
    //     System.debug('Fecha Fin: ' + fechaFin);
    //     String query;
    //     String usersList;
    //     String condicion =  (String.isNotBlank(estado) ? 'Estado__c = \'' + estado + '\'' : '');
    //     //Aca formo el string con la lista de usuarios en los combobox.
    //     for (String thisUser : users) {
    //         if (String.isNotBlank(usersList)) {
    //             usersList += ', ' + '\'' + thisUser + '\'';
    //         } else {
    //             usersList = '(' + '\'' + thisUser + '\'';
    //         }
    //     }
    //     usersList += ')';
    //     ///////////////////
    //     // Si no hay un usuario especifico seleccionado cargo los datos con los usuarios disponibles para elegir segun supervisor.
    //     if (String.isNotBlank(user)) {
    //         if (String.isNotBlank(condicion)) {
    //             condicion += ' AND VisMed_APM__c = \'' + user + '\'';
    //         } else {
    //             condicion += '';
    //         }
    //     } else if (!users.isEmpty()) {
    //         condicion += ' AND VisMed_APM__c IN ' + usersList;
    //     }
    //     condicion += (String.isNotBlank(recordTypeName) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' RecordType.DeveloperName = \'' + recordTypeName + '\'' : '');
        
    //     if (objeto.equals('Dan360_Licencia__c')) {
    //         if (String.isNotBlank(condicion)) {
    //             condicion += (String.isNotBlank(fechaInicio) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_inicio__c >= ' + fechaInicio : '');
    //             condicion += (String.isNotBlank(fechaFin) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_Fin__c <= ' + fechaFin : '');
    //             query =
    //             'SELECT Id, Name, Estado__c, CreatedDate, Fecha_de_inicio__c, Fecha_de_Fin__c, Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Cantidad_de_Dias__c, VisMed_Cantidad_de_Horas_Numerico__c, Comentarios__c FROM Dan360_Licencia__c WHERE ' +
    //             condicion;
    //         } else {
    //             query = 'SELECT Id, Name, Estado__c, CreatedDate, Fecha_de_inicio__c, Fecha_de_Fin__c, Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Cantidad_de_Dias__c, VisMed_Cantidad_de_Horas_Numerico__c, Comentarios__c FROM Dan360_Licencia__c';
    //         }
    //         query += ' Order By CreatedDate Desc ';
    //     } else if (objeto.equals('Dan360_Interacciones__c')){
    //         if (String.isNotBlank(condicion)) {
    //             condicion += (String.isNotBlank(fechaInicio) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' VisMed_Fecha__c >= ' + fechaInicio : '');
    //             condicion += (String.isNotBlank(fechaFin) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' VisMed_Fecha__c <= ' + fechaFin : '');
    //             query =
    //                 'SELECT Id, Name, Estado__c, CreatedDate, VisMed_Fecha__c, VisMed_Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Profesional__c, Profesional__r.Name, VisMed_Domicilio_de_la_Visita__c, VisMed_Domicilio_de_la_Visita__r.Name, VisMed_Comentarios__c, Aprobador_Final__c, Aprobador_Final__r.Name, Fecha_de_Aprobacion__c, Comentario_de_Aprobacion__c, RecordType.Name, VisMed_Tipo_de_Visita__c FROM Dan360_Interacciones__c WHERE ' +
    //                 condicion;
    //         } else {
    //             query = 'SELECT Id, Name, Estado__c, CreatedDate, VisMed_Fecha__c, VisMed_Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Profesional__c, Profesional__r.Name, VisMed_Domicilio_de_la_Visita__c, VisMed_Domicilio_de_la_Visita__r.Name, VisMed_Comentarios__c, Aprobador_Final__c, Aprobador_Final__r.Name, Fecha_de_Aprobacion__c, Comentario_de_Aprobacion__c, RecordType.Name, VisMed_Tipo_de_Visita__c FROM Dan360_Interacciones__c';
    //         }
    //         query += ' Order By CreatedDate Desc ';
    //     } else if(objeto.equals('VisMed_Bajas__c')) {
    //         if (String.isNotBlank(condicion)) {
    //             condicion += (String.isNotBlank(fechaInicio) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_Desactivacion__c >= ' + fechaInicio : '');
    //             condicion += (String.isNotBlank(fechaFin) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_Reactivacion__c <= ' + fechaFin : '');
    //             query =
    //                 'SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Estado__c, Institucion__c, Institucion__r.Name, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, VisMed_APM__c, VisMed_APM__r.Name, Fecha_de_Reactivacion__c, Motivo_de_la_Baja__c, Fecha_de_Desactivacion__c, Comentario__c FROM VisMed_Bajas__c WHERE ' +
    //                 condicion;
    //         } else {
    //             query = 'SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Estado__c, Institucion__c, Institucion__r.Name, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, VisMed_APM__c, VisMed_APM__r.Name, Fecha_de_Reactivacion__c, Motivo_de_la_Baja__c, Fecha_de_Desactivacion__c, Comentario__c FROM VisMed_Bajas__c';
    //         }

    //         if (String.isNotBlank(recordTypeName)) {
    //             if (recordTypeName == 'Seguimiento') {
    //                 query += ' Order By CreatedDate ';
    //             } else if (recordTypeName == 'Profesional_de_la_Salud') {
    //                 query += ' Order By CreatedDate Desc ';
    //             }
    //         }
    //     } else if(objeto.equals('VisMed_Contacto_Cuenta_Usuario__c')) {
    //         if (String.isNotBlank(condicion)) {
    //             condicion = condicion.replaceAll('Aprobada', 'Activo');
    //             query =
    //                 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Institucion__c, Institucion__r.Name, Ultima_Visita__c, VisMed_APM__c, VisMed_APM__r.Name, Predeterminada__c, Estado__c, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE ' +
    //                 condicion;
    //         } else {
    //             query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Institucion__c, Institucion__r.Name, Ultima_Visita__c, VisMed_APM__c, VisMed_APM__r.Name, Predeterminada__c, Estado__c, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c';
    //         }
    //         query += ' Order By CreatedDate Desc ';
    //     }
    //     System.debug('Query: ' + query);

    //     Id recordTypeMatriculaNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
    //     Id recordTypeMatriculaProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
    //     Map<Id, Dan360_Matricula__c> matriculasNacionalesXProfesional = new Map<Id, Dan360_Matricula__c>();
    //     Map<Id, Dan360_Matricula__c> matriculasProvincialesXProfesional = new Map<Id, Dan360_Matricula__c>();
    //     List<Dan360_Matricula__c> matriculasNacionales = [SELECT Id, Name, RecordTypeId, Provincia__c, Numero_de_matricula__c, Profesional__c, Municipios__c FROM Dan360_Matricula__c WHERE RecordTypeId = :recordTypeMatriculaNacional];
    //     List<Dan360_Matricula__c> matriculasProvinciales = [SELECT Id, Name, RecordTypeId, Provincia__c, Numero_de_matricula__c, Profesional__c, Municipios__c FROM Dan360_Matricula__c WHERE RecordTypeId = :recordTypeMatriculaProvincial];
    //     System.debug(matriculasNacionales);
    //     for (Dan360_Matricula__c matricula : matriculasNacionales) {
    //         matriculasNacionalesXProfesional.put(matricula.Profesional__c, matricula);
    //     }
    //     System.debug(matriculasProvinciales);
    //     for (Dan360_Matricula__c matricula : matriculasProvinciales) {
    //         matriculasProvincialesXProfesional.put(matricula.Profesional__c, matricula);
    //     }

    //     List<ObjectWrapper> response = new List<ObjectWrapper>();

    //     if (objeto.equals('Dan360_Licencia__c')) {
    //         List<Dan360_Licencia__c> records = Database.query(query);
    //         System.debug('licentcias : ' + records);
    //         for (Dan360_Licencia__c licencia : records) { 
    //             ObjectWrapper obj = new ObjectWrapper();
    //             obj.id = licencia.Id;
    //             obj.name = licencia.Name;
    //             obj.nameUrl = '/' + licencia.Id;
    //             obj.estado = licencia.Estado__c;
    //             obj.createdDate = licencia.CreatedDate;
    //             obj.fechaDeInicio = licencia.Fecha_de_inicio__c;
    //             obj.fechaDeFin = licencia.Fecha_de_Fin__c;
    //             obj.cantidadDeDias = licencia.Cantidad_de_Dias__c.format();
    //             obj.cantidadDeHoras = licencia.VisMed_Cantidad_de_Horas_Numerico__c.format();
    //             obj.motivo = licencia.Motivo__c;
    //             obj.ownerUrl = '/' + licencia.VisMed_APM__c;
    //             obj.owner = licencia.VisMed_APM__r.Name;
    //             obj.comentario = licencia.Comentarios__c;
    //             response.add(obj);
    //         }
    //     } else if (objeto.equals('Dan360_Interacciones__c')){
    //         List<Dan360_Interacciones__c> records = Database.query(query);
    //         System.debug('interacciones : ' + records);
    //         for (Dan360_Interacciones__c interaccion : records) { 
    //             ObjectWrapper obj = new ObjectWrapper();
    //             obj.id = interaccion.Id;
    //             obj.name = interaccion.Name;
    //             obj.nameUrl = '/' + interaccion.Id;
    //             obj.estado = interaccion.Estado__c;
    //             obj.createdDate = interaccion.CreatedDate;
    //             obj.fechaDeInicio = interaccion.VisMed_Fecha__c;
    //             obj.motivo = interaccion.VisMed_Motivo__c;
    //             obj.profesionalUrl = '/' + interaccion.Profesional__c;
    //             obj.profesional = interaccion.Profesional__r.Name;
    //             obj.institucionUrl = '/' + interaccion.VisMed_Domicilio_de_la_Visita__c;
    //             obj.institucion = interaccion.VisMed_Domicilio_de_la_Visita__r.Name;
    //             obj.ownerUrl = '/' + interaccion.VisMed_APM__c;
    //             obj.owner = interaccion.VisMed_APM__r.Name;
    //             obj.comentario = interaccion.VisMed_Comentarios__c;
    //             obj.recordType = interaccion.RecordType.Name;
    //             obj.tipoDeVisita = interaccion.VisMed_Tipo_de_Visita__c;
    //             response.add(obj);
    //         }
    //     } else if (objeto.equals('VisMed_Bajas__c')) {
    //         List<VisMed_Bajas__c> records = Database.query(query);
    //         System.debug('interacciones : ' + records);
    //         for (VisMed_Bajas__c baja : records) { 
    //             ObjectWrapper obj = new ObjectWrapper();
    //             obj.id = baja.Id;
    //             obj.name = baja.Name;
    //             obj.nameUrl = '/' + baja.Id;
    //             obj.estado = baja.Estado__c;
    //             obj.createdDate = baja.CreatedDate;
    //             obj.institucionUrl = '/' + baja.Institucion__c;
    //             obj.institucion = baja.Institucion__r.Name;
    //             obj.fechaDeInicio = baja.Fecha_de_Desactivacion__c;
    //             obj.fechaDeFin = baja.Fecha_de_Reactivacion__c;
    //             obj.motivo = baja.Motivo_de_la_Baja__c;
    //             obj.profesionalUrl = '/' + baja.Profesional__c;
    //             obj.profesional = baja.Profesional__r.Name;
    //             obj.especialidad = baja.Profesional__r.Primera_especialidad__c;
    //             if (matriculasNacionalesXProfesional.containsKey(baja.Profesional__c)) {
    //                 obj.matriculaNacional = matriculasNacionalesXProfesional.get(baja.Profesional__c).Numero_de_matricula__c;
    //             }
    //             if (matriculasProvincialesXProfesional.containsKey(baja.Profesional__c)) {
    //                 obj.matriculaProvincial = matriculasProvincialesXProfesional.get(baja.Profesional__c).Numero_de_matricula__c;
    //             }
    //             obj.ownerUrl = '/' + baja.VisMed_APM__c;
    //             obj.owner = baja.VisMed_APM__r.Name;
    //             obj.comentario = baja.Comentario__c;
    //             obj.recordType = baja.RecordType.Name;
    //             response.add(obj);
    //         }
    //     } else if (objeto.equals('VisMed_Contacto_Cuenta_Usuario__c')){
    //         List<VisMed_Contacto_Cuenta_Usuario__c> records = Database.query(query);
    //         System.debug('seguimientos : ' + records);
    //         for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : records) { 
    //             ObjectWrapper obj = new ObjectWrapper();
    //             obj.id = seguimiento.Id;
    //             obj.name = seguimiento.Name;
    //             obj.nameUrl = '/' + seguimiento.Id;
    //             obj.estado = seguimiento.Estado__c;
    //             obj.createdDate = seguimiento.CreatedDate;
    //             obj.profesionalUrl = '/' + seguimiento.Profesional__c;
    //             obj.profesional = seguimiento.Profesional__r.Name;
    //             obj.tipo = seguimiento.Tipo__c;
    //             obj.especialidad = seguimiento.Profesional__r.Primera_especialidad__c;
    //             if (matriculasNacionalesXProfesional.containsKey(seguimiento.Profesional__c)) {
    //                 obj.matriculaNacional = matriculasNacionalesXProfesional.get(seguimiento.Profesional__c).Numero_de_matricula__c;
    //             }
    //             if (matriculasProvincialesXProfesional.containsKey(seguimiento.Profesional__c)) {
    //                 obj.matriculaProvincial = matriculasProvincialesXProfesional.get(seguimiento.Profesional__c).Numero_de_matricula__c;
    //             }
    //             obj.institucionUrl = '/' + seguimiento.Institucion__c;
    //             obj.institucion = seguimiento.Institucion__r.Name;
    //             obj.ownerUrl = '/' + seguimiento.VisMed_APM__c;
    //             obj.owner = seguimiento.VisMed_APM__r.Name;
    //             response.add(obj);
    //         }
    //     }

    //     return response; 
    // }
    @AuraEnabled(cacheable=true) 
    public static List<ObjectWrapper> getData (String objeto, String recordTypeName, String estado, String user, List<String> users, String fechaInicio, String fechaFin) {
        System.debug('Fecha Inicio: ' + fechaInicio);
        System.debug('Fecha Fin: ' + fechaFin);
        String query;
        String usersList;
        String condicion =  (String.isNotBlank(estado) ? 'Estado__c = \'' + estado + '\'' : '');
        //Aca formo el string con la lista de usuarios en los combobox.
        for (String thisUser : users) {
            if (String.isNotBlank(usersList)) {
                usersList += ', ' + '\'' + thisUser + '\'';
            } else {
                usersList = '(' + '\'' + thisUser + '\'';
            }
        }
        usersList += ')';
        ///////////////////
        // Si no hay un usuario especifico seleccionado cargo los datos con los usuarios disponibles para elegir segun supervisor.
        if (String.isNotBlank(user)) {
            if (String.isNotBlank(condicion)) {
                condicion += ' AND VisMed_APM__c = \'' + user + '\'';
            } else {
                condicion += '';
            }
        } else if (!users.isEmpty()) {
            condicion += ' AND VisMed_APM__c IN ' + usersList;
        }
        condicion += (String.isNotBlank(recordTypeName) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' RecordType.DeveloperName = \'' + recordTypeName + '\'' : '');
        
        if (objeto.equals('Dan360_Licencia__c')) {
            if (String.isNotBlank(condicion)) {
                condicion += (String.isNotBlank(fechaInicio) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_inicio__c >= ' + fechaInicio : '');
                condicion += (String.isNotBlank(fechaFin) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_Fin__c <= ' + fechaFin : '');
                query =
                'SELECT Id, Name, Estado__c, CreatedDate, Fecha_de_inicio__c, Fecha_de_Fin__c, Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Cantidad_de_Dias__c, VisMed_Cantidad_de_Horas_Numerico__c, Comentarios__c FROM Dan360_Licencia__c WHERE ' +
                condicion;
            } else {
                query = 'SELECT Id, Name, Estado__c, CreatedDate, Fecha_de_inicio__c, Fecha_de_Fin__c, Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Cantidad_de_Dias__c, VisMed_Cantidad_de_Horas_Numerico__c, Comentarios__c FROM Dan360_Licencia__c';
            }
        } else if (objeto.equals('Dan360_Interacciones__c')){
            if (String.isNotBlank(condicion)) {
                condicion += (String.isNotBlank(fechaInicio) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' VisMed_Fecha__c >= ' + fechaInicio : '');
                condicion += (String.isNotBlank(fechaFin) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' VisMed_Fecha__c <= ' + fechaFin : '');
                query =
                    'SELECT Id, Name, Estado__c, CreatedDate, VisMed_Fecha__c, VisMed_Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Profesional__c, Profesional__r.Name, VisMed_Domicilio_de_la_Visita__c, VisMed_Domicilio_de_la_Visita__r.Name, VisMed_Comentarios__c, Aprobador_Final__c, Aprobador_Final__r.Name, Fecha_de_Aprobacion__c, Comentario_de_Aprobacion__c, RecordType.Name, VisMed_Tipo_de_Visita__c FROM Dan360_Interacciones__c WHERE ' +
                    condicion;
            } else {
                query = 'SELECT Id, Name, Estado__c, CreatedDate, VisMed_Fecha__c, VisMed_Motivo__c, VisMed_APM__c, VisMed_APM__r.Name, Profesional__c, Profesional__r.Name, VisMed_Domicilio_de_la_Visita__c, VisMed_Domicilio_de_la_Visita__r.Name, VisMed_Comentarios__c, Aprobador_Final__c, Aprobador_Final__r.Name, Fecha_de_Aprobacion__c, Comentario_de_Aprobacion__c, RecordType.Name, VisMed_Tipo_de_Visita__c FROM Dan360_Interacciones__c';
            }
        } else if(objeto.equals('VisMed_Bajas__c')) {
            if (String.isNotBlank(condicion)) {
                condicion += (String.isNotBlank(fechaInicio) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_Desactivacion__c >= ' + fechaInicio : '');
                condicion += (String.isNotBlank(fechaFin) ? (String.isNotBlank(condicion) ? +' AND ' : '') + ' Fecha_de_Reactivacion__c <= ' + fechaFin : '');
                query =
                    'SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Estado__c, Institucion__c, Institucion__r.Name, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, VisMed_APM__c, VisMed_APM__r.Name, Fecha_de_Reactivacion__c, Motivo_de_la_Baja__c, Fecha_de_Desactivacion__c, Comentario__c FROM VisMed_Bajas__c WHERE ' +
                    condicion;
            } else {
                query = 'SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Estado__c, Institucion__c, Institucion__r.Name, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, VisMed_APM__c, VisMed_APM__r.Name, Fecha_de_Reactivacion__c, Motivo_de_la_Baja__c, Fecha_de_Desactivacion__c, Comentario__c FROM VisMed_Bajas__c';
            }
        } else if(objeto.equals('VisMed_Contacto_Cuenta_Usuario__c')) {
            if (String.isNotBlank(condicion)) {
                condicion = condicion.replaceAll('Aprobada', 'Activo');
                query =
                    'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, Fecha_Solicitud__c,CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Institucion__c, Institucion__r.Name, Ultima_Visita__c, VisMed_APM__c, VisMed_APM__r.Name, Predeterminada__c, Estado__c, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE ' +
                    condicion;
            } else {
                query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, Fecha_Solicitud__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Institucion__c, Institucion__r.Name, Ultima_Visita__c, VisMed_APM__c, VisMed_APM__r.Name, Predeterminada__c, Estado__c, Profesional__c, Profesional__r.Name, Profesional__r.Primera_especialidad__c, Tipo__c FROM VisMed_Contacto_Cuenta_Usuario__c';
            }
        }
    
        query += ' Order By CreatedDate Desc ';
        System.debug('Query::: ' + query);

        Id recordTypeMatriculaNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
        Id recordTypeMatriculaProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
        Map<Id, Dan360_Matricula__c> matriculasNacionalesXProfesional = new Map<Id, Dan360_Matricula__c>();
        Map<Id, Dan360_Matricula__c> matriculasProvincialesXProfesional = new Map<Id, Dan360_Matricula__c>();
        List<Dan360_Matricula__c> matriculasNacionales = [SELECT Id, Name, RecordTypeId, Provincia__c, Numero_de_matricula__c, Profesional__c, Municipios__c FROM Dan360_Matricula__c WHERE RecordTypeId = :recordTypeMatriculaNacional];
        List<Dan360_Matricula__c> matriculasProvinciales = [SELECT Id, Name, RecordTypeId, Provincia__c, Numero_de_matricula__c, Profesional__c, Municipios__c FROM Dan360_Matricula__c WHERE RecordTypeId = :recordTypeMatriculaProvincial];
        System.debug(matriculasNacionales);
        for (Dan360_Matricula__c matricula : matriculasNacionales) {
            matriculasNacionalesXProfesional.put(matricula.Profesional__c, matricula);
        }
        System.debug(matriculasProvinciales);
        for (Dan360_Matricula__c matricula : matriculasProvinciales) {
            matriculasProvincialesXProfesional.put(matricula.Profesional__c, matricula);
        }

        List<ObjectWrapper> response = new List<ObjectWrapper>();

        if (objeto.equals('Dan360_Licencia__c')) {
            List<Dan360_Licencia__c> records = Database.query(query);
            System.debug('licentcias : ' + records);
            for (Dan360_Licencia__c licencia : records) { 
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = licencia.Id;
                obj.name = licencia.Name;
                obj.nameUrl = '/' + licencia.Id;
                obj.estado = licencia.Estado__c;
                obj.createdDate = licencia.CreatedDate;
                obj.fechaDeInicio = licencia.Fecha_de_inicio__c;
                obj.fechaDeFin = licencia.Fecha_de_Fin__c;
                obj.cantidadDeDias = licencia.Cantidad_de_Dias__c.format();
                obj.cantidadDeHoras = licencia.VisMed_Cantidad_de_Horas_Numerico__c.format();
                obj.motivo = licencia.Motivo__c;
                obj.ownerUrl = '/' + licencia.VisMed_APM__c;
                obj.owner = licencia.VisMed_APM__r.Name;
                obj.comentario = licencia.Comentarios__c;
                response.add(obj);
            }
        } else if (objeto.equals('Dan360_Interacciones__c')){
            List<Dan360_Interacciones__c> records = Database.query(query);
            System.debug('interacciones : ' + records);
            for (Dan360_Interacciones__c interaccion : records) { 
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = interaccion.Id;
                obj.name = interaccion.Name;
                obj.nameUrl = '/' + interaccion.Id;
                obj.estado = interaccion.Estado__c;
                obj.createdDate = interaccion.CreatedDate;
                obj.fechaDeInicio = interaccion.VisMed_Fecha__c;
                obj.motivo = interaccion.VisMed_Motivo__c;
                obj.profesionalUrl = '/' + interaccion.Profesional__c;
                obj.profesional = interaccion.Profesional__r.Name;
                if (interaccion.VisMed_Domicilio_de_la_Visita__c == null){
                    obj.institucionUrl = '';
                    obj.institucion = '';
                } else {
                    obj.institucionUrl = '/' + interaccion.VisMed_Domicilio_de_la_Visita__c;
                    obj.institucion = interaccion.VisMed_Domicilio_de_la_Visita__r.Name;
                }
                obj.ownerUrl = '/' + interaccion.VisMed_APM__c;
                obj.owner = interaccion.VisMed_APM__r.Name;
                obj.comentario = interaccion.VisMed_Comentarios__c;
                obj.recordType = interaccion.RecordType.Name;
                obj.tipoDeVisita = interaccion.VisMed_Tipo_de_Visita__c;
                response.add(obj);
            }
        } else if (objeto.equals('VisMed_Bajas__c')) {
            List<VisMed_Bajas__c> records = Database.query(query);
            System.debug('interacciones : ' + records);
            for (VisMed_Bajas__c baja : records) { 
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = baja.Id;
                obj.name = baja.Name;
                obj.nameUrl = '/' + baja.Id;
                obj.estado = baja.Estado__c;
                obj.createdDate = baja.CreatedDate;
                obj.institucionUrl = '/' + baja.Institucion__c;
                obj.institucion = baja.Institucion__r.Name;
                obj.fechaDeInicio = baja.Fecha_de_Desactivacion__c;
                obj.fechaDeFin = baja.Fecha_de_Reactivacion__c;
                obj.motivo = baja.Motivo_de_la_Baja__c;
                obj.profesionalUrl = '/' + baja.Profesional__c;
                obj.profesional = baja.Profesional__r.Name;
                obj.especialidad = baja.Profesional__r.Primera_especialidad__c;
                if (matriculasNacionalesXProfesional.containsKey(baja.Profesional__c)) {
                    obj.matriculaNacional = matriculasNacionalesXProfesional.get(baja.Profesional__c).Numero_de_matricula__c;
                }
                if (matriculasProvincialesXProfesional.containsKey(baja.Profesional__c)) {
                    obj.matriculaProvincial = matriculasProvincialesXProfesional.get(baja.Profesional__c).Numero_de_matricula__c;
                }
                obj.ownerUrl = '/' + baja.VisMed_APM__c;
                obj.owner = baja.VisMed_APM__r.Name;
                obj.comentario = baja.Comentario__c;
                obj.recordType = baja.RecordType.Name;
                response.add(obj);
            }
        } else if (objeto.equals('VisMed_Contacto_Cuenta_Usuario__c')){
            List<VisMed_Contacto_Cuenta_Usuario__c> records = Database.query(query);
            System.debug('seguimientos : ' + records);
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : records) { 
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = seguimiento.Id;
                obj.name = seguimiento.Name;
                obj.nameUrl = '/' + seguimiento.Id;
                obj.estado = seguimiento.Estado__c;
                obj.createdDate = seguimiento.CreatedDate;
                obj.fechaSolicitud = seguimiento.Fecha_Solicitud__c;
                obj.profesionalUrl = '/' + seguimiento.Profesional__c;
                obj.profesional = seguimiento.Profesional__r.Name;
                obj.tipo = seguimiento.Tipo__c;
                obj.especialidad = seguimiento.Profesional__r.Primera_especialidad__c;
                if (matriculasNacionalesXProfesional.containsKey(seguimiento.Profesional__c)) {
                    obj.matriculaNacional = matriculasNacionalesXProfesional.get(seguimiento.Profesional__c).Numero_de_matricula__c;
                }
                if (matriculasProvincialesXProfesional.containsKey(seguimiento.Profesional__c)) {
                    obj.matriculaProvincial = matriculasProvincialesXProfesional.get(seguimiento.Profesional__c).Numero_de_matricula__c;
                }
                obj.institucionUrl = '/' + seguimiento.Institucion__c;
                obj.institucion = seguimiento.Institucion__r.Name;
                obj.ownerUrl = '/' + seguimiento.VisMed_APM__c;
                obj.owner = seguimiento.VisMed_APM__r.Name;
                response.add(obj);
            }
        }

        return response; 
    }

    @AuraEnabled
    public static List<ObjectWrapper> updateRecord (List<String> recordsId, String objeto, String comentario, String estado, String user) {
        List<ObjectWrapper> response = new List<ObjectWrapper>();
        if (estado == 'Aprobada') {
            estado = 'Approve';
        } else {
            estado = 'Reject';
        }
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId 
                                                    FROM ProcessInstanceWorkitem 
                                                    WHERE ProcessInstance.TargetObjectId IN :recordsId 
                                                ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction(estado);
            req.setComments(comentario);
            requests.add(req);
        }
        system.debug('request '+ requests);
        Approval.ProcessResult[] processResults = Approval.process(requests); 
        System.debug('proccessResults '+ processResults);
        // for (Approval.ProcessResult process : processResults) {
        //     System.debug('proccessResults '+ process.isSuccess());
        //     if (process.isSuccess()) {
        //         ObjectWrapper obj = new ObjectWrapper();
        //         obj.approvalProccessStatus = 'Correcto';
        //         response.add(obj);
        //     }
        // }
        
        return response;
    }

    @TestVisible
    private class ObjectWrapper{
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String nameUrl {get;set;}
        @AuraEnabled
        public Datetime createdDate {get;set;}
        @AuraEnabled
        public Date fechaSolicitud {get;set;}
        @AuraEnabled
        public Date fechaDeInicio {get;set;}
        @AuraEnabled
        public Date fechaDeFin {get;set;}
        @AuraEnabled
        public String motivo {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String ownerUrl {get;set;}
        @AuraEnabled
        public String estado {get;set;}
        @AuraEnabled
        public String profesional {get;set;}
        @AuraEnabled
        public String profesionalUrl {get;set;}
        @AuraEnabled
        public String institucion {get;set;}
        @AuraEnabled
        public String institucionUrl {get;set;}
        @AuraEnabled
        public String aprobador {get;set;}
        @AuraEnabled
        public String aprobadorUrl {get;set;}
        @AuraEnabled
        public Date fechaDeAprobacion {get;set;}
        @AuraEnabled
        public String comentarioDeAprobacion {get;set;}
        @AuraEnabled
        public String recordType {get;set;}
        @AuraEnabled
        public String tipoDeVisita {get;set;}
        @AuraEnabled
        public String comentario {get;set;}
        @AuraEnabled
        public String cantidadDeDias {get;set;}
        @AuraEnabled
        public String cantidadDeHoras {get;set;}
        @AuraEnabled
        public String matriculaNacional {get;set;}
        @AuraEnabled
        public String matriculaProvincial {get;set;}
        @AuraEnabled
        public String especialidad {get;set;}
        @AuraEnabled
        public String tipo {get;set;}
        // @AuraEnabled
        // public String approvalProccessStatus {get;set;}
    }

}