public class MkCloudNutritionFormController {
    
    public String pcid {get; set;}
    public Account paciente {get; set;}
    public String pacienteName {get; set;}
    public boolean yaRegistrado {get; set;}
    public String consumeLoprofin{ get; set; }   
    public List<EYN_Formulario__mdt> valoresDeEYN {get; set;}
    public Formulario_MarketingCloud__c formMk { get; set; }
    public Map<String,String> nameAndLabels { get; set; }

    public MkCloudNutritionFormController(ApexPages.StandardController controller) {
        
        pcid = Apexpages.currentPage().getParameters().get('pcid');
        if (pcid != null && pcid != ''){
            nameAndLabels= new Map<String,String>();
            formMk= new Formulario_MarketingCloud__c();    
            getFieldLabels();
            paciente = getPaciente(pcid);
            
            if(paciente!=null){
                yaRegistrado=false;
                pacienteName= paciente.firstName!=null ? paciente.firstName +  ' ' + paciente.lastName :''  + paciente.lastName;
                
            }else{ 
                yaRegistrado =true;
            }
        }else{ 
            yaRegistrado =true;
        }
    }

    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Formulario_MarketingCloud__c.FieldSets.EYN.getFields();
    }

    public void getFieldLabels() {
        List<Schema.FieldSetMember> fields = SObjectType.Formulario_MarketingCloud__c.FieldSets.EYN.getFields();
        Map<String,String> apiNameAndLabel = new Map<String,String>();

        valoresDeEYN= [
            SELECT id,Api_name_del_campo__c,Pregunta_para_VF__c
            FROM EYN_Formulario__mdt
            WHERE Es_pregunta__c= true
        ];
        
        for(EYN_Formulario__mdt eyn : valoresDeEYN){
            apiNameAndLabel.put(eyn.Api_name_del_campo__c, eyn.Pregunta_para_VF__c);
        }

        for(Schema.FieldSetMember f : fields) {
            nameAndLabels.put(f.getFieldPath(),apiNameAndLabel.get(f.getFieldPath()));
        }
    }
    
    public Account getPaciente(String accountId){
        List<Formulario_MarketingCloud__c> oldFormMK = new List<Formulario_MarketingCloud__c>();
        oldFormMK = [
            SELECT id,Cuenta__c
            FROM Formulario_MarketingCloud__c
            WHERE Cuenta__c = :accountId
            AND Formulario_ya_contestado_vs__c =true
        ];
        
        if(oldFormMK.isEmpty()){
            List<Account> accounts =  [
                SELECT Id,LastName, firstName
                FROM Account
                WHERE id = :accountId
                LIMIT 1
            ];
            
            if(!accounts.isEmpty()){
                return accounts.get(0);
            }else{
                return null;
            }
        }
        else{
            return null;
        }
    }
    public void insertRecords(){
            if(!yaRegistrado ){
            formMk.Cuenta__c = pcid;
            formMk.Formulario_ya_contestado_vs__c=true;
            formMk.RecordTypeId = XappiaHelper.getRecordType('Formulario_MarketingCloud__c', 'EYN').Id;

            insert formMk;
            MkCloudNutritionFormController_Helper.generaKitsNUBAyAMN(pcid);
            yaRegistrado=true;
        }
    
}

}