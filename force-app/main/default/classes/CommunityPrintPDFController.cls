public with sharing class CommunityPrintPDFController {
    
    @AuraEnabled
    public static WrapperPDF getPDFInfo(String formularioId){
        WrapperPDF pdfInfo = new WrapperPDF();
        
        List<Formulario__c> form = [
            SELECT Id, Name
            FROM Formulario__c
            WHERE Id = :formularioId
            LIMIT 1
        ];

        String pdfPageInfo = Test.isRunningTest()?
            'Los métodos definidos como TestMethod no admiten llamadas a getContent':
        	 EncodingUtil.base64Encode(new PageReference('/apex/communityPrintFormulario?id=' + formularioId).getContentAsPDF());
        
        pdfInfo.pdfInfoBase64 = pdfPageInfo;
        pdfInfo.formularioName = form[0].Name;
        
        return pdfInfo;
    } 
    
    public class WrapperPDF{
        @AuraEnabled public String pdfInfoBase64 {get; set;}
        @AuraEnabled public String formularioName {get; set;}
        public WrapperPDF(){
            pdfInfoBase64 = '';
            formularioName = '';
        }
    }
}