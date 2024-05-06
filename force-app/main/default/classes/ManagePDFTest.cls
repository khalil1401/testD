@isTest
public with sharing class ManagePDFTest {
    @isTest
    public static void grabPDFFromIntegration() {
        Pagereference page = Page.checkingAccountPDF;
        Test.setCurrentPage(page);
        ManagePDF controller = new ManagePDF();
        Apexpages.currentPage().getParameters().put('docNumber', '1502A00014362');
        Apexpages.currentPage().getParameters().put('docType', 'FCNUA');
        Test.setMock(WebServiceMock.class, new WSDLMethodsMock());
        Test.startTest();
            String pdfString = controller.getPDFFromIntegration2();
        Test.stopTest();
        System.debug(pdfString);
        System.assertEquals('abcdefg', pdfString, 'No trajo el pdf correcto');
    }
}