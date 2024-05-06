@isTest
global class WSDLMethodsMock implements WebServiceMock {
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType){
            WSDLMethods.ConsultaUnDocumentoResponse_element response_x = new WSDLMethods.ConsultaUnDocumentoResponse_element();
            WSDLMethods.Respuesta respuestaToAdd = new WSDLMethods.Respuesta();
            WSDLMethods.ArrayOfResumen resumenes = new WSDLMethods.ArrayOfResumen();
            List<WSDLMethods.Resumen> listResumenes = new List<WSDLMethods.Resumen>();
            WSDLMethods.Resumen resumen = new WSDLMethods.Resumen();
            resumen.DocId = '';
            resumen.FechaPublicacion = '';
            resumen.ruta = '';
            resumen.PDFStream = 'abcdefg';
            resumen.Descripcion = '';
            resumen.IdProceso = '';
            resumen.CenEmi = '';
            resumen.NroComp = '';
            resumen.Tidocu = '';
            listResumenes.add(resumen);
            resumenes.Resumen = listResumenes;
            respuestaToAdd.Resumenes = resumenes;
            response_x.Respuesta = respuestaToAdd;
            response.put('response_x', response_x); 
        }
}