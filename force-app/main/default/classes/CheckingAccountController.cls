public with sharing class CheckingAccountController {
	@AuraEnabled
	public static ServerResponse getCheckingAccountDocuments(Map<String, String> criteria) {
		ServerResponse response;
		TreeGrid grid = new TreeGrid();
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');
		GridColumn.TypeAttributes typeAttributes = new GridColumn.TypeAttributes();
		GridColumn.Label label = new GridColumn.Label();
		// GridColumn.TypeAttributes typeAttributes2 = new GridColumn.TypeAttributes();
		// GridColumn.Label label2 = new GridColumn.Label();

		label.fieldName = 'ProofNumber';
		typeAttributes.label = label;
		typeAttributes.target = '_parent';
		typeAttributes.tooltip = new GridColumn.Tooltip();
		typeAttributes.tooltip.fieldName = 'ProofNumber';
		grid.GridColumns = new List<GridColumn>();
		grid.GridColumns.add(helper.getCustomColumn('ProofNumberLink', 'url', 'Número de documento', true,  typeAttributes));
		grid.GridColumns.add(helper.getColumn('Dan360_TipoDeDocumento__c', true));
		grid.GridColumns.add(helper.getColumn('Dan360_CodigoCliente__c', true));

		typeAttributes = new GridColumn.TypeAttributes();
		label = new GridColumn.Label();
		label.fieldName = 'SubsidiaryName';
		typeAttributes.label = label;
		typeAttributes.target = '_parent';
		typeAttributes.tooltip = new GridColumn.Tooltip();
		typeAttributes.tooltip.fieldName = 'SubsidiaryName';
		grid.GridColumns.add(helper.getCustomColumn('SubsidiaryName', 'text', 'Sucursal', true,  typeAttributes));

		typeAttributes = new GridColumn.TypeAttributes();
		label = new GridColumn.Label();
		label.fieldName = 'SubsidiaryBillingStreet';
		typeAttributes.label = label;
		typeAttributes.target = '_parent';
		typeAttributes.tooltip = new GridColumn.Tooltip();
		typeAttributes.tooltip.fieldName = 'SubsidiaryBillingStreet';
		grid.GridColumns.add(helper.getCustomColumn('SubsidiaryBillingStreet', 'text', 'Dirección', true,  typeAttributes));
		grid.GridColumns.add(helper.getColumn('Dan360_FechaDocumento__c', true));
		grid.GridColumns.add(helper.getColumn('Dan360_Vencimiento__c', true));
		grid.GridColumns.add(helper.getColumn('Dan360_Remito__c', true));
		grid.GridColumns.add(helper.getColumn('Dan360_DiasDeVencido__c', true));
		grid.GridColumns.add(helper.getColumn('Dan360_ImporteDocumento__c', 'currency', true));
		grid.GridColumns.add(helper.getColumn('Dan360_Saldo__c', 'currency', true));
		grid.GridColumns.add(helper.getColumn('Dan360_Acumulado__c', 'currency', true));
		grid.GridColumns.add(helper.getColumn('Dan360_Semaforo__c', true));
		// grid.GridColumns.add(helper.getCustomColumn('PDFLink', 'html', '', true,  typeAttributes2));

		grid.GridData = CheckingAccountHelper.getDocumentsData(criteria);
		response = new ServerResponse('SUCCESS', grid, '');

		if (
			grid.GridData == null ||
			((Map<String, Map<String, Object>>)grid.GridData).isEmpty() ||
			((Map<String, Map<String, Object>>)grid.GridData).size() == 0
		) {
			response.message = 'No se encontraron resultados con los datos ingresados, intente con otros criterios.';
		}

		return response;
	}

	@AuraEnabled
	public static ServerResponse getUserInfo(Id userId){
		ServerResponse response = new ServerResponse();

		response.state = 'SUCCESS';
		response.data = [SELECT AccountId FROM User WHERE Id = :userId];

		return response;
	}

	@AuraEnabled
	public static String getFieldSet(String fieldSetName) {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');
		List<Danone360Helper.FieldWrapper> fieldset = (List<Danone360Helper.FieldWrapper>)JSON.deserialize(
			JSON.serialize(helper.getFieldSetMembers(fieldSetName)),
			List<Danone360Helper.FieldWrapper>.class
		);

		for (Danone360Helper.FieldWrapper field : fieldset) {
			if (field.type == 'picklist') {
				if (field.fieldPath.indexOf('__r') > -1) {
					List<String> arr = field.fieldPath.split('\\.');
					field.sobjectName = helper.getFieldReference(arr[0].replace('__r', '__c'));
					field.picklistApiName = arr[1];
				} else {
					field.sobjectName = 'Dan360_DocumentosCuentaCorriente__c';
					field.picklistApiName = field.fieldPath;
				}
			} else if (field.type == 'reference') {
				if (field.fieldPath.indexOf('__r') > -1) {
					List<String> arr = field.fieldPath.split('\\.');
					field.sobjectName = helper.getFieldReference(arr[0].replace('__r', '__c'));
				} else {
					field.sobjectName = helper.getFieldReference(field.fieldPath);
				}
			} else if (field.type == 'date') {
				if (field.fieldPath == 'Dan360_FechaDocumento__c') {
					field.label = 'Fecha inicial';
					field.fieldPath = 'startDate';
				}
			}
		}

		return JSON.serialize(fieldset);
	}
}