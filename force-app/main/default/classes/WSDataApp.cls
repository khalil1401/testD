@RestResource(urlMapping='/data/*')
global without sharing class WSDataApp {
    
    @HttpGet
    global static Respuesta doGet(){
        Integer queryLimit = 2000;
        
        Date fechaActual = System.today();
        
        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        respuesta.sobjects = new List<SObject>();
        Map<String, String> headers = new Map<String, String>();
        
        for(String header : req.headers.keySet()){
            System.debug('header:::' + header); 
            if(header.toLowerCase() != 'iddeluser'){
                if(header == 'profesional' || header == 'institucion'){
                    headers.put(header, req.headers.get(header));
                } else {
                    headers.put(header.toLowerCase(),req.headers.get(header).toLowerCase());
                }
                
            }
            else{
                headers.put(header.toLowerCase(),req.headers.get(header));
            }
        }
        
        String lastSyncString = headers.containsKey('lastsync') ? headers.get('lastsync') : null;
        String token = headers.containsKey('token') ? headers.get('token') : null;
        String objeto = headers.containsKey('objeto') ? headers.get('objeto') : null; 
        String ultimaSincronizacion = headers.containsKey('ultimasincronizacion') ? headers.get('ultimasincronizacion') : null; 
        id user = headers.containsKey('iddeluser') ? id.valueOf(headers.get('iddeluser')) : null;
        String profesionalHeader = headers.containsKey('profesional') ? headers.get('profesional') : null;
        String institucionHeader = headers.containsKey('institucion') ? headers.get('institucion') : null;
        String lastId = headers.containsKey('lastid') ? id.valueOf(headers.get('lastid'),true) : '';

        System.debug('Objeto: ' + objeto);
        System.debug('profesionalHeader: ' + profesionalHeader);
        System.debug('institucionHeader: ' + institucionHeader);
        System.debug('Id Del User: ' + user);
        System.debug('Ultima Sicronizacion String: ' + ultimaSincronizacion);
        System.debug('lastId: ' + lastId);

        //Integer offset = UserInfo.getTimezone().getOffset(DateTime.parse(ultimaSincronizacion));
        Datetime ultimaSincronizacionDate = (DateTime)JSON.deserialize('"' + ultimaSincronizacion + '"', DateTime.class);
        //DateTime ultimaSincronizacionDate = DateTime.parse(ultimaSincronizacion); 
        System.debug('Ultima Sicronizacion GMT Date: ' + ultimaSincronizacionDate);
        //System.debug('Ultima Sicronizacion Local Date: ' + DateTime.parse(ultimaSincronizacion).addSeconds(offset/1000));
        

        Id recordAPM = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
        Contact apm = [SELECT Id FROM Contact WHERE OwnerId = :user AND RecordTypeId = : recordAPM LIMIT 1];
        
        if (objeto == 'institucion') {
            Set<Id> recordTypeIntituciones = new Set<Id>();
            List<Id> instituciones = new List<Id>();
            recordTypeIntituciones.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId());            
            recordTypeIntituciones.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Consultorio').getRecordTypeId());            
            recordTypeIntituciones.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Farmacia').getRecordTypeId());       
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, Profesional__c, Institucion__C 
                                                                        FROM VisMed_Contacto_Cuenta_Usuario__c 
                                                                        WHERE VisMed_APM__r.OwnerId  = :user AND (Estado__c = 'Activo' OR Estado__c = 'Baja Temporal' OR Estado__c = 'Pendiente')];     
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (!instituciones.contains(seguimiento.Institucion__c)) {
                    instituciones.add(seguimiento.Institucion__c);
                }
            }
            respuesta.sobjects = [SELECT Id, LastName, FirstName, Name, OwnerId, Piso__c, Departamento__c, Phone, RecordType.Name, BillingStreet, BillingCity, BillingPostalCode, 
                                        BillingState, IsDeleted, Type, Provincia__c, Localidad__c, Codigo_postal__c
                                    FROM Account
                                    WHERE RecordTypeId IN :recordTypeIntituciones AND Id IN :instituciones AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit 
                                    ALL ROWS];
        } 
        else if (objeto == 'all institucion') {
            Set<Id> recordTypeIntituciones = new Set<Id>();
            recordTypeIntituciones.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId());            
            recordTypeIntituciones.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Consultorio').getRecordTypeId());            
            recordTypeIntituciones.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Farmacia').getRecordTypeId());       
            
            respuesta.sobjects = [SELECT Id, LastName, FirstName, Name, OwnerId, Piso__c, Departamento__c, Phone, RecordType.Name, BillingStreet, BillingCity, BillingPostalCode, BillingState
                                    FROM Account
                                    WHERE RecordTypeId IN :recordTypeIntituciones
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit];
        } 
        else if (objeto == 'profesional de la salud') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
            List<Id> profesionales = new List<Id>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, Profesional__c, Institucion__C 
                                                                    FROM VisMed_Contacto_Cuenta_Usuario__c 
                                                                    WHERE VisMed_APM__r.OwnerId  = :user /* AND (Estado__c = 'Activo' OR Estado__c = 'Baja Temporal' OR Estado__c = 'Pendiente') */];     
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (!profesionales.contains(seguimiento.Profesional__c)) {
                    profesionales.add(seguimiento.Profesional__c);
                }
            }  
            
            system.debug('banderilla recordTypeProfesional > ' + recordTypeProfesional );
            system.debug('banderilla profesionales > ' + profesionales );
            system.debug('banderilla ultimaSincronizacionDate > ' + ultimaSincronizacionDate );
            system.debug('banderilla lastId > ' + lastId );
            system.debug('banderilla queryLimit > ' + queryLimit );
 
            // Esta es la parte del codigo que trae los datos que funcionan con los filtros de FICHERO

            respuesta.sobjects = [SELECT Id, MiddleName, LastName, FirstName, Name, PersonContactId,OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, PersonBirthdate, IsDeleted,
                                        PersonEmail,Genero__c,Profesional_Activo__c,Edad_del_Profesional__c, Derivador__c, Phone, KOL__c, Prefiere_Nutricia__c, PAC_0_12_MESES_SEM_C_COB_SOC__c, 
                                        PAC_0_12_MESES_SEM_C_COB_SOC_C_APLV__c, PAC_0_12_MESES_SEM_SIN_COB_SOC__c, PAC_0_12_MESES_SEM_SIN_COB_SOC_C_APLV__c, 
                                        COBERTURA_DE_PACIENTES_PREDOMINANTE__c, COLOR_HCP__c, TIPO_HCP__c, PAC_13_24_MESES_SEM_C_COB_SOC__c, PAC_13_24_MESES_SEM_C_COB_SOC_C_APLV__c, 
                                        PAC_13_24_MESES_SEM_SIN_COB_SOC__c, PAC_13_24_MESES_SEM_SIN_COB_SOC_C_APLV__c, X1ERA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, 
                                        X2DA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, X3ERA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, Trabaja_en_Institucion_Top__c, INSTITUCION_TOP__c, 
                                        Promedio_de_pacientes_Nicho__c, Como_trabaja__c, Sub_Equipo__pc, VisMed_Equipo__pc, VisMed_Areas_Terap_uticas__pc,
                                  		VisMed_UsaAlgunaHerramientaTelemedicina__c,VisMed_QueTanAdeptoALaTecnologiaEs__c,VisMed_CualTelemedicina__c,VisMed_NivelDeIngles__c, Provincia__c, Localidad__c, Codigo_postal__c, BillingCity, BillingPostalCode, BillingState, PREFIERE_NUTRICIA_ALERGIA__c, ALER_PAC_0_12_MESES_SEM_C_COB_SOC_C_APLV__c, ALER_PAC_0_12_MES_SEM_SIN_COB_SOC_C_APLV__c, ALER_PAC_13_24_MES_SEM_C_COB_SOC_C_APLV__c, ALER_PAC_13_24_MES_SEM_S_COB_SOC_C_APLV__c
                                    FROM Account
                                    WHERE RecordTypeId = :recordTypeProfesional AND Id IN :profesionales AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'all profesional de la salud') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
            
            respuesta.sobjects = [SELECT Id, MiddleName, LastName, FirstName, Name, PersonContactId,OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, PersonBirthdate,
                                    PersonEmail,Genero__c,Profesional_Activo__c,Edad_del_Profesional__c, Phone, KOL__c, Prefiere_Nutricia__c, PAC_0_12_MESES_SEM_C_COB_SOC__c, PAC_0_12_MESES_SEM_C_COB_SOC_C_APLV__c, PAC_0_12_MESES_SEM_SIN_COB_SOC__c, PAC_0_12_MESES_SEM_SIN_COB_SOC_C_APLV__c, COBERTURA_DE_PACIENTES_PREDOMINANTE__c, COLOR_HCP__c, TIPO_HCP__c, PAC_13_24_MESES_SEM_C_COB_SOC__c, PAC_13_24_MESES_SEM_C_COB_SOC_C_APLV__c, PAC_13_24_MESES_SEM_SIN_COB_SOC__c, PAC_13_24_MESES_SEM_SIN_COB_SOC_C_APLV__c, X1ERA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, X2DA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, X3ERA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, Trabaja_en_Institucion_Top__c, INSTITUCION_TOP__c, Promedio_de_pacientes_Nicho__c, Como_trabaja__c, Sub_Equipo__pc, VisMed_Equipo__pc, VisMed_Areas_Terap_uticas__pc, Codigo_postal__c, BillingCity, BillingPostalCode, BillingState, PREFIERE_NUTRICIA_ALERGIA__c, ALER_PAC_0_12_MESES_SEM_C_COB_SOC_C_APLV__c, ALER_PAC_0_12_MES_SEM_SIN_COB_SOC_C_APLV__c, ALER_PAC_13_24_MES_SEM_C_COB_SOC_C_APLV__c, ALER_PAC_13_24_MES_SEM_S_COB_SOC_C_APLV__c
                                    FROM Account
                                    WHERE RecordTypeId = :recordTypeProfesional
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit];
        }
        else if (objeto == 'all profesional') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
            
            respuesta.sobjects = [SELECT Id, LastName, FirstName, Name, PersonContactId,OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, PersonBirthdate,
                                    PersonEmail,Genero__c,Profesional_Activo__c,Edad_del_Profesional__c, Phone, KOL__c, Prefiere_Nutricia__c, PAC_0_12_MESES_SEM_C_COB_SOC__c, PAC_0_12_MESES_SEM_C_COB_SOC_C_APLV__c, PAC_0_12_MESES_SEM_SIN_COB_SOC__c, PAC_0_12_MESES_SEM_SIN_COB_SOC_C_APLV__c, COBERTURA_DE_PACIENTES_PREDOMINANTE__c, COLOR_HCP__c, TIPO_HCP__c, PAC_13_24_MESES_SEM_C_COB_SOC__c, PAC_13_24_MESES_SEM_C_COB_SOC_C_APLV__c, PAC_13_24_MESES_SEM_SIN_COB_SOC__c, PAC_13_24_MESES_SEM_SIN_COB_SOC_C_APLV__c, X1ERA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, X2DA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, X3ERA_OOSS_POR_LA_CUAL_PRESCRIBE_TN__c, Trabaja_en_Institucion_Top__c, INSTITUCION_TOP__c, Promedio_de_pacientes_Nicho__c, Como_trabaja__c, Sub_Equipo__pc, VisMed_Equipo__pc, VisMed_Areas_Terap_uticas__pc, Codigo_postal__c, BillingCity, BillingPostalCode, BillingState, PREFIERE_NUTRICIA_ALERGIA__c, ALER_PAC_0_12_MESES_SEM_C_COB_SOC_C_APLV__c, ALER_PAC_0_12_MES_SEM_SIN_COB_SOC_C_APLV__c, ALER_PAC_13_24_MES_SEM_C_COB_SOC_C_APLV__c, ALER_PAC_13_24_MES_SEM_S_COB_SOC_C_APLV__c
                                    FROM Account
                                    WHERE RecordTypeId = :recordTypeProfesional
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit];
        } 
        else if (objeto == 'otro profesional') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId(); 
            List<Id> profesionales = new List<Id>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [SELECT Id, Profesional__c, Institucion__C 
                                                                    FROM VisMed_Contacto_Cuenta_Usuario__c 
                                                                    WHERE VisMed_APM__r.OwnerId  = :user AND (Estado__c = 'Activo' OR Estado__c = 'Baja Temporal' OR Estado__c = 'Pendiente')];     
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientos) {
                if (!profesionales.contains(seguimiento.Profesional__c)) {
                    profesionales.add(seguimiento.Profesional__c);
                }
            }
            respuesta.sobjects = [SELECT Id, LastName, FirstName, PersonContactId,PersonEmail, Genero__c, PersonBirthdate, Edad_del_Profesional__c, DNI__c,  Name, OwnerId, Primera_especialidad__c, 
                                        Segunda_especialidad__c, Tercera_especialidad__c, VisMed_Areas_Terap_uticas__pc, IsDeleted, Codigo_postal__c
                                    FROM Account
                                    WHERE RecordTypeId = :recordTypeProfesional AND Id IN :profesionales
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'all otro profesional') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId(); 
            
            respuesta.sobjects = [SELECT Id, LastName, FirstName, PersonContactId,PersonEmail, Genero__c, PersonBirthdate, Edad_del_Profesional__c, DNI__c,  Name, OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, VisMed_Areas_Terap_uticas__pc
                                    FROM Account
                                    WHERE RecordTypeId = :recordTypeProfesional
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit];
        } 
        else if (objeto == 'ciclo') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, Anio__c, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_Cmpt_Tiempo_no_promocional__c, 
                                        Numero_de_mes__c
                                    FROM VisMed_Ciclo__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'efectividad') {
            respuesta.sobjects = [SELECT Id, IsDeleted, Name, CreatedDate, VisMed_Dias_de_Licencia_Unicos__c, 
                                        VisMed_Codigo_de_duplicidad__c, Dias_de_Licencia_Transcurridos__c, VisMed_Promedio__c, Dias_feriados_Transcurridos__c, Dias_de_Licencia__c, Tiempo_no_promocional__c, 
                                        Dias_feriados__c, Fecha_de_inicio__c, Fecha_de_Fin__c, Dias_de_campo_efectivo__c, Dias_habiles_transcurridos__c, VisMed_Visitas_restantes__c, Dias_Totales_del_Ciclo__c, VisMed_APM__c, 
                                        VisMed_Target_Diario__c, Dias_habiles_del_ciclo__c, VisMed_Visitas_realizadas__c, VisMed_Ciclo__c, VisMed_Efectividad__c, VisMed_Cmpt_Tiempo_no_promocional__c
                                    FROM Dan360_Efectividad__c
                                    WHERE VisMed_APM__r.OwnerId = :user AND Fecha_de_inicio__c <= :fechaActual AND CreatedDate >= LAST_N_YEARS:2 AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'interaccion') {
            Date currentDate = System.today();
            Integer monthForQuery  = currentDate.month();
            Integer yearForQuery = currentDate.year();
            if(currentDate.month() == 1 ){
                monthForQuery = 12;
                yearForQuery = yearForQuery - 1;
            }
            Datetime myDateTimeToDay1 = Datetime.newInstance( yearForQuery , monthForQuery, 1, 0,0,0);
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, RecordTypeId, Estado__c, Accion_por_cuenta__c, VisMed_Domicilio_de_la_Visita__c, 
                                    VisMed_APM__c, VisMed_Tipo_de_Visita__c, VisMed_Motivo__c, VisMed_Efectividad__c, VisMed_Canal__c, 
                                    VisMed_Comentarios__c, VisMed_Fecha__c, Profesional__c, Interaccion__c, Editable__c
                                    FROM Dan360_Interacciones__c
                                    WHERE VisMed_APM__r.OwnerId = :user AND CreatedDate >= LAST_N_YEARS:2 AND LastModifiedDate >= :myDateTimeToDay1
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'licencia') {
            respuesta.sobjects = [SELECT Id, IsDeleted, CreatedDate, Name, RecordTypeId, Motivo__c, Fecha_de_inicio__c, Fecha_de_Fin__c, Estado__c, Comentarios__c, Cantidad_de_Horas__c, 
                                        Cantidad_de_Dias__c, VisMed_Cantidad_de_Horas_Numerico__c, Efectividad__c, Cantidad_de_Horas_Valor__c, VisMed_APM__c, Editable__c
                                    FROM Dan360_Licencia__c
                                    WHERE VisMed_APM__r.OwnerId = :user AND CreatedDate >= LAST_N_YEARS:2 AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'seguimiento') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, Fecha_Solicitud__c, Institucion__c, Ultima_Visita__c, VisMed_APM__c, Tipo__c, Predeterminada__c, Estado__c, 
                                        Profesional__c, Frecuencia__c, Inicio_de_Frecuencia__c, Aun_Quedan_Meses__c, Visitas_Realizadas__c, Visitas_Restantes__c, Segmenta_Por__c, 
                                        Categoria__c, Plan__c, Estado_de_aprobacion__c, Fecha_de_Aprobacion__c, VisMed_Semaforo__c, Profesional__r.Codigo_postal__c,Institucion__r.BillingState, Institucion__r.BillingCity, Institucion__r.BillingPostalCode
                                    FROM VisMed_Contacto_Cuenta_Usuario__c
                                    WHERE VisMed_APM__r.OwnerId  = :user/*  AND (Estado__c = 'Activo' OR Estado__c = 'Baja Temporal' OR Estado__c = 'Pendiente') */ AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        }
        else if (objeto == 'seguimientostatus') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, Institucion__c, Ultima_Visita__c, VisMed_APM__c, Tipo__c, Predeterminada__c, Estado__c, 
                                        Profesional__c, Frecuencia__c, Inicio_de_Frecuencia__c, Aun_Quedan_Meses__c, Visitas_Realizadas__c, Visitas_Restantes__c, Segmenta_Por__c, 
                                        Categoria__c, Plan__c, Estado_de_aprobacion__c, Fecha_de_Aprobacion__c, Profesional__r.Codigo_postal__c, Institucion__r.BillingState, Institucion__r.BillingCity, Institucion__r.BillingPostalCode
                                    FROM VisMed_Contacto_Cuenta_Usuario__c
                                    WHERE VisMed_APM__r.OwnerId  = :user AND Profesional__c = :profesionalHeader AND Institucion__c = :institucionHeader
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        }
        else if (objeto == 'equipo de cuentas') {
            respuesta.sobjects = [SELECT Id, AccountId, UserId, TeamMemberRole, PhotoUrl, Title, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, CreatedDate, CreatedById, 
                                    LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted
                                    FROM AccountTeamMember
                                    WHERE UserId = :user AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS]; //comentario para borrar
        }
        else if (objeto == 'matricula') {
            respuesta.sobjects = [SELECT Id, IsDeleted, CreatedDate, Name, RecordTypeId, Provincia__c, Numero_de_matricula__c, Profesional__c, Municipios__c
                                    FROM Dan360_Matricula__c 
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        }
        else if (objeto == 'lugares de trabajo') {
            respuesta.sobjects = [SELECT Id, IsDeleted, CreatedDate, Name, Cargo__c, Dias_de_Atencion__c, Institucion__c, Profesional__c
                                    FROM Dan360_Lugar_de_Trabajo__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        }
        else if (objeto == 'recordstype') {
            respuesta.sobjects = [SELECT Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, 
                                        LastModifiedById, LastModifiedDate, SystemModstamp FROM RecordType 
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit];
        }
        else if (objeto == 'bajas') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, RecordTypeId, Estado__c, Profesional__c, VisMed_APM__c, Fecha_de_Reactivacion__c, Motivo_de_la_Baja__c, 
                                    Fecha_de_Desactivacion__c, Comentario__c,Institucion__c
                                    FROM VisMed_Bajas__c 
                                    WHERE OwnerId = :user AND CreatedDate >= LAST_N_YEARS:2 AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                  ALL ROWS];
        } 
        else if (objeto == 'stockXciclo') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, Ciclo__c, APM__c, Anio__c, Mes__c 
                                    FROM Stock_x_Ciclo__c 
                                    WHERE APM__r.OwnerId = :user AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                  ALL ROWS];  
        } 
        else if (objeto == 'stockxMM') {
            respuesta.sobjects = [SELECT Id, IsDeleted, CreatedDate, Name, Stock_x_Ciclo__c, Muestra_Medica__c, Remanente__c, Recibido__c, Entregado__c, Total__c, Ciclo__c, APM__c, 
                                    Stock_x_Ciclo__r.OwnerId, Muestra_Medica_Name__c 
                                  FROM Stock_x_MM__c 
                                  WHERE Stock_x_Ciclo__r.OwnerId = :user AND LastModifiedDate >= :ultimaSincronizacionDate
                                  AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                  ALL ROWS];            
        } 
        else if (objeto == 'muestras de las visitas') {
            respuesta.sobjects = [SELECT Id, IsDeleted, CreatedDate, Name, Stock_x_MM__c, Interaccion__c, Cantidad__c, Muestra_Medica__c 
                                    FROM Muestras_Entregadas__c
                                    WHERE Interaccion__r.OwnerId = :user AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'notificacion') {
            respuesta.sobjects = [SELECT Id, IsDeleted, CreatedDate, Name, Cuerpo__c, Leido__c, Relacion__c, APM__c, Id_del_Objeto__c 
                                    FROM Notificacion__c 
                                    WHERE APM__c = :apm.Id AND Leido__c = false AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'receta'){ 
            respuesta.sobjects = [SELECT Id, Name, CreatedDate, Producto__c, Cantidad__c, Cuatrimestre__c, Profesional_de_la_receta__c, IsDeleted
                                    FROM VisMed_Receta__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'producto de receta') {
            respuesta.sobjects = [SELECT Id, OwnerId, CreatedDate, Name, Id_SAP__c, Compania__c, Sub_Etapa__c, IsDeleted
                                    FROM VisMed_ProductoDeReceta__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'cuatrimestre') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, Fecha_inicio__c, Fecha_fin__c 
                                    FROM VisMed_Cuatrimestre__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        }
        else if (objeto == 'objetivo') {
            respuesta.sobjects = [SELECT Id, OwnerId, CreatedDate, Name, VisMed_DescripcionObjetivo__c, VisMed_FechaInicio__c, VisMed_FechaFin__c, IsDeleted, Estado__c
                                    FROM VisMed_Objetivo__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'objetivoXcuenta') {
            respuesta.sobjects = [SELECT Id, Name, CreatedDate, VisMed_FechaInicio__c, VisMed_FechaFin__c, VisMed_PorcentajeAvance__c, VisMed_Objetivo__c, 
                                        VisMed_CantidadAcciones__c, VisMed_SumatoriaPorcentajesAcciones__c, VisMed_APM__c, IsDeleted
                                    FROM visMed_ObjetivoPorCuenta__c 
                                    WHERE VisMed_APMContacto__c = :apm.Id AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'accion') {
            respuesta.sobjects = [SELECT Id, Name, CreatedDate, VisMed_Objetivo__c, VisMed_DescripcionAccion__c, VisMed_FechaInicio__c, VisMed_FechaFin__c, IsDeleted, Estado__c
                                    FROM VisMed_Accion__c
                                    WHERE LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'accionXcuenta') {
            respuesta.sobjects = [SELECT Id, Name, CreatedDate, VisMed_Objetivo__c, VisMed_Accion__c, VisMed_ObjetivoPorCuenta__c, VisMed_PromedioAvance__c, 
                                    VisMed_APM__c, IsDeleted 
                                    FROM VisMed_AccionPorCuenta__c 
                                    WHERE VisMed_APMContacto__c = :apm.Id AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        } 
        else if (objeto == 'logs') {
            respuesta.sobjects = [SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CreatedDate, id_app__c, json__c, json2__c, Mensaje__c, Objeto__c, Usuario__c
                                    FROM AppLog__c
                                    WHERE OwnerId = :user AND LastModifiedDate >= :ultimaSincronizacionDate
                                    AND ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit
                                    ALL ROWS];
        }else if (objeto == 'Grilla') {
            respuesta.sobjects = [SELECT id, Name, Plan__r.Name, Segmento__r.Name , Orden__c 
                                    FROM Grilla__c 
                                    WHERE ID > :lastId
                                    ORDER BY ID ASC
                                    LIMIT :queryLimit];
        }
        
        if(respuesta.sobjects.size() == queryLimit){
            respuesta.hasNext = true;
            respuesta.lastId = respuesta.sobjects[respuesta.sobjects.size()-1].id;
        } else {
            respuesta.hasNext = false;
            respuesta.lastId = '';
        }
        return respuesta;
    }
    
    @HttpPost
    global static Respuesta doPost() {
        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        
        String jsonStr = req.requestBody.toString();
        System.debug(jsonStr);
        Request request = (Request)JSON.deserialize(jsonStr, Request.class);
        System.debug(request);
        
        String objeto = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        SObjectType objectType = Schema.getGlobalDescribe().get(objeto);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        System.debug(objeto);
        System.debug(mfields);
        Id currentUser = request.user;
        DateTime fechaDeModificacionDelRegistro = request.fechaDeModificacionDelRegistro;
        System.debug(fechaDeModificacionDelRegistro);
        
        respuesta.sobjects = new List<SObject>();
        
        system.debug(request.recordsFromApp);
        if (request.recordsFromApp != null && request.recordsFromApp.size()>0) {  
           
            List<Id> recordsId = new List<Id>();
            List<SObject> newRecordsFromAppMap = New List<SObject>(); //Registros que no tengan un Id desde el JSON significa que son nuevos.
            Map<Id, SObject> updateRecordsFromAppMap = New Map<Id, SObject>(); 
            Map<Id, SObject> salesforceObjectsMap = New Map<Id, SObject>();
            List<SObject> recordsForUpsert = New List<SObject>();
            String error = '';
            String appId = '';
            for (Sobject objWrapper : request.recordsFromApp) {
                system.debug('recordId: '+ objWrapper.Id);
                Map<String,Object> mapKeysValuesRegistro = objWrapper.getPopulatedFieldsAsMap();
                Map<String,List<SObject>> mapaToUpsert = new Map<String,List<SObject>>();
                
                for(String clave : mapKeysValuesRegistro.keySet()){
                    System.debug('clave');
                    if(clave == 'ID_App__c'){
                        appId = (String)mapKeysValuesRegistro.get(clave);
                        System.debug(appId);
                    }
                    if(clave.containsIgnoreCase('__r')){
                        List<SObject> newList = new List<SObject>();
                        if(!mapaToUpsert.containsKey(clave)){
                            SObject registro = (SObject)mapKeysValuesRegistro.get(clave);
                            newList.add(registro);
                        }
                        else{
                            newList = mapaToUpsert.get(clave);
                            SObject registro = (SObject)mapKeysValuesRegistro.get(clave);
                            newList.add(registro);
                        }
                        mapaToUpsert.put(clave,newList);
                    }
                }

                if (mfields.containsKey('Editable__c')) {
                    objWrapper.put('Editable__c', false);
                }
               
                if (String.isNotBlank(objWrapper.Id) && objWrapper.Id != null) {
                    if (mfields.containsKey('OwnerId')) {
                        try {
                            objWrapper.put('OwnerId', currentUser); //Agrego el Owner del registro. Si el registro es parte de una relacion Principal-Detalle entonces entraria al catch.
                        } catch(Exception ex) {
                            system.debug(ex.getMessage());
                        }
                    }              
                    recordsId.add(objWrapper.Id);
                    updateRecordsFromAppMap.put(objWrapper.Id, objWrapper);
                    System.debug(updateRecordsFromAppMap);
                }
                else {
                    if (mfields.containsKey('OwnerId')) {
                        try {
                            objWrapper.put('OwnerId', currentUser); //Agrego el Owner del registro. Si el registro es parte de una relacion Principal-Detalle entonces entraria al catch.
                        } catch(Exception ex) {
                            system.debug(ex.getMessage());
                        }
                    }   
                    newRecordsFromAppMap.add(objWrapper);
                    System.debug(newRecordsFromAppMap);
                }
            }

            String query = 'SELECT Id, LastModifiedDate FROM ' + objeto + ' WHERE Id IN :recordsId AND LastModifiedDate > :fechaDeModificacionDelRegistro';
            salesforceObjectsMap = new Map<Id, SObject>(Database.query(query));
            System.debug(salesforceObjectsMap);
            if (!salesforceObjectsMap.isEmpty()) {
                for (SObject recordFromSalesfoce : salesforceObjectsMap.values()) {
                    if (updateRecordsFromAppMap.containsKey(recordFromSalesfoce.Id)) { //Si la fecha de modificacion del registro en Salesforce es mas actual que la que se tiene guardado en la App entonces se prioriza la de salesforce.
                        updateRecordsFromAppMap.remove(updateRecordsFromAppMap.get(recordFromSalesfoce.Id).Id);
                    }
                }
            }
            System.debug(updateRecordsFromAppMap);
            recordsForUpsert.addAll(updateRecordsFromAppMap.values());
            recordsForUpsert.addAll(newRecordsFromAppMap);
            if(!recordsForUpsert.isEmpty()){
                System.debug(recordsForUpsert);
                try{
                    Database.UpsertResult[] srList = Database.upsert(recordsForUpsert, false);
                    System.debug('Insert');
                    System.debug(srList);
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess()) {
                            respuesta.sobjects = recordsForUpsert;
                            respuesta.status = 200;
                            respuesta.message = 'OK';                   
                            System.debug(sr);
                            return Respuesta;
                        } 
                        else {
                            List<String> splitMessage = new List<String>();
                            List<SObject> listquerySF = new List<SObject>();
                            String querySF = 'SELECT Id, ID_App__c FROM ' + objeto + ' WHERE ID_App__c = :appId';
                            listquerySF = Database.query(querySF);
                            if(listquerySF.size() == 0){
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('Error');
                                    //insert de log dentro de salesforce.
                                    error += err.getStatusCode() + ': ' + err.getMessage() + '----';
                                    String aux = jsonStr.replaceAll('"token":"[^"]+"','"token":"******"'); 
                                    AppLog__c l = new AppLog__c();
                                        l.Name = 'Hubo un error al intentar guardar : ' + objeto;
                                        l.objeto__c = objeto;
                                        l.usuario__c = currentUser;
                                        l.Mensaje__c = error;
                                        l.OwnerId = currentUser;
                                        // if (l.Mensaje__c.length() > 255) {
                                        //     l.Mensaje__c = l.Mensaje__c.substring(0,255);
                                        // }
                                        if (aux.length() > 131070) {
                                            l.json__c = aux.substring(0,131070);
                                            l.json2__c = aux.substring(131071, aux.length()-1);
                                        } else {
                                            l.json__c = aux;
                                        }
                                        System.debug(l);
                                        respuesta.message = 'Hubo un error al intentar guardar los datos de: ' + objeto;
                                    insert l;
                                }
                                respuesta.status = 508;
                            } else {
                               respuesta.duplicatedId =  listquerySF[0].id;
                               respuesta.status = 409;
                            }
                            // Agregar error 409 para saber si es de duplicado
                            System.debug('Respuesta');
                            System.debug(Respuesta);
                            return Respuesta;
                        }
                    }
                }
                catch(Exception ex){
                    system.debug(ex.getMessage());
                }
            } else {
                // crear notificacion de que los datos no se guardaron porque hay informacion mas actual en la base de datos.
                System.debug('entro en el else');
            }
        } 
        else {
            respuesta.status = 508;
            respuesta.message = 'No hay registros para Guardar';                   
            return Respuesta;
        }
        return null; //Puse esto para evitar errores.
    }
    
    global class Request {
        public String user {get; set;}
        public DateTime fechaDeModificacionDelRegistro {get; set;}
        public List<Sobject> recordsFromApp {get; set;}
    }
    
    global class Respuesta {
        public String duplicatedId {get;set;}
        public Integer status {get; set;}
        public String message {get;set;}
        public Integer size {get { return this.sobjects.size();}}
        public String response {get; set;}
        public Boolean hasNext {get; set;}
        public String lastId {get; set;}
        public List<SObject> sobjects {get; set;}
    }
    
}