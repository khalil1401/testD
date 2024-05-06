@IsTest
public class WSMetadataAppTest {
    private static final Id recordTypeFuncionalidad = Schema.SObjectType.VisMed_ConfigApp__c.getRecordTypeInfosByDeveloperName().get('Funcionalidad').getRecordTypeId();
    private static final Id recordTypeObjeto = Schema.SObjectType.VisMed_ConfigApp__c.getRecordTypeInfosByDeveloperName().get('Objeto').getRecordTypeId();
    @TestSetup
    static void makeData(){
        List<VisMed_ConfigApp__c> listToInsert = new List<VisMed_ConfigApp__c>();
        VisMed_ConfigApp__c visMedFuncionalActivo = Build.aVisMedConfigAppFuncionalidad()
            .withName('Ciclo')
            .withVisMedActiva(true)
            .build();     
        visMedFuncionalActivo.Objeto_Principal__c = 'objetoPrincipalFuncional';
        visMedFuncionalActivo.VisMed_Vista_Compacta__c = 'vistaCompactaFuncional';
        visMedFuncionalActivo.VisMed_Vista_Detalle__c = 'vistaDetalleFuncional';
        visMedFuncionalActivo.VisMed_Vista_Formulario__c = 'vistaFormularioFuncional';
        listToInsert.add(visMedFuncionalActivo);

        VisMed_ConfigApp__c visMedFuncionalDesactivado = Build.aVisMedConfigAppFuncionalidad()
            .withName('Ciclo Desactivado')
            .withVisMedActiva(false)
            .build();     
        visMedFuncionalDesactivado.Objeto_Principal__c = 'objetoPrincipalFuncional';
        visMedFuncionalDesactivado.VisMed_Vista_Compacta__c = 'vistaCompactaFuncional';
        visMedFuncionalDesactivado.VisMed_Vista_Detalle__c = 'vistaDetalleFuncional';
        visMedFuncionalDesactivado.VisMed_Vista_Formulario__c = 'vistaFormularioFuncional';
        listToInsert.add(visMedFuncionalDesactivado);

        VisMed_ConfigApp__c visMedObjetoActivo = Build.aVisMedConfigAppObjeto()
            .withName('MedConf2')
            .withVisMedActiva(true)
            .build();     
        visMedObjetoActivo.Objeto_Principal__c = 'objetoPrincipalObjeto';
        visMedObjetoActivo.VisMed_Vista_Compacta__c = 'vistaCompactaObjeto';
        visMedObjetoActivo.VisMed_Vista_Detalle__c = 'vistaDetalleObjeto';
        visMedObjetoActivo.VisMed_Vista_Formulario__c = 'vistaFormularioObjeto';
        listToInsert.add(visMedObjetoActivo);

        VisMed_ConfigApp__c visMedObjetoDesactivo = Build.aVisMedConfigAppObjeto()
            .withName('MedConf2 desactivo')
            .withVisMedActiva(false)
            .build();     
        visMedObjetoDesactivo.Objeto_Principal__c = 'objetoPrincipalObjeto';
        visMedObjetoDesactivo.VisMed_Vista_Compacta__c = 'vistaCompactaObjeto';
        visMedObjetoDesactivo.VisMed_Vista_Detalle__c = 'vistaDetalleObjeto';
        visMedObjetoDesactivo.VisMed_Vista_Formulario__c = 'vistaFormularioObjeto';
        listToInsert.add(visMedObjetoDesactivo);

        insert listToInsert;
    }
    
    @IsTest
    public static void ValidateMethodForRecordTypeFuncional(){
        RestRequest req = new RestRequest();
        req.addHeader('recordtype','Funcionalidad');
        req.requestURI = '/services/apexrest/metadata/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        Test.startTest();
        WSMetadataApp.Respuesta resp = WSMetadataApp.doGet();
        Test.stopTest();

        List<VisMed_ConfigApp__c> listOnSalesforce = [
            SELECT id, Name, Objeto_Principal__c, VisMed_Vista_Compacta__c, VisMed_Vista_Detalle__c,VisMed_Vista_Formulario__c 
            FROM VisMed_ConfigApp__c
            WHERE VisMed_Activa__c = true 
            AND RecordTypeId = :recordTypeFuncionalidad
        ];

        system.assertEquals(resp.status, 200, 'Error en el consumo del WS');
        system.assertEquals(resp.forms.size(),1,'Error en los datos');
        system.assertEquals(resp.forms.get(0).nombre,listOnSalesforce.get(0).Name,'Error en los datos');
        system.assertEquals(resp.forms.get(0).id,listOnSalesforce.get(0).Id,'Error en los datos');
        system.assertEquals(resp.forms.get(0).objetoPrincipal,listOnSalesforce.get(0).Objeto_Principal__c,'Error en los datos');
        system.assertEquals(resp.forms.get(0).vistaCompacta,listOnSalesforce.get(0).VisMed_Vista_Compacta__c,'Error en los datos');
        system.assertEquals(resp.forms.get(0).vistaDetalle,listOnSalesforce.get(0).VisMed_Vista_Detalle__c,'Error en los datos');
        system.assertEquals(resp.forms.get(0).vistaFormulario,listOnSalesforce.get(0).VisMed_Vista_Formulario__c,'Error en los datos');
    }

    @IsTest
    public static void ValidateMethodForRecordTypeObjeto(){
        RestRequest req = new RestRequest();
        req.addHeader('recordtype','Objeto');
        req.requestURI = '/services/apexrest/metadata/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        Test.startTest();
        WSMetadataApp.Respuesta resp = WSMetadataApp.doGet();
        Test.stopTest();

        List<VisMed_ConfigApp__c> listOnSalesforce = [
            SELECT id, Name, Objeto_Principal__c, VisMed_Vista_Compacta__c, VisMed_Vista_Detalle__c,VisMed_Vista_Formulario__c 
            FROM VisMed_ConfigApp__c
            WHERE VisMed_Activa__c = true 
            AND RecordTypeId = :recordTypeObjeto
        ];

        system.assertEquals(resp.status, 200, 'Error en el consumo del WS');
        system.assertEquals(resp.forms.size(),1,'Error en los datos');
        system.assertEquals(resp.forms.get(0).nombre,listOnSalesforce.get(0).Name,'Error en los datos');
        system.assertEquals(resp.forms.get(0).id,listOnSalesforce.get(0).Id,'Error en los datos');
        system.assertEquals(resp.forms.get(0).objetoPrincipal,listOnSalesforce.get(0).Objeto_Principal__c,'Error en los datos');
        system.assertEquals(resp.forms.get(0).vistaCompacta,listOnSalesforce.get(0).VisMed_Vista_Compacta__c,'Error en los datos');
        system.assertEquals(resp.forms.get(0).vistaDetalle,listOnSalesforce.get(0).VisMed_Vista_Detalle__c,'Error en los datos');
        system.assertEquals(resp.forms.get(0).vistaFormulario,listOnSalesforce.get(0).VisMed_Vista_Formulario__c,'Error en los datos');
    }

    @IsTest
    public static void ValidateMethodForRecordTypeNull(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/metadata/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        Test.startTest();
        WSMetadataApp.Respuesta resp = WSMetadataApp.doGet();
        Test.stopTest();
       
        system.assertEquals(resp.status, 200, 'Error en el consumo del WS');
        system.assertEquals(resp.forms.size(),0,'Error en los datos');       
    }
}