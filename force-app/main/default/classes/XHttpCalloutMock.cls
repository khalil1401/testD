@isTest
public class XHttpCalloutMock implements HttpCalloutMock {
	public static final String NOT_FOUND_ADDRESS = '404 not found'; 
	/**
	* Total amount of calls made to all callout services.
	*/
	public Integer callsMade;
	public Map<String, ResponseWrapper> responseWrappers;
	
	public HTTPRequest latestRequest;
	public List<HTTPRequest> receivedRequests;
	
	public XHttpCalloutMock() {
		callsMade = 0;
		receivedRequests = new List<HTTPRequest>();
		responseWrappers = new Map<String, ResponseWrapper>();
		
		//Make sure there is a 404 in case the address received doesn't match
		buildResponse().withStatus('404 not found').withStatusCode(404)
		.addForAddress(NOT_FOUND_ADDRESS); 
	}
	
	public HTTPResponse respond(HTTPRequest req) {
		latestRequest = req;
		receivedRequests.add(req);
		callsMade++;
		
		//Try to get the response for the address with parameters
		ResponseWrapper rw = responseWrappers.get(req.getEndpoint());
		if(rw == null) {
			//Try to get the response for the address without parameters
			rw = responseWrappers.get(req.getEndpoint().split('\\?')[0]);
			if(rw == null) {
				//Return address not found
				rw = responseWrappers.get(NOT_FOUND_ADDRESS);
			}
		}
		
		HTTPResponse res = rw.generateResponse(req);
		
		return res;
	}
	
	//=============================================
	public ResponseWrapperBuilder buildResponse() {
		return new ResponseWrapperBuilder(this);
	}
	
	public class ResponseWrapper {
		public Integer statusCode = 200;
		public String status = 'OK';
		public String body = '';
		public Boolean simulateNetworkError = false;
		public String exceptionMessage = 'err'; 
		public Map<String, String> responseHeaders = new Map<String, String>();
		
		//Extended for XML services with the same endpoint and different methods 
		public Boolean useDifferentMethods = false; 
		public String pathToMethodName;// = 'Body';
		public Map<String,ResponseWrapper> responseByMethodName;  
		
		public HTTPRequest latestRequest;
		public List<HTTPRequest> servedRequests = new List<HTTPRequest>();

		public ResponseWrapper(){}

		public ResponseWrapper( 
			String body, 
			Integer statusCode, 
			String status, 
			boolean simulate, 
			String exceptMessage
		){ 
			this.statusCode = statusCode;
			this.status = status;
			this.body = body;
			this.simulateNetworkError = simulate;
			this.exceptionMessage = exceptMessage;
		}
		
		//======================================================
		private HTTPResponse generateResponse(HTTPRequest req) {
			servedRequests.add(req);
			latestRequest = req;

			if(simulateNetworkError) {
				throw new CalloutException(exceptionMessage);
			}
			
			HTTPResponse res = new HTTPResponse();

			//Add headers in response
			if(!responseHeaders.isEmpty()) {
				for(String key :responseHeaders.keySet()) {
					res.setHeader(key, responseHeaders.get(key));
				}
			}

			//Extended for XML services with the same endpoint and different methods  
			if(!useDifferentMethods) {
				res.setBody(body);
				res.setStatusCode(statusCode);
				res.setStatus(status);
			} else { 
				dom.XmlNode methodContainerNode = XMLParser.getNode(req.getBody(),this.pathToMethodName);  
				if(methodContainerNode != null) {

					List<dom.XmlNode> childs = methodContainerNode.getChildren();

					if(childs != null && !childs.isEmpty()){

						String methodName = childs[0].getName();

						if(	String.isNotBlank(methodName)){ 
						ResponseWrapper respForMethod = responseByMethodName.get(methodName);  
							if(respForMethod != null){ 
								if(respForMethod.simulateNetworkError) {
									throw new CalloutException(respForMethod.exceptionMessage);
								} 
								res.setBody(respForMethod.body);
								res.setStatusCode(respForMethod.statusCode);
								res.setStatus(respForMethod.status);
							} else {
								res.setBody('');
								res.setStatusCode(404);
								res.setStatus('404 response not found for method name');
							}			  
						} else {
							res.setBody('');
							res.setStatusCode(404);
							res.setStatus(	'404 method name not found in the node');
						}		
					} else {
						res.setBody('');
						res.setStatusCode(404);
						res.setStatus('404 method node not found (the method name is correct?)');
					} 
				}  else {
					res.setBody('');
					res.setStatusCode(404);
					res.setStatus('404 method container node not found (the path is correct?)');
				}	
			}  
			return res;
		}
	}

	//===================================
	public class ResponseWrapperBuilder {
		ResponseWrapper rw = new ResponseWrapper();
		XHttpCalloutMock parent;
		
		public ResponseWrapperBuilder(XHttpCalloutMock parent) {
			this.parent = parent;
		}
		
		public ResponseWrapperBuilder withStatusCode(Integer value) {
			rw.statusCode = value;
			return this;
		}

		//Extended for XML services with the same endpoint and different methods  
		public ResponseWrapperBuilder withDifferentsResponseByMethodNameXML( 
			String method,   
			String responseBody,
			Integer statusCode,
			String status,
			Boolean simulate,
			String excepMessage
		) {
			if(!rw.useDifferentMethods) {
				rw.useDifferentMethods = true;
				rw.responseByMethodName = new Map<String,ResponseWrapper>(); 
			}

			rw.responseByMethodName.put( 
				method, 
				new ResponseWrapper( 
					responseBody,
					statusCode,
					status,
					simulate,
					excepMessage
				)
			); 
			return this;
		} 

		public ResponseWrapperBuilder withDifferentsResponseByMethodNameXML( 
			String method, 
			String responseBody,
			Integer statusCode
		) {
			if(!rw.useDifferentMethods) {
				rw.useDifferentMethods = true;
				rw.responseByMethodName = new Map<String,ResponseWrapper>(); 
			}
			rw.responseByMethodName.put( 
				method, 
				new ResponseWrapper( 
					responseBody,
					statusCode,
					'Ok',
					false,
					'err'
				)
			); 
			return this;
		} 

		public ResponseWrapperBuilder withPathToMethodNameXML(String value) {
			rw.pathToMethodName = value;
			return this;
		}

		public ResponseWrapperBuilder withStatus(String value) {
			rw.status = value;
			return this;
		}
		
		public ResponseWrapperBuilder withBody(String value) {
			rw.body = value;
			return this;
		}
		

		public ResponseWrapperBuilder withHeader(String key, String value) {
			rw.responseHeaders.put(key, value);
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