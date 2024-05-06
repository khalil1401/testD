public class RestWS {
	private String endpoint = '';
	public WSParameter[] parameters;
	public WSParameter[] headerParameters;
	public WSParameter bodyParameter;
	public HttpRequest request;

	public Boolean hasError = false;
	public String errorMessage = '';

	public RestWS(String endpoint, String method, WSParameter[] urlParameters, WSParameter bodyParameter, WSParameter[] headersParameter) {
		System.debug(endpoint);
		this.request = new HttpRequest();
		this.request.setMethod(method);
		this.request.setTimeout(120000);
		this.bodyParameter = bodyParameter;
		this.headerParameters = headersParameter;
		this.endpoint = endpoint;
		this.parameters = urlParameters;
	}

	public RestWS(String endpoint, String method, WSParameter[] urlParameters, WSParameter bodyParameter) {
		this(endpoint, method, urlParameters, bodyParameter, new WSParameter[]{});
	}

	public RestWS(String endpoint, String method, WSParameter[] urlParameters, String bodyParameter, WSParameter[] headersParameter) {
		this(endpoint, method, urlParameters, new WSParameter('body', bodyParameter, false, false),headersParameter);
	}

	public RestWS(String endpoint, String method, WSParameter[] urlParameters, String bodyParameter) {
		this(endpoint, method, urlParameters, new WSParameter('body', bodyParameter, false, false));
	}

	public RestWS(String endpoint, String method, WSParameter[] urlParameters) {
		this(endpoint, method, urlParameters, '');
	}

	private String getMissingParametersMessage() {
		if (parameters == null && bodyParameter == null) {
			return '';
		}

		WSParameter[] parametersToCheck = new WSParameter[]{};
		if (parameters != null) {
			parametersToCheck.addAll(parameters);
		}
		if (bodyParameter != null) {
			parametersToCheck.add(bodyParameter);
		}

		String[] missingParms = new String[]{};
		for (WSParameter parameter: parametersToCheck) {
			if (parameter.isRequired && String.isBlank(parameter.value)) {
				missingParms.add(parameter.name);
			}
		}

		if (missingParms.size() > 0) {
			String message = String.format(
					'Faltan parametros para realizar la operacion: {0} .',
					new String[] {String.join(missingParms, ',') }
			);
			return message;
		} else {
			return '';
		}
	}

	private String formatEndpoint() {
		if (parameters == null || parameters.isEmpty()) {
			return endpoint;
		}
		List<String> paramValues = new List<String>();
		for (WSParameter parameter : parameters) {
			paramValues.add(parameter.toString());
		}
		return String.format(endpoint, paramValues);
	}

	private String getBody() {
		return bodyParameter != null ? bodyParameter.toString() : '';
	}

	private String setHeaders() {
		if (this.headerParameters == null || this.headerParameters.isEmpty()) {
			return '';
		}

		WSParameter[] parametersToCheck = new WSParameter[]{};
		parametersToCheck.addAll(this.headerParameters);

		String[] missingParms = new String[]{};
		for (WSParameter parameter: parametersToCheck) {
			if ( String.isBlank(parameter.value) ) {
				missingParms.add(parameter.name);
			} else {
				this.request.setHeader(parameter.name, parameter.value);
			}
		}

		if (missingParms.size() > 0) {
			String message = String.format(
					'Faltan parametros de cabecera para realizar la operacion: {0} .',
					new String[] {String.join(missingParms, ',') }
			);
			return message;
		} else {
			return '';
		}
	}

	public WSResult invoke(WSResult result) {

		result.request = request;

		if (hasError) {
			result.hasError = true;
			result.message = errorMessage;
			return result;
		}

		String missingParamsMessage = getMissingParametersMessage();

		if (String.isNotBlank(missingParamsMessage)) {
			result.hasError = true;
			result.message = missingParamsMessage;
			return result;
		}

		request.setEndpoint(formatEndpoint());
		String body = getBody();
		if (String.isNotBlank(body)) {
			request.setBody(body);
		}

		/* Set Headers */
		String setHeadersError= this.setHeaders();
		if(String.isNotBlank(setHeadersError)){
			result.hasError = true;
			result.message = setHeadersError;
			return result;
		}

		result.request = request;

		try {
			System.debug(LoggingLevel.DEBUG, '[REQUEST]: ' + request.getBody());

			HttpResponse response = new Http().send(request);
			result.response = response;

			System.debug(LoggingLevel.DEBUG, '[RESPONSE]: ' + response?.getBody());

			result.hasError = response.getStatusCode() >= 300;

			if(!result.hasError) {
				result.processResponse(response);
			} else {
				result.processErrorResponse(response);
			}

		} catch(Exception ex) {
			result.hasError = true;
			result.resultException = ex;
			result.message = ex.getMessage();
		}

		return result;
	}
}