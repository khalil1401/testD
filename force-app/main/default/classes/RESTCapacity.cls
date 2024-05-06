/**
 * Company:      CloudGaia
 * Description:  REST Resource for Capacity.
 * Test Class:   SFCCCapacityHelper_Test
 */
@RestResource(urlMapping='/Capacity/*')
global with sharing class RESTCapacity {
    /**
     * @description doPost get Capacity payload from
     * SFCC and return a new JSON, with specified
     * attributes
     * @return   return response
     */
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        SFCCCapacityRequestWrapper rw = (SFCCCapacityRequestWrapper) JSON.deserialize(requestString, SFCCCapacityRequestWrapper.class);
        System.debug(rw);
        
        //Inicio de response
        String responseContentBody = '';
        RestResponse resp = RestContext.response;

        try{
            //En RW queda toda la data de la request.
            //Hacer todas las validaciones y poner todo en el responseWrapper
            SFCCCapacityHelper.setUpData(rw);
            SFCCCapacityHelper.getPolygonsData();
            SFCCCapacityHelper.calculatePossibleDays();
            SFCCCapacityHelper.noDuplicateOrders();
            SFCCCapacityHelper.polygonsFrequency();
            SFCCCapacityHelper.productStock();
            SFCCCapacityHelper.polygonsCapacity();

            //Armado de response SUCCESS
            responseContentBody = SFCCCapacityHelper.createResponse();
        }
        catch(exception e){
            //Armado de response FAIL
            System.debug('## EXCEPTION: ' + e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getLineNumber());
            responseContentBody = SFCCCapacityHelper.createResponse();
        }
        resp.responseBody = Blob.valueOf(responseContentBody);
    }
}