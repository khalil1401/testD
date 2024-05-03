public with sharing class CustomRelatedListAccountController{
  
    public String accId {get;set;}
    public Integer recordsPerPage {get;set;}
    public Paginator navigation {get; set;}
    public List<Task> tskListToDisplay {get;set;}

    
    public CustomRelatedListAccountController(ApexPages.StandardController controller){
        accId = controller.getId();
        recordsPerPage = 3;
        paginationBuilder();
        updatePage();
    }
    
    public void updatePage(){
        tskListToDisplay = navigation.getSObjects();
        
        if (navigation.pageNumber == 1) {
        	List<Task> tsk = [SELECT Id, Subject, Owner.Name, Status, ActivityDate, WhatId, What.Name
                              FROM Task
                              WHERE WhatId = :accId AND Carga_de_pedido_en_Oracle__c = true
                              LIMIT 1];
            if(tsk.size() > 0)
                tskListToDisplay.add(tsk[0]);
        }
    }

    public void paginationBuilder(){
        
        String fieldsQ = 'SELECT Id, Subject, Owner.Name, Status, ActivityDate, WhatId, What.Name ';
        
        String fromQ = 'FROM Task';
        
        String whereQ = 'WHERE WhatId IN (SELECT Id' + 
                                          ' FROM Modulo_de_paciente__c' +
                                          ' WHERE Estado__c = \'' + 'Activo' + '\'' +
                                          ' AND Cuenta__c = \'' + accId + '\')' + 						  
                                          ' AND Carga_de_pedido_en_Oracle__c = true';
          
        String countQuery = String.join(new String[] { 'SELECT Count()', fromQ, whereQ }, ' ');
        
        String query = String.join(new String[] { fieldsQ, fromQ, whereQ }, ' ');
        
        navigation = new Paginator(query, countQuery, recordsPerPage);
    }
    
    public void next(){
        navigation.next();
        updatePage();
    }   
    
    public void previous(){ 
        navigation.previous(); 
        updatePage();
    }
    
    public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('3', '3'));
		options.add(new SelectOption('10', '10'));
		return options;
	}
    
    public void updatePageSize(){
        navigation.setPageSize(recordsPerPage);
        updatePage();
    }
}