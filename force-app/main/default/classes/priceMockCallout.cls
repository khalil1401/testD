@isTest
global class priceMockCallout implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(SapPricesMock.getSucess());
        response.setStatusCode(200);
        return response; 
    }
}