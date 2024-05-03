@isTest
public class SurveyResponseTriggerTest {
	public static Survey__c setSurvey()
    {
        
        Survey__c encuesta = new Survey__c();
       	insert encuesta;
        Survey_Question__c preg = new Survey_Question__c();
        preg.Survey__c = encuesta.Id;
        preg.Question__c = 'Sopa do macaco?';
        preg.OrderNumber__c = 0;
        insert preg;
        return encuesta;
    }
    @isTest
    public static void EnvioRespuestas_DebenGuardarQuienCerroElCaso()
    {
        Profile perfilVisitadorMedico = [
			SELECT Id 
			FROM Profile
			WHERE Name = 'PSP'
		];
       User usuario = Build.aUser()
			.withUserName(
				'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
			)
			.withLastName('Contacto')
			.withEmail('contacto@xappia.com')
			.withAlias('contact1')
			.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
			.withLocaleSidKey('es_AR')
			.withCommunityNickname('prueba1.xappia')
			.withEmailEncodingKey('ISO-8859-1')
			.withProfileId(perfilVisitadorMedico.Id)
			.withLanguageLocaleKey('es')
			.build();
		insert usuario;
		
        Survey__c encuesta = setSurvey();
        Case caso = build.aCase().build();
        insert caso;
        SurveyTaker__c take = new SurveyTaker__c();
        take.Survey__c = encuesta.Id;
        take.Case__c = caso.Id;
        insert take;
        SurveyQuestionResponse__c response = new SurveyQuestionResponse__c();
        response.SurveyTaker__c = take.Id;
        response.Response__c = 'Si pofavo';
        response.Survey_Question__c = [SELECT Id FROM Survey_Question__c].Id;
        
        
        Test.startTest();
        
        System.runAs(usuario){
            caso.Status = 'Cerrado';
            update caso;
        }
        insert response;
        Test.stopTest();
        
        caso = [SELECT Id, LastModifiedById, CerradoPor__c FROM Case];
        response = [SELECT Id, CasoCerradoPor__c FROM SurveyQuestionResponse__c];
        System.assertEquals(caso.CerradoPor__c, response.CasoCerradoPor__c, 'No son iguales');
        System.assertNotEquals(null, caso.CerradoPor__c, 'Response tiene CerradoPor nulo');
        System.assertNotEquals(null, response.CasoCerradoPor__c, 'Response tiene CasoCerradoPor nulo');
    }
}