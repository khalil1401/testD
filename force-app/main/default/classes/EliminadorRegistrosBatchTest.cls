@isTest
public with sharing class EliminadorRegistrosBatchTest {
       
    @TestSetup
    static void insertarRegistrosDePrueba(){

        Clientes__c cliente = new Clientes__c();
        Facturacion__c facturacion = new Facturacion__c();
        Producto__c producto = new Producto__c();
        Referencia_Cruzada__c referencia = new Referencia_Cruzada__c();
        Transaccion_de_Inventario__c transaccion = new Transaccion_de_Inventario__c();
        Trazabilidad_de_Pedido__c trazabilidad = new Trazabilidad_de_Pedido__c();
        Stock__c stock = new Stock__c();        
       
        insert trazabilidad;
        insert stock;
        insert referencia;
        insert transaccion;
        insert producto;
        insert cliente;
        insert facturacion;
           
    }

    @isTest 
    public static void eliminacionExitosaDeRegistrosClientesMedianteBatch() {
        Test.startTest();    
        EliminadorRegistrosBatch batchClientes = new EliminadorRegistrosBatch('Clientes__c');
        database.executeBatch(batchClientes); 
        Test.stopTest();
        List<Clientes__c> lstCliente = [
        	SELECT Id
            FROM Clientes__c   
        ];
        System.assertEquals(0, lstCliente.size(),'El batch deberia borrar todos los registros');    
    }

    @isTest
    public static void eliminacionExitosaDeRegistrosTrazabilidadDePedidosMedianteBatch(){
        Test.startTest();
        EliminadorRegistrosBatch batchTraza = new EliminadorRegistrosBatch('Trazabilidad_de_Pedido__c');
        database.executeBatch(batchTraza);
        Test.stopTest();
         List<Trazabilidad_de_Pedido__c> lstTrazabilidad = [
         	SELECT Id 
            FROM Trazabilidad_de_Pedido__c                         
        ];
        System.assertEquals(0, lstTrazabilidad.size(),'El batch deberia borrar todos los registros');
    }

    @isTest
    public static void eliminacionExitosaDeRegistrosStockMedianteBatch(){
        Test.startTest();
        EliminadorRegistrosBatch batchStock = new EliminadorRegistrosBatch('Stock__c');
        database.executeBatch(batchStock); 
        Test.stopTest();               
        List<Stock__c> lstStock = [
        	SELECT Id
            FROM Stock__c                        
        ];
        System.assertEquals(0, lstStock.size(),'El batch deberia borrar todos los registros');
    }    

    @isTest
    public static void eliminacionExitosaDeRegistrosReferenciaCruzadaMedianteBatch(){
        Test.startTest();
        EliminadorRegistrosBatch batchReferencia = new EliminadorRegistrosBatch('Referencia_Cruzada__c');
        database.executeBatch(batchReferencia);
        Test.stopTest();
        List<Referencia_Cruzada__c> lstReferencia = [
        	SELECT Id 
            FROM Referencia_Cruzada__c                        
        ];
        System.assertEquals(0, lstReferencia.size(),'El batch deberia borrar todos los registros');
    }
    @isTest
    public static void eliminacionExitosaDeRegistrosTransaccionDeInventarioMedianteBatch(){
        Test.startTest();
        EliminadorRegistrosBatch batchTransaccion = new EliminadorRegistrosBatch('Transaccion_de_Inventario__c');
        database.executeBatch(batchTransaccion);
        Test.stopTest();        
        List<Transaccion_de_Inventario__c> lstTransaccion = [
        	SELECT Id 
            FROM Transaccion_de_Inventario__c                         
        ];
        System.assertEquals(0, lstTransaccion.size(),'El batch deberia borrar todos los registros');
    }
    @isTest
    public static void eliminacionExitosaDeRegistrosFacturacionMedianteBatch(){
        Test.startTest();
        EliminadorRegistrosBatch batchFacturacion = new EliminadorRegistrosBatch('Facturacion__c');
        database.executeBatch(batchFacturacion);  
        Test.stopTest();
        List<Facturacion__c> lstFacturacion = [
        	SELECT Id
            FROM Facturacion__c
        ];
        System.assertEquals(0, lstFacturacion.size(),'El batch deberia borrar todos los registros');
    }
    @isTest
    public static void eliminacionExitosaDeRegistrosProductoMedianteBatch(){
        Test.startTest(); 
        EliminadorRegistrosBatch batchProducto = new EliminadorRegistrosBatch('Producto__c');
        database.executeBatch(batchProducto, 200);
        Test.stopTest();
        List<Producto__c> lstProducto = [
        	SELECT Id 
            FROM Producto__c                            
        ];
        System.assertEquals(0, lstProducto.size(),'El batch deberia borrar todos los registros');

    }

}