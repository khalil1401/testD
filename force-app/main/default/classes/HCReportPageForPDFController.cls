public with sharing class HCReportPageForPDFController {
    
    public Pagereference armaryAdjuntarPdf(){

        Formulario__c historiaClinica = [
            SELECT Id, Name, Peso_ajustado__c,Nombre_y_Apellido_del_Paciente__c ,Peso_Estimado__c,Nombre_y_Apellido_del_Paciente__r.Nutricionista_Asignado__r.Name,
            Nombre_y_Apellido_del_Paciente__r.Enfermero_Asignado__r.Name,Nombre_y_Apellido_del_Paciente__r.Medico_Asignado__r.Name,Patologia__c,
            Nombre_y_Apellido_del_Paciente__r.Obra_social__pc,Nombre_y_Apellido_del_Paciente__r.Estado_de_paciente__c,Peso_actual_Talla__c, Talla__c, IMC__c,
            VGS__c, Circunferencia_del_brazo_cm__c, Percentilo_circunferencia_del_Brazo__c, Pliegue_tricipital__c, Percentilo_pliegue_tricipital__c, 
            area_muscular_del_brazo__c, Percentilo_Area_Muscular_del_Brazo__c, Edemas__c, Sarcopenia__c, Escara__c, Grado__c, Fecha_ultimo_recambio__c,
            Enteral__c,Requerimiento_calorico__c, Requerimiento_Proteico__c, Meta_nutricional__c, Modalidad__c, Aporte_cal_rico_enteral_Kcal_d_a__c,Edad__c,
            Aporte_v_a_oral_Kcal__c, Producto__c, Producto2__c, Producto_nro_3__c, Sistema_digestivo__c, Complicaciones_metabolicas__c, Comentarios__c,
            Fecha__c,Via_de_acceso__c,Complicacion_actual__c,Nombre_y_Apellido_del_Paciente__r.Name
            FROM Formulario__c 
            WHERE Id = :ApexPages.currentPage().getParameters().get('hcid')
        ];

        PageReference reportPage = Page.HcReportPage;
        reportPage.setRedirect(true);	
        reportPage.getParameters().put('hcid', historiaClinica.Id);
        Blob reportPdf;
        if(Test.isRunningTest()) { 
            reportPdf = blob.valueOf('Unit.Test');
          } else {
             reportPdf = reportPage.getContentAsPDF();
          }
        ContentVersion cv = new ContentVersion();
        cv.VersionData = reportPdf;
        cv.Title = historiaClinica.Name;
        cv.PathOnClient = historiaClinica.Name+'.pdf';
        
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = historiaClinica.Id;
        cdl.ShareType = 'V';
        
        insert cdl;

        return reportPage;
    }
}