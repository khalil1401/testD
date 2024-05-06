/**
 * Company:      CloudGaia
 * Description:  REST Resource for Confirm.
 * Test Class:   SFCCConfirmHelper_Test
 */
@RestResource(urlMapping='/Confirm/*')
global with sharing class RESTConfirm {
    /**
     * @description doPost get Confirm payload from
     * SFCC and return a new JSON, with specified
     * attributes
     * @return   return response
     */
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        SFCCConfirmRequestWrapper rw = (SFCCConfirmRequestWrapper) JSON.deserialize(requestString, SFCCConfirmRequestWrapper.class);
        System.debug('## on RESTConfirm.doPost() method');

        System.debug('## rw: ' + rw);

        //Inicio de response
        String responseContentBody = '';
        RestResponse resp = RestContext.response;
        SFCCConfirmHelper confirmHelper = new SFCCConfirmHelper();

        try {
            /* En RW queda toda la data de la request. Hacer todas las validaciones y poner todo en el responseWrapper */
            System.debug('## on RESTConfirm.setUpData() method');
            confirmHelper.setUpData(rw);
            System.debug('## on RESTConfirm.validateRequiredFields() method');
            confirmHelper.validateRequiredFields();
            System.debug('## on RESTConfirm.reCheckProductStock() method');
            confirmHelper.reCheckProductStock();
            System.debug('## on RESTConfirm.recheckPolygonsCapacity() method');
            confirmHelper.reCheckPolygonsCapacity();

            // Armado de response SUCCESS
            System.debug('## on RESTConfirm.responseAndInsertData() method');
            responseContentBody = confirmHelper.responseAndInsertData();
        } catch(Exception e) {
            /* Armado de response FAIL */
            System.debug('## Exception has been thrown. e: ' + e.getMessage());
            responseContentBody = confirmHelper.responseAndInsertData();
        }

        resp.responseBody = Blob.valueOf(responseContentBody);
    }
}