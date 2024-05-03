@isTest
public class KetoWSTest {
    
    @testSetup static void setup(){
        Account account = new Account();
        account.Name = 'testAccount';
        account.DNI__c = '12345';
        insert account;
        
        Contact contact = new Contact();
        contact.LastName = 'testContact';
        contact.DNI__c = '123456';
        insert contact;
    }
    
    @isTest static void getMethodShouldReturnAnAccountIfMatches(){
        
        KetoWS.Result result;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/ValidatePatient/' + [
            SELECT DNI__c
            FROM Account
            LIMIT 1
        ].DNI__c;
        request.httpMethod = 'GET';
        
        RestContext.request = request;
        result = KetoWS.doGet();
        Test.stopTest();
        
        system.assertEquals(result.hasFound, true);
    }
    
    @isTest static void getMethodShouldReturnAContactIfMatches(){
        KetoWS.Result result;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/ValidatePatient/' + [
            SELECT DNI__c
            FROM Contact
            LIMIT 1
        ].DNI__c;
        request.httpMethod = 'GET';
        
        RestContext.request = request;
        result = KetoWS.doGet();
        Test.stopTest();
        
        system.assertEquals(result.hasFound, true);
    }
    
    @isTest static void getMethodShouldNotReturnNothingIfNoMatches(){
        KetoWS.Result result;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/ValidatePatient/' + 'invalidParam';
        request.httpMethod = 'GET';
        
        RestContext.request = request;
        result = KetoWS.doGet();
        Test.stopTest();
        
        system.assertEquals(result.hasFound, false);
    }
    
    @isTest static void getMethodShouldNotReturnNothingIfError(){
        KetoWS.Result result;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = null;
        request.httpMethod = 'GET';
        
        RestContext.request = request;
        result = KetoWS.doGet();
        Test.stopTest();
        
        system.assertEquals(result.hasFound, false);
    }
    
}