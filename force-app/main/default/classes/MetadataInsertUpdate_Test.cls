@isTest
public class MetadataInsertUpdate_Test {

    @isTest
    static void testMetadataInsertUpdateSucess(){
    
    Test.startTest();
        MetadataInsertUpdate.testResultIsSuccessful =true;
        MetadataInsertUpdate.handleInsertAndUpdate('Test meta', 'Meta label', new Map<String, Object> {'Field'=> 'Value test'});
    Test.stopTest();

    System.assertEquals(true, MetadataInsertUpdate.resultsEvents.isSuccess());
    }

    @isTest
    static void testMetadataInsertUpdateError(){

    Test.startTest();
        MetadataInsertUpdate.testResultIsSuccessful =false;
        MetadataInsertUpdate.handleInsertAndUpdate('Test meta', 'Meta label', new Map<String, Object> {'Field'=> 'Value test'});
    Test.stopTest();

    System.assertEquals(null, MetadataInsertUpdate.resultsEvents);
    }

}