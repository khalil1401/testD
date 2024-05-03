@isTest
public class MkCloudNutritionForm_Test {
    
    @isTest
    public static void testInsertionOfFormMKFromVisualforcePage(){
        Account acc = Build.anAccountPacienteBestCare()
            .withLastName('BestCare 2')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En tratamiento')
            .withSubestadoDePaciente('Tratamiento Efectivo')
            .build();
        insert acc;
        PageReference page = Page.FormularioVForce;
        
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('pcid',acc.id);
              
        MkCloudNutritionFormController controller = new MkCloudNutritionFormController(null);
        Account account =controller.getPaciente(acc.id);    
        controller.insertRecords();
        
        List<Formulario_MarketingCloud__c> formMK = [
            SELECT id,Cuenta__c,Formula_que_consume_vs__c
            FROM Formulario_MarketingCloud__c
        ];
        System.assertEquals(acc.id, formMK[0].Cuenta__c);
       
        /*Segunda vez que se quiere contestar el formulario*/
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('pcid',acc.id);
        Account sameAccount =controller.getPaciente(acc.id);
        
        System.assertEquals(null, sameAccount);
    }

    @isTest
    Public static void siElpacienteCompletaElFormularioSeLeDebenGenerarSuKit() {
        List<Product2> productos = new List<Product2>();
       
        for(integer i=0;i<5 ;i++){
            Product2 product = Build.aProduct2()
                .withProductoPara('Best Care')
                .withName('AMNoNUBA ' + i)
                .withDescription('Producto'+ i)
                .build();
                product.Producto_SAP__c= true;
                product.IsActive= true;
                
            productos.add(product);
        }
        productos[0].Codigo_producto_Id_externo__c = '49636';
        productos[1].Codigo_producto_Id_externo__c = '49621';    
        productos[2].Codigo_producto_Id_externo__c = '53930';    
        productos[3].Codigo_producto_Id_externo__c = '49635';    
        productos[4].Codigo_producto_Id_externo__c = '49638';    
        productos[4].Name = 'LP Drink';
        
        insert productos;
        
        Account testCuenta = Build.anAccountPacienteBestCare()
            .withLastName('Prueba Met')	
            .withDNI('425452222')
            .withAreaTerapeutica('Metabólicos')
            .withEstadoDePaciente('En tratamiento')
            .withSubestadoDePaciente('Tratamiento Efectivo')
            .build();
        
        insert testCuenta;
        
        Test.startTest();
        MkCloudNutritionFormController_Helper.generaKitsNUBAyAMN(testCuenta.id);
        Test.stopTest();
        
        List<Envio_Sin_Cargo__c> kits = [
            SELECT id,Paciente__c
            FROM Envio_Sin_Cargo__c
            WHERE  Paciente__c = :testCuenta.id
        ];
        Set<Id> kitsID = new Set<Id>();
        for(Envio_Sin_Cargo__c aKit: kits){
            kitsID.add(aKit.id);
        }
        List<Producto_de_envio__c> productosDB = [
            SELECT id, Envio_sin_cargo__c,Formula__r.Name
            FROM Producto_de_envio__c
            WHERE Formula__r.Name LIKE '%AMNoNUBA%'
        ];
        List<Task> tareasEYN = [
            SELECT id,WhatId
            FROM Task
            WHERE WhatId = :testCuenta.id
        ];
        System.assertEquals(2, kits.size());
        System.assertEquals(4, productosDB.size()); 
        System.assertEquals(1, tareasEYN.size());  
        
    }
    
}