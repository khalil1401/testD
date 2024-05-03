@isTest
public class HistoriaClinicaControllerTest {
    
    
    
    @isTest
    public static void validateStandardControllerPrueba(){
        
        Account testAcc1 = Build.anAccount().withLastName('Rios')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias').build();
        
        
        insert testAcc1;
        
        Date myDate = Date.newInstance(2000, 2, 17);
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1).withObraSocial('32423423423')
            .withFechaDeNacimiento(myDate)//.withPerdidaDePeso(66.15)
            .build();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        insert historiaClinica;
        
        
        ApexPages.StandardController stdFormulario = new ApexPages.StandardController(historiaClinica);
        HistoriaClinicaController controller  = new HistoriaClinicaController(stdFormulario);
        
        List<String> secciones = new List<String>();
        for(Metadata.LayoutSection laySect :controller.getLayout()){
            secciones.add(String.valueOf(laySect.label) );
            
        }
        String[] misSecciones = new String[]{
            'Historia Clínica de Enfermería','Indicación Médica','Monitoreo de Signos Vitales',
                'Estado de Hidratación','Acceso Enteral','Estado de la Piel','Kinesiología','Complicaciones del Acceso Enteral',
                'Complicaciones Asociadas a la Nutrición Enteral',
                'Funcionamiento del Equipo','Indice de Katz','Evolución de Enfermería','Profesional'
                };
                    
                    //QUE ESTEN TODAS LAS SECCIONES (INDISTINTAMENTE QUE TENGAN CAMPOS NULL)
                    for (Integer i = 0; i < 10; i++){
                        System.assertEquals(misSecciones[i], secciones.get(i));
                    }
    }
    
    
    @isTest
    public static void validateStandardControllerHCNutricion(){
        
        Account testAcc1 = Build.anAccount().withLastName('Rios')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias').build();
        
        
        insert testAcc1;
        
        Date myDate = Date.newInstance(2000, 2, 17);
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1).withObraSocial('32423423423')
            .withFechaDeNacimiento(myDate).withPerdidaDePeso(66.15)
            .build();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        insert historiaClinica; 
        
        
        ApexPages.StandardController stdFormulario = new ApexPages.StandardController(historiaClinica);
        HistoriaClinicaController controller  = new HistoriaClinicaController(stdFormulario);
        
        List<String> secciones = new List<String>();
        for(Metadata.LayoutSection laySect :controller.getLayout()){
            secciones.add(String.valueOf(laySect.label) );
            
        }
        /*
String[] misSecciones = new String[]{'Valoración Global subjetiva','Cambio de peso',
'Cambios en la ingesta respecto de la habitual','Síntomas gastrointestinales (que persisten más de 2 semanas)',
'Capacidad funcional', 'Requerimientos Nutricionales Según Patología','Examen físico',
'Observaciones','Clasificación Según Clasificación Global Subjetiva' ,'Información del sistema'};
*/
        //QUE ESTEN TODAS LAS SECCIONES (INDISTINTAMENTE QUE TENGAN CAMPOS NULL)
        for (Integer i = 0; i < 10; i++){
            System.debug('Secciones ' + secciones.get(i));
        }        
    }
    
     @isTest
    public static void validatemakeAttachedPdf(){
         Account testAcc1 = Build.anAccount().withLastName('Rios')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias').build();
        
        
        insert testAcc1;
        
        Date myDate = Date.newInstance(2000, 2, 17);
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1).withObraSocial('32423423423')
            .withFechaDeNacimiento(myDate)//.withPerdidaDePeso(66.15)
            .build();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        insert historiaClinica;
        
        Test.startTest();
        HistoriaClinicaHelper.makeAttachedPdf(historiaClinica.Id);
        Test.stopTest();
        
        List<ContentDocumentLink> cdl = [
            SELECT Id, LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink where LinkedEntityId=:historiaClinica.id
        ];
        
        Formulario__c formUpdated = [
            SELECT Name,Fecha_de_la_visita__c	
            FROM Formulario__c
            WHERE id = :historiaClinica.id
        ];
        
        List<ContentVersion> contVersion = [
            SELECT id
            FROM ContentVersion
            WHERE Title = :formUpdated.Name
        ];
        system.assert(!cdl.isEmpty());
        system.assert(!contVersion.isEmpty());

    }
    
    
      @isTest
    public static void validatelinkPdfHistoriaClinicaToAccountAndCase(){
         Account testAcc1 = Build.anAccount().withLastName('Rios')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .withCanalParaConsumidorBaby('Farmacias').build();
        
        
        insert testAcc1;
        
        Case aCase = Build.aCase()
			   .forAccount(testAcc1)
			   .withType('Consulta')
			   .withStatus('Abierto')
			   .build();
		insert aCase;
        
        Date myDate = Date.newInstance(2000, 2, 17);
        Formulario__c historiaClinica = Build.anHistoriaClinicaDeEnfermeria().withName('Nombre de formulario')
            .withPaciente(testAcc1).withObraSocial('32423423423')
            .withCaso(aCase.id)
            .withFechaDeNacimiento(myDate)//.withPerdidaDePeso(66.15)
            .build();
        historiaClinica.Fecha_de_la_visita__c = System.today();
        insert historiaClinica;
        HistoriaClinicaHelper.makeAttachedPdf(historiaClinica.Id);
        
        Test.startTest();
        HistoriaClinicaHelper.linkPdfHistoriaClinicaToAccountAndCase(historiaClinica.Id);
        Test.stopTest();
        
        List<ContentDocumentLink> cdl = [
            SELECT Id, LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink where LinkedEntityId=:historiaClinica.id
        ];
        
        Formulario__c formUpdated = [
            SELECT Name
            FROM Formulario__c
            WHERE id = :historiaClinica.id
        ];
        
        List<ContentVersion> contVersion = [
            SELECT id
            FROM ContentVersion
            WHERE Title = :formUpdated.Name
        ];
        
        system.assert(!cdl.isEmpty());
        system.assert(!contVersion.isEmpty());
    }
    
}