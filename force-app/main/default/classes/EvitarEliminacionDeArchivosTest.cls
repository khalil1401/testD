@isTest
public class EvitarEliminacionDeArchivosTest {
    
    @isTest
    public static void siSeIntentaEliminarUnArchivoConElPerFilProfesionalBestCare(){
              
        Account testAcc1 = Build.anAccount().withLastName('Rios')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias').build();
        
        
        insert testAcc1;
        
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1)
            .withObraSocial('32423423423')
            .build();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        insert historiaClinica; 
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=historiaClinica.id;
        contentlink.shareType = 'V';
        contentlink.contentdocumentid=[
            SELECT contentdocumentid 
            FROM contentversion 
            WHERE id =: content.id].contentdocumentid;
        
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        Test.startTest();
        
        try{

            delete contentlink;
            
        }catch(Exception e){

            system.assert(e.getMessage().contains('Permisos insuficientes para eliminar el archivo.'));
        }
        
        Test.stopTest();
    }
    
    
}