@isTest
public with sharing class userHelperTest {
    @TestSetup
    static void makeData(){
        
        Id noProfileCommunity = [select id from profile where name='APM'].id;
        
        Id rolId1 = [SELECT id FROM UserRole WHERE Name = 'Jefe Supervisores Adultos Nicho'].id;

        User thisUser = new User(Id=UserInfo.getUserId());
        thisUser.UserRoleId = rolId1;
        update thisUser;

        System.runAs(thisUser) {
            Account portalAccount = new Account(name = 'portalAccount');
            insert portalAccount;
            Contact portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id);
            insert portalContact;
        }
        
        
    }

    @isTest
    public static void sendNewPasswordToCommunityUser(){
        
        Id rolId = [SELECT id FROM UserRole WHERE Name = 'Comunidad Partner User'].id;
        Id profileCommunity = [SELECT id FROM profile WHERE name='Cliente CC'].id;
        Id con = [SELECT Id FROM Contact].id ;
        
        User user = new User(alias = 'test123', email='test123@globant.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileCommunity, country='AR',IsActive =true,
        ContactId = con,
        timezonesidkey='America/Argentina/Buenos_Aires', username='tester@globant.com');

        test.startTest();
        System.debug(Limits.getEmailInvocations());
            insert user;
        test.stopTest();
        System.debug(Limits.getEmailInvocations());
    }
}