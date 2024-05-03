@isTest
public class WSDataAppTest {

    @isTest
    private static void doGet() {
        
		Account cuenta = Build.anAccountCuentacommunity()
			.withName('Xappia1')
			.build();
		insert cuenta;
	
		Contact contacto1 = Build.aContactVisitadormedico()
			.withFirstName('Primer')
			.withLastName('Contacto')
			.forAccount(cuenta)
			.build();
		insert contacto1;

		Profile perfil = [
			SELECT Id 
			FROM Profile 
			WHERE Name = 'Coordinación médica/enfermería' 
			LIMIT 1
		];
        
        User userTest = Build.aUser()
            .withContactId(contacto1)
			.withUsername(
				'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
			)
			.withLastName('Contacto1')
			.withEmail('contacto1@xappia.com')
			.withAlias('contact1')
			.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
			.withLocaleSidKey('es_AR')
			.withCommunityNickname('prueba1.xappia')
			.withEmailEncodingKey('ISO-8859-1')
			.withProfileId(perfil.Id)
			.withLanguageLocaleKey('es')
			.build();
        
        userTest.Contrasenia_App__c = 'Test';
		insert userTest;
        
        List<String> sobjectsList = new List<String>();
        sobjectsList.add('Profesional_de_la_salud');
        sobjectsList.add('Otro_Profesional');
        sobjectsList.add('Institucion');
        sobjectsList.add('Obra_Social');
        sobjectsList.add('Ciclo');
        sobjectsList.add('Colaboracion');
        sobjectsList.add('Actividad_Institucional');
        sobjectsList.add('Visita_Medica');
        sobjectsList.add('Licencia');
        sobjectsList.add('Producto');
		sobjectsList.add('Colaboracion');
        sobjectsList.add('Muestra_Medica');
		
        for (String obj :sobjectsList) {
        	RestRequest req = new RestRequest();
            
            req.requestURI = '/services/apexrest/objetos/' + obj;
            req.addHeader('lastSync', '2000-01-01 00:00:00');
            req.addHeader('Username', userTest.Username);
            req.addHeader('Token', userTest.Contrasenia_App__c);
            req.httpMethod = 'GET';
            
            RestContext.request = req;
            WSDataApp.Respuesta result = new WSDataApp.Respuesta();
            
            result = WSDataApp.doGet();
            
            system.assertEquals(200, result.status);
            system.assertEquals(0, result.sobjects.size());    
        }
        
        RestRequest req = new RestRequest();
            
        req.requestURI = '/services/apexrest/objetos/no_existe';
        req.addHeader('Username', userTest.Username);
        req.addHeader('Token', userTest.Contrasenia_App__c);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        WSDataApp.Respuesta result = new WSDataApp.Respuesta();
        
        result = WSDataApp.doGet();
        System.debug('//// '+result);
        system.assertEquals(500, result.status);
        
        ConfigApp__c config = new ConfigApp__c(
        	Name='test',
            formularioEdicion__c='',
            formularioLista__c='',
            activo__c=true
        );
        
        insert config;
            
        WSMetadataApp.doGet();
        
        WSEditRemoto.doGet();
        
        ModApp__c mod = new ModApp__c(
        	Usuario__c=userTest.Username,
            Estado__c='Mod',
            Tipo__c='Profesional_de_la_salud',
            id_app__c='1'
        );
        insert mod;
        
        RestRequest req2 = new RestRequest();
            
        req2.requestURI = '/services/apexrest/editRemoto';
        req2.addHeader('Username', userTest.Username);
        req2.httpMethod = 'GET';
        
        RestContext.request = req2;
        WSEditRemoto.doGet();
    
    }
    
