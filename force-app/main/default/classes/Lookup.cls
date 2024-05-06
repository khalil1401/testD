public without sharing class Lookup {

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter, List<Id> accountTeam) {
        String myQuery = null;
        if(filter != null && filter != ''){
            System.debug('Accteams: '+ accountTeam);              
            if (accountTeam.size() > 0) {  
                System.debug('Accteams: '+ accountTeam);              
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' AND Id in :accountTeam ORDER BY Name ASC LIMIT  5';
                System.debug('Query: '+ myQuery);              
                
            }else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' ORDER BY Id DESC LIMIT  5';     
            }
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        System.debug(myQuery);
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
}