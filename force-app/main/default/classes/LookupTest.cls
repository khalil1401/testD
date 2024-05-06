@isTest
private with sharing class LookupTest {
    @TestSetup
	static void makeData(){
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal').getRecordTypeId();
		Account accountOne = Build.anAccount()
			.withName('TEST1')
			.withRecordTypeId(recordTypeId)	
			.withIdSap('11111')
			.build();	

		insert accountOne;		
	}
    @IsTest
    static void whenSearchIsMakedMustGetOneResult(){
        List<Id> emptyList = new List<Id>();
        Test.startTest();
            List<Object> result = Lookup.search('Test', 'Account', '', emptyList);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'No se encontro la busqueda');
        
    }
    //@IsTest
    static void whenSearchIsNotMakedMustGetAllResult(){
        List<Id> emptyList = new List<Id>();
        Test.startTest();
            List<Object> result = Lookup.search('', 'Account', '', emptyList);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'No se encontro la busqueda');
        
    }
    @IsTest
    static void whenSearchAndFilterIsMakedMustGetOneResult(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal').getRecordTypeId();
        String filter = 'recordType.Name = \'Sucursal\'';
        List<Id> emptyList = new List<Id>();
        Test.startTest();
            List<Object> result = Lookup.search('Test', 'Account', filter, emptyList);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'No se encontro la busqueda');
        
    }
    @IsTest
    static void whenSearchIsMakedTheLimitAreFiveResults(){
        List<Id> emptyList = new List<Id>();
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 7; i++) {
            Account a = Build.anAccount()
			.withName('TEST'+i)
			.build();
            
            accounts.add(a);
        }
        insert accounts;

        Test.startTest();
            List<Object> result = Lookup.search('Test', 'Account', '',emptyList);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'No se encontro la busqueda');
        
    }
    // @IsTest
    // static void whenSearchIsMakedOnlyForObjectMustGetOneResult(){
    //     Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal').getRecordTypeId();
	// 	Account accountOne = Build.anAccount()
	// 		.withName('TEST1')
	// 		.withRecordTypeId(recordTypeId)				
	// 		.build();	

	// 	insert accountOne;
        
	// 	Account accountTwo = Build.anAccount()
	// 		.withName('TEST2')
	// 		.withRecordTypeId(recordTypeId)				
	// 		.build();	

	// 	insert accountTwo;
        
    //     Test.startTest();
    //         List<Object> result = Lookup.search(null, 'Account', '');
    //     Test.stopTest();

    //     System.assertEquals(3, result.size(), 'No se encontro la busqueda');
        
    // }
}