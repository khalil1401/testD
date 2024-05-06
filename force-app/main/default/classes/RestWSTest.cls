@isTest
private class RestWSTest {
	private static TestWSResult result;
	private static XHttpCalloutMock serverMock;
	private static String wsAddress;
	private static String method;

	static {
		wsAddress = 'address.test?{0}';
		method = 'GET';

		serverMock = new XHttpCalloutMock();
		serverMock.buildResponse().withBody('some body').addForAddress(wsAddress);
		Test.setMock(HttpCalloutMock.class, serverMock);
		result = new TestWSResult();
	}

	@isTest
	private static void itShouldBePosibleToSetHeadersInTheRequest() {
		// Setup(Given)
		String parameterName = 'Content-Type';
		String parameterValue = 'application/x-www-form-urlencoded';

		List<WSParameter> parameterList = new List<WSParameter> {
			new WSParameter(parameterName, parameterValue, false)
		};

		RestWS serviceCaller = new RestWS(wsAddress, 'POST', null, 'Body', parameterList);

		// Exercise (When)
		Test.startTest();
		serviceCaller.invoke(result);
		Test.stopTest();

		// Test(Then)
		System.assertEquals(parameterValue, serviceCaller.request.getHeader('Content-Type'), 'No se seteo correctamente el valor del header');
	}

	@isTest
	private static void itShouldBePosibleToCallAWebService() {
		RestWS serviceCaller = new RestWS(wsAddress, method, null, (WSParameter)null);
		serviceCaller.invoke(result);

		System.assertEquals(true, result.processResponseCalled);
		System.assertEquals(1, serverMock.callsMade);
		System.assertEquals(method, serverMock.latestRequest.getMethod());
		System.assertEquals(wsAddress, serverMock.latestRequest.getEndpoint());
	}

	@isTest
	private static void itShouldBePosibleToSendParametersInTheAddressOfARequest() {
		String parameterName = 'Name';
		String parameterValue = 'Value';
		List<WSParameter> parameterList = new List<WSParameter> {
			new WSParameter(parameterName, parameterValue, false)
		};

		RestWS serviceCaller = new RestWS(wsAddress, method, parameterList);
		serviceCaller.invoke(result);

		String param = serverMock.latestRequest.getEndpoint().split('\\?')[1];
		System.assertEquals(parameterValue, param);
	}

	@isTest
	private static void itShouldBePosibleToSendDataInTheBodyOfTheRequest() {
		String bodyValue = 'Value';

		RestWS serviceCaller = new RestWS(wsAddress, 'POST', null, bodyValue);
		serviceCaller.invoke(result);

		System.assertEquals(bodyValue, serverMock.latestRequest.getBody());
	}

	@isTest
	private static void ifARequiredParameterIsNotPresent_AnErrorShouldBeReturned() {
		String parameterName = 'Name';
		List<WSParameter> parameterList = new List<WSParameter> {
			new WSParameter(parameterName, null, true)
		};

		RestWS serviceCaller = new RestWS(wsAddress, method, parameterList);
		serviceCaller.invoke(result);

		System.assertEquals(0, serverMock.callsMade);
		System.assertEquals(false, result.processResponseCalled);
		System.assertEquals(
			'Faltan parametros para realizar la operacion: ' + parameterName + ' .',
			result.message
		);
	}

	@isTest
	private static void ifTheServerReturnsAnExceptionTheResponseShouldNotBeProcessed() {
		String errorMessage = 'An error';
		serverMock.buildResponse().simulateNetworkError().withExceptionMessage(errorMessage)
			.addForAddress(wsAddress);

		RestWS serviceCaller = new RestWS(wsAddress, method, null, (WSParameter)null);
		serviceCaller.invoke(result);

		System.assertEquals(false, result.processResponseCalled);
		System.assertEquals(true, result.hasError);
		System.assertEquals(errorMessage, result.message);
	}

	@isTest
	private static void ifTheServerReturnsAnErrorTheResponseShouldNotBeProcessed() {
		Integer statusCode = 404;
		serverMock.buildResponse().withStatusCode(statusCode).addForAddress(wsAddress);

		RestWS serviceCaller = new RestWS(wsAddress, method, null, (WSParameter)null);
		serviceCaller.invoke(result);

		System.assertEquals(false, result.processResponseCalled);
		System.assertEquals(true, result.hasError);
		System.assertEquals(statusCode, result.response.getStatusCode());
	}

	@isTest
	private static void itShouldBePosibleToForceAnError() {
		RestWS serviceCaller = new RestWS(wsAddress, method, null, (WSParameter)null);
		serviceCaller.hasError = true;
		serviceCaller.errorMessage = 'Forced error';
		serviceCaller.invoke(result);

		System.assertEquals(false, result.processResponseCalled);
		System.assertEquals(true, result.hasError);
		System.assertEquals(serviceCaller.errorMessage, result.message);
	}

	public class TestWSResult extends WSResult {
		public Boolean processResponseCalled = false;

		public override void processResponse(HttpResponse response) {
			processResponseCalled = true;
		}

        public override void processErrorResponse(HttpResponse response) {
			processResponseCalled = false;
		}
	}
}