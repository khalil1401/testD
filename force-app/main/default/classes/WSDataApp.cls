@RestResource(urlMapping='/objetos/*')
global with sharing class WSDataApp {
	
    // *************************************************************************************************
    // *************************************************************************************************
    // GET
    @ HttpGet
    global static Respuesta doGet(){
    	
        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        String objeto = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String lastSyncString = req.headers.get('lastSync');
        String userName = req.headers.get('Username');
        String token = req.headers.get('Token');
        
        List<User> users = [select id, Contrasenia_App__c, Profile.Name from User where username = :userName];
        User currentUser;
        if (users.size()>0 && users.get(0).Contrasenia_App__c == token) {
			currentUser = users.get(0);
        }
        else {
            respuesta.status = 501;
            respuesta.message = 'Usuario o Pass Incorrectos';
            
            return respuesta;
        }
        
        Datetime lastSync;
        if (lastSyncString != null) {
			lastSync = Datetime.valueOfGmt(lastSyncString);     
        } else {
            lastSync = Datetime.valueOfGmt('2000-01-01 00:00:00');
        }
       	
        List<String> allGroupIDs = new List<String>();
        for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where UserOrGroupId = :currentUser.Id]) {
            allGroupIDs.add(gm.group.id);
        }
        
        respuesta.URI = '/objetos/' + objeto;
        
        if (objeto == 'Profesional_de_la_salud') {
			
			List<Id> sharedAccounts = new List<Id>();
            for (AccountShare share :[select id, AccountId from AccountShare where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs) and Account.recordtype.developerName = 'Profesional_de_la_salud']) {
                sharedAccounts.add(share.accountId);
            }	
			
            if (currentUser.Profile.Name == 'Administrador del sistema' || currentUser.Profile.Name == 'KAE') {
                respuesta.sobjects = [select id, FirstName, LastName, ID_Medico__c, DNI__c, Matricula__c, Hobby__c, Equipo_de_futbol__c, Tiene_hijos__c, 
                                  Influyente__c, Jefe_de_equipo__c, Prescriptor__c, Miembro_de_Advisory_Board__c, Esta_escribiendo_algun_trabajo__c,
                                  Medico_de_Best_Care__c, Trabajo_sobre__c, Perfil_Succeed__c, Primera_especialidad__c,
                                  Institucion_principal__c, Institucion_principal__r.Name, Phone, Telefono_interno__c, OwnerId, Owner.Name, PersonBirthdate, 
                                  Espacio_de_visita__c, Area_terapeutica__c, calle__c, Sexo__c, Esta_dado_de_alta_como_proveedor__c, Dado_de_alta__c,
                                  Segunda_Especialidad__c, Otra__c, Departamento__c, Habla_ingles__c, Detalle_de_hijos__c, PersonEmail,
                                  Codigo_postal_service__c, Codigo_postal_service__r.Name, Localidad__c, Provincia__c, Dia_Desde__c, Dia_Hasta__c, Desde_Horas_1__c,
                                  Hasta_Horas_1__c, Lunes__c, Desde_Lunes__c, Hasta_Lunes__c, Martes__c, Hasta_Martes__c, Desde_Martes__c, Es_residente__c, 
                                  Escribio_trabajos_cientificos__c, Es_considerado_KOL_o_Referente__c, Mas_de_5_anos_en_la_especialidad__c, Cargo__c, Sociedad_2__c,
                                  Que_sociedad__c, Miembro_de_sociedad__c, Instituto_donde_ejerce_2__c, Instituto_donde_ejerce_1__c, Docente_en_la_Universidad__c, 
                                  Cargo_dentro_de_la_institucion__c, Hasta_Viernes__c, Desde_Viernes__c, Viernes__c, Hasta_Jueves__c, Desde_Jueves__c,
                                  Jueves__c, Hasta_Miercoles__c, Desde_Miercoles__c, Miercoles__c, Medico_de_la_especialidad__c, Matricula2__c, 
                                  Tipo_de_Contacto__c, Tipo_de_Institucion__c, Derivador__c, Futuro_especialista__c, Area_de_Servicio__c, Observaciones__c, Inactivo__c,
                                  (select Profesional__c, Institucion__c from Profesionales_por_Instituciones1__r)
                                  from Account where recordtype.developerName = 'Profesional_de_la_salud'];
            }
            else {
        		respuesta.sobjects = [select id, FirstName, LastName, ID_Medico__c, DNI__c, Matricula__c, Hobby__c, Equipo_de_futbol__c, Tiene_hijos__c, 
                                  Influyente__c, Jefe_de_equipo__c, Prescriptor__c, Miembro_de_Advisory_Board__c, Esta_escribiendo_algun_trabajo__c,
                                  Medico_de_Best_Care__c, Trabajo_sobre__c, Perfil_Succeed__c, Primera_especialidad__c,
                                  Institucion_principal__c, Institucion_principal__r.Name, Phone, Telefono_interno__c, OwnerId, Owner.Name, PersonBirthdate, 
                                  Espacio_de_visita__c, Area_terapeutica__c, calle__c, Sexo__c, Esta_dado_de_alta_como_proveedor__c, Dado_de_alta__c,
                                  Segunda_Especialidad__c, Otra__c, Departamento__c, Habla_ingles__c, Detalle_de_hijos__c, PersonEmail,
                                  Codigo_postal_service__c, Codigo_postal_service__r.Name, Localidad__c, Provincia__c, Dia_Desde__c, Dia_Hasta__c, Desde_Horas_1__c,
                                  Hasta_Horas_1__c, Lunes__c, Desde_Lunes__c, Hasta_Lunes__c, Martes__c, Hasta_Martes__c, Desde_Martes__c, Es_residente__c, 
                                  Escribio_trabajos_cientificos__c, Es_considerado_KOL_o_Referente__c, Mas_de_5_anos_en_la_especialidad__c, Cargo__c, Sociedad_2__c,
                                  Que_sociedad__c, Miembro_de_sociedad__c, Instituto_donde_ejerce_2__c, Instituto_donde_ejerce_1__c, Docente_en_la_Universidad__c, 
                                  Cargo_dentro_de_la_institucion__c, Hasta_Viernes__c, Desde_Viernes__c, Viernes__c, Hasta_Jueves__c, Desde_Jueves__c,
                                  Jueves__c, Hasta_Miercoles__c, Desde_Miercoles__c, Miercoles__c, Medico_de_la_especialidad__c, Matricula2__c, 
                                  Tipo_de_Contacto__c, Tipo_de_Institucion__c, Derivador__c, Futuro_especialista__c, Area_de_Servicio__c, Observaciones__c, Inactivo__c,
                                  (select Profesional__c, Institucion__c from Profesionales_por_Instituciones1__r)
                                  from Account where recordtype.developerName = 'Profesional_de_la_salud' and (ownerId = :currentUser.Id or id in :sharedAccounts)];
            }
        } 
        else if (objeto == 'Otro_profesional') {
        	
			List<Id> sharedAccounts = new List<Id>();
            for (AccountShare share :[select id, AccountId from AccountShare where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs) and Account.recordtype.developerName = 'Otro_profesional']) {
                sharedAccounts.add(share.accountId);
            }			

			if (currentUser.Profile.Name == 'Administrador del sistema') {
            	respuesta.sobjects = [select id, FirstName, LastName, ID_Medico__c, DNI__c, Matricula__c, Hobby__c, Equipo_de_futbol__c, Tiene_hijos__c, 
                                  Influyente__c, Jefe_de_equipo__c, Prescriptor__c, Miembro_de_Advisory_Board__c, Esta_escribiendo_algun_trabajo__c,
                                  Medico_de_Best_Care__c, Trabajo_sobre__c, Perfil_Succeed__c, Primera_especialidad__c,
                                  Institucion_principal__c, Institucion_principal__r.Name, Phone, Telefono_interno__c, OwnerId, Owner.Name, PersonBirthdate, 
                                  Espacio_de_visita__c, Area_terapeutica__c, calle__c, Sexo__c, Esta_dado_de_alta_como_proveedor__c, Dado_de_alta__c,
                                  Segunda_Especialidad__c, Otra__c, Departamento__c, Habla_ingles__c, Detalle_de_hijos__c, PersonEmail,
                                  Codigo_postal_service__c, Codigo_postal_service__r.Name, Localidad__c, Provincia__c, Dia_Desde__c, Dia_Hasta__c, Desde_Horas_1__c,
                                  Hasta_Horas_1__c, Lunes__c, Desde_Lunes__c, Hasta_Lunes__c, Martes__c, Hasta_Martes__c, Desde_Martes__c, Es_residente__c, 
                                  Escribio_trabajos_cientificos__c, Es_considerado_KOL_o_Referente__c, Mas_de_5_anos_en_la_especialidad__c, Cargo__c, Sociedad_2__c,
                                  Que_sociedad__c, Miembro_de_sociedad__c, Instituto_donde_ejerce_2__c, Instituto_donde_ejerce_1__c, Docente_en_la_Universidad__c, 
                                  Cargo_dentro_de_la_institucion__c, Hasta_Viernes__c, Desde_Viernes__c, Viernes__c, Hasta_Jueves__c, Desde_Jueves__c,
                                  Jueves__c, Hasta_Miercoles__c, Desde_Miercoles__c, Miercoles__c, Medico_de_la_especialidad__c, Tipo_de_Profesional__c,
                                  Tipo_de_Contacto__c, Tipo_de_Institucion__c, Derivador__c, Futuro_especialista__c, Area_de_Servicio__c, Observaciones__c,
                                  Desde_Intervalo__c, Hasta_Intervalo__c, Desde_Horas_2__c, Hasta_Horas_2__c, Inactivo__c
                                  from Account where recordtype.developerName = 'Otro_profesional'];
            }
            else {
	            respuesta.sobjects = [select id, FirstName, LastName, ID_Medico__c, DNI__c, Matricula__c, Hobby__c, Equipo_de_futbol__c, Tiene_hijos__c, 
                                  Influyente__c, Jefe_de_equipo__c, Prescriptor__c, Miembro_de_Advisory_Board__c, Esta_escribiendo_algun_trabajo__c,
                                  Medico_de_Best_Care__c, Trabajo_sobre__c, Perfil_Succeed__c, Primera_especialidad__c,
                                  Institucion_principal__c, Institucion_principal__r.Name, Phone, Telefono_interno__c, OwnerId, Owner.Name, PersonBirthdate, 
                                  Espacio_de_visita__c, Area_terapeutica__c, calle__c, Sexo__c, Esta_dado_de_alta_como_proveedor__c, Dado_de_alta__c,
                                  Segunda_Especialidad__c, Otra__c, Departamento__c, Habla_ingles__c, Detalle_de_hijos__c, PersonEmail,
                                  Codigo_postal_service__c, Codigo_postal_service__r.Name, Localidad__c, Provincia__c, Dia_Desde__c, Dia_Hasta__c, Desde_Horas_1__c,
                                  Hasta_Horas_1__c, Lunes__c, Desde_Lunes__c, Hasta_Lunes__c, Martes__c, Hasta_Martes__c, Desde_Martes__c, Es_residente__c, 
                                  Escribio_trabajos_cientificos__c, Es_considerado_KOL_o_Referente__c, Mas_de_5_anos_en_la_especialidad__c, Cargo__c, Sociedad_2__c,
                                  Que_sociedad__c, Miembro_de_sociedad__c, Instituto_donde_ejerce_2__c, Instituto_donde_ejerce_1__c, Docente_en_la_Universidad__c, 
                                  Cargo_dentro_de_la_institucion__c, Hasta_Viernes__c, Desde_Viernes__c, Viernes__c, Hasta_Jueves__c, Desde_Jueves__c,
                                  Jueves__c, Hasta_Miercoles__c, Desde_Miercoles__c, Miercoles__c, Medico_de_la_especialidad__c, Tipo_de_Profesional__c,
                                  Tipo_de_Contacto__c, Tipo_de_Institucion__c, Derivador__c, Futuro_especialista__c, Area_de_Servicio__c, Observaciones__c,
                                  Desde_Intervalo__c, Hasta_Intervalo__c, Desde_Horas_2__c, Hasta_Horas_2__c, Inactivo__c
                                  from Account where recordtype.developerName = 'Otro_profesional' and (ownerId = :currentUser.Id or id in :sharedAccounts)];
            }
        }
        else if (objeto == 'Institucion') {
            
            List<Id> sharedAccounts = new List<Id>();
            for (AccountShare share :[select id, AccountId from AccountShare where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs) and Account.recordtype.developerName = 'Otro_profesional']) {
                sharedAccounts.add(share.accountId);
            }
            
            Set<Id> misInstiuciones = new Set<Id>();
            
            for (Profesional_por_Institucion__c profXInst :[select Profesional__c, Institucion__c from Profesional_por_Institucion__c where Profesional__r.ownerId = :currentUser.Id or Profesional__c in :sharedAccounts]) {
                misInstiuciones.add(profXInst.Institucion__c);
            }
            
            List<Account> instituciones = [select id, name, owner.Name, Institucion_principal__c, Institucion_principal__r.Name, Parent.Name, Description, 
                                  Es_drogueria__c, phone, Financiador_1__c, Financiador_2__c, Financiador_3__c, Financiador_4__c, Porcentaje_financiador_1__c, 
                                  Porcentaje_financiador_2__c, Porcentaje_financiador_3__c, Porcentaje_financiador_4__c, Usuario_Visitador_medico__c, 
                                  Usuario_Visitador_medico__r.Name, Cantidad_de_bombas__c, Cantidad_de_Bombas_Nutricia__c, Forma_de_compra__c, Distribuidor__c,
                                  Cantidad_de_camas_UTI__c, Cantidad_Camas_UTI_con_Sonda__c, Cantidad_Camas_Piso__c, Cantidad_Camas_Piso_con_Sonda__c,
                                  Calle__c, Piso__c, Departamento__c, Referencia__c, Localidad__c, Provincia__c, Pais__c,
                                  Codigo_postal_service__c, Codigo_postal_service__r.Name,
                                  (select Profesional__c, Institucion__c from Profesionales_por_Instituciones__r)
                                  from Account where recordtype.developerName = 'Institucion' /*and lastModifiedDate >= :lastSync*/];
            
            for (Account inst :instituciones) {
                inst.miInstitucion__c = misInstiuciones.contains(inst.Id);
            }
            
            respuesta.sobjects = instituciones;
        }
        else if (objeto == 'Obra_Social') {
            respuesta.sobjects = [select id, name, Delegacion__c, Sigla__c, CUIT__c, Phone, KAM__c, KAM__r.Name, Usuario_Visitador_medico__c, 
                                  Usuario_Visitador_medico__r.Name, ParentId, Parent.Name, Cantidad_de_afiliados__c, Area_de_Influencia__c, Provincias__c,
                                  Obra_Social_principal__c, Obra_Social_principal__r.Name, Calle__c, Piso__c, Departamento__c, Referencia__c, 
                                  Localidad__c, Codigo_postal_service__c, Provincia__c, Codigo_postal_service__r.Name, Pais__c 
                                  from Account where recordtype.developerName = 'Obra_social' and lastModifiedDate >= :lastSync];
        }
        else if (objeto == 'Ciclo') {
           
			List<Id> cicloShares = new List<Id>();
            for (Ciclo__Share share :[select id, ParentId from Ciclo__Share where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs)]) {
                cicloShares.add(share.ParentId);
            }
            
            respuesta.sobjects = [select id, name, Fecha_de_inicio__c, Fecha_de_fin__c, Cantidad_de_dias_habiles__c, Total_dias_de_licencia__c,
                                  Dias_de_campo_efectivo__c, Promedio__c, Target_diario__c, Total_de_visitas_realizadas__c, 
                                  Efectividad__c, Reloj_actual__c, Reloj_real__c
                                  from Ciclo__c where lastModifiedDate >= :lastSync and (ownerId = :currentUser.Id or id in :cicloShares)];
        }
        else if (objeto == 'Colaboracion') {
            List<Id> colaboracionShares = new List<Id>();
            for (Colaboracion__Share share :[select id, ParentId from Colaboracion__Share where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs)]) {
                colaboracionShares.add(share.ParentId);
            }
            respuesta.sobjects = [select id, name, Institucion__c, Institucion__r.Name, Profesional__c, Profesional__r.Name, Primera_especialidad__c, Comentarios__c,
                                  Tipo_de_accion__c, Fecha_desde__c, Fecha_hasta__c, Lugar__c, Institucion_principal_del_profesional__c
                                  from Colaboracion__c where lastModifiedDate >= :lastSync and (ownerId = :currentUser.Id or id in :colaboracionShares)];
        }
        else if (objeto == 'Actividad_Institucional') {
            List<Id> cicloShares = new List<Id>();
            for (Ciclo__Share share :[select id, ParentId from Ciclo__Share where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs)]) {
                cicloShares.add(share.ParentId);
            }
            respuesta.sobjects = [select id, name, Profesional_de_la_salud__c, Profesional_de_la_salud__r.Name, Ciclo__c, Ciclo__r.Name, Tipo__c,
                                  Fecha__c, Hora__c, Comentario__c, Descripcion_de_entrega_de_material__c 
                                  from Interaccion__c where recordtype.developerName = 'Actividad_institucional' and lastModifiedDate >= :lastSync and (Ciclo__r.ownerId = :currentUser.Id or Ciclo__c in :cicloShares)];
        }
        else if (objeto == 'Visita_Medica') {
            List<Id> cicloShares = new List<Id>();
            for (Ciclo__Share share :[select id, ParentId from Ciclo__Share where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs)]) {
                cicloShares.add(share.ParentId);
            }
            respuesta.sobjects = [select id, name, Profesional_de_la_salud__c, Profesional_de_la_salud__r.Name, Ciclo__c, Ciclo__r.Name, Tipo_de_visita__c,
                                  Fecha__c, Hora__c, Comentario__c, Deja_muestra_medica__c, Cual__c, Descripcion_de_entrega_de_material__c,
                                  (select id, Interaccion__c, Producto__c, Cantidad_de_unidades__c from Productos_por_visitas__r)
                                  from Interaccion__c where recordtype.developerName = 'Visita_medica' and lastModifiedDate >= :lastSync and (Ciclo__r.ownerId = :currentUser.Id or Ciclo__c in :cicloShares)];
        }

        else if (objeto == 'Licencia') {
            List<Id> cicloShares = new List<Id>();
            for (Ciclo__Share share :[select id, ParentId from Ciclo__Share where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs)]) {
                cicloShares.add(share.ParentId);
            }
            respuesta.sobjects = [select id, name, Ciclo__c, Ciclo__r.Name, Motivo__c, Cantidad_de_visitas_que_no_se_realizar_n__c, Aprobado__c,
                                  Duracion_de_licencia__c, Dia_decimal__c, Fecha_de_inicio__c, Fecha_de_fin__c, Comentarios__c  
                                  from Licencia__c where lastModifiedDate >= :lastSync and (Ciclo__r.ownerId = :currentUser.Id or Ciclo__c in :cicloShares)];
        } 
        else if (objeto == 'Producto') {
            respuesta.sobjects = [select id, name, Ean__c, IsActive,
                                  (select id, Interaccion__c, Producto__c, Cantidad_de_unidades__c from Productos_por_visitas__r)
                                  from Product2 where Producto_para__c = 'Best Care' and lastModifiedDate >= :lastSync ];
        }
        else if (objeto == 'Muestra_Medica') {
            List<Id> cicloShares = new List<Id>();
            for (Ciclo__Share share :[select id, ParentId from Ciclo__Share where (UserOrGroupId = :currentUser.Id or UserOrGroupId in :allGroupIDs)]) {
                cicloShares.add(share.ParentId);
            }
            respuesta.sobjects = [select id, name, Producto__c, Interaccion__c, Producto__r.Name, Interaccion__r.Name, Cantidad_de_unidades__c 
                                  from Producto_por_Visita__c where lastModifiedDate >= :lastSync and (Interaccion__r.ciclo__r.OwnerId = :currentUser.Id or Interaccion__r.ciclo__c in :cicloShares)];
        }
        else if (objeto == 'Profesional_por_Institucion') {
            respuesta.sobjects = [select id, Institucion__c, Institucion__r.Name, Profesional__c, Profesional__r.Name 
                                  from Profesional_por_Institucion__c where lastModifiedDate >= :lastSync];
        }
        else if (objeto == 'Caso') {
            respuesta.sobjects = [select id, CaseNumber, AccountId, Nombre_del_paciente__c  
                                  from Case where lastModifiedDate >= :lastSync and recordType.developerName = 'Profesionales_de_la_salud' and (OwnerId = :currentUser.Id or Profesional_Best_Care__c = :currentUser.Id)];
        }
        else if (objeto == 'Formulario') {
            respuesta.sobjects = [select id, Name, RecordTypeId, RecordType.Name
                                  from Formulario__c where lastModifiedDate >= :lastSync and caso__r.recordType.developerName = 'Profesionales_de_la_salud ' and (Caso__r.OwnerId = :currentUser.Id or Caso__r.Profesional_Best_Care__c = :currentUser.Id)];
        }
        else if (objeto == 'Paciente') {
            List<Id> pacientes = new List<Id>();
            for (Case caso :[select id, AccountId
                                  	from Case where lastModifiedDate >= :lastSync and recordType.developerName = 'Profesionales_de_la_salud ' and (OwnerId = :currentUser.Id or Profesional_Best_Care__c = :currentUser.Id)]) {
				if (caso.AccountId != null) {
                	pacientes.add(caso.accountId);    
                }
            }
            respuesta.sobjects = [select id, FirstName, LastName
                                  from Account where id in :pacientes];
        }
        
        else {
		System.debug('algo '+objeto);
            respuesta.status = 500;
            respuesta.message = 'Objeto No Encontrado';
            
            return respuesta;
        }
        
        respuesta.status = 200;
        respuesta.message = 'OK';
        
        return respuesta;
    }

    // *************************************************************************************************
    // *************************************************************************************************
    @ HttpPost
    global static Respuesta doPost(){
        
    	RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        
        String jsonStr = req.requestBody.toString();
        system.debug('jsonStr:'+jsonStr);
        
        String objeto = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String usuario = '';
        
        try {
            
            Map<String,Id> recordTypeMap = new Map<String,Id>();
            for (RecordType rt :[select id, developerName from RecordType]) {
                recordTypeMap.put(rt.developerName,rt.Id);
            }
            
			Request request;
            try {
                request = (Request)JSON.deserialize(jsonStr, Request.class);     
            } 
            catch (Exception ex) {
                system.debug('Segundo intento');
                
                String newJsonStr = jsonStr.replaceAll('Hora__c', 'HoraString__c');
                system.debug('newJsonStr:'+newJsonStr);
                request = (Request)JSON.deserialize(newJsonStr, Request.class);     
                
                String horaStringNewObj = (String)request.SObjectWrappers.get(0).newObject.get('HoraString__c');
                if (horaStringNewObj != null) {
                	request.SObjectWrappers.get(0).newObject.put('Hora__c', parseTime(horaStringNewObj));    
                }
                
                String horaStringOldObj = (String)request.SObjectWrappers.get(0).oldObject.get('HoraString__c');
                if (horaStringOldObj != null) {
                	request.SObjectWrappers.get(0).oldObject.put('Hora__c', parseTime(horaStringOldObj));
                }
            }
			
			usuario = request.username;            
            List<User> users = [select id, Contrasenia_App__c from User where username = :request.username];
            User currentUser;
            if (users.size()>0 && users.get(0).Contrasenia_App__c == request.token) {
                currentUser = users.get(0);
            }
            else {
                respuesta.status = 501;
                respuesta.message = 'Usuario o Pass Incorrectos';
                
                return respuesta;
            }
            
            respuesta.sobjects = new List<SObject>();
            system.debug('request.lastSync '+ request.lastSync);
            DateTime lastModifiedDate = DateTime.valueOfGMT(request.lastSync);
            
            if (request.SObjectWrappers != null && request.SObjectWrappers.size()>0) {
                
                List<Id> objIds = new List<Id>();
                Map<String,SObject> objectToInsert = new Map<String,SObject>();
                Map<Id,SObject> newObjectsMap = new Map<Id,SObject>();
                Map<Id,SObject> oldObjectsMap = new Map<Id,SObject>();
                Map<Id,SObject> salesforceObjectsMap = new Map<Id,SObject>();
                
                for (SObjectWrapper objWrapper :request.SObjectWrappers) {
                    system.debug('objWrapper.newObject:'+objWrapper.newObject);
                    if (objWrapper.newObject.Id != null) {
                        objIds.add(objWrapper.newObject.Id);
                        newObjectsMap.put(objWrapper.newObject.Id, objWrapper.newObject);
                        oldObjectsMap.put(objWrapper.oldObject.Id, objWrapper.oldObject);
                    } else {
                        if (objWrapper.tipoRegistro != null && objWrapper.tipoRegistro != '' && recordTypeMap.get(objWrapper.tipoRegistro) != null) {
                            objWrapper.newObject.put('recordTypeId',recordTypeMap.get(objWrapper.tipoRegistro));
                        }
                        
                        try {
                            objWrapper.newObject.put('OwnerId', currentUser.Id);
                        }
                        catch(Exception ex) {
                        }
                        
                        objectToInsert.put(objWrapper.appId,objWrapper.newObject);    
                    }
                }
                
                Map<String, Object> fieldsToValue = request.SObjectWrappers.get(0).newObject.getPopulatedFieldsAsMap();
                String fields = '';
                for (String field :fieldsToValue.keySet()) {
                    if (field != 'Owner' && !field.contains('__r') && !field.contains('__R')) { 
	                    fields += field + ' ,';
                    }
                }
                
                fields = fields.substring(0,fields.length()-1);
                
                String query = 'Select lastModifiedDate, ' + fields + ' from ' + objeto + ' where id in :objIds';
                system.debug('query:'+query);
                salesforceObjectsMap = new Map<Id,SObject>(Database.query(query));
                
                for (Id objId :newObjectsMap.keySet()) {
                    SObject newObj = newObjectsMap.get(objId);
                    SObject oldObj = oldObjectsMap.get(objId);
                    SObject saleObj = salesforceObjectsMap.get(objId);
                    
                    for (String field :newObj.getPopulatedFieldsAsMap().keySet()) {
                        if (field != 'Owner' && !field.contains('__r') && !field.contains('__R')) {
	                        if (saleObj.get(field) == null || (newObj.get(field) != saleObj.get(field) && (oldObj.get(field) == null || oldObj.get(field) == saleObj.get(field)))){
                            	saleObj.put(field,newObj.get(field));
                            }
                        }
                    }
                }
                
                system.debug('salesforceObjectsMap:'+salesforceObjectsMap);
                update salesforceObjectsMap.values();
                system.debug('objectToInsert:'+objectToInsert);
                
                insert objectToInsert.values();
                
                system.debug('objectToInsert:' + objectToInsert);
                
                respuesta.sobjects = objectToInsert.values();
            }
            
            respuesta.URI = '/objetos/' + objeto;
            
            respuesta.status = 200;
            respuesta.message = 'OK';
        	
            return Respuesta;
        
    	} catch (Exception ex) {

            system.debug('Error:'+ex.getMessage()+' - Linea:'+ex.getLineNumber());
            
            String aux = jsonStr.replaceAll('"token":"[^"]+"','"token":"******"'); 
           
            AppLog__c l = new AppLog__c();
            l.objeto__c = objeto;
            l.usuario__c = usuario;
            l.Mensaje__c = ex.getStackTraceString() + ' - ' +ex.getMessage();
            if (l.Mensaje__c.length() > 255) {
                l.Mensaje__c = l.Mensaje__c.substring(0,255);
            }
            if (aux.length() > 131070) {
            	l.json__c = aux.substring(0,131070);
                l.json2__c = aux.substring(131071, aux.length()-1);
            } else {
                l.json__c = aux;
            }
            
            JSONParser parser = JSON.createParser(l.json__c);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'appId')) {
                    parser.nextToken();
                    l.id_app__c = parser.getText();  
                    break;
                }
            }
            
            insert l;
            
            respuesta.status = 508;
            respuesta.message = 'Error: ' + ex.getMessage() + ' - (' + l.id + ')';
            
            return respuesta;
        }
    }
    
    public static Time parseTime(String timeString) {
        // 14:26:41.276Z or "14:26:41.276Z"
        List<String> values = timeString.replace('Z', '').replace('"', '').split(':'); 
        
        // (14, 26, 41.276)         
        Integer hours = Integer.valueOf(values[0]); 
        Integer minutes = Integer.valueOf(values[1]);
        
        // 41.276 -> (41, 276) 
        //Integer seconds = Integer.valueOf(values[2].split('\\.')[0]);
        //Integer milliseconds = Integer.valueOf(values[2].split('\\.')[1]);
        Integer seconds = 0;
        Integer milliseconds = 0;
        
        return Time.newInstance(hours, minutes, seconds, milliseconds);
    }
	
    global class Request {
        public String lastSync {get; set;}
        public String username {get; set;}
        public String token {get; set;}
        public List<SObjectWrapper> SObjectWrappers {get; set;}
    }
    
    global class SObjectWrapper {
        public String appId {get;set;}
        public String tipoRegistro {get;set;}
        public SObject newObject {get;set;}
        public SObject oldObject {get;set;}
    }
    
	global class Respuesta {
        public Integer status {get; set;}
        public String message {get;set;}
        public String URI {get;set;}
        public List<SObject> sobjects {get; set;}
    }
	
}