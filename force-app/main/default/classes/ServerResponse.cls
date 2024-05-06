/*···································································
	Created by: Diego Rene Valle
	Date: 19-08-2021
	Description: Object to Response from server to client.
	···································································*/
public with sharing class ServerResponse {
	@AuraEnabled
	public String state;

	@AuraEnabled
	public Object data;

	@AuraEnabled
	public String message;

	@AuraEnabled
	public Map<String, String> errors;

	public ServerResponse() {
		this.errors = new Map<String, String>();
	}

	public ServerResponse(String state, Object data, String message) {
		this.state = state;
		this.data = data;
		this.message = message;
		this.errors = new Map<String, String>();
	}

	public void addError(String id, String error) {
		this.errors.put(id, error);
	}

	public Boolean hasErrors() {
		return this.errors.size() > 0;
	}
}