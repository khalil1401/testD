public without sharing class FormularioController {
    
    public string recordTypeSelected {get;set;}
    Map<String, String> mapRecordTypes = new Map<String, String>();
    public String taskId {get;set;}

    public List<SelectOption> getFormList(){
        List<SelectOption> options = new List<SelectOption>();
        
        for(RecordType rt : [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Formulario_MarketingCloud__c'
            AND IsActive = true
        ]){
            options.add(new SelectOption(rt.Id, rt.Name));
            mapRecordTypes.put(rt.Id, rt.Name);
        }
        return options;
    }
    
    public PageReference doSubmit(){
        taskId = ApexPages.currentPage().getParameters().get('taskId');

        List<Task> infoTask = [
            SELECT Id, WhatId 
            FROM Task 
            WHERE Id=:taskId
            LIMIT 1
        ];
        
        if(infoTask[0].WhatId == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,
                                label.FaltaCampoNombreEnTarea));
            return null;
        }

        
        Formulario_MarketingCloud__c newForm = new Formulario_MarketingCloud__c(
            recordTypeId=recordTypeSelected
        );
        
        if (String.valueOf(infoTask[0].WhatId.getSObjectType()) == 'Account') newForm.Cuenta__c = infoTask[0].WhatId;
        
        Insert newForm;
        infoTask[0].WhatId = newForm.Id;
        update infoTask;
        
        PageReference acctPage = new ApexPages.StandardController(newForm).view();
        acctPage.setRedirect(true);
        return acctPage;
    }
}