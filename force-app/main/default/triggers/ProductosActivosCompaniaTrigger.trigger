trigger ProductosActivosCompaniaTrigger on Productos_Activos_Compania__c (after insert, after update, after delete, after undelete){

	if (Trigger.isAfter) {

		LREngine.Context contexto = new LREngine.Context(
			Modulo_de_paciente__c.SObjectType,
			Productos_Activos_Compania__c.SObjectType,
			Schema.SObjectType.Productos_Activos_Compania__c.fields.Modulo_de_paciente__c,
			'(Estado__c = \'Por retirar\' OR Estado__c = \'Entregado\')'
		);

		contexto.add(new LREngine.RollupSummaryField(
			Schema.SObjectType.Modulo_de_paciente__c.fields.Cont_Productos_Activos_Compania__c,
			Schema.SObjectType.Productos_Activos_Compania__c.fields.Id,
			LREngine.RollupOperation.Count
		));

		List<Productos_Activos_Compania__c> productos = new List<Productos_Activos_Compania__c>();

		if (Trigger.isInsert || Trigger.isUndelete) {

			for (Productos_Activos_Compania__c productosAct : Trigger.new) {
				if (!String.isBlank(productosAct.Modulo_de_paciente__c)) {
					productos.add(productosAct);
				}
			}

		} else if (Trigger.isDelete) {

			for (Productos_Activos_Compania__c productosAct : Trigger.old) {
				if (!String.isBlank(productosAct.Modulo_de_paciente__c)) {
					productos.add(productosAct);
				}
			}

		} else if (Trigger.isUpdate) {

			for (Productos_Activos_Compania__c productosAct : Trigger.new) {
				
				Productos_Activos_Compania__c productosActOld = Trigger.oldMap.get(productosAct.Id);
					
				Boolean productoChanged = productosAct.Modulo_de_paciente__c != productosActOld.Modulo_de_paciente__c;
				Boolean productoEstadoChanged = productosAct.Estado__c != productosActOld.Estado__c;
				
				if (productoChanged) {
						
					if (!String.isBlank(productosActOld.Modulo_de_paciente__c)) {
						productos.add(productosActOld);
					}

					if (!String.isBlank(productosAct.Modulo_de_paciente__c)) {
						productos.add(productosAct);
					}
				}

				if (productoEstadoChanged) {
					if (!String.isBlank(productosAct.Modulo_de_paciente__c)) {
						productos.add(productosAct);
					}
				}
			}
		}

		if (!productos.isEmpty()) {

			Map<Id, Modulo_de_paciente__c> moduloPaciente = new Map<Id, Modulo_de_paciente__c>();
			for (Modulo_de_paciente__c modulo : (List<Modulo_de_paciente__c>) LREngine.rollUp(contexto, productos)) {
				moduloPaciente.put(modulo.Id, modulo);
			}
			update moduloPaciente.values();
		}
	}

}