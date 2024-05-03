@isTest
public class TecnovozControllerTest {

    @isTest
    private static void testCalling()
    {
        Test.setCurrentPageReference(new PageReference('Page.TecnoVozLisenter'));
		System.currentPageReference().getParameters().put('phoneNumber', '1111');                
        System.currentPageReference().getParameters().put('direction', '1');
		System.currentPageReference().getParameters().put('LogData', 'Log data');
        
        TecnovozCommunicatorCtrl tecnoVozController = new TecnovozCommunicatorCtrl();
        tecnoVozController.CallBegin();
        System.assertNotEquals(null, tecnoVozController.currentCall);
        tecnoVozController.CallEnd();        
        System.assertEquals('Log data', tecnoVozController.currentCall.Description);
    }
    
    @isTest
    private static void testCreateClient() {
		Test.setCurrentPageReference(new PageReference('Page.TecnoVozLisenter'));
		System.currentPageReference().getParameters().put('phoneNumber', '123');                
        System.currentPageReference().getParameters().put('direction', '1');

        TecnovozCommunicatorCtrl ctrl = new TecnovozCommunicatorCtrl();
        ctrl.CallBegin();
		ctrl.phoneNumber = '123';
		ctrl.newContactLastName = 'lastname';
		ctrl.newContactType = RecordTypes.Account_PacienteBestCare;
		ctrl.CreateContact();

        Account acc = [
			SELECT LastName, Phone, RecordTypeId
			FROM Account
		];
        
		System.assertEquals(XappiaHelper.getRecordType(RecordTypes.Account_PacienteBestCare).Id, acc.RecordTypeId);
    }
        
    
    @isTest
    private static void testTabOpennedWithAccountTryToShowMenu() {
       TecnovozCommunicatorCtrl tecnoVozController = new TecnovozCommunicatorCtrl();
        
        Account Client = new Account();
		Client.RecordTypeId = XappiaHelper.getRecordType(RecordTypes.Account_PacienteBestCare).Id;
        Client.Phone = '1111';
		Client.LastName = 'lastname';
        insert Client;
        
		Test.setCurrentPageReference(new PageReference('Page.TecnoVozLisenter'));		        
        System.currentPageReference().getParameters().put('objectId', Client.Id);
        
        tecnoVozController.TabOpenned();
        
        System.assert(tecnoVozController.callfunc.contains('ShowCallMenu'));
    }
    
	@isTest
    private static void TestTabOpennedWithoutAccountTryToHideMenu() {
        TecnovozCommunicatorCtrl tecnoVozController = new TecnovozCommunicatorCtrl();        		
        tecnoVozController.TabOpenned();
        
        System.assert(tecnoVozController.callfunc.contains('HideCallMenu'));
    }    
}