public with sharing class GridColumn {
	public class Label {
		@AuraEnabled
		public String fieldName;
	}

	public class TypeAttributes {
		@AuraEnabled
		public Label label;
		@AuraEnabled
		public String target;
		@AuraEnabled
		public Tooltip tooltip;
		@AuraEnabled
		public String currencyCode;
		@AuraEnabled
		public String weekday;
		@AuraEnabled
		public String year;
		@AuraEnabled
		public String month;
		@AuraEnabled
		public String day;
		@AuraEnabled
		public String hour;
		@AuraEnabled
		public String minute;
	}

	public class Tooltip {
		@AuraEnabled
		public string fieldName;
		public Boolean sortable;
	}

	@AuraEnabled
	public String type;
	@AuraEnabled
	public String fieldName;
	@AuraEnabled
	public String label;
	@AuraEnabled
	public Integer initialWidth;
	@AuraEnabled
	public Boolean wrapText;
	@AuraEnabled
	public Boolean hideDefaultActions;
	@AuraEnabled
	public Boolean sortable;
	@AuraEnabled
	public TypeAttributes typeAttributes;
	// @AuraEnabled
	public List<String> errors;
	@AuraEnabled
	public String cellAttributes;

	public GridColumn() {
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Integer initialWidth,
		Boolean wrapText
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.initialWidth = initialWidth;
		this.wrapText = wrapText;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Integer initialWidth
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.initialWidth = initialWidth;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Boolean wrapText,
		Boolean hideDefaultActions
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.wrapText = wrapText;
		this.hideDefaultActions = hideDefaultActions;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Boolean hideDefaultActions,
		String cellAttributes
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.hideDefaultActions = hideDefaultActions;
		this.cellAttributes = cellAttributes;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Integer initialWidth,
		Boolean wrapText,
		TypeAttributes typeAttributes
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.initialWidth = initialWidth;
		this.wrapText = wrapText;
		this.typeAttributes = typeAttributes;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Integer initialWidth,
		TypeAttributes typeAttributes
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.initialWidth = initialWidth;
		this.typeAttributes = typeAttributes;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Boolean hideDefaultActions,
		Boolean wrapText,
		TypeAttributes typeAttributes
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.hideDefaultActions = hideDefaultActions;
		this.wrapText = wrapText;
		this.typeAttributes = typeAttributes;
		this.errors = new List<String>();
	}

	public GridColumn(
		String type,
		String fieldName,
		String label,
		Boolean hideDefaultActions,
		TypeAttributes typeAttributes
	) {
		this.type = type;
		this.fieldName = fieldName;
		this.label = label;
		this.hideDefaultActions = hideDefaultActions;
		this.typeAttributes = typeAttributes;
		this.errors = new List<String>();
	}

	public void addError(String error) {
		this.errors.add(error);
	}
}