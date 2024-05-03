@isTest
public with sharing class HCReportTest {
    
    @isTest
    public static void testHCReportPageController(){
        
        Formulario__c historiaClinica = [
            SELECT id,Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];
        
        PageReference page = Page.HCReportPage;
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('hcid',historiaClinica.id);
        HCReportPageController controller = new HCReportPageController();
        
        Test.startTest();
        Test.stopTest();
        
        System.assertEquals(120, controller.historiaClinica.Requerimiento_Proteico__c);
        System.assertEquals('Hipofosfatemia', controller.historiaClinica.Complicaciones_metabolicas__c);
    }
    
    
    @isTest
    public static void testHCReportPageForPDF(){
        
        Formulario__c historiaClinica = [
            SELECT id,Nombre_y_Apellido_del_Paciente__c
            FROM Formulario__c
        ];
        
        PageReference page = Page.HCReportPageForPDF;
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('hcid',historiaClinica.id);
        HCReportPageForPDFController controller = new HCReportPageForPDFController();
        
        Test.startTest();
        controller.armaryAdjuntarPdf();
        Test.stopTest();
        
        ContentVersion contentVersion= [
            SELECT id,title,ContentDocumentId,contentSize,Description
            FROM ContentVersion 
            LIMIT 1
        ];
        Map<integer,String>  monthNameMap = new Map<integer, String> {
            1=>'Enero', 2=>'Febrero', 3=>'Marzo', 4=>'Abril', 5=>'Mayo', 6=>'Junio',
                7=>'Julio', 8=>'Agosto', 9=>'Septiembre',10=>'Octubre', 11=>'Noviembre', 12=>'Diciembre'
                };
                    System.assertEquals('Test Nut - Historia Clínica de Enfermería - '+monthNameMap.get(System.now().month())+' 2022', contentVersion.title);
    }
    
    
    @testSetup 
    static void setup() {
        Account testAcc1 = Build.anAccount().withLastName('Test Nut')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert testAcc1;
        
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1)
            .build();
        historiaClinica.Requerimiento_Proteico__c=120;
        historiaClinica.Complicaciones_metabolicas__c='Hipofosfatemia';
        historiaClinica.Sistema_digestivo__c='Constipación; Distensión';
        historiaClinica.Modalidad__c='Nutrición enteral';
        historiaClinica.Via_de_acceso__c='Gastrostomía';
        historiaClinica.Complicacion_actual__c='Lesión por decúbito';
        historiaClinica.Fecha_ultimo_recambio__c = System.today();
        historiaClinica.Fecha__c=System.today();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        historiaClinica.Sexo__c= 'Masculino';
        
        insert historiaClinica; 
    }
}