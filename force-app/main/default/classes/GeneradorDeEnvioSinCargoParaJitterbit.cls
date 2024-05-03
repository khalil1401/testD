global class GeneradorDeEnvioSinCargoParaJitterbit {
    
    WebService static String generarNuevosEnviosParaJiter(id envio){
        String status;
        
        List<Producto_de_envio__c> listProdEnvio = [
            SELECT id,Envio_sin_cargo__c, Envio_sin_Cargo__r.name,Envio_sin_Cargo__r.Estado_del_envio__c,Envio_sin_Cargo__r.Xml_ya_generado__c
            FROM Producto_de_envio__c
            WHERE Envio_sin_cargo__c = :envio
        ];
        
        
        if(!listProdEnvio.isEmpty()){
            if(!listProdEnvio.get(0).Envio_sin_Cargo__r.Xml_ya_generado__c){
                Envio_sin_Cargo__c envioToUpdate = new Envio_sin_Cargo__c(
                    Id = listProdEnvio.get(0).Envio_sin_Cargo__c,
                    Estado_del_envio__c = listProdEnvio.get(0).Envio_sin_Cargo__r.Estado_del_envio__c
                );
                
                status = 'XML generado para envio: '+listProdEnvio.get(0).Envio_sin_Cargo__r.name;
                envioToUpdate.Estado_del_envio__c= 'Reservado';
                envioToUpdate.Xml_ya_generado__c = true;
                
                update envioToUpdate;
                
            }
            else{
                status = 'Ya se genero un XML para este Envío sin Cargo.';
            }
        }
        else{
            status = 'Error. No se pueden generar XML vacios';         
        }
        
        return status;
    }
    
}