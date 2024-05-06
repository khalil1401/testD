public with sharing class ProductListComponentController {
    @AuraEnabled
    public static List<WrapProduct> getProductList (String recordId){
        List<WrapProduct> listProducts = new List<WrapProduct>();
        // Obtenemos el Id de la cuenta de la orden y la unidad de negocio
        Order pedido = [
            SELECT ID, Name,OrderNumber, AccountId, Dan360_UnidadNegocio__c, Dan360_PlantillaProductos__c, TotalAmount, Dan360_CustomerSalesArea__c, RecordType.Name
            FROM Order
            WHERE id = :recordId
            WITH SECURITY_ENFORCED
        ];

        String distributionChannel = pedido.RecordType.Name == 'Pedido de Venta Directa' ? '00' : '05';

        Map<String, OrderItem> mapitemsDePedido = new Map<String, OrderItem>();
        List<OrderItem> itemsDePedido = [
            SELECT id, Product2Id
            FROM OrderItem
            WHERE OrderId = :recordId
            WITH SECURITY_ENFORCED
        ];
        for(OrderItem item : itemsDePedido){
            mapitemsDePedido.put(item.Product2Id, item);
        }

        // Obtenemos la lista de precios
        Account cuenta = [
            SELECT ID, Name, Dan360_ListaPrecios__c
            FROM Account
            WHERE id = :pedido.AccountId
            WITH SECURITY_ENFORCED
        ];

        // Obtenemos la Plantilla de la cuenta perteneciente a la unidad de negocio que sea igual al pedido (Nuba o AMN)
        dAN360_PlantillaporcCuenta__c plantillaCuenta = [
            SELECT ID, Name, Dan360_UnidadNegocio__c, Dan360_PlantillaDeProductos__c
            FROM dAN360_PlantillaporcCuenta__c
            WHERE Dan360_Cuenta__c =:cuenta.ID
                AND 
                    (Dan360_UnidadNegocio__c = :pedido.Dan360_UnidadNegocio__c AND Dan360_DistributionChannel__c = :distributionChannel)
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        //TODO informar que no hay plantilla en caso de que la query no devuelva nada
        /* pedido.Dan360_PlantillaProductos__c = plantillaCuenta.Dan360_PlantillaDeProductos__c;
        update pedido; */

        //Obtenemos los ID de los productos pertenecientes a la plantilla de dicha unidad de negocio.
        List<Dan360_ProductoPorPlantilla__c> plantillaProductos = [
            SELECT Dan360_Producto__c, Dan360_UnidadDeMedida__c, Dan360_Activo__c, Dan360_VigenciaDesde__c, Dan360_Vigencia__c
            FROM Dan360_ProductoPorPlantilla__c
            WHERE Dan360_PlantillaProductos__c = :plantillaCuenta.Dan360_PlantillaDeProductos__c AND Dan360_Activo__c = true
                AND Dan360_VigenciaDesde__c <= TODAY //AND Dan360_Vigencia__c >= TODAY
            WITH SECURITY_ENFORCED
        ];
        System.debug('Productos de plantilla');
        System.debug(plantillaProductos);
        
        List<String> prodIds = new List<String>();
        Map<String, String> mapUnidadMedidaProducto = new Map<String, String>();
        for(Dan360_ProductoPorPlantilla__c productosId : plantillaProductos){
            prodIds.add(productosId.Dan360_Producto__c);
            mapUnidadMedidaProducto.put(productosId.Dan360_Producto__c,productosId.Dan360_UnidadDeMedida__c);
        }

        // Productos
        List<Product2> products = [
            SELECT Id, Name , ProductCode ,Dan360_UnidadesPorBulto__c//, (SELECT UnitPrice FROM PricebookEntries)
            FROM Product2
            WHERE Id IN : prodIds AND IsActive = true
            WITH SECURITY_ENFORCED
        ];
        System.debug('products');
		System.debug(products);
        // Se filtran para obtener solamente los productos que no estan ya en la order (como OrderItem)
        Map<String,Product2> mapProducts = new  Map<String,Product2>();
        for(Product2 prod : products){
            if(mapitemsDePedido.containsKey(prod.Id)){
                continue;
            }
            mapProducts.put(prod.Id, prod);
        }
        //System.debug('products que no estan en la orden');
        //System.debug(mapProducts);
        //************************************************************
        //OLD LOGIC TO GET LISTA DE PRECIOS START HERE
        //************************************************************
        /*
        String UnidadNegocioID;
        switch on pedido.Dan360_UnidadNegocio__c {
            when 'AMN'{
                UnidadNegocioID = '5800';
            }
            when 'NuBa' {
                UnidadNegocioID = '5770';
            }
        }
        System.debug('UnidadNegocioID');
        System.debug(UnidadNegocioID);
        // Precio de Productos en la lista de la cuenta. CAMBIAR LOGICA POR SALES AREA.
        Dan360_CustomerSalesArea__c customerSalesArea = [
            SELECT  id
            FROM    Dan360_CustomerSalesArea__c
            WHERE   Dan360_SalesArea__r.Dan360_SalesOrganization__c = :UnidadNegocioID
                AND Dan360_SalesArea__r.Dan360_DistributionChannel__c = '01'
                // AND Dan360_SalesArea__r.Dan360_DistributionChannel__c = '00'
            LIMIT 1
        ];
        System.debug('customerSalesArea');
        System.debug(customerSalesArea);
        */
        //************************************************************
        //OLD LOGIC END HERE
        //************************************************************

        //************************************************************
        //NEW LOGIC TO GET LISTA DE PRECIOS START HERE
        //************************************************************
        // ?______________________________________________________________________________________________________________________________________________
        // System.debug('Dan360_CustomerSalesArea__c:::' + pedido.Dan360_CustomerSalesArea__c);
        // if (pedido.Dan360_CustomerSalesArea__c != null) {
        //     Pricebook2 priceList = [SELECT id FROM Pricebook2 WHERE Dan360_CustomerSalesArea__c =: pedido.Dan360_CustomerSalesArea__c];
        //     System.debug('Lista de Precios');
        //     System.debug(priceList);
        // } else {

        // }
        // ?______________________________________________________________________________________________________________________________________________



        /* SI ES 05, TRAER LA ESTANDARD , SI ES LA 00, TRAER LA QUE CORRESPONDE ----------------> Hacer esto*/
        Pricebook2 priceList;
        if(distributionChannel == '00'){
            /* Pricebook2  */priceList = [SELECT id FROM Pricebook2 WHERE Dan360_CustomerSalesArea__c =: pedido.Dan360_CustomerSalesArea__c LIMIT 1]; 
        } else {
            priceList = [SELECT id FROM Pricebook2 WHERE Name = 'Standard Price Book'];
        }
        //Pricebook2 priceList = [SELECT id FROM Pricebook2 WHERE Dan360_CustomerSalesArea__c =: pedido.Dan360_CustomerSalesArea__c];
        System.debug('Lista de Precios');
        System.debug(priceList);


   
        
        
        //************************************************************
        //NEW LOGIC END HERE
        //************************************************************
        List<PricebookEntry> products2 = [
            SELECT Id, Product2.Name, Product2.Dan360_UnidadesPorBulto__c, unitPrice, Dan360_Descuento__c, UnitPriceWithDiscountS__c
            FROM PricebookEntry
            WHERE Product2Id IN :prodIds
                AND Pricebook2Id =: priceList.Id
                AND IsActive = true
            WITH SECURITY_ENFORCED 
        ];
        System.debug('PricebookEntry pertenencientes a los productos y a la lista de precios de la cuenta');
        System.debug(products2);

        // Completamos el wrapper que se va a pasar al JS del LWC.
        for(PricebookEntry priceBookEntryForProduct : products2){
            
            String unidad;
            if(mapProducts.containsKey(priceBookEntryForProduct.Product2Id)){
                Product2 product2 = mapProducts.get(priceBookEntryForProduct.Product2Id);
                System.debug('PricebookEntry pertenencientes a los productos y a la lista de precios de la cuenta');
                System.debug(priceBookEntryForProduct);
                if(mapUnidadMedidaProducto.containsKey(priceBookEntryForProduct.Product2Id)){
                    /* Si mapUnidadMedidaProducto.get(priceBookEntryForProduct.Product2Id) es null, poner Unidad ----------------> Hacer esto*/
                    unidad = mapUnidadMedidaProducto.get(priceBookEntryForProduct.Product2Id) == null ? 'Unidad' :mapUnidadMedidaProducto.get(priceBookEntryForProduct.Product2Id);
                    System.debug('Unidad Medida');
                    System.debug(unidad);
                }
                if(priceBookEntryForProduct.Dan360_Descuento__c == null) {
                    priceBookEntryForProduct.Dan360_Descuento__c = 0;
                }
                WrapProduct product = new WrapProduct(
                    product2.Name,
                    priceBookEntryForProduct.unitPrice,
                    product2.Dan360_UnidadesPorBulto__c,
                    unidad,
                    priceBookEntryForProduct.Product2Id,
                    recordId,
                    priceBookEntryForProduct.Id,
                    product2.ProductCode,
                    priceBookEntryForProduct.Dan360_Descuento__c,
                    pedido.TotalAmount,
                    priceBookEntryForProduct.UnitPriceWithDiscountS__c
                );
                listProducts.add(product);
                System.debug('product wrapper');
                System.debug(product);
            }
        }
        return listProducts;
    }

    @AuraEnabled
    public static String saveProducts(string listProducts){
        //System.debug(listProducts);
        List<OrderItem> listNewOrderItem = new List<OrderItem>();
        List<ProductListComponentController.WrapProduct> productos =
            (List<ProductListComponentController.WrapProduct>) JSON.deserialize(
                listProducts,
                List<ProductListComponentController.WrapProduct>.class
        );


        for(ProductListComponentController.WrapProduct product : productos){
            if(product.descuento == null){
                product.descuento = 0;
            }
            System.debug('product save');
            System.debug(product);
            System.debug('product.UnitPriceWithDiscount');
            System.debug(product.UnitPriceWithDiscount);
            Decimal unitPriceToInsert;
            if(product.UnitPriceWithDiscount != null){
                String decimalString1 = '00';
                List<String> listString1 = product.UnitPriceWithDiscount.split('\\.');
                System.debug(listString1);
                if(listString1.size() == 1){
                    unitPriceToInsert = Decimal.valueOf(listString1[0]);
                } else {
                    if(listString1[1].length() == 1){
                        decimalString1 = listString1[1]+'0';
                    }else{
                        decimalString1 = listString1[1].substring(0,2);
                    }
                    String fullUnitPriceString1 =  listString1[0]+'.'+decimalString1;
                    unitPriceToInsert = Decimal.valueOf(fullUnitPriceString1);
                }
                
            } else {
                unitPriceToInsert = product.price;
            }
 
            OrderItem newOrderItem = new OrderItem();
            newOrderItem.OrderId = product.pedidoId;
            newOrderItem.Product2Id = product.productoId;
            newOrderItem.UnitPrice = unitPriceToInsert;//product.price - ((product.price * product.descuento)/100);
            newOrderItem.Quantity = product.cantidad;
            newOrderItem.PricebookEntryId = product.priceBookId;
            newOrderItem.Dan360_Descuento__c = product.descuento;
            newOrderItem.Dan360_ListPrice__c = product.price;
            newOrderItem.Dan360_UnidadMedida__c = product.unidadMedida;
            listNewOrderItem.add(newOrderItem);
            System.debug('newOrderItem');
            System.debug(newOrderItem);
        }
        String estado;
        Database.SaveResult[] saveResultList = Database.insert(listNewOrderItem, true);
        for (Database.SaveResult sr : saveResultList) {
            if (sr.isSuccess()) {
                String exito = 'Los productos seleccionados se han agregado correctamente';
                estado = exito;
            }
            else {
                String errorList;
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    errorList += err.getStatusCode() + ': ' + err.getMessage() + '/br';
                }
                estado = errorList;
            }
        }

        return estado;
    }

    public class WrapProduct{
        @AuraEnabled
        public String name { get;set;}
        @AuraEnabled
        public Decimal price { get;set;}
        @AuraEnabled
        public Decimal bulto { get;set;}
        @AuraEnabled
        public Decimal totalPrice { get;set;}
        @AuraEnabled
        public Integer cantidad { get;set;}
        @AuraEnabled
        public String unidadMedida { get;set;}
        @AuraEnabled
        public String productoId { get;set;}
        @AuraEnabled
        public String pedidoId { get;set;}
        @AuraEnabled
        public String priceBookId { get;set;}
        @AuraEnabled
        public String productCode { get;set;}
        @AuraEnabled
        public Decimal descuento { get;set;}
        @AuraEnabled
        public Decimal orderPrice { get;set;}
        @AuraEnabled
        public String UnitPriceWithDiscount { get;set;}

        public WrapProduct(String name, Decimal price, Decimal bulto, String unidadMedida, String productoId, String pedidoId, String priceBookId, String productCode, Decimal descuento,  Decimal orderPrice, String UnitPriceWithDiscount){
            this.name = name;
            this.price = price;
            this.bulto = bulto;
            this.cantidad = 0;
            this.totalPrice = 0;
            this.unidadMedida = unidadMedida;
            this.productoId = productoId;
            this.pedidoId = pedidoId;
            this.priceBookId = priceBookId;
            this.productCode = productCode;
            this.descuento = descuento;
            this.orderPrice = orderPrice;
            this.UnitPriceWithDiscount = UnitPriceWithDiscount;
        }
    }


}