public without sharing class TaskGeneratorQueueable implements Queueable {
    public List<Account> accounts ; 
    public Date dueDate;
    
    public TaskGeneratorQueueable(List<Account> accounts,Date dueDate){
        this.accounts = accounts ;  
        this.dueDate= dueDate;
    }
    
    public void execute(QueueableContext context) { 
        Set<Id> accountsIds = new Set<Id>();
        List<Account> accountsDB = new List<Account>();
        
        for(Account anAccount : this.accounts){
            accountsIds.add(anAccount.Id);
        }
        
        accountsDB = [
            SELECT id ,Enfermero_Asignado__c,LastName,
            Nutricionista_Asignado__c,Kinesiologo_asignado__c,Medico_Asignado__c
            FROM Account
            WHERE Id IN : accountsIds
        ];
        
        if(!accountsDB.isEmpty()){
            createTasks(accountsDB);
        }
    }
    
    public void createTasks(List<Account> accountsDB){
        List<Task> newTasks = new List<Task>();
        List<Tareas_de_profesionales__c> profesionales = Tareas_de_profesionales__c.getall().values();
        Map<String, Tareas_de_profesionales__c> nombreConProfesionales = new Map<String, Tareas_de_profesionales__c>();
        Map<Id, Account> IdsWithAccounts = new Map<Id, Account>();
        
        for(Tareas_de_profesionales__c aProf : profesionales){
            nombreConProfesionales.put(aProf.Titulo_del_profesional__c, aprof);
        }
        
        for(Account anAccount : accountsDB){
            
            if(anAccount.Enfermero_Asignado__c!=null){
                Tareas_de_profesionales__c prof = nombreConProfesionales.get('Enfermero');
                for(Integer i = 0;i<prof.Tareas_del_profesional__c ;i++){
                    newTasks.add(newTask(anAccount.Id, anAccount.Enfermero_Asignado__c, prof.Asunto_de_la_visita__c));
                }
            }
            if(anAccount.Nutricionista_Asignado__c!=null){
                Tareas_de_profesionales__c prof = nombreConProfesionales.get('Nutricionista');
                for(Integer i = 0;i<prof.Tareas_del_profesional__c ;i++){
                    newTasks.add(newTask(anAccount.Id, anAccount.Nutricionista_Asignado__c, prof.Asunto_de_la_visita__c));
                }
            }
            if(anAccount.Kinesiologo_asignado__c!=null){
                Tareas_de_profesionales__c prof = nombreConProfesionales.get('Kinesiologo');
                for(Integer i = 0;i<prof.Tareas_del_profesional__c;i++){
                    newTasks.add(newTask(anAccount.Id, anAccount.Kinesiologo_asignado__c,prof.Asunto_de_la_visita__c));
                }
            }
            if(anAccount.Medico_Asignado__c!=null){
                Tareas_de_profesionales__c prof = nombreConProfesionales.get('Medico');
                for(Integer i = 0;i<prof.Tareas_del_profesional__c;i++){
                    newTasks.add(newTask(anAccount.Id, anAccount.Medico_Asignado__c, prof.Asunto_de_la_visita__c));
                }
            }
            IdsWithAccounts.put(anAccount.Id,anAccount);
        }
        if(!newTasks.isEmpty()){
            
            Database.SaveResult[] srList = Database.insert(newTasks,false);
            String resultsSuccess= 'Tareas exitosas:';
            String resultsFail= '\n\nTareas que fallaron:\n';
            Set<Id> taskIds = new set<Id>();
            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){
                    String accountName =IdsWithAccounts.containsKey(newTasks[i].whatId) ? IdsWithAccounts.get(newTasks[i].whatId).LastName: '';
                    for(Database.Error err : srList[i].getErrors()) {     
                        resultsFail+='.' + accountName + ': ' + newTasks[i].Subject + ' | Error: '+err.getMessage() +'\n';
                    }
                }
                else{
                    taskIds.add(srList[i].getId());
                }
            }
            
            if(!taskIds.isEmpty()){
                List<Task> taskDb = [
                    SELECT Account.LastName, subject,owner.Name
                    FROM Task
                    WHERE Id IN : taskIds
                ];
                resultsSuccess+= ' ('+ taskDb.size()+')\n';
                
                for(Task aTask: taskDb){
                    resultsSuccess+= '\n. '+ aTask.Account.LastName + ' - '+ aTask.Subject +' - '+ aTask.Owner.Name;
                }
            }
            
            sendResults(resultsSuccess ,resultsFail);
        }
    }
    public void sendResults(String success, String errors){
        String userEmail= [
            SELECT Email 
            FROM User 
            WHERE Username = : UserInfo.getUserName() 
            LIMIT 1
        ]?.Email;

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { userEmail };
            message.subject = 'Resultado de creación de tareas: ';
        message.plainTextBody = success + errors;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    
    public Task newTask(Id accId, Id ownerId, String subject){
        Task aTask = new Task();
        aTask.WhatId = accId;
        aTask.Priority ='Media';
        aTask.OwnerId = ownerId;
        aTask.ActivityDate = this.dueDate;
        aTask.Subject = subject;
        
        return aTask;
    }
}