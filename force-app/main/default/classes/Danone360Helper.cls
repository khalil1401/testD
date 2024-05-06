/**
 * Created by: Diego Rene Valle
 * Created Date: 26-08-2021
 * Update Date: --
 *
 * Description: Class to store all methods that helps to execute generic actions.
 *
 * Suggestions:
 *      -Avoid adds actions for specific SObjects.
 *      -Every new method should have it own test methods into Danone360HelperTest.
 *
 * Related class: Danone360HelperTest
 */
public with sharing class Danone360Helper {
	public static Map<String, Schema.SObjectType> schemaObjectGlobalDescribe;
	public static Map<String, Schema.SObjectField> sObjectFieldMap;
	public static Schema.SObjectType sObjectType;

	public Danone360Helper() {
	}

	public Danone360Helper(String objectName) {
		schemaObjectGlobalDescribe = Schema.getGlobalDescribe();
		sObjectType = schemaObjectGlobalDescribe.get(objectName);
		sObjectFieldMap = sObjectType.getDescribe().fields.getMap();
	}

	public static String getApiNameFields(String objectName) {
		Map<String, Schema.SObjectField> objectSchemaField;
		List<String> fieldsMap;
		String result;

		try {
			if(!String.isBlank(objectName)) {
				objectSchemaField = schemaObjectGlobalDescribe.get(objectName)
					.getDescribe()
					.fields
					.getMap();

				if(objectSchemaField != null) {
					fieldsMap = new List<String>(objectSchemaField.keySet());

					if(fieldsMap != null && fieldsMap.size() > 0) {
						result = String.join(fieldsMap, ', ');
					} else {
						result = Label.Nombre_de_campos;
					}
				} else {
					result = Label.Esquema_de_campos;
				}
			} else {
				result = Label.Nombre_de_API;
			}
		} catch(Exception ex) {
			result = Label.Esquema_de_campos;
		}

		return result;
	}

	public String getApiNameByLabel(String label) {
		Map<String,Schema.SObjectField> fields = sObjectFieldMap;

		for(String strField : fields.keySet())
		{
			SObjectField fl = fields.get(strField);

			if(label == fl.getDescribe().getlabel())
			{
				return strField;
			}
		}

		return '';
	}

	/**
	 * Gets Columns automatically for SObject
	 * @return  `List<GridColumn>`
	 */
	public List<GridColumn> getColumns() {
		List<GridColumn> columns = new List<GridColumn>();

		for (String fieldApiName : sObjectFieldMap.keySet()) {
			Schema.SObjectField field = sObjectFieldMap.get(fieldApiName);

			columns.add(getColumn(fieldApiName));
		}

		return columns;
	}

	/**
	 * Gets columns by Field API Name list
	 * @param fieldApiNames
	 * @return  `List<GridColumn>`
	 */
	public List<GridColumn> getColumns(List<String> fieldApiNames) {
		List<GridColumn> columns = new List<GridColumn>();

		for (String fieldApiName : fieldApiNames) {
			columns.add(getColumn(fieldApiName));
		}

		return columns;
	}

	/**
	 * Gets column by Field API Name
	 * @param fieldApiName
	 * @return  `Column`
	 */
	public GridColumn getColumn(String fieldApiName) {
		Schema.SObjectField field = sObjectFieldMap.get(fieldApiName);
		GridColumn column = new GridColumn();

		if (field != null) {
			column.type = getDisplayType(field);
			column.fieldName = fieldApiName;
			column.label = getLabel(field);
			column.initialWidth = 250;
		} else {
			column.addError('No se encontró el campo ' + fieldApiName);
		}

		return column;
	}

	public GridColumn getColumn(
		String fieldApiName,
		Integer initialWidth
	) {
		Schema.SObjectField field = sObjectFieldMap.get(fieldApiName);
		GridColumn column = new GridColumn();

		if (field != null) {
			column.type = getDisplayType(field);
			column.fieldName = fieldApiName;
			column.label = getLabel(field);
			column.initialWidth = initialWidth;
		} else {
			column.addError('No se encontró el campo ' + fieldApiName);
		}

		return column;
	}

	public GridColumn getColumn(
		String fieldApiName,
		Boolean hideDefaultActions
	) {
		Schema.SObjectField field = sObjectFieldMap.get(fieldApiName);
		GridColumn column = new GridColumn();

		if (field != null) {
			column.type = getDisplayType(field);
			column.fieldName = fieldApiName;
			column.label = getLabel(field);
			column.hideDefaultActions = hideDefaultActions;
		} else {
			column.addError('No se encontró el campo ' + fieldApiName);
		}

		return column;
	}

	public GridColumn getColumn(
		String fieldApiName,
		String customType,
		Boolean hideDefaultActions
	) {
		Schema.SObjectField field = sObjectFieldMap.get(fieldApiName);
		GridColumn column = new GridColumn();
		String cellAtribute = '{ alignment: "left" }';

		if (fieldApiName == 'TotalAmount') {
			column.cellAttributes = cellAtribute;
		}
		if (field != null) {
			column.type = customType;
			column.fieldName = fieldApiName;
			column.label = getLabel(field);
			column.hideDefaultActions = hideDefaultActions;
		} else {
			column.addError('No se encontró el campo ' + fieldApiName);
		}

		return column;
	}

	public GridColumn getColumn(
		String fieldApiName,
		String customType,
		Boolean hideDefaultActions,
		GridColumn.TypeAttributes typeAttributes
	) {
		Schema.SObjectField field = sObjectFieldMap.get(fieldApiName);
		GridColumn column = new GridColumn();

		if (fieldApiName == 'EffectiveDate') {
			typeAttributes.month = '2-digit';
			typeAttributes.day = '2-digit';
		}
		if (field != null) {
			column.type = customType;
			column.fieldName = fieldApiName;
			column.label = getLabel(field);
			column.hideDefaultActions = hideDefaultActions;
			column.typeAttributes = typeAttributes;
		} else {
			column.addError('No se encontró el campo ' + fieldApiName);
		}

		return column;
	}

	public GridColumn getCustomColumn(
		String fieldApiName,
		String customType,
		String customLabel,
		Boolean hideDefaultActions,
		GridColumn.TypeAttributes typeAttributes
	) {
		GridColumn column = new GridColumn();

		column.type = customType;
		column.fieldName = fieldApiName;
		column.label = customLabel;
		column.hideDefaultActions = hideDefaultActions;
		column.typeAttributes = typeAttributes;

		return column;
	}

	public GridColumn getCustomColumnWithSort(
		String fieldApiName,
		String customType,
		String customLabel,
		Boolean hideDefaultActions,
		Boolean sortable,
		GridColumn.TypeAttributes typeAttributes
	) {
		GridColumn column = new GridColumn();

		column.type = customType;
		column.fieldName = fieldApiName;
		column.label = customLabel;
		column.hideDefaultActions = hideDefaultActions;
		column.sortable = sortable; 
		column.typeAttributes = typeAttributes;

		return column;
	}

	private static String getDisplayType(Schema.SObjectField field) {
		return String.valueOf(field.getDescribe().getType());
	}

	private static String getLabel(Schema.SObjectField field) {
		return field.getDescribe().getLabel();
	}

	public String getFieldsFromFieldSet(String fieldSetName) {
		if(!String.isEmpty(fieldSetName)){
			Map<String, String> fieldSets = new Map<String, String>();
			List<Schema.FieldSetMember> fieldSetMember = sObjectType.getDescribe()
				.fieldSets
				.getMap()
				.get(fieldSetName)
				.getFields();

			fieldSets.put('FIELD_LIST', JSON.serialize(fieldSetMember));
			fieldSets.put('OBJECT_LABEL', sObjectType?.getDescribe()?.getLabel());

			return JSON.serialize(fieldSets);
		}

		return null;
	}

	public List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetName) {
		if(!String.isEmpty(fieldSetName)){
			List<Schema.FieldSetMember> fieldSetMembers = sObjectType.getDescribe()
				.fieldSets
				.getMap()
				.get(fieldSetName)
				.getFields();

			return fieldSetMembers;
		}

		return null;
	}

	public Map<String, Id> getRecordTypes() {
		Schema.DescribeSObjectResult sobjectResult = sObjectType.getDescribe();
		List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
		Map<String, Id> recordTypesIdsByName = new Map<String, Id>();

		for(Schema.RecordTypeInfo info : recordTypeInfo) {
			recordTypesIdsByName.put(info.getDeveloperName(),info.getRecordTypeId());
		}

		return recordTypesIdsByName;
	}

	public String getFieldReference(String fieldName) {
		String referenceName = '';

		Schema.DescribeFieldResult f = sObjectFieldMap.get(fieldName).getDescribe();

		for(Schema.SObjectType reference : f.getReferenceTo()) {
			referenceName = reference.getDescribe().getName();
		}

		return referenceName;
	}

	public Map<String, Schema.SObjectField> getSObjectFieldMap() {
		return sObjectFieldMap;
	}

	public List<Schema.PicklistEntry> getPicklistEntries(String picklistAPIName) {
		List<Schema.PicklistEntry> picklistEntries = new List<Schema.PicklistEntry>();

		if (sObjectFieldMap.get(picklistAPIName) != null) {
			picklistEntries = sObjectFieldMap.get(picklistAPIName)
					.getDescribe()
					.getPicklistValues();
		}

		return picklistEntries;
	}

	public Map<String, List<Schema.PicklistEntry>> getPicklistValues(List<String> sobjectsAndPicklists) {
		Map<String, List<Schema.PicklistEntry>> picklistValues = new Map<String, List<Schema.PicklistEntry>>();

		for (String picklistValueApi : sobjectsAndPicklists) {
			if (sObjectFieldMap.get(picklistValueApi) != null) {
				List<Schema.PicklistEntry> picklistEntries = sObjectFieldMap.get(picklistValueApi)
						.getDescribe()
						.getPicklistValues();

				picklistValues.put(picklistValueApi, picklistEntries);
			}
		}

		return picklistValues;
	}

	public static String getSObjectIcon(String sobjectName) {
		List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
		List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
		List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
		String iconName;

		for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
			tabDesc.addAll(tsr.getTabs());
		}

		for(Schema.DescribeTabResult tr : tabDesc) {
			if( sObjectName == tr.getSobjectName()) {
				if( tr.isCustom() == true ) {
					iconDesc.addAll(tr.getIcons());
				} else {
					iconName = 'standard:' + sObjectName.toLowerCase();
				}
			}
		}

		for (Schema.DescribeIconResult ir : iconDesc) {
			if (ir.getContentType() == 'image/svg+xml') {
				iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
				break;
			}
		}
		System.debug(iconName);
		return iconName;
	}

	public static String extractFromApiName (String apiName) {
		Pattern p = Pattern.Compile('(((D|d)an)360_)*(__([c|C]))*');
		Matcher m = p.Matcher(apiName);

		if (m.Matches()) {
			return m.replaceAll('');
		}

		return '';
	}

	public class FieldWrapper {
		@AuraEnabled
		public Boolean dbRequired;

		@AuraEnabled
		public String fieldPath;

		@AuraEnabled
		public String label;

		@AuraEnabled
		public Boolean required;

		@AuraEnabled
		public String type;

		@AuraEnabled
		public String typeApex;

		@AuraEnabled
		public String sobjectName;

		@AuraEnabled
		public String picklistApiName;

		@AuraEnabled
		public String referenceApiName;
	}
}