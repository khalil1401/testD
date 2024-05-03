@isTest
public with sharing class ProductoDeInternacionTriggerTest {
    @TestSetup
    static void makeData(){
        Account accountTest = new Account();
        accountTest.LastName = 'Test acc';
        accountTest.recordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Sanatorio').Id;
        insert accountTest;
        
        Internacion__c internacionTest = new Internacion__c();
        internacionTest.Paciente__c = accountTest.Id;
        
        insert internacionTest;
        
        Modulo__c moduloToTest = Build.aModulo()
            .withName('Alergia')
            .withDescripcion('Test')
            .build();
        insert moduloToTest;
        
        Modulo__c moduloEnteral = Build.aModulo()
            .withName('Enteral Advanced')
            .withDescripcion('Test')
            .build();
        insert moduloEnteral;
        
        
        Product2 product = Build.aProduct2().build();
        product.Producto_SAP__c = true;
        product.Modulo__c = 'Alergia';
        insert product;
        
        Product2 productEnteral = Build.aProduct2().build();
        productEnteral.Producto_SAP__c = true;
        productEnteral.Modulo__c = 'Enteral Advanced';
        insert productEnteral;
    }
    
    @isTest
    public static void siSeInsertaUnNuevoProductoSeDebenCompletarLostiposDeServicioEnLAInternacion() {
        
        Producto_de_Internacion__c productTest = new Producto_de_Internacion__c();
        productTest.Internacion__c= getInternacion().Id;
        productTest.Tipo_de_servicio__c = 'Cuidado completo';
        productTest.Producto__c = getProduct2()[1].Id;
        
        insert productTest;
        
        System.assertEquals('Cuidado completo', getInternacion().Tipo_de_Servicio__c);
        System.assertEquals('Enteral Advanced',getInternacion().Modulo__r.Name);
    }
    
    @isTest
    public static void siSeInsertaUnNuevoProductoDeMayorJerarquiaSeDebenCompletarLostiposDeServicioEnLAInternacion() {
        
        Producto_de_Internacion__c productTest = new Producto_de_Internacion__c();
        productTest.Internacion__c= getInternacion().Id;
        productTest.Tipo_de_servicio__c = 'Cuidado completo';
        productTest.Producto__c = getProduct2()[0].Id;
        insert productTest;
        
        Producto_de_Internacion__c productTest2 = new Producto_de_Internacion__c();
        productTest2.Internacion__c= getInternacion().Id;
        productTest2.Tipo_de_servicio__c = 'Cuidado completo';
        productTest2.Producto__c = getProduct2()[1].Id;
        
        Test.startTest();
        insert productTest2;
        
        Test.stopTest();
        System.assertEquals( 'Enteral Advanced', getInternacion().Modulo__r.Name);
    }
    
    @isTest
    public static void siSeEliminaUnNuevoProductoSeDebenCompletarLostiposDeServicioEnLAInternacion() {
        
        Producto_de_Internacion__c productTest = new Producto_de_Internacion__c();
        productTest.Internacion__c= getInternacion().Id;
        productTest.Tipo_de_servicio__c = 'Cuidado completo';
        productTest.Producto__c = getProduct2()[0].Id;
        
        insert productTest;
        
        Producto_de_Internacion__c productTest2 = new Producto_de_Internacion__c();
        productTest2.Internacion__c= getInternacion().Id;
        productTest2.Producto__c = getProduct2()[1].Id;
        
        insert productTest2;
        
        Test.startTest();
        
        Producto_de_Internacion__c prod = 
            [
                SELECT id
                FROM Producto_de_Internacion__c
                WHERE id = :productTest2.Id
            ];
        
        delete prod;
        
        Test.stopTest();
        
        System.assertEquals( 'Alergia', getInternacion().Modulo__r.Name);
        
        
    }
    
    public static Internacion__c getInternacion(){
        return [
            SELECT id,Tipo_de_Servicio__c,Modulo__c,Modulo__r.Name
            FROM Internacion__c
            LIMIT 1
        ];
    }
    public static List<Product2> getProduct2(){
        return [
            SELECT id,Modulo__c
            FROM Product2
        ];
    }
    public static List<Modulo__c> getModulo(){
        return [
            SELECT id,Name
            FROM Modulo__c
        ];
    }
    
}