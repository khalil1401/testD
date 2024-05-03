public class InternacionTriggerHelper {
    
    public static void closeProductsDate(Map<Id, Internacion__c> internaciones){
        List<Producto_de_Internacion__c> products = new List<Producto_de_Internacion__c>();
        List<Producto_de_Internacion__c> productsToUpdate = new List<Producto_de_Internacion__c>();
        products.addAll(
            [
                SELECT id,Fecha_Fin_Producto__c,Internacion__c
                FROM Producto_de_Internacion__c
                WHERE Internacion__c IN : internaciones.keySet()
                AND Fecha_Fin_Producto__c = null
            ]
        );
        for(Producto_de_Internacion__c aProd : products){
            aProd.Fecha_Fin_Producto__c = internaciones.get(aProd.Internacion__c).Fecha_de_Fin_Internaci_n__c;
            aProd.Bypass_apex__c =true;
            productsToUpdate.add(aProd);
        }
        if(!productsToUpdate.isEmpty()){
            update productsToUpdate;
        }
    }
    
    
    public static void validateActiveInternacion(List<Internacion__c> internaciones){
        Map<Id, Internacion__c> internacionesWithAccId = new  Map<Id, Internacion__c>();
        Map<Id, Internacion__c> internacionesActives = new Map<Id, Internacion__c>();
        List<Internacion__c> internacionesDB = new List<Internacion__c>();
        
        for(Internacion__c aInternacion : internaciones){
            internacionesWithAccId.put(aInternacion.Paciente__c , aInternacion);
        }
        
        internacionesDB.addAll([
            SELECT id ,Name,Paciente__c
            FROM Internacion__c
            WHERE Paciente__c IN : internacionesWithAccId.keySet()
            AND Fecha_de_Fin_Internaci_n__c= null 
        ]);
        
        for(Internacion__c aInternacion : internacionesDB){
            internacionesActives.put(aInternacion.Paciente__c , aInternacion);
        }
        
        for(Internacion__c aInt : internaciones){
            if(internacionesActives.containsKey(aInt.Paciente__c)){
                String internacionLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+internacionesActives.get(aInt.Paciente__c).Id;
                String hiperlink= '<a href='+internacionLink+'>'+internacionesActives.get(aInt.Paciente__c).Name +'</a>';
                aInt.addError('El Paciente tiene una internación activa: ' + hiperlink,false);
            }
        }
    }
    public static void updateAccountStatus(List<Internacion__c> internaciones){
        Map<Id, Internacion__c> internacionesWithAccountId = new Map<Id, Internacion__c>();
        List<Account> accounts = new List<Account>();
        
        for(Internacion__c aInt: internaciones){
            internacionesWithAccountId.put(aInt.Paciente__c, aInt);
        }
        
        List<Account> accountsToUpdateStatus = [
            SELECT id,Estado_de_paciente__c,Subestado_del_paciente__c,Fecha_de_obito__c
            FROM Account
            WHERE id IN :internacionesWithAccountId.keySet()
        ];
        
        for(Account anAccount : accountsToUpdateStatus){
            Internacion__c internacion = internacionesWithAccountId.get(anAccount.Id);
            anAccount.Subestado_del_paciente__c = internacion.Estado_de_Fin_Internaci_n__c;
            
            if(internacion.Fecha_de_Fin_Internaci_n__c==null){
                anAccount.Estado_de_paciente__c = 'En tratamiento';
                anAccount.Fecha_de_obito__c = null;
                if(internacion.Paciente_Aguarda_Internaci_n_domiciliari__c){
                    anAccount.Subestado_del_paciente__c = 'Aguarda Internación domiciliaria';
                }
            }else{
                anAccount.Estado_de_paciente__c = 'No tratamiento';
            }
            accounts.add(anAccount);
        }
        if(!accounts.isEmpty()){
            update accounts;
        }
    }

}