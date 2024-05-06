@isTest
public class XWebServiceMock implements WebServiceMock {
	public static final String NOT_FOUND_ADDRESS = '404 not found';
	/**
	* Total amount of calls made to all soap services.
	*/
	public Integer callsMade;
	public Map<String, ResponseWrapper> responseWrappers;
	
	public RequestWrapper latestRequest;
	public List<RequestWrapper> receivedRequests;
	
	public XWebServiceMock() {
		callsMade = 0;
		receivedRequests = new List<RequestWrapper>();
		responseWrappers = new Map<String, ResponseWrapper>();
		
		//Make sure there is a 404 in case the address received doesn't match
		buildResponse().simulateNetworkError().addForAddress(NOT_FOUND_ADDRESS);
	}
	
	public void doInvoke(
		Object stub,
		Object soapRequest,
		Map<String,Object> responseMap,
		String endpoint,
		String soapAction,
		String requestName,
		String responseNamespace,
		String responseName,
		String responseType
	) {
		RequestWrapper req = new RequestWrapper(
			stub,
			soapRequest,
			endpoint,
			soapAction,
			requestName
		);
		callsMade++;
		latestRequest = req;
		receivedRequests.add(req);
		
		//Try to get the response for the address with parameters
		ResponseWrapper rw = responseWrappers.get(endpoint);
		if(rw == null) {
			//Try to get the response for the address without parameters
			rw = responseWrappers.get(endpoint.split('\\?')[0]);
			if(rw == null) {
				//Return address not found
				rw = responseWrappers.get(NOT_FOUND_ADDRESS);
			}
		}
		
		responseMap.put('response_x', rw.generateResponse(req));
	}
	
	//========================================
	public ResponseWrapperBuilder buildResponse() {
		return new ResponseWrapperBuilder(this);
	}
	
	public class ResponseWrapper {
		public Boolean simulateNetworkError = false;
		public Object responseObject;
		public String exceptionMessage = 'err';
		
		public RequestWrapper latestRequest;
		public List<RequestWrapper> receivedRequests = new List<RequestWrapper>();
		
		private Object generateResponse(RequestWrapper req) {
			latestRequest = req;
			receivedRequests.add(req);
			if(simulateNetworkError) {
				throw new CalloutException(exceptionMessage);
			}
			return responseObject;
		}
	}
	
	public class RequestWrapper {
		public Object stub;
		public Object soapRequest;//You want this one 99% of the times
		public String endpoint;
		public String soapAction;
		public String requestName;
		
		public RequestWrapper(
			Object stub,
			Object soapRequest,
			String endpoint,
			String soapAction,
			String requestName
		) {
			this.stub = stub;
			this.soapRequest = soapRequest;
			this.endpoint = endpoint;
			this.soapAction = soapAction;
			this.requestName = requestName;
		}
	}
	
	public class ResponseWrapperBuilder {
		ResponseWrapper rw = new ResponseWrapper();
		XWebServiceMock parent;
		
		public ResponseWrapperBuilder(XWebServiceMock parent) {
			this.parent = parent;
		}
		
		public ResponseWrapperBuilder withResponseObject(Object value) {
			rw.responseObject = value;
			return this;
		}
		
		/**
		* When a response is created with this, whenever the response has to generate the
		* response, a CalloutException will be thrown, the request will still be saved
		*/
		public ResponseWrapperBuilder simulateNetworkError() {
			rw.simulateNetworkError = true;
			return this;
		}
		
		/**
		* When the response is set to simulate a network error, this message will be used as the
		* exception message.
		*/
		public ResponseWrapperBuilder withExceptionMessage(String value) {
			rw.exceptionMessage = value;
			return this;
		}
		
		/**
		* Add the response to the mock responses for an address.
		* @param address url address for wich the response is, may or may not include parameters (urls with parameters are prioritized when responding).
		*/
		public void addForAddress(String address) {
			parent.responseWrappers.put(address, rw);
		}
	}
}