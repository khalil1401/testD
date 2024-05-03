@isTest
public class PedidoTest {

    @isTest
    Public static void pedidoDebeTomarListaDePrecioDeCuenta(){
        
        PriceBook2 listaDePrecios = New PriceBook2();
        listaDePrecios.Name = 'Lista de prueba';
        listaDePrecios.IsActive = True;
        
        insert listaDePrecios;
        
		Account parent = Build.anAccountCliente().withName('Name').withStatus('#').build();
		insert parent;
		Account cuenta = Build.anAccountSucursaldeenvio()
							.withStatus('#')
							.withListaDePrecios(listaDePrecios.Id)
							.withIdSucursalOracle('idTest')
							.withName('Prueba')
							.withTipoDeSucursal('SHIP_TO')						   				   
							.build();
        cuenta.ParentId = parent.Id;
        cuenta.DISTRIBUTIONCHANNELID__c = '00';
        insert cuenta;
        
        Order nuevoPedido = New Order();
        nuevoPedido.AccountId = cuenta.Id;
        nuevoPedido.Status = 'Borrador';
		nuevoPedido.EffectiveDate = Date.today() + 1;        
        Test.startTest();
        insert nuevoPedido;
        Test.stopTest();
        
        Order pedidoModificado = [ SELECT PriceBook2Id FROM Order WHERE Id = :nuevoPedido.Id ];
        
        System.assertEquals(listaDePrecios.Id, pedidoModificado.Pricebook2Id);
        
    }
    
}