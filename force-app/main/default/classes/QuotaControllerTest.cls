@IsTest
public with sharing class QuotaControllerTest {
    @TestSetup
    static void makeData(){
        Id pricebookId = Test.getStandardPricebookId();
        Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
            .withIdSap('12340')
			.build();
			insert accountCanalComercial;
		Product2 productCanalComercial = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
            .withIdSap('23121')
			.build();
		insert productCanalComercial;	

		Dan360_Cuota__c cuotaCanalComercial =
			Build.aCuota()						
				.withCuota(0002)
				.withCuotaActiva('Activa')				
				.withProducto(productCanalComercial)
				.withCanalComercial('E-Commerce')										
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		insert cuotaCanalComercial;
    }
   @IsTest
   private static void whenSaveQuotaMustReturnStateSuccess(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
		Dan360_Cuota__c cuota = [
            SELECT Id, Dan360_Cuota__c
            FROM Dan360_Cuota__c
            WHERE Dan360_Cuota__c = 0002
        ];		
        String dataString = 'Producto,Cuota,Cliente,Canal Comercial,Canal de distribución,Saldo,Vigencia desde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('SUCCESS', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderVigenciaDesdeFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,Cliente,Canal Comercial,Canal de distribución,Saldo,BadVigenciaDesde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderVigenciaHastaFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,Cliente,Canal Comercial,Canal de distribución,Saldo,Vigencia Desde,BadHeaderVigenciaHasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderProductoFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'BadHedaderProducto,Cuota,Cliente,Canal Comercial,Canal de distribución,Saldo,BadVigenciaDesde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderCuotaFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,BadHeaderCuota,Cliente,Canal Comercial,Canal de distribución,Saldo,Vigencia Desde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderClienteFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,BadHeaderCliente,Canal Comercial,Canal de distribución,Saldo,Vigencia Desde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderCanalComercialFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,Cliente,BadHeaderCanalComercial,Canal de distribución,Saldo,Vigencia Desde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderCanaldeDistribucionFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,Cliente,Canal Comercial,BadHeaderCanaldeDistribución,Saldo,Vigencia Desde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderSaldoFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,Cliente,Canal Comercial,Canal de Distribución,BadHeaderSaldo,Vigencia Desde,Vigencia hasta,Estado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenSaveQuotaWithBadHeaderEstadodeCuotaFieldEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];        
				
        String dataString = 'Producto,Cuota,Cliente,Canal Comercial,Canal de Distribución,Saldo,Vigencia Desde,Vigencia hasta,BadHeaderEstado de cuota\r\n'+
        producto.Id_SAP__c+',0002,'+account.Id_SAP__c+',,,1000,'+Date.Today()+','+Date.Today().addDays(1)+',Activa';
        String base64Data = JSON.serialize(dataString);
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
   @IsTest
   private static void whenCSVIsEmptyMustReturnAnErrorMessage(){
    
        Account account = [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c = '12340'
        ];
        
		Product2 producto = [
            SELECT Id, Id_SAP__c
            FROM Product2
            WHERE Id_SAP__c = '23121'
        ];     		
        
        String base64Data = '';
        Test.startTest();
        ServerResponse response = QuotaController.save(base64Data);
        Test.stopTest();
        System.assertEquals('ERROR', response.state, 'Error al guardar cuota');
   }
}