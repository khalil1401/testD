@istest public class FinanzasInformationTest {
    private Static testmethod void drummyTest(){ 
    
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Paciente_Best_Care').getRecordTypeId();

        
		Account a = build.anAccount().withLastName('test').withRecordTypeId(recordTypeId).build();
        insert a;
        ApexPages.currentPage().getParameters().put('id',a.id);
        ApexPages.StandardController account = new ApexPages.StandardController(a);
        FinanzasInformation con  = new FinanzasInformation(account);
    }
}