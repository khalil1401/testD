trigger OrderItem_Trigger on OrderItem (before insert, before update, before delete) {

    if( Trigger.IsBefore && Trigger.IsInsert ){
        
        List<Id> productosId = New List<Id>();
        For( OrderItem prodPedido : Trigger.New ){
            
            productosId.add(prodPedido.Product2Id);
        
        }
        
        List<Product2> productos = New List<Product2>();
        productos = [SELECT id, stock__c FROM Product2 WHERE Id IN:productosId];
        
        Map<Id, Product2> mapProductos = New Map<Id, Product2>();
        For( Product2 producto : productos ){
            
            mapProductos.put(producto.Id, producto);
        
        }
        
        Product2 producto;
        For( orderItem prodPedido : Trigger.New ){
            
            producto = mapProductos.get(prodPedido.Product2Id);
            If( producto.Stock__c > prodPedido.Quantity ){
                
                prodPedido.Estado_stock__c = 'Disponible';
                prodPedido.Cantidad_disponible_para_el_pedido__c = prodPedido.Quantity;
                producto.Stock__c -= prodPedido.Quantity;
            
            }else If( producto.Stock__c <= 0 ){
                
                prodPedido.Estado_stock__c = 'Sin stock';
                prodPedido.Cantidad_disponible_para_el_pedido__c = 0;
                producto.Stock__c = 0;
            
            }else If( producto.Stock__c < prodPedido.Quantity ){
            
                prodPedido.Estado_stock__c = 'Entrega parcial';
                prodPedido.Cantidad_disponible_para_el_pedido__c = producto.Stock__c;
                producto.Stock__c = 0;
            
            }
        }
        
        update mapProductos.values();
        
    }else if( Trigger.isUpdate && Trigger.isBefore ){
        
        Map<Id, OrderItem> newOrderItems = Trigger.NewMap;
        List<Id> productosId = New List<Id>();
        
        For( OrderItem productoDePedido : Trigger.New ){
            
            productosId.add(productoDePedido.Product2Id);
            
        }
        
        List<Product2> productos = New List<Product2>();
        
        productos = [SELECT Id, Stock__c 
                     FROM Product2 
                     WHERE Id IN : productosId];
        
        Map<Id,Product2> mapProductos = New Map<Id, Product2>();
        
        For( Product2 prod : productos ){
            
            mapProductos.put(prod.Id, prod);
            
        }
        
        Product2 producto;
        OrderItem prodNuevo;
        For( OrderItem prodViejo : Trigger.Old ){
            
            producto = mapProductos.get(prodViejo.Product2Id);
            prodNuevo = newOrderItems.get(prodViejo.Id);

            producto.Stock__c += prodViejo.Cantidad_disponible_para_el_pedido__c;
            //producto.Stock__c = producto.Stock__c - prodNuevo.Quantity;
            
            If( prodNuevo.Quantity < producto.Stock__c ){
                
                prodNuevo.Estado_stock__c = 'Disponible';
                prodNuevo.Cantidad_disponible_para_el_pedido__c = prodNuevo.Quantity;
                producto.Stock__c = producto.Stock__c - prodNuevo.Quantity;
                
            }else If( producto.Stock__c <=0 ){
                
                prodNuevo.Estado_stock__c = 'Sin stock';
                prodNuevo.Cantidad_disponible_para_el_pedido__c = 0;
                producto.Stock__c = 0;
                
            }else If( producto.Stock__c < prodNuevo.Quantity ){
                
                prodNuevo.Estado_stock__c = 'Entrega parcial';
                prodNuevo.Cantidad_disponible_para_el_pedido__c = producto.Stock__c;
                producto.Stock__c = 0;
            
            }
            
            //producto.Stock__c = producto.Stock__c - prodNuevo.Quantity;
        
        }
        
        update mapProductos.values();
        
    }If( Trigger.isDelete && Trigger.isBefore ){
        
        List<Id> productosId = New List<Id>();
        
        For( OrderItem prodDeOportunidad : Trigger.Old ){
            
            productosId.add(prodDeOportunidad.Product2Id);
            
        }
        
        List<Product2> productos = [SELECT Id, Stock__c
                                   FROM Product2
                                   WHERE Id IN: productosId];
        
        Map<Id, Product2> mapProductos = New Map<Id, Product2>();
        
        For( Product2 prod: productos ){
            
            mapProductos.put(prod.Id, prod);
            
        }
        
        Product2 producto;
        For( OrderItem prodOportunidad : Trigger.Old ){
            
            producto = mapProductos.get( prodOportunidad.Product2Id );
            
            If( prodOportunidad.Cantidad_disponible_para_el_pedido__c > 0){
            	producto.Stock__c += prodOportunidad.Cantidad_disponible_para_el_pedido__c;
            }
            
        }
        
        update mapProductos.values();
        
    }
}