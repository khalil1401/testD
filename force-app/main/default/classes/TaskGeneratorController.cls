public with sharing class TaskGeneratorController {
    
	public Account acct {get;set;}
	public Boolean rend {get;set;}
	public List<Account> accountList {get;set;}
	ApexPages.StandardSetController controller;
    
    
	public TaskGeneratorController(ApexPages.StandardSetController controller) {
		this.controller = controller;
		this.acct = (Account)controller.getRecord();
        getCuentas();
		
	}

	public List<Account> getSelected() {
		return controller.getSelected();
	}

    public List<Account> getCuentas() {
        List<Account> listaSelecionada = getSelected();  
        List<Account> listaSelecionadaFinal = getAccountsQuery(listaSelecionada);

        accountList = new List<Account>();
                for(Account cuenta: listaSelecionadaFinal) {
                    accountList.add(cuenta);
                }
                return accountList;
        }
        @AuraEnabled
        public static accWrapper getAccountWrapper(List<String> ids) {
            Set<String> accIds = new Set<String>();

            for(String i : ids){
                accIds.add(i);
            }
            Set<Id> selectedAccIdSet = new Set<Id>();
            accWrapper wrapper = new accWrapper();
            wrapper.accList =getAccountsQuery(accIds);

            for(Account acc:wrapper.accList){  
            selectedAccIdSet.add(acc.Id);  
          }  
            wrapper.selectedIdSet = selectedAccIdSet;

            return wrapper;
    }
    @AuraEnabled
	public static void queueTasks(List<Account> accounts,Date dueDate) {
        ID jobID = System.enqueueJob(new TaskGeneratorQueueable(accounts,dueDate));
	}
    @AuraEnabled(cacheable=true)
    public List<FieldsWrapper> getFieldsSet() {
        return getFields();
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldsWrapper> getFields() {
        List<Schema.FieldSetMember> lstFSMember = getFieldSetMember();
        List<FieldsWrapper> wrapperList = new List<FieldsWrapper>();

        for(Schema.FieldSetMember aMember : lstFSMember){
            FieldsWrapper wrapper = new FieldsWrapper();
            wrapper.fieldName = aMember.label;
            wrapper.fieldPath = aMember.fieldpath;
            wrapperList.add(wrapper);
        }
        
        return wrapperList;
    }
    public static List<Schema.FieldSetMember> getFieldSetMember() {
        SObject sObj = (SObject)(Type.forName('Schema.'+ 'Account').newInstance());
        return sObj.getSObjectType().getDescribe().fieldSets.getMap().get('Campos_para_generador_de_tareas').getFields();
    }

    public static List<Account> getAccountsQuery(List<Account> listaSelecionada) {
        SObject sObj = (SObject)(Type.forName('Schema.'+ 'Account').newInstance());
        List<Schema.FieldSetMember> lstFSMember= sObj.getSObjectType().getDescribe().fieldSets.getMap().get('Campos_para_generador_de_tareas').getFields();
        String query = 'SELECT ';

        for(Schema.FieldSetMember f : lstFSMember) {
	        query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM Account WHERE Id IN :listaSelecionada AND (Enfermero_Asignado__c !=null OR Medico_Asignado__c!=null OR Kinesiologo_asignado__c!=null OR Nutricionista_Asignado__c!=null)';
            return Database.query(query);
    }
    public static List<Account> getAccountsQuery(Set<String> Ids) {
        SObject sObj = (SObject)(Type.forName('Schema.'+ 'Account').newInstance());
        List<Schema.FieldSetMember> lstFSMember= sObj.getSObjectType().getDescribe().fieldSets.getMap().get('Campos_para_generador_de_tareas').getFields();
        String query = 'SELECT ';

        for(Schema.FieldSetMember f : lstFSMember) {
	        query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM Account WHERE Id IN :Ids AND (Enfermero_Asignado__c !=null OR Medico_Asignado__c!=null OR Kinesiologo_asignado__c!=null OR Nutricionista_Asignado__c!=null)';
            return Database.query(query);
    }
    public class accWrapper{  
        @AuraEnabled public List<Account> accList {get; set;}  
        @AuraEnabled public set<Id> selectedIdSet {get; set;}  
      }  

      public class FieldsWrapper{  
        @AuraEnabled public String fieldName {get; set;}  
        @AuraEnabled public String fieldPath {get; set;}  
      }  
}