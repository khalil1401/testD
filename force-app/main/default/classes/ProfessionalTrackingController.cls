public with sharing class ProfessionalTrackingController {
	public class Criteria {
		public String FieldName;
		public String Operator;
		public String FieldValue;

		public Criteria(String f_name, String f_value) {
			this.FieldName = f_name;
			this.FieldValue = f_value;
			this.Operator = '=';
		}

		public String getSOQLCriteria() {
			if (fieldName.indexOf('Dan360_FechaDocumento__c') > -1) {
				return fieldName + ' '  + Operator + ' ' + FieldValue + '';
			}else {
				return fieldName + ' '  + Operator + ' \'' + FieldValue + '\'';
			}
		}

		public Boolean IsFieldValueGiven() {
			return FieldValue != null && FieldValue != '';
		}
	}

	@AuraEnabled
	public static ServerResponse getTracking(Map<String, String> criterias) {
		ServerResponse response;
		Map<String, Map<String, Object>> tracking = new Map<String, Map<String, Object>>();
		List<Criteria> all_criterias = new List<Criteria>();
		TreeGrid grid = new TreeGrid();
		Danone360Helper helper = new Danone360Helper('VisMed_Contacto_Cuenta_Usuario__c');

		GridColumn.TypeAttributes typeAttributesOne = new GridColumn.TypeAttributes();
		GridColumn.Label labelOne = new GridColumn.Label();
		labelOne.fieldName = 'Professional';
		typeAttributesOne.label = labelOne;
		typeAttributesOne.target = '_parent';
		typeAttributesOne.tooltip = new GridColumn.Tooltip();
		typeAttributesOne.tooltip.fieldName = 'Professional';

		GridColumn.TypeAttributes typeAttributesTwo = new GridColumn.TypeAttributes();
		GridColumn.Label labelTwo = new GridColumn.Label();
		labelTwo.fieldName = 'Institución';
		typeAttributesTwo.label = labelTwo;
		typeAttributesTwo.target = '_parent';
		typeAttributesTwo.tooltip = new GridColumn.Tooltip();
		typeAttributesTwo.tooltip.fieldName = 'Institution';

		GridColumn.TypeAttributes typeAttributesThree = new GridColumn.TypeAttributes();
		GridColumn.Label labelThree = new GridColumn.Label();
		labelThree.fieldName = 'Visitador';
		typeAttributesThree.label = labelThree;
		typeAttributesThree.target = '_parent';
		typeAttributesThree.tooltip = new GridColumn.Tooltip();
		typeAttributesThree.tooltip.fieldName = 'Visitor';

		grid.GridColumns = new List<GridColumn>();
		grid.GridColumns.add(helper.getCustomColumn('VisitorLink', 'url', 'Visitador', true,  typeAttributesThree));
		grid.GridColumns.add(helper.getCustomColumn('ProfessionalLink', 'url', 'Profesional', true,  typeAttributesOne));
		grid.GridColumns.add(new GridColumn('text', 'Institution', 'Institucion(es)', true, true,  typeAttributesOne));

		System.debug('criterias');
		System.debug(criterias);

		String soqlQuery = 'SELECT  Id,';
		soqlQuery += '				Name,';
		soqlQuery += '				Profesional__c,';
		soqlQuery += '				Profesional__r.Name,';
		soqlQuery += '				Institucion__c,';
		soqlQuery += '				Institucion__r.Name,';
		soqlQuery += '				Predeterminada__c,';
		soqlQuery += '				Ultima_Visita__c,';
		soqlQuery += '				Visitador__c,';
		soqlQuery += '				Visitador__r.Name';
		soqlQuery += '		FROM	VisMed_Contacto_Cuenta_Usuario__c';

		if (criterias != null && !criterias.isEmpty()) {
			for (String key : criterias.keySet()) {
				all_criterias.add(new Criteria(key, criterias.get(key)));
			}

			soqlQuery += '	WHERE	';
			soqlQuery += generateWhereQuery(all_criterias);
		}

		Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>> seguimiento = new Map<Id, List<VisMed_Contacto_Cuenta_Usuario__c>>();

		System.debug('soqlQuery');
		System.debug(Database.query(soqlQuery));

		for (VisMed_Contacto_Cuenta_Usuario__c item : Database.query(soqlQuery)) {
			if (!seguimiento.containsKey(item.Profesional__c)) {
				seguimiento.put(item.Profesional__c, new List<VisMed_Contacto_Cuenta_Usuario__c>());
			}

			seguimiento.get(item.Profesional__c).add(item);
		}

		Map<String, Map<String, List<VisMed_Contacto_Cuenta_Usuario__c>>> profesionales = new Map<String, Map<String, List<VisMed_Contacto_Cuenta_Usuario__c>>>();

		for (Id profesionalId : seguimiento.keySet()) {
			Map<String, List<VisMed_Contacto_Cuenta_Usuario__c>> visitors = new Map<String, List<VisMed_Contacto_Cuenta_Usuario__c>>();
			List<VisMed_Contacto_Cuenta_Usuario__c> seg = seguimiento.get(profesionalId);
			Map<String, Object> row = new Map<String, Object>();

			for (VisMed_Contacto_Cuenta_Usuario__c s : seg) {
				if (!visitors.containsKey(s.Visitador__c)) {
					visitors.put(s.Visitador__c, new List<VisMed_Contacto_Cuenta_Usuario__c>());
				}

				visitors.get(s.Visitador__c).add(s);

				profesionales.put(s.Profesional__c, visitors);
			}
		}

		List<Map<String, Object>> rows = new List<Map<String, Object>>();

		for (String profesional : profesionales.keySet()) {
			Map<String, List<VisMed_Contacto_Cuenta_Usuario__c>> visitors = (Map<String, List<VisMed_Contacto_Cuenta_Usuario__c>>)profesionales.get(profesional);

			for (String visitor : visitors.keySet()) {
				List<VisMed_Contacto_Cuenta_Usuario__c> seg = (List<VisMed_Contacto_Cuenta_Usuario__c>)visitors.get(visitor);
				Set<Id> institucionesIds = new Set<Id>();
				List<String> instituciones = new List<String>();
				Map<String, Object> wrapper = new Map<String, Object>();

				for (VisMed_Contacto_Cuenta_Usuario__c s : seg) {
					wrapper.put('ProfessionalLink', profesional);
					wrapper.put('VisitorLink', visitor);
					wrapper.put('Visitador', s.Visitador__r.Name);
					wrapper.put('Professional', s.Profesional__r.Name);
					institucionesIds.add(s.Institucion__c);

					if (!instituciones.contains(s.Institucion__r.Name)) {
						instituciones.add(s.Institucion__r.Name);
					}
				}

				wrapper.put('InstitucionesIds', institucionesIds);
				wrapper.put('Institution', String.join(instituciones, ', \r\n'));
				rows.add(wrapper);

			}
		}

		grid.GridData = rows;
		response = new ServerResponse('SUCCESS', grid, '');


		return response;
	}

	private static String generateWhereQuery(List<Criteria> criterias) {
		List<String> and_conditions = new List<String>();
		String conditions;

		for(Criteria single_criteria : criterias) {
			if (single_criteria.IsFieldValueGiven()) {
				and_conditions.add(single_criteria.getSOQLCriteria());
			}
		}

		conditions = String.join(and_conditions, and_conditions.size() > 1 ? ' AND ': '');

		return conditions;
	}

	@AuraEnabled
	public static String getFieldSet(String fieldSetApiName) {
		Danone360Helper helper = new Danone360Helper('VisMed_Contacto_Cuenta_Usuario__c');
		List<Danone360Helper.FieldWrapper> fieldset = (List<Danone360Helper.FieldWrapper>)JSON.deserialize(
			JSON.serialize(helper.getFieldSetMembers(fieldSetApiName)),
			List<Danone360Helper.FieldWrapper>.class
		);

		for (Danone360Helper.FieldWrapper field : fieldset) {
			if (field.type == 'picklist') {
				if (field.fieldPath.indexOf('__r') > -1) {
					List<String> arr = field.fieldPath.split('\\.');
					field.sobjectName = helper.getFieldReference(arr[0].replace('__r', '__c'));
					field.picklistApiName = arr[1];
				} else {
					field.sobjectName = 'VisMed_Contacto_Cuenta_Usuario__c';
					field.picklistApiName = field.fieldPath;
				}
			} else if (field.type == 'reference') {
				if (field.fieldPath.indexOf('__r') > -1) {
					List<String> arr = field.fieldPath.split('\\.');
					field.sobjectName = helper.getFieldReference(arr[0].replace('__r', '__c'));
				} else {
					field.sobjectName = helper.getFieldReference(field.fieldPath);
				}
			}
		}

		return JSON.serialize(fieldset);
	}

	@AuraEnabled
	public static Boolean transferProfessional(String newAPM, List<Map<String, Object>> professionalsSelected) {
		Boolean isSuccess = true;
		List<VisMed_Contacto_Cuenta_Usuario__c> toTransfer = new List<VisMed_Contacto_Cuenta_Usuario__c>();
		List<VisMed_Contacto_Cuenta_Usuario__c> toDelete = new List<VisMed_Contacto_Cuenta_Usuario__c>();
		Map<Id, Map<String, Object>> professionalsToTransfer = new Map<Id, Map<String, Object>>();

		System.debug('professionalsSelected');
		System.debug(professionalsSelected);

		for (Object row : professionalsSelected) {
			Map<String, Object> o = (Map<String, Object>)row;
			Map<String, Object> professionalData = new Map<String, Object>();
			String professional = String.valueOf(o.get('Profesional__c'));
			String visitor = String.valueOf(o.get('Visitador__c'));
			Set<String> institutions = new Set<String>((List<String>)JSON.deserialize(JSON.serialize(o.get('Instituciones')), List<String>.class));

			professionalData.put('professional', professional);
			professionalData.put('visitor', visitor);
			professionalData.put('institutions', institutions);

			professionalsToTransfer.put(professional, professionalData);
		}

		Set<Id> profesionalIds = professionalsToTransfer.keySet();

		for (VisMed_Contacto_Cuenta_Usuario__c seg : [
			SELECT	Id,
					Visitador__c,
					Profesional__c,
					Institucion__c,
					Tipo__c
			FROM	VisMed_Contacto_Cuenta_Usuario__c
			WHERE	Profesional__c IN :profesionalIds
		]) {
			Map<String, Object> professionalToTransfer = professionalsToTransfer.get(seg.Profesional__c);
			Set<String> insts = (Set<String>)professionalToTransfer.get('institutions');

			if (
				professionalToTransfer.get('visitor') == seg.Visitador__c &&
				insts.contains(seg.Institucion__c)
			) {
				VisMed_Contacto_Cuenta_Usuario__c cloned = seg.clone();
				cloned.Tipo__c = seg.Tipo__c;
				System.debug('cloned.Tipo__c: '+ cloned.Tipo__c);
				cloned.Visitador__c = newAPM;
				toTransfer.add(cloned);
				toDelete.add(seg);
			}
		}
		System.debug('segTest');
		for(VisMed_Contacto_Cuenta_Usuario__c segTest : toTransfer){
			System.debug(segTest);
			System.debug(segTest.Tipo__c);
		}
		List<Database.DeleteResult> deleteResults = Database.delete(toDelete);

		for (Database.DeleteResult dr : deleteResults) {
			isSuccess = dr.isSuccess();
			if (!isSuccess) {
				for (Database.Error error : dr.getErrors()) {
					System.debug(error.getMessage());
				}
			}
		}

		if (isSuccess) {
			List<Database.SaveResult> insertResults = Database.insert(toTransfer);

			for (Database.SaveResult sr : insertResults) {
				isSuccess = sr.isSuccess();

				if (!isSuccess) {
					for (Database.Error error : sr.getErrors()) {
						System.debug(error.getMessage());
					}
					break;
				}
			}
		}

		return isSuccess;
	}

	@AuraEnabled
	public static Boolean shareProfessional(String newAPM, List<Map<String, Object>> professionalsSelected){
		Boolean isSuccess = true;
		List<VisMed_Contacto_Cuenta_Usuario__c> toShare = new List<VisMed_Contacto_Cuenta_Usuario__c>();
		Map<Id, Map<String, Object>> professionalsToShare = new Map<Id, Map<String, Object>>();

		for (Object row : professionalsSelected) {
			Map<String, Object> o = (Map<String, Object>)row;
			Map<String, Object> professionalData = new Map<String, Object>();
			String professional = String.valueOf(o.get('Profesional__c'));
			String visitor = String.valueOf(o.get('Visitador__c'));
			Set<String> institutions = new Set<String>((List<String>)JSON.deserialize(JSON.serialize(o.get('Instituciones')), List<String>.class));

			professionalData.put('professional', professional);
			professionalData.put('visitor', visitor);
			professionalData.put('institutions', institutions);

			professionalsToShare.put(professional, professionalData);
		}

		Set<Id> profesionalIds = professionalsToShare.keySet();

		for (VisMed_Contacto_Cuenta_Usuario__c seg : [
			SELECT	Id,
					Visitador__c,
					Profesional__c,
					Institucion__c
			FROM	VisMed_Contacto_Cuenta_Usuario__c
			WHERE	Profesional__c IN :profesionalIds
		]) {
			Map<String, Object> professionalToTransfer = professionalsToShare.get(seg.Profesional__c);
			Set<String> insts = (Set<String>)professionalToTransfer.get('institutions');

			if (professionalToTransfer.get('visitor') == seg.Visitador__c && insts.contains(seg.Institucion__c))
			{
				VisMed_Contacto_Cuenta_Usuario__c cloned = seg.clone();
				cloned.Visitador__c = newAPM;
				toShare.add(cloned);
			}
		}

		if (isSuccess) {
			List<Database.SaveResult> insertResults = Database.insert(toShare);

			for (Database.SaveResult sr : insertResults) {
				isSuccess = sr.isSuccess();
				if (!isSuccess) {for (Database.Error error : sr.getErrors()) {System.debug(error.getMessage());}break;}
			}
		}

		return isSuccess;
	}

	@AuraEnabled
	public static Boolean unsubscribeProfessional(List<Map<String, Object>> professionalsToUnsubscribe){
		List<VisMed_Bajas__c> bajas = new List<VisMed_Bajas__c>();
		Boolean isSuccess = true;

		for (Object professional : professionalsToUnsubscribe) {
			Map<String, Object> prof = (Map<String, Object>)professional;
			VisMed_Bajas__c baja = new VisMed_Bajas__c();

			Id profesional = String.valueOf(prof.get('professional'));
			baja.Profesional__c = profesional;
			baja.APM__c = String.valueOf(prof.get('visitor'));
			baja.Motivo_de_la_Baja__c = String.valueOf(prof.get('reasonForUnsubscribe'));
			baja.Fecha_de_Desactivacion__c = prof.containsKey('deactivationDate') ? Date.valueOf(String.valueOf(prof.get('deactivationDate'))) : null;
			baja.Fecha_de_Reactivacion__c = prof.containsKey('reactivationDate') ? Date.valueOf(String.valueOf(prof.get('reactivationDate'))) : null;
			baja.Comentario__c = String.valueOf(prof.get('comment'));
			baja.Estado__c = 'Pendiente';

			bajas.add(baja);
		}

		List<Database.SaveResult> saveResults = Database.insert(bajas);

		for (Database.SaveResult result : saveResults) {
			isSuccess = result.isSuccess(); if (!isSuccess) {break;}
		}
		return isSuccess;
	}

	@AuraEnabled
	public static List<Contact> getAPMList(){
		Id recordTypeId = (Id)getRecordTypeId('Contact', 'Visitador_Medico');

		List<Contact> apms = [
			SELECT  Id,
					Name
			FROM    Contact
			WHERE   RecordTypeId = :recordTypeId
		];

		return apms;
	}

	@AuraEnabled
	public static Object getRecordTypeId(String sobjectname, String apiname){
		Danone360Helper helper = new Danone360Helper(sobjectname);
		Map<String, Id> recordTypes = helper.getRecordTypes();
		return String.isEmpty(apiname) ? (Object)recordTypes : recordTypes.get(apiname);
	}

	@AuraEnabled
	public static ServerResponse getUserInfo(Id userId){
		ServerResponse response = new ServerResponse();

		response.state = 'SUCCESS';
		response.data = [SELECT Id, Profile.Name FROM User WHERE Id = :userId];

		return response;
	}

	@AuraEnabled(cacheable=true)
    public static List<User> getSupervisores () {
        List<User> supervisores = [SELECT Id, Name, ContactId FROM User WHERE Profile.Name  = 'Supervisores' AND IsActive = TRUE ORDER BY Name];
        System.debug('supervisores: ' + supervisores);
        return supervisores;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUser(String supervisor) {
        String query;
        String condicion =  (String.isNotBlank(supervisor) ? 'ManagerId = \'' + supervisor + '\'' : '');
        if (String.isNotBlank(condicion)) {
            query =
                'SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True AND ' +
                condicion;
        } else { query = 'SELECT Id, Name, ContactId FROM User WHERE IsPortalEnabled = True AND IsActive = True AND VisMed_Es_un_Visitador_Medico__c = True'; }
        List<User> users = Database.query(query);
        Return users;
    }

}