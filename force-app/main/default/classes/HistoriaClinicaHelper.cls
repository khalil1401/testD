public class HistoriaClinicaHelper {
    
    public static void makeAttachedPdf(Id recordId){
        Pagereference reportPage = Page.HistoriaClinica;
        reportPage.getParameters().put('id', recordId);
        
        
        List<Formulario__c> historiaClinica = [
            SELECT Id,Name
            FROM Formulario__c
            WHERE Id =:recordId
        ];
        
        Blob reportPdf;
        if(!Test.isRunningTest()){
            reportPdf = reportPage.getContentAsPDF();
        }
        else{
            reportPdf = Blob.valueOf('Test');
        }
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = reportPdf;
        cv.Title = historiaClinica.get(0).Name;
        cv.PathOnClient = historiaClinica.get(0).Name+'.pdf';
        
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        
        insert cdl;
    }
    
    public static void linkPdfHistoriaClinicaToAccountAndCase(Id recordId){
        
        List<ContentDocumentLink> links = [
            SELECT ID,ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            
        ];
        
        if(!links.isEmpty()){
            
            Formulario__c historiaClinica = [
                SELECT ID,Nombre_y_Apellido_del_Paciente__c,Caso__c
                FROM Formulario__c
                WHERE Id = : recordId
                LIMIT 1
            ];
            
            List<Case> relatedCase = [
                select id 
                from case 
                where id = :historiaClinica.Caso__c
            ];
            
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = links[0].ContentDocumentId;
            cdl.LinkedEntityId = historiaClinica.Nombre_y_Apellido_del_Paciente__c;
            // ShareType is either 'V', 'C', or 'I'
            // V = Viewer, C = Collaborator, I = Inferred
            cdl.ShareType = 'V';
            insert cdl;
            
            if(!relatedCase.isEmpty()){
                ContentDocumentLink cdlCase = new ContentDocumentLink();
                cdlCase.ContentDocumentId = links[0].ContentDocumentId;
                cdlCase.LinkedEntityId = relatedCase.get(0).id;
                cdlCase.ShareType = 'V';
                
                insert cdlCase;
            }
           
            
        }
    }
    
    public static Boolean noTienePdfHistoriaClinica(Id recordId,String title){
        system.debug(recordId);
        system.debug('title: '+title);
        String query = 'SELECT ID '+
            'FROM ContentDocumentLink '+
            'WHERE LinkedEntityId = :recordId';
        if(String.isNotBlank(title)){
            query +=' AND ContentDocument.Title = :title';
        }
        List<ContentDocumentLink> links = database.query(query);
        if(links.isEmpty()){
            return true;
        }
        return false;
    }
}