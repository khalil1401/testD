public class MkCloudNutritionFormController_Helper {
    
    public static void generaKitsNUBAyAMN(String idDePaciente) {
        List<Envio_Sin_Cargo__c> kits = new List<Envio_Sin_Cargo__c>();
        Id recordTypeId = XappiaHelper.getRecordType('Envio_Sin_Cargo__c', 'EYN').id;
        
        List<Account> paciente = [
            SELECT id 
            FROM Account
            WHERE id = : idDePaciente
            LIMIT 1
        ];
        
        if(!paciente.isEmpty()){ 
            Envio_Sin_Cargo__c kitAMN = new Envio_Sin_Cargo__c();
            kitAMN.recordTypeId =recordTypeId;
            kitAMN.Razon_de_envio__c ='Kit de Inicio';
            kitAMN.Organizacion__c ='AMN';
            kitAMN.Autoriza_Envio__c = 'Adultos & Nicho';
            kitAMN.Estado_del_envio__c= 'Ingresado';
            kitAMN.Paciente__c= paciente.get(0).id;
            
            kits.add(kitAMN);
            Envio_Sin_Cargo__c kitNUBA = new Envio_Sin_Cargo__c();
            kitNUBA.recordTypeId =recordTypeId;
            kitNUBA.Razon_de_envio__c ='Kit de Inicio';
            kitNUBA.Organizacion__c ='NUBA';
            kitNUBA.Autoriza_Envio__c = 'Adultos & Nicho';
            kitNUBA.Estado_del_envio__c= 'Ingresado';
            kitNUBA.Paciente__c= paciente.get(0).id;
            
            kits.add(kitNUBA);
        }
        
        if(!kits.isEmpty()){
            insert kits;
            insertarProductosDeEnvio(kits, paciente.get(0));
        }
    }
    public static void insertarProductosDeEnvio(List<Envio_Sin_Cargo__c> kits,Account paciente) {
        List<Producto_de_envio__c> productosDeEnvio = new List<Producto_de_envio__c>();
        Product2 productoLPDrink;
        Set<String> codigosDeProductos = new Set<String>();
        Map<String, Productos_para_EYN__mdt> productosMapa = new Map<String, Productos_para_EYN__mdt>();
        
        List<Productos_para_EYN__mdt> productosMeta =[
            SELECT id, DeveloperName, Codigo_de_producto_EYN__c,Organizacion__c,Cantidad__c
            FROM Productos_para_EYN__mdt
        ];
        for(Productos_para_EYN__mdt prod : productosMeta){
            productosMapa.put(prod.Codigo_de_producto_EYN__c, prod);
        }
        
        List<Product2> productos =[
            SELECT Id, Name,ProductCode
            FROM Product2
            WHERE ProductCode IN : productosMapa.keySet()
            AND ProductCode !=null
        ];
        if(!productos.isEmpty()){
            for(Product2 aProducto: productos){
                Productos_para_EYN__mdt productoMetadata=  productosMapa.get(aProducto.productCode);
                if(productoMetadata.Organizacion__c== 'NUBA'){
                    productoLPDrink = aProducto;
                }
            }
            
            for(Envio_Sin_Cargo__c akit : kits){
                if(aKit.Organizacion__c== 'AMN'){
                    for(Product2 aProducto : productos){
                        Productos_para_EYN__mdt productoMetadata=  productosMapa.get(aProducto.ProductCode);
                        Producto_de_envio__c productoAMN = new Producto_de_envio__c();
                        if(productoMetadata.Organizacion__c =='AMN'){
                            productoAMN.Envio_sin_cargo__c = akit.id;
                            productoAMN.Formula__c = aProducto.id;
                            productoAMN.Cantidad__c=  productoMetadata.Cantidad__c;
                            productosDeEnvio.add(productoAMN);
                        }
                    }              
                }else{               
                    Producto_de_envio__c productoNUBA = new Producto_de_envio__c();
                    productoNUBA.Envio_sin_cargo__c = akit.id;
                    productoNUBA.Formula__c = productoLPDrink!= null ? productoLPDrink.id: null;
                    productoNUBA.Cantidad__c= '1';
                    productosDeEnvio.add(productoNUBA);
                }
            }
        }
        if(!productosDeEnvio.isEmpty()){
            insert productosDeEnvio;
            insertarTareaDeEYN(paciente);
        }
    }
    public static void insertarTareaDeEYN(Account paciente) {
        List<Task> tareasDeEYN = new List<Task>();
        Id psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND NAME = 'PSP'
            LIMIT 1
        ].id;
        
        Task tareaEYN = new Task();
        tareaEYN.Subject= Label.EYN_asunto;
        tareaEYN.Status= 'Abierta';
        tareaEYN.OwnerId= psp;
        tareaEYN.Description = Label.EYN_descripcion;
        tareaEYN.WhatId= paciente.id;
        tareasDeEYN.add(tareaEYN);
        
        insert tareasDeEYN;
    }
}