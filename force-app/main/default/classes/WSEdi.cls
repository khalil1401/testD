@RestResource(urlMapping='/edi')
global with sharing class WSEdi {

    @HttpPost
    global static Respuesta doPost() {

        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        String jsonStr = req.requestBody.toString();
        Request request = (Request)JSON.deserialize(jsonStr, Request.class);
        
        List<String> clientesTablaSF = new List<String>();

        for(Clientes_No_EDI__mdt tablaGLN : Clientes_No_EDI__mdt.getAll().values()){
            clientesTablaSF.add(tablaGLN.GLN__c);
        }

        
        if(!clientesTablaSF.contains(request.soldTo)){ //Si NO existe en la tabla, es un cliente que procesar.
            Decimal shiptTo = Decimal.valueOf(request.shipTo);
            String companyCode = '5771';
            List<Account> sucursal = [SELECT ID,Id_SAP__c, Cliente_EDI__c FROM Account WHERE Dan360_StoreEAN__c = :shiptTo];

            List<String> productsEAN = new List<String>();
            List<Product2> productsToAdd = new List<Product2>();
            List<Items> productsWithError = new List<Items>();
            Map<String , String> mapProductLotQuantity = new Map<String , String>();
            Map<String , String> mapEanLotQuantity = new Map<String , String>();
            
            if(sucursal.size() > 0) { // Si el cliente existe en SF.
                List<Dan360_CustomerSalesArea__c> customerSalesAreas = [SELECT id, Dan360_Block__c 
                                                                FROM Dan360_CustomerSalesArea__c 
                                                                WHERE Dan360_SalesArea__r.Dan360_SalesOrganization__c = :companyCode 
                                                                    AND Dan360_SalesArea__r.Dan360_DistributionChannel__c = '00'
                                                                    AND Dan360_Customer__c = :sucursal[0].Id];
                if(customerSalesAreas.isEmpty()){
                    respuesta.message = 'Cliente sin customer sales area';
                    return respuesta;
                }
                Dan360_CustomerSalesArea__c customerSalesArea = customerSalesAreas[0];
                Boolean block = customerSalesArea.Dan360_Block__c; //Si tiene bloqueo, se crea orden con Error.
                Boolean checkEdi = sucursal[0].Cliente_EDI__c; //Si tiene el check, se crea la orden confirmada, caso contrario, se crea con error.
                Map<String, Product2> mapEANProducts = new Map<String, Product2>();

                for(Items item : request.items){// Mapa de material con Cantidad pedida.
                    productsEAN.add(item.matNumber);
                    if(!mapEanLotQuantity.containsKey(item.matNumber)){
                        mapEanLotQuantity.put(item.matNumber, item.lotQuantity);
                    }
                }

                for(Product2 producto : [SELECT Id, Name, Dan360_ean13__c, Dan360_UnidadesPorBulto__c,Id_SAP__c FROM Product2 WHERE Dan360_ean13__c IN :productsEAN]){
                    if(!mapEANProducts.containsKey(producto.Dan360_ean13__c)){ // Mapa de Producto con su EAN
                        mapEANProducts.put(producto.Dan360_ean13__c, producto);
                    }
                }
    
                for(String ean : mapEANProducts.keySet()){
                    if(mapEanLotQuantity.containsKey(ean)){ // Creo un mapa del Id del producto con la cantidad pedida.
                        mapProductLotQuantity.put(mapEANProducts.get(ean).id, mapEanLotQuantity.get(ean));
                    }
                }
                
                for(Items item : request.items){
                    
                    if(mapEANProducts.containsKey(item.matNumber)){
                        productsToAdd.add(mapEANProducts.get(item.matNumber)); //Producto a agregar a la orden
                    } else {
                        productsWithError.add(item); //Producto que no se encuentra en SF, se crea un log asociado a la orden.
                    }
                }
                // System.debug('productsToAdd');
                // System.debug(productsToAdd);
                // System.debug('productsWithError');
                // System.debug(productsWithError);
                // System.debug('mapProductLotQuantity');
                // System.debug(mapProductLotQuantity);
                //CREAR ORDEN
                // WSEdiHelper.createOrder(request,sucursal[0], productsToAdd, mapProductLotQuantity,productsWithError, checkEdi, request.poNumber, companyCode, block, jsonStr);


                String request_content = JSON.serialize(request);
                String informationAccount = JSON.serialize( sucursal[0] ); 
                String request_productsToAdd = JSON.serialize(productsToAdd);
                String request_mapProductLotQuantity = JSON.serialize(mapProductLotQuantity);
                String request_productsWithError = JSON.serialize(productsWithError);     
                
                executeOrderStore(request_content, informationAccount, request_productsToAdd,  request_mapProductLotQuantity, request_productsWithError, String.valueOf(checkEdi), request.poNumber, companyCode, String.valueOf(block), jsonStr );


                respuesta.message = 'Recibi los datos para crear la orden';
            } else { //CREAR LOG DE QUE NO SE ENCONTRO LA SUCURSAL CARGADA EN SF.  
                WSEdiHelper.createAppLog(request, 'Cliente - Sucursal inexistente', jsonStr);
                respuesta.message = 'Sucursal inexistente';
            }
        } else { //CREAR LOG DE QUE NO ES CLIENTE EDI. 
            //WSEdiHelper.createAppLog(request, 'Cliente - No es cliente EDI', jsonStr);
            respuesta.message = 'No es un cliente EDI. No se procesa en Salesforce';
        }
        
        return respuesta;
    }

    @future(callout=true)
    public static void executeOrderStore(String request_content, String accountInfo, String request_productsToAdd , String request_mapProductLotQuantity, String request_productsWithError, String request_checkEdi , String request_poNumber , String companyCode, String request_block, String request_jsonStr ){
        // WSEdi.Request request,Account sucursal, List<Product2> productsToAdd,Map<String,String> mapProductLotQuantity, List<WSEdi.Items> productsWithError, Boolean ediCheck, String poNumber, String companyCode, Boolean block, String jsonStr

        Request request = (Request) JSON.deserialize( request_content , Request.class);
        Account sucursal = (Account) JSON.deserialize( accountInfo , Account.class);
        List<Product2> productsToAdd = (List<Product2>) JSON.deserialize( request_productsToAdd , List<Product2>.class);
        Map<String, String> mapProductLotQuantity = (Map<String, String>) JSON.deserialize( request_mapProductLotQuantity , Map<String,String>.class);
        List<WSEdi.Items> productsWithError = (List<WSEdi.Items>) JSON.deserialize(request_productsWithError, List<WSEdi.Items>.class);
        Boolean block = Boolean.valueOf(request_block);
        Boolean checkEdi = Boolean.valueOf(request_checkEdi);

        WSEdiHelper.createOrder(request, sucursal, productsToAdd, mapProductLotQuantity, productsWithError, checkEdi , request_poNumber, companyCode , block, request_jsonStr);
    }
    

    global class Request {
        public String companyCode {get; set;}
        public String organizationId {get; set;}
        public String poNumber {get; set;}
        public String soldTo {get; set;}
        public String shipTo {get; set;}
        public List<Items> items {get; set;}
    }

    global class Items {
        public String matNumber {get; set;}
        public String orderedQuantity {get; set;}
        public String lotQuantity {get; set;}
        public String quantityByLot {get; set;}
    }

    global class Respuesta {
        public String message {get;set;}
    }
}