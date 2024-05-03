@RestResource(urlMapping='/ValidatePatient/*')
global with sharing class KetoWS {
    
    @HttpGet
    global static Result doGet() {
        RestRequest req = RestContext.request;
        Result result;
        
        try{
            String param = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            
            List<Account> account = [
                SELECT ID
                FROM Account
                WHERE DNI__c = :param
            ];
            
            List<Contact> contact = [
                SELECT ID
                FROM Contact
                WHERE DNI__c = :param
            ];
            
            if(!account.isEmpty()){
                result = new Result(
                    true,
                    JSON.serialize(account[0])
                );
            }else if(!contact.isEmpty()){
                result = new Result(
                    true,
                    JSON.serialize(contact[0])
                );
            }else{
                result = new Result(
                    false,
                    ''
                );
            }
            
        }catch(Exception e){
            result = new Result(
                false,
                ''
            );
        }
        
        return result;
    }
    
    global class Result{
        
        global Result(boolean hasFound, String record){
            this.hasFound = hasFound;
            this.record = record;
        }
        
        global boolean hasFound {get;set;}
        global String record {get;set;}
    }
    
}