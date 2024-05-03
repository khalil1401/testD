@isTest
public class TestAccountTeamMemberTrigger {
    

    @isTest  
    static void siSeCreaUnNuevoAccountTeamMemberCompletarElCampoCorrespondienteDePropietario() {
        
       Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];
        
        User user1 = Build.aUser()
                    .withUsername('test1test1te234st1@gmail.com')
                    .withEmail('test1tes432t1test1danonearg@gmail.com')
                    .withAlias('Ts33')
                    .withTimeZoneSidKey('GMT')
                    .withLocaleSidKey('en_US')
                    .withLastName('test apellido33')
                    .withCommunityNickname('test123789')
                    .withEmailEncodingKey('UTF-8')
                    .withProfileId(profileIdTest.id)
                    .withLanguageLocaleKey('en_US')
                    .Build();
        
        insert user1; 

        User user2 = Build.aUser()
        .withUsername('test1tes2344t3test3@gmail.com')
        .withEmail('test1test3t42est3danonearg@gmail.com')
        .withAlias('Ts333')
        .withTimeZoneSidKey('GMT')
        .withLocaleSidKey('en_US')
        .withLastName('test apellido213')
        .withCommunityNickname('test1237589')
        .withEmailEncodingKey('UTF-8')
        .withProfileId(profileIdTest.id)
        .withLanguageLocaleKey('en_US')
        .Build();

        insert user2; 

         User user3 = Build.aUser()
        .withUsername('test1tes234t3test33@gmail.com')
        .withEmail('test1test223test33danonearg@gmail.com')
        .withAlias('Ts33333')
        .withTimeZoneSidKey('GMT')
        .withLocaleSidKey('en_US')
        .withLastName('test apellido2313')
        .withCommunityNickname('test12373589')
        .withEmailEncodingKey('UTF-8')
        .withProfileId(profileIdTest.id)
        .withLanguageLocaleKey('en_US')
        .Build();

        insert user3; 

        User user4 = Build.aUser()
        .withUsername('test1tes22t3test43@gmail.com')
        .withEmail('test1test233test43@gmail.com')
        .withAlias('Ts33343')
        .withTimeZoneSidKey('GMT')
        .withLocaleSidKey('en_US')
        .withLastName('test apellido2443')
        .withCommunityNickname('test12343589')
        .withEmailEncodingKey('UTF-8')
        .withProfileId(profileIdTest.id)
        .withLanguageLocaleKey('en_US')
        .Build();

        insert user4; 

        User user6 = Build.aUser()
        .withUsername('test1test32test63@gmail.com')
        .withEmail('test1test2223te6643danonearg@gmail.com')
        .withAlias('Ts3643')
        .withTimeZoneSidKey('GMT')
        .withLocaleSidKey('en_US')
        .withLastName('test apellido643')
        .withCommunityNickname('test1263589')
        .withEmailEncodingKey('UTF-8')
        .withProfileId(profileIdTest.id)
        .withLanguageLocaleKey('en_US')
        .Build();

        insert user6;


        Account testAcc1 = new Account();
        testAcc1.Name = 'cuenta 1';
        testAcc1.Canal_para_Consumidor_Baby__c = 'Farmacias';
        
        insert testAcc1;

        AccountTeamMember testAccMember2 = new AccountTeamMember();
        testAccMember2.UserId = user1.id;
        testAccmember2.AccountId = testAcc1.id;

        insert testAccMember2;

        AccountTeamMember testAccMember3 = new AccountTeamMember();
        testAccMember3.UserId = user2.id;
        testAccmember3.AccountId = testAcc1.id;

        insert testAccMember3;

        AccountTeamMember testAccMember4 = new AccountTeamMember();
        testAccMember4.UserId = user3.id;
        testAccmember4.AccountId = testAcc1.id;

        insert testAccMember4;

        
        AccountTeamMember testAccMember5 = new AccountTeamMember();
        testAccMember5.UserId = user4.id;
        testAccmember5.AccountId = testAcc1.id;

        insert testAccMember5;

        AccountTeamMember testAccMember6 = new AccountTeamMember();
        testAccMember6.UserId = user6.id;
        testAccmember6.AccountId = testAcc1.id;

        insert testAccMember6;

        Test.startTest();
        
        Test.stopTest();
        
        Account accQuery = [SELECT id,Canal_para_Consumidor_Baby__c,Propietario_Nicho__c , Propietario_adulto__c,Propietario_3__c,Propietario_4__c,Propietario_5__c  
                            from account 
                            WHERE id = :testAcc1.id
                           ];
         
        System.assertEquals(testAccMember2.UserId, accQuery.Propietario_Nicho__c);
        System.assertEquals( testAccMember3.UserId, accQuery.Propietario_adulto__c);
        System.assertEquals( testAccMember4.UserId, accQuery.Propietario_3__c);
        System.assertEquals( testAccMember5.UserId, accQuery.Propietario_4__c);
        System.assertEquals( testAccMember6.UserId, accQuery.Propietario_5__c);
      
    }



    @isTest  
    static void siEliminoUnAccountTeamMemberEliminarElCampoCorrespondienteDePropietario() {
        
       Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];
        
        User user1 = Build.aUser()
                    .withUsername('test1te221st1test1@gmail.com')
                    .withEmail('test1tes512t1test1danonearg@gmail.com')
                    .withAlias('Ts33')
                    .withTimeZoneSidKey('GMT')
                    .withLocaleSidKey('en_US')
                    .withLastName('test apellido33')
                    .withCommunityNickname('test123789')
                    .withEmailEncodingKey('UTF-8')
                    .withProfileId(profileIdTest.id)
                    .withLanguageLocaleKey('en_US')
                    .Build();
        
        insert user1; 

        User user2 = Build.aUser()
        .withUsername('test1tes54t3test3@gmail.com')
        .withEmail('test1test453test3@gmail.com')
        .withAlias('Ts333')
        .withTimeZoneSidKey('GMT')
        .withLocaleSidKey('en_US')
        .withLastName('test apellido213')
        .withCommunityNickname('test1237589')
        .withEmailEncodingKey('UTF-8')
        .withProfileId(profileIdTest.id)
        .withLanguageLocaleKey('en_US')
        .Build();

        insert user2; 
        
        Account testAcc1 = new Account();
        testAcc1.Name = 'cuenta 1';
        testAcc1.Canal_para_Consumidor_Baby__c = 'Farmacias';
        
        insert testAcc1;

        AccountTeamMember testAccMember2 = new AccountTeamMember();
        testAccMember2.UserId = user1.id;
        testAccmember2.AccountId = testAcc1.id;

        insert testAccMember2;

        AccountTeamMember testAccMember3 = new AccountTeamMember();
        testAccMember3.UserId = user2.id;
        testAccmember3.AccountId = testAcc1.id;

        insert testAccMember3;
        
        Test.startTest();
        
        delete testAccMember2;
        delete testAccMember3;

        Test.stopTest();
        
        List<AccountTeamMember> accTeamQuery = 
                            [SELECT id,accountId 
                            FROM AccountTeamMember 
                            WHERE AccountId = :testAccMember2.accountId
                            OR AccountId = :testAccMember3.accountId
                            ];
        
       System.assertEquals(0, accTeamQuery.size());                   
        
    }

   
    
}