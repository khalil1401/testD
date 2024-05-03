global class BatchTareaRecurrente implements Database.Batchable<sObject> {
    
    global List<String> errores = new List<String>(); 

    global BatchTareaRecurrente() {
        errores.add('Errores detectados: \n');
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, Ultimo_llamado_de_seguimiento__c, CreatedDate ' + 
            'FROM Account ' +
            'WHERE RecordType.DeveloperName = \'Paciente_Best_Care\'';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> cuentaLista) {
	
        List<Task> Tareas = new List<Task>();		        
        
        
        String recordTypeId = [
            SELECT Id 
            FROM RecordType
            WHERE sobjectType = 'Task' 
            	AND DeveloperName = 'Llamado_de_seguimiento'
        ].Id;

        
        if (String.isBlank(recordTypeId)) {
        	errores.add('Error: No hay tipo de registro llamado de seguimiento');
            return;
        }

		Date fechaActual = Date.today();
		
		List<Task> listaTareas = new List<Task>();
        
		for (Account cuentas : cuentaLista) {
            Date cumple3Meses;
			Boolean insertarTarea = false;
            if (cuentas.Ultimo_llamado_de_seguimiento__c != null) {
				if (cuentas.Ultimo_llamado_de_seguimiento__c.addMonths(3).addDays(-1) == fechaActual) {
					insertarTarea = true;
					cumple3Meses = cuentas.Ultimo_llamado_de_seguimiento__c.addMonths(3);
				}
			} else {
				Date createdDateCuenta = cuentas.CreatedDate.dateGmt();
				if (createdDateCuenta.addMonths(3).addDays(-1) == fechaActual) {
					insertarTarea = true;     
					cumple3Meses = createdDateCuenta.addMonths(3);
				}
			}
			if (insertarTarea) {
				listaTareas.add(new Task(
					subject = 'Llamado de seguimiento',
					Priority = 'Normal',
					Status = 'Abierta',
					WhatId = cuentas.Id,
					RecordTypeId = recordTypeId,
					ActivityDate = cumple3Meses
				));
			}
        }        	
            
        if (!listaTareas.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(listaTareas, false);

            for (Database.SaveResult saveResult : srList) {
    		
           		if (saveResult.isSuccess()){
                	System.debug('inserción de tareas con éxito. ID: ' + saveResult.getId());
            	} else {
        			for (Database.Error error : saveResult.getErrors()) {
                    	System.debug('se ha producido un error: ' + error.getMessage());                    
        				errores.add('Error: ' + error.getMessage());
                	}
   		 		}
			}
        } else {
        	errores.add('Error: No hay tareas por crear');
            return;
        }
    }   
    
    global void finish(Database.BatchableContext BC) { 
		if (errores.size() > 1) {
			System.debug('Se ha ejecutado el batch de Tareas.\n Al ejecutar el batch se detectaron los siguientes errores:\n' +
				String.join(errores, '\n'));
		}
    } 
}