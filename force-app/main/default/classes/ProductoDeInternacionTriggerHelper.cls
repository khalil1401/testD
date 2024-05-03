public class ProductoDeInternacionTriggerHelper {
    public static void autoCompleteModuloAndTipoDeServicio(List<Producto_de_Internacion__c> productosInternacionList){
        
        List<Id> internacionesIds = new List<Id> (); 
        Map<id, Internacion__c> internacionesToUpdate = new Map<id,Internacion__c> ();                 
        Map<String, Modulo__c> mapaModulos = new Map<String, Modulo__c>();
        List<String> modulosSelected = new List<String>();
        List<String> namesOfServiciosAlreadySelected = new List<String>();
        List<Modulo_disponible__mdt> modulosMtdFilter = new List<Modulo_disponible__mdt>();
        Map<String, double> metadataNombreConJerarquia = new Map<String, double>();
        Map<String, double> metadataTotal = new Map<String, double>();
        
        for (Producto_de_Internacion__c productoDeInternacion : productosInternacionList) {    
            internacionesIds.add(productoDeInternacion.Internacion__c);            
        }
        
        Map<id, Internacion__c> mapInternaciones = 
            new Map<Id, Internacion__c> ([
                SELECT id, Tipo_de_Servicio__c
                FROM Internacion__c
                WHERE Id IN :internacionesIds
            ]);
        
        List<Producto_de_Internacion__c> existingProductosDeInternacion = [
            SELECT id,Internacion__c,Modulo_del_producto__c  ,Tipo_de_servicio__c
            FROM Producto_de_Internacion__c 
            WHERE Internacion__c IN :mapInternaciones.keySet()
        ];
        
        if(Trigger.isDelete && existingProductosDeInternacion.isEmpty()){
            for (Producto_de_Internacion__c internacionProd : productosInternacionList) {
                Internacion__c newInternacion = mapInternaciones.get(internacionProd.Internacion__c);     
                newInternacion.Tipo_de_Servicio__c = null;
                newInternacion.Modulo__c = null;
                
                internacionesToUpdate.put(newInternacion.Id, newInternacion);
            }
            if(!internacionesToUpdate.isEmpty()){
                update internacionesToUpdate.values();
            }
            
        }else{
            
            for(Producto_de_Internacion__c pdInternacion : existingProductosDeInternacion){
                namesOfServiciosAlreadySelected.add(pdInternacion.Tipo_de_servicio__c);
                modulosSelected.add(pdInternacion.Modulo_del_producto__c);
            }
            
            
            List<Modulo_disponible__mdt> modulosMtd = [
                SELECT Nombre_del_Modulo__c, Numero_de_Jerarquia__c
                FROM Modulo_disponible__mdt 
                WHERE Numero_de_Jerarquia__c != null
                ORDER BY Numero_de_Jerarquia__c ASC
            ];
            
            for(Modulo_disponible__mdt meta : modulosMtd){
                metadataTotal.put(meta.Nombre_del_Modulo__c, meta.Numero_de_Jerarquia__c);
                
                if(modulosSelected.contains(meta.Nombre_del_Modulo__c)){
                    modulosMtdFilter.add(meta);
                    metadataNombreConJerarquia.put(meta.Nombre_del_Modulo__c,meta.Numero_de_Jerarquia__c);
                }
            }        
            
            List<Modulo__c> modulosRelated = [
                SELECT id,Name 
                FROM Modulo__c 
                LIMIT 50
            ];
            
            if(!modulosRelated.isEmpty()){
                for(Modulo__c mod : modulosRelated){
                    mapaModulos.put(mod.Name, mod);
                }
            }
            
            for (Producto_de_Internacion__c internacionProd : productosInternacionList) {
                double jerarquiaNuevoProd = metadataTotal.get(internacionProd.Modulo_del_producto__c); 
                double jerarquiaProdExistente= metadataNombreConJerarquia.values()[0]; 
                Modulo__c modulo = mapaModulos.get(internacionProd.Modulo_del_producto__c);
                Modulo__c oldModulo = mapaModulos.get(modulosMtdFilter[0].Nombre_del_Modulo__c);
                
                Internacion__c newInternacion = mapInternaciones.get(internacionProd.Internacion__c);     
                newInternacion.Tipo_de_Servicio__c = internacionProd.Tipo_de_Servicio__c;
                
                if(Trigger.isDelete && oldModulo!=null){
                    newInternacion.Modulo__c = oldModulo.Id;
                }else if(!Trigger.isDelete && jerarquiaNuevoProd <= jerarquiaProdExistente){   
                    newInternacion.Modulo__c =  modulo.Id;
                }
                internacionesToUpdate.put(newInternacion.id, newInternacion); 
                
                if (!InternacionesToUpdate.isEmpty()) {               
                    update InternacionesToUpdate.values();
                } 
            }    
        }
        
    }
}