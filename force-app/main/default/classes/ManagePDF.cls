public with sharing class ManagePDF {
    @TestVisible
    private static final ApiDanone__c SERVICE_CONFIG = ApiDanone__c.getInstance();

    public string getPDFFromIntegration2() {
        String docNumber;
        String docType;
        
        docNumber = ApexPages.currentPage().getParameters().get('docNumber');
        docType = ApexPages.currentPage().getParameters().get('docType');
                
        // String docType2 = System.currentPageReference().getHeaders().get('referer').substringBetween('docType','&docNumber');
        // String docNumber2 = System.currentPageReference().getHeaders().get('referer').substringAfter('docNumber');
       
        if(docNumber == null){
            docNumber = System.currentPageReference().getHeaders().get('referer').substringAfter('docNumber=');
        }
        if(docType == null) {
            docType = System.currentPageReference().getHeaders().get('referer').substringBetween('docType=','&docNumber');
        }

        System.debug(docNumber);
        System.debug(docType);
        //https://dev-danone360.cs61.force.com/s/checkingAccountPDF?invoice=a0T4C00000287HRUAY&docType=FCNUA&docNumber=1502A00014362
    
        String centroEmisor = docNumber.substring(0,4);
        String numeroDocumento = docNumber.substring(5,docNumber.length());
        
        WSDLMethods.wsNubaSoap service = new WSDLMethods.wsNubaSoap();
        service.inputHttpHeaders_x = new Map<String, String>{
            'user_key' => SERVICE_CONFIG.User_Key__c //'4b56130b643e90bd795d4b83612b49d0'
        };
        System.debug(service.inputHttpHeaders_x);
        WSDLMethods.Respuesta response = service.ConsultaUnDocumento(centroEmisor,numeroDocumento,docType );

        return response.Resumenes.Resumen[0].PDFStream;
    }
}