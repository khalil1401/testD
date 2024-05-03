@isTest
public class ConfirmacionDeConsentimiento_test {
    
    @isTest
    public static void siIntentaIngresarNuevamenteParaResponderDebeSalirUnMensajeDeAviso(){
        Formulario__c historiaClinica = [
            SELECT id,Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];
        
        PageReference page = Page.FormularioDeConsentimiento;
        test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('hcid',historiaClinica.id);
        ConfirmacionDeConsentimientoController controller = new ConfirmacionDeConsentimientoController();
        
        test.startTest();
        controller.nombreFirmante = 'testFirmante';
        controller.esFirmante = true;
        controller.confirmacionDeFirma();
        test.stopTest();
        
        Formulario__c historiaClinicaDB = [
            SELECT id,Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];

        Account accountDb = [
            SELECT id, Estado_del_consentimiento__c,Consentimiento_ya_registrado__c
            FROM Account
            WHERE id = : historiaClinicaDB.Nombre_y_Apellido_del_Paciente__c
        ];
        /*Segunda prueba para validar que no le permita registrar otra respuesta*/
        Apexpages.currentPage().getParameters().put('hcid',historiaClinicaDB.id);
        ConfirmacionDeConsentimientoController controller2 = new ConfirmacionDeConsentimientoController();
        controller.confirmacionDeFirma();
        
        System.assertEquals(true,accountDb.Consentimiento_ya_registrado__c);
        System.assertEquals(true,controller2.respuestaYaRegistrada);
        
    }
    
    @isTest
    public static void siAceptaYElidDeLaHCNoEsNuloDebeInsertarFirmanteYSetearElCampoDeConsentimiento(){
        Formulario__c historiaClinica = [
            SELECT id ,Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];
        
        PageReference page = Page.FormularioDeConsentimiento;
        test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('hcid',historiaClinica.id);
        ConfirmacionDeConsentimientoController controller = new ConfirmacionDeConsentimientoController();
        
        test.startTest();
        controller.nombreFirmante = 'testFirmante';
        controller.esFirmante = true;
        controller.confirmacionDeFirma();
        test.stopTest();
        
        Account accountDb = [
            SELECT id, Estado_del_consentimiento__c,Consentimiento_ya_registrado__c
            FROM Account
            WHERE id = : historiaClinica.Nombre_y_Apellido_del_Paciente__c
        ];
        Firmante_de_Consentimiento__c firmanteDB = [
            SELECT id, Historia_clinica__c, Paciente__c
            FROM Firmante_de_Consentimiento__c
        ]; 
        System.assertEquals(firmanteDB.Paciente__c, accountDb.id);
        System.assertEquals('Aceptado',accountDb.Estado_del_consentimiento__c);    
    }
    
    @isTest
    public static void siRechazaYElidDeLaHCNoEsNuloYesFirmanteDebeInsertarFirmanteYSetearElCampoDeConsentimientoEnRechazo(){
        Formulario__c historiaClinica = [
            SELECT id,Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];
        
        PageReference page = Page.FormularioDeConsentimiento;
        test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('hcid',historiaClinica.id);
        ConfirmacionDeConsentimientoController controller = new ConfirmacionDeConsentimientoController();
        
        controller.checkRechazo = true; 
        test.startTest();
        controller.nombreFirmante = 'testFirmante';
        controller.esFirmante = true;
        controller.rechazoDeConsentimiento();
        test.stopTest();
        Account accountDb = [
            SELECT id, Estado_del_consentimiento__c,Consentimiento_ya_registrado__c
            FROM Account
            WHERE id = : historiaClinica.Nombre_y_Apellido_del_Paciente__c
        ];
        Firmante_de_Consentimiento__c firmanteDB = [
            SELECT id, Historia_clinica__c,Paciente__c
            FROM Firmante_de_Consentimiento__c
        ]; 
        Set<Id> ContentDocumentIDs = new Set<Id>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
        List<ContentDocumentLink> contentLinks = [
            SELECT id,contentDocumentId,LinkedEntityId,ContentDocument.title,contentDocument.Id 
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (SELECT Id FROM Account where id = :accountDb.id)
        ];
        for(ContentDocumentLink aContenLink: contentLinks){
            ContentDocumentIDs.add(aContenLink.contentDocumentId);
        }  
        contentVersionList= [
            SELECT id,title,ContentDocumentId,contentSize,Description
            FROM ContentVersion 
            WHERE contentDocumentId IN :ContentDocumentIDs
        ];
        System.assertEquals(firmanteDB.Paciente__c, accountDb.id);
        System.assertEquals('Rechazado',accountDb.Estado_del_consentimiento__c);
        System.assertEquals(1,contentVersionList.size());
        /**URL de redireccionamiento para descargar pdf **/
        System.assertNotEquals(null,controller.descargarFormulario());  
        System.assertEquals('/apex/FormularioConsentimiento?ace=false&'+'hcid='+historiaClinica.id+'&name=testFirmante', controller.descargarFormulario().getUrl());
         
    }
    
    
    @isTest
    public static void siQUiereDescargarElFormularioSeLeDebeRenderizarComoPDFLaVisualforceFormularioDeConsentimiento(){
        
        /*Formulario__c historiaClinica = [
            SELECT id, Estado_del_consentimiento__c, Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];
        
        PageReference page = Page.ConfirmacionDeConsentimiento;
        test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('hcid',historiaClinica.id);
        ConfirmacionDeConsentimientoController controller = new ConfirmacionDeConsentimientoController();

        System.assertNotEquals(null,controller.descargarFormulario());  
        System.assertEquals('/apex/FormularioConsentimiento?hcid='+ historiaClinica.id, controller.descargarFormulario().getUrl());*/
    }
    
    @testSetup 
    static void setup() {
        Account testAcc1 = Build.anAccount().withLastName('Test Nut')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias').build();
        
        insert testAcc1;
        
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1)
            .build();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        
        insert historiaClinica; 
    }
}