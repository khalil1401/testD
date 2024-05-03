@isTest
public class PedidoTriggerHelperTest{
    
    @isTest
    Public static void pedidoConMismoNumeroOrdenYFechaCreacionNoDebeExistir(){
        
        Account parent = Build.anAccountCliente().withName('Name').withStatus('A').build();
        insert parent;
        Account cuenta = Build.anAccountSucursaldeenvio()
            .withStatus('#')
            .withIdSucursalOracle('idTest')
            .withName('Prueba')
            .withTipoDeSucursal('SHIP_TO')						   				   
            .build();
        cuenta.ParentId = parent.Id;
        cuenta.DISTRIBUTIONCHANNELID__c = '00';
        insert cuenta;
        
        Order nuevoPedidoA = New Order();
        nuevoPedidoA.AccountId = cuenta.Id;
        nuevoPedidoA.Orden_de_compra__c = '123456';
        nuevoPedidoA.Status = 'Borrador';
        nuevoPedidoA.EffectiveDate = Date.today() + 1;  
        
        insert nuevoPedidoA;
        
        Order nuevoPedidoB = New Order();
        nuevoPedidoB.AccountId = cuenta.Id;
        nuevoPedidoB.Orden_de_compra__c = '123456';
        nuevoPedidoB.Status = 'Borrador';
        nuevoPedidoB.EffectiveDate = Date.today() + 1;  
        
        try{
            insert nuevoPedidoB;
        }
        
        catch(Exception e)
            
        {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una orden con la misma orden de compra y fecha de creacion');
            
            System.Assert(expectedExceptionThrown, 'Se esperaba el error: Ya existe una orden con la misma orden de compra y fecha de creacion');
            
        }                 
        
    }
    @isTest
    Public static void pedidoConMismoNumeroOrdenYFechaCreacionEnMismoInsert(){
        
        Account parent = Build.anAccountCliente().withName('Name').withStatus('A').build();
        insert parent;
        Account cuenta = Build.anAccountSucursaldeenvio()
            .withStatus('#')
            .withIdSucursalOracle('idTest')
            .withName('Prueba')
            .withTipoDeSucursal('SHIP_TO')						   				   
            .build();
        cuenta.ParentId = parent.Id;
        cuenta.DISTRIBUTIONCHANNELID__c = '00';
        insert cuenta;
        
        List<Order> nuevosPedidos = new List<Order>();
        
        Order nuevoPedidoA = New Order();
        nuevoPedidoA.AccountId = cuenta.Id;
        nuevoPedidoA.Orden_de_compra__c = '123456';
        nuevoPedidoA.Status = 'Borrador';
        nuevoPedidoA.EffectiveDate = Date.today() + 1;  
                
        Order nuevoPedidoB = New Order();
        nuevoPedidoB.AccountId = cuenta.Id;
        nuevoPedidoB.Orden_de_compra__c = '123456';
        nuevoPedidoB.Status = 'Borrador';
        nuevoPedidoB.EffectiveDate = Date.today() + 1; 
        
        nuevosPedidos.add(nuevoPedidoA);
        nuevosPedidos.add(nuevoPedidoB);
        
        try{
            insert nuevosPedidos;
        }
        
        catch(Exception e)
            
        {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una orden con la misma orden de compra y fecha de creacion');
            
            System.Assert(expectedExceptionThrown, 'Se esperaba el error: Ya existe una orden con la misma orden de compra y fecha de creacion');
            
        }                 
        
    }
    
    @isTest
    Public static void actualizarPedidoAOtroConMismoNumeroOrdenYFechaCreacion(){
        
        Account parent = Build.anAccountCliente().withName('Name').withStatus('A').build();
        insert parent;
        Account cuenta = Build.anAccountSucursaldeenvio()
            .withStatus('#')
            .withIdSucursalOracle('idTest')
            .withName('Prueba')
            .withTipoDeSucursal('SHIP_TO')						   				   
            .build();
        cuenta.ParentId = parent.Id;
        cuenta.DISTRIBUTIONCHANNELID__c = '00';
        insert cuenta;
                
        Order nuevoPedidoA = New Order();
        nuevoPedidoA.AccountId = cuenta.Id;
        nuevoPedidoA.Orden_de_compra__c = '123456';
        nuevoPedidoA.Status = 'Borrador';
        nuevoPedidoA.EffectiveDate = Date.today() + 1;  

                
        insert nuevoPedidoA;
        
        Order nuevoPedidoB = New Order();
        nuevoPedidoB.AccountId = cuenta.Id;
        nuevoPedidoB.Orden_de_compra__c = '78910';
        nuevoPedidoB.Status = 'Borrador';
        nuevoPedidoB.EffectiveDate = Date.today() + 1; 
        
        insert nuevoPedidoB;
        
        try{
            nuevoPedidoB.Orden_de_compra__c= '123456';
            update nuevoPedidoB;
        }
        
        catch(Exception e)
            
        {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una orden con la misma orden de compra y fecha de creacion');
            
            System.Assert(expectedExceptionThrown, 'Se esperaba el error: Ya existe una orden con la misma orden de compra y fecha de creacion');
            
        }                 
        
    }
    @isTest
    Public static void pedidosTodoOk(){
        
        Account parent = Build.anAccountCliente().withName('Name').withStatus('A').build();
        insert parent;
        Account cuenta = Build.anAccountSucursaldeenvio()
            .withStatus('#')
            .withIdSucursalOracle('idTest')
            .withName('Prueba')
            .withTipoDeSucursal('SHIP_TO')						   				   
            .build();
        cuenta.ParentId = parent.Id;
        cuenta.DISTRIBUTIONCHANNELID__c = '00';
        insert cuenta;
        
        Order nuevoPedidoA = New Order();
        nuevoPedidoA.AccountId = cuenta.Id;
        nuevoPedidoA.Orden_de_compra__c = '123456';
        nuevoPedidoA.Status = 'Borrador';
        nuevoPedidoA.EffectiveDate = Date.today() + 1;  
        
        insert nuevoPedidoA;
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(nuevoPedidoA.Id, yesterday);  
        
        Order nuevoPedidoB = New Order();
        nuevoPedidoB.AccountId = cuenta.Id;
        nuevoPedidoB.Orden_de_compra__c = '78910';
        nuevoPedidoB.Status = 'Borrador';
        nuevoPedidoB.EffectiveDate = Date.today() + 1;  
        
        try{
            insert nuevoPedidoB;
        }
        
        catch(Exception e)
            
        {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una orden con la misma orden de compra y fecha de creacion');
            
            System.assertNotEquals(expectedExceptionThrown, true, 'No se esperaba un error');
            
        }                 
        
    }
    
}