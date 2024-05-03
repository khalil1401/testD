public class GenerateXmlModuloController {
    
    public String moduloId { get; set; }
    public Modulo_de_paciente__c mdp{ get; set; }
    List<Producto_de_modulo__c> pdmList = new List<Producto_de_modulo__c>();
    public String button;
    public string actualPage;  
    public ApexPages.StandardController sctrl;
    public List<Productos_Activos_Compania__c> prodAcCom = new List<Productos_Activos_Compania__c>(); 
    public boolean flagXMl{get; set;}
    public boolean mdpSinProductos{get; set;}  
    public boolean mdpSinModulo{get; set;}  
    public boolean mdpSinSoldTo{get; set;}  
    public boolean mdpSinShipTo{get; set;}  
    public boolean mdpSinNroDeAutoriz{get; set;}  
    public boolean mdpValorTotalMax{get; set;}  
    public boolean mdpFechaIncorrecta{get; set;} 
    public boolean yaGenerado{get; set;} 
    
    public GenerateXmlModuloController(ApexPages.StandardController controller) {
        this.sctrl = controller;        
        moduloId  = ApexPages.CurrentPage().getparameters().get('id');
        flagXMl= false;
        mdpSinProductos = false;
        mdpSinModulo = false;
        mdpSinSoldTo = false;
        mdpSinShipTo = false;
        mdpSinNroDeAutoriz = false;
        mdpValorTotalMax = false;
        mdpFechaIncorrecta = false;
        yaGenerado= false;
    }
    
    public PageReference back()
    {
        PageReference cancel = sctrl.cancel();
        return cancel;
    }    
    
    public void insertXml(){
        
        // Verificamos que no existan  ModulosJitterbit para ese MDP 
        List<Modulo_jitterbit__c> lista_mj_previa = [SELECT Id 
        FROM Modulo_jitterbit__c 
        WHERE Modulo_de_paciente__c = :moduloId];
        if(lista_mj_previa.size() == 0){  
        
        /****Insertar Modulo de Jiterbit***/
        
        List<Modulo_Jitterbit__c> modJitList= new List<Modulo_Jitterbit__c>();
        List<Modulo_Jitterbit__c> prodJitList= new List<Modulo_Jitterbit__c>(); 

        mdp= [
            select name,N_SOLD_TO__c,N_SHIP_TO__c,Fecha_de_despacho__c,Nro_de_autorizacion__c,N_de_Material__c,Duracion_modulo__c,Modulo__c,Valor_total_pesos__c,modulo__r.N_de_Material__c     
            from Modulo_de_paciente__c
            where id =: moduloId
        ];
        
        pdmList = [
            SELECT id,Modulo_de_paciente__c,Categoria_de_producto__c,Id_de_SAP__c,Formula__r.name,Cantidad__c  
            FROM Producto_de_modulo__c 
            WHERE Modulo_de_paciente__c = :moduloId
        ];
        
        List<Modulo_Jitterbit__c> prodJitListDb = [
            Select id,Modulo_de_paciente__c 
            from Modulo_Jitterbit__c 
            where Modulo_de_paciente__c = :moduloId 
        ];
        if(prodJitListDb.size()>0){
            yaGenerado = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Ya se genero el XML para este modulo'));
        }
        else{
            
            if(pdmList.size()== 0){
                mdpSinProductos =true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Es necesario al menos agregar 1 producto'));
            }
            if(mdp.N_de_Material__c==null || mdp.N_de_Material__c=='0'){
                mdpSinModulo = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Es necesario agregar un material de servicio a este Modulo'));
            }
            if(mdp.N_SOLD_TO__c==null){
                mdpSinSoldTo = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Este modulo no tiene asociado SOLD-TO'));
            }
            if(mdp.N_SHIP_TO__c==null){
                mdpSinShipTo = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Este modulo no tiene asociado SHIP-TO'));
            }
            if(mdp.Nro_de_autorizacion__c==null){
                mdpSinNroDeAutoriz = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Por favor ingresar el numero de autorización'));
            }
            if(mdp.Valor_total_pesos__c > 3000000){
                mdpValorTotalMax = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'El modulo supera el limite permitido'));
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
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'XML generado y ' +mdp.Name +' se paso a reservado.'));
                   
                   if(mdp.Modulo__c!=null){
                       Modulo_Jitterbit__c newModulo = new Modulo_Jitterbit__c();
                       newModulo.Modulo_de_paciente__c = moduloId;
                       newModulo.Name = 'MDP - Objeto modulo';
                       newModulo.Material__c = string.valueOf(mdp.modulo__r.N_de_Material__c);
                       newModulo.Quantity__c = mdp.Duracion_modulo__c;
                       newModulo.PriceCondition__c = 'ZSER';
                       newModulo.Value__c = mdp.Valor_total_pesos__c;
                       newModulo.ConditionPricingUnit__c = mdp.Duracion_modulo__c;
                       
                       insert newModulo;
                   }
                   
                   if(pdmList.size()> 0){
                       for(Producto_de_modulo__c pdm: pdmList){
                           Modulo_Jitterbit__c newModulo1 = new Modulo_Jitterbit__c();
                           newModulo1.Modulo_de_paciente__c = moduloId;
                           newModulo1.Name = 'MDP - Producto'+pdm.Formula__r.name;
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
        }
    }
}