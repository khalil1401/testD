@isTest
private class CommunityPrintPDFControllerTest {
	@isTest
    static void whenThe(){

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente;

		Formulario__c form = new Formulario__c();
        form.Nombre_y_Apellido_del_Paciente__c = paciente.Id;
        form.Fecha_de_la_visita__c = System.today();
        insert form;
        
        Formulario__c formulario = [
            SELECT Id, Name
            FROM Formulario__c
            LIMIT 1
        ];
        
        Test.startTest();
        CommunityPrintPDFController.WrapperPDF infoPDF = CommunityPrintPDFController.getPDFInfo(formulario.Id);
        Test.stopTest();

        System.assertEquals('Los métodos definidos como TestMethod no admiten llamadas a getContent', infoPDF.pdfInfoBase64);
        System.assertEquals(formulario.Name, infoPDF.formularioName);
        
    }
}