    @isTest
    private static void doPost() {
        
        Account cuenta = Build.anAccountCuentacommunity()
			.withName('Xappia1')
			.build();
		insert cuenta;
	
		Contact contacto1 = Build.aContactVisitadormedico()
			.withFirstName('Primer')
			.withLastName('Contacto')
			.forAccount(cuenta)
			.build();
		insert contacto1;

		Profile perfil = [
			SELECT Id 
			FROM Profile 
			WHERE Name = 'Coordinación médica/enfermería' 
			LIMIT 1
		];
        
        User userTest = Build.aUser()
            .withContactId(contacto1)
			.withUsername(
				'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
			)
			.withLastName('Contacto1')
			.withEmail('contacto1@xappia.com')
			.withAlias('contact1')
			.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
			.withLocaleSidKey('es_AR')
			.withCommunityNickname('prueba1.xappia')
			.withEmailEncodingKey('ISO-8859-1')
			.withProfileId(perfil.Id)
			.withLanguageLocaleKey('es')
			.build();
        
        userTest.Contrasenia_App__c = 'Test';
		insert userTest;
        
        //POST INSERT
        String actual = '{"attributes":{"type":"Account","url":"/services/data/v43.0/sobjects/Account/"},"FirstName":"NombrePrueba ","LastName":"ApellidoPrueba","DNI__c":"11111111","Matricula__c":"123456789","Tiene_hijos__c":"Si","Detalle_de_hijos__c":"Detalle "}';
        
        String jsonStr =
        	+ '{' +
            + ' "lastSync":"2018-06-22 14:12:31",' +
            + ' "username":"' + userTest.username + '",' +
            + ' "token":"' + userTest.Contrasenia_App__c + '",' +
            + ' "SObjectWrappers": [' +
            + '   {'
            + '     "appId":"1",' +
            + '     "tipoRegistro":"Profesional_de_la_salud",' +
            + '     "newObject":' + actual + ' ,' +
            + '     "oldObject":' + actual +
            + '   }' +
            + ' ]' +
            + '}';
        
    	RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/objetos/account';
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        
        req.requestBody = Blob.valueOf(jsonStr);
        WSDataApp.Respuesta resultado = new WSDataApp.Respuesta();
        
        resultado = WSDataApp.doPost();
        
        system.assertEquals(200, resultado.status);
        system.assertEquals(1, resultado.sobjects.size());
		
		//GET        
        RestRequest req2 = new RestRequest();
            
        req2.requestURI = '/services/apexrest/objetos/Profesional_de_la_salud';
        req2.addHeader('lastSync', '2000-01-01 00:00:00');
        req2.addHeader('Username', userTest.Username);
        req2.addHeader('Token', userTest.Contrasenia_App__c);
        req2.httpMethod = 'GET';
        
        RestContext.request = req2;
        WSDataApp.Respuesta result = new WSDataApp.Respuesta();
        
        result = WSDataApp.doGet();
        
        system.assertEquals(200, result.status);
        system.assertEquals(1, result.sobjects.size()); 
        
        //POST UPDATE
        Account acc = (Account) result.sobjects.get(0);
        String original = JSON.serialize(acc);
        acc.DNI__c = '12121212';
        actual = JSON.serialize(acc); 
        
		jsonStr =
        	+ '{' +
            + ' "lastSync":"2018-06-22 14:12:31",' +
            + ' "username":"' + userTest.username + '",' +
            + ' "token":"' + userTest.Contrasenia_App__c + '",' +
            + ' "SObjectWrappers": [' +
            + '   {'
            + '     "appId":"1",' +
            + '     "tipoRegistro":"Profesional_de_la_salud",' +
            + '     "newObject":' + actual + ' ,' +
            + '     "oldObject":' + original +
            + '   }' +
            + ' ]' +
            + '}';        
		
        RestRequest req3 = new RestRequest();
        
        req3.requestURI = '/services/apexrest/objetos/account';
        req3.httpMethod = 'POST';
        
        RestContext.request = req3;
        
        req3.requestBody = Blob.valueOf(jsonStr);
        WSDataApp.Respuesta resultado3 = new WSDataApp.Respuesta();
        
        resultado3 = WSDataApp.doPost();
        
        system.assertEquals(200, resultado3.status);
        system.assertEquals(0, resultado3.sobjects.size());
        
        //POST ERROR
        jsonStr = '{}';
        
        RestRequest req4 = new RestRequest();
        
        req4.requestURI = '/services/apexrest/objetos/account';
        req4.httpMethod = 'POST';
        
        RestContext.request = req4;
        
        req4.requestBody = Blob.valueOf(jsonStr);
        WSDataApp.Respuesta resultado4 = new WSDataApp.Respuesta();
        
        resultado4 = WSDataApp.doPost();
        
        system.assertEquals(501, resultado4.status);
        
		       
    }
    
}