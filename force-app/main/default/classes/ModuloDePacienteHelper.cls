public with sharing class ModuloDePacienteHelper {
    
    public static void statusAndTypeUpdate (Set<Id> accountsIds) {	
        
        List<Account> accounts = [
            SELECT Id,estado_de_paciente__c, Ultimo_Modulo__c,(SELECT Id, Tipo__c FROM Modulos_de_paciente__r WHERE Estado__c = 'Activo')
            FROM Account
            WHERE RecordType.name ='Paciente Best Care'
            AND ID IN :accountsIds
        ];
        
        for (Account acc : accounts) {
            boolean isLogistic = true;
            for (Modulo_de_paciente__c mod : acc.Modulos_de_paciente__r) {
                if (mod.Tipo__c == 'CUIDADO COMPLETO')  isLogistic = false;
            }
            
            if (acc.Modulos_de_paciente__r.size() == 0) {
                if (acc.estado_de_paciente__c == 'En tratamiento') {
                    acc.Estado_de_paciente__c = 'En Seguimiento';
                    acc.Subestado_del_paciente__c = 'Modulo Inactivo';
                }
            } else {
                acc.Ultimo_Modulo__c = isLogistic ? 'Logistico' : 'Full';
                acc.Estado_de_paciente__c = 'En tratamiento';
                acc.Subestado_del_paciente__c = 'Tratamiento Efectivo';
                
            }
        }
        update accounts;
    }
    
    public static void completaCamposDeCuentaConUltimoMDP(List<Modulo_de_paciente__c> modulosDePaciente){
        Set<Id> idDeCuentas = new Set<Id>();
        Map<Id, Account> mapaIdConCuentas = new Map<Id, Account>();
       // List<Account> cuentasparaActualizar = new List<Account>();
        Map<id, Account> cuentasparaActualizar = new Map<id,Account>();
        for(Modulo_de_paciente__c unMdp: modulosDePaciente){
            idDeCuentas.add(unMdp.Cuenta__c);
        }
        
        List<Account> cuentasRelacionadas = [
            SELECT Id
            FROM Account
            WHERE id IN : idDeCuentas
            AND RecordType.DeveloperName= 'Paciente_Best_Care'
            ORDER BY createddate DESC
        ];
        
        if(!cuentasRelacionadas.isEmpty()){
            for(Account unaCuenta: cuentasRelacionadas){
                mapaIdConCuentas.put(unaCuenta.id, unaCuenta);
            }
            
            for(Modulo_de_paciente__c unModulo : modulosDePaciente ){
                Account cuentaRelacionada = mapaIdConCuentas.get(unModulo.Cuenta__c);
                if(cuentaRelacionada!=null){
                    cuentaRelacionada.Modulo_activo__c = unModulo.id;
                    cuentaRelacionada.Estado_del_ultimo_modulo__c= unModulo.Estado_de_modulo__c;
                    cuentaRelacionada.Modulo_hasta__c = unModulo.Modulo_hasta_autocalculable__c;
                    cuentaRelacionada.Tipo_de_servicio__c = unModulo.Tipo__c;
                    
                    if(unModulo.Modulo__c!=null){ 
                        cuentaRelacionada.Modulo__c = unModulo.Modulo__c;
                    }
                    cuentasparaActualizar.put(cuentaRelacionada.id, cuentaRelacionada);
                }
            }
            if(!cuentasparaActualizar.isEmpty()){
                update cuentasparaActualizar.values(); 
            }
        }
    }
}