public class BatchCrearCasoNoRenovacion implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator([SELECT	Id FROM	Account 
                                        WHERE RecordType.DeveloperName  = 'Paciente_Best_Care'
                                        AND	Subestado_del_paciente__c  = 'Modulo Inactivo'
                                        AND	Estado_de_paciente__c  = 'En Seguimiento'
                                        AND	Dias_en_este_estado__c  = 5
                                        AND	Area_terapeutica__c  IN ('Dieta Cetogénica', 'Metabólicos', 'NEG')
                                        AND	Servicio_Activo__c = 'AUTOCUIDADO.'
                                        //AND	Id NOT IN (SELECT AccountId FROM Case WHERE Subject = 'Nuevo seguimiento no renovación' )
                                        ]);
        
	}

    public void execute(Database.BatchableContext context, List<Account> accounts) {
        
        if(accounts.size() > 0){
            
            List<Case> listaCasosPreviosNoRenovacion = [SELECT AccountId FROM Case WHERE Subject = 'Nuevo seguimiento no renovación'];
            system.debug('Casos >>> ' + listaCasosPreviosNoRenovacion );
            List<Id> cuentasLimpias = new List<Id>();
            
            Map<String, String> accountsMap = new Map<String, String>();
			Map<String, String> casesMap = new Map<String, String>();
            
            for(Account cuenta : accounts){
                    accountsMap.put(cuenta.Id, '');
                }
            
            for(Case caso : listaCasosPreviosNoRenovacion){
                    casesMap.put(caso.AccountId, '');
                }
            
            for(Id accountId : accountsMap.keyset()){
                if( !casesMap.containsKey(accountId)){
                    cuentasLimpias.add(accountId);
                }
            }

            List<Case> newcases =   new List<Case>();
            BusinessHours bh =      [SELECT Id FROM BusinessHours WHERE Isactive = TRUE LIMIT 1];
            Group groupOfPeople =   [SELECT Id FROM Group WHERE Name = 'Fidelizacion' LIMIT 1];
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Retencion' LIMIT 1];
    
            for(Id accountId : cuentasLimpias){
                Case newcase = new Case(
                    AccountId = accountId,
                    BusinessHoursId = bh.id,
                    Description = 'Es necesario validar con el paciente: - Estado del tratamiento - Documentación disponible - Fecha de ultima presentación en Obra Social - Estado de cobertura / Problemas OOSS - Motivos del cambio de tratamiento - Modulo de paciente: Debe completar el ultimo MDP activo',
                    OwnerId = groupOfPeople.Id,
                    Priority = 'Media',
                    RecordTypeId = recordType.Id,
                    Status = 'Nuevo',
                    Subject = 'Nuevo seguimiento no renovación',
                    Subtipo__c = 'Seguimiento no renovación'
                );
                newcases.add(newcase);
            }
            
            INSERT newcases;
        }
	}

	public void finish(Database.BatchableContext context) {
        System.debug('Se ejecuto el batch  - BatchCrearCasoNoRenovacion');
    }
}