public with sharing class GenerarXML_FlowHelper {

    @InvocableMethod(label = 'GenerarXML_FlowHelper' description='Apex class que genera Modulos Jitterbit a partir del modulo de paciente')
    public static List<String> GenerarXML_FlowHelper(List<ID> id_MDP) {

        List<Modulo_Jitterbit__c> modJitList= new List<Modulo_Jitterbit__c>();
        List<Modulo_Jitterbit__c> prodJitList= new List<Modulo_Jitterbit__c>(); 
        
        Modulo_de_paciente__c mdp = new Modulo_de_paciente__c();
        List<Producto_de_modulo__c> pdmList = new List<Producto_de_modulo__c>();
        List<String> resultado = new List<string>();
        String resultado_flow = '';

        Boolean flagXMl = false;
        Boolean mdpSinProductos = false;
        Boolean mdpSinModulo = false;
        Boolean mdpSinSoldTo = false;
        Boolean mdpSinShipTo = false;
        Boolean mdpSinNroDeAutoriz  = false;
        Boolean mdpValorTotalMax    = false;
        Boolean mdpFechaIncorrecta  = false;
        Boolean yaGenerado  = false;

        

        mdp= [
            select name,N_SOLD_TO__c,N_SHIP_TO__c,Fecha_de_despacho__c,Nro_de_autorizacion__c,N_de_Material__c,Duracion_modulo__c,Modulo__c,Valor_total_pesos__c,modulo__r.N_de_Material__c     
            from Modulo_de_paciente__c
            where id =: id_MDP
        ];
        
        pdmList = [
            SELECT id,Modulo_de_paciente__c,Categoria_de_producto__c,Id_de_SAP__c,Formula__r.name,Cantidad__c  
            FROM Producto_de_modulo__c 
            WHERE Modulo_de_paciente__c = :id_MDP
        ];

        List<Modulo_Jitterbit__c> prodJitListDb = [
            Select id,Modulo_de_paciente__c 
            from Modulo_Jitterbit__c 
            where Modulo_de_paciente__c = :id_MDP
        ];

        if(prodJitListDb.size() <> 0){
            // yaGenerado = true;
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Ya se genero el XML para este modulo'));
            resultado_flow = resultado_flow +'Ya se genero el XML para este modulo';
        }else{
            
            if(pdmList.size()== 0){
                mdpSinProductos =true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Es necesario al menos agregar 1 producto'));
                resultado_flow = resultado_flow +'\n Es necesario al menos agregar 1 producto';
            }
            if(mdp.N_de_Material__c==null || mdp.N_de_Material__c=='0'){
                mdpSinModulo = true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Es necesario agregar un material de servicio a este Modulo'));
                resultado_flow = resultado_flow +'\n Es necesario agregar un material de servicio a este Modulo';
            }
            if(mdp.N_SOLD_TO__c==null){
                mdpSinSoldTo = true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Este modulo no tiene asociado SOLD-TO'));
                resultado_flow = resultado_flow +'\n Este modulo no tiene asociado SOLD-TO';
            }
            if(mdp.N_SHIP_TO__c==null){
                mdpSinShipTo = true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Este modulo no tiene asociado SHIP-TO'));
                resultado_flow = resultado_flow +'\n Este modulo no tiene asociado SHIP-TO';
            }
            if(mdp.Nro_de_autorizacion__c==null){
                mdpSinNroDeAutoriz = true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Por favor ingresar el numero de autorización'));
                resultado_flow = resultado_flow +'\n Por favor ingresar el numero de autorización';
            }
            if(mdp.Valor_total_pesos__c > 3000000){
                mdpValorTotalMax = true;
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El modulo supera el limite permitido'));
                // resultado.add('El modulo supera el limite permitido');
                resultado_flow = resultado_flow + '\n El modulo supera el limite permitido';
            }
            
            if(prodJitListDb.size()==0 && !mdpSinProductos &&
               !mdpSinModulo && !mdpSinSoldTo &&
               !mdpSinShipTo && !mdpSinNroDeAutoriz &&
               !mdpValorTotalMax){
                   
                   if(mdp.Fecha_de_despacho__c < System.today()){
                       mdp.Fecha_de_despacho__c = System.today();
                   }
                   
                   mdp.Estado_de_modulo__c = 'Reservado';
                   update mdp;
                   
                   flagXMl= true;
                //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'XML generado y ' +mdp.Name +' se paso a reservado.'));
                // resultado.add('XML generado y '+ mdp.Name +' se paso a reservado.');
                resultado_flow = resultado_flow + 'XML generado y '+ mdp.Name +' se paso a reservado.';
                   
                   if(mdp.Modulo__c!=null){
                       Modulo_Jitterbit__c newModulo = new Modulo_Jitterbit__c();
                       newModulo.Modulo_de_paciente__c = id_MDP[0];
                       newModulo.Name = 'MDP - Objeto modulo';
                       newModulo.Material__c = string.valueOf(mdp.modulo__r.N_de_Material__c);
                       newModulo.Quantity__c = mdp.Duracion_modulo__c;
                       newModulo.PriceCondition__c = 'ZSER';
                       newModulo.Value__c = mdp.Valor_total_pesos__c;
                       newModulo.ConditionPricingUnit__c = mdp.Duracion_modulo__c;
                       System.debug('newModulo creado > '+ JSON.serialize(newModulo));      
                       insert newModulo;
                   }
                   
                   if(pdmList.size()> 0){
                       for(Producto_de_modulo__c pdm: pdmList){
                           Modulo_Jitterbit__c newModulo1 = new Modulo_Jitterbit__c();
                           newModulo1.Modulo_de_paciente__c = id_MDP[0];
                           newModulo1.Name = 'MDP - Producto' + pdm.Formula__r.name;
                           newModulo1.Material__c = pdm.Id_de_SAP__c;
                           newModulo1.Quantity__c = decimal.valueOf(pdm.Cantidad__c);
                           
                           modJitList.add(newModulo1);
                       }
                   } 
                   
                   if(modJitList.size()> 0){
                        insert modJitList; 
                   }
               }
            
        }
        System.debug('modJitList creados > '+ modJitList.size());
        resultado.add(resultado_flow);

        return resultado;

    }
}