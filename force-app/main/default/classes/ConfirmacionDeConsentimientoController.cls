public class ConfirmacionDeConsentimientoController{
    Formulario__c hc{ get; set; }
    
    public boolean yaSeleccionado{ get; set; }
    
    public boolean agradecimiento{ get; set; }
    
    public String HCid{ get; set; }
    
    public String fecha{ get; set; }
    
    public String nombreCompleto{ get; set; }
    
    public String dni{ get; set; }
    
    public String direccion{ get; set; }
    
    public String provincia{ get; set; }
    
    public String medico{ get; set; }
    
    public String emailPaciente{ get; set; }
    
    public String celularPaciente{ get; set; }
    
    public String patologia{ get; set; }
    
    public String tipoDeacceso{ get; set; }
    
    public String nombreFirmante{ get; set; }
    
    public String dniFirmante{ get; set; }
    
    public String domicilioFirmante{ get; set; }
    
    public String emailFirmante{ get; set; }
    
    public String relacion{ get; set; }
    
    public String celularFirmante{ get; set; }
    
    public boolean checkRechazo{ get; set; }
    
    public boolean agradecimientoSinLink{ get; set; }
    
    public boolean respuestaYaRegistrada{ get; set; }
    
    public boolean esFirmante{ get; set; }
    
    public boolean acepto{ get; set; }
    
    public boolean error{ get; set; }
    
    public ConfirmacionDeConsentimientoController(){
        
        error = false;
        esFirmante = false;
        yaSeleccionado = true;
        agradecimiento = false;
        fecha = getFechaActual();
        HCid = Apexpages.currentPage().getParameters().get('hcid');
        if (HCid != null){
            hc = getHistoriaClinica(HCid);
            if (hc.Nombre_y_Apellido_del_Paciente__r.Consentimiento_ya_registrado__c){
                respuestaYaRegistrada = true;
            } else{
                respuestaYaRegistrada = false;
            }
            if (hc != null){
                nombreCompleto = hc.Nombre_y_Apellido_del_Paciente__r.name;
                dni = hc.Nombre_y_Apellido_del_Paciente__r.dni__c;
                direccion = hc.Nombre_y_Apellido_del_Paciente__r.direccion__c;
                provincia = hc.Nombre_y_Apellido_del_Paciente__r.Provincia_localidad__c;
                medico = hc.owner.name;
                emailPaciente = hc.Nombre_y_Apellido_del_Paciente__r.personEmail;
                celularPaciente = hc.Nombre_y_Apellido__r.phone;
                tipodeAcceso = hc.Via_de_acceso__c;
                patologia = hc.Patologia__c;
            }
            
        } else if(respuestaYaRegistrada==null){
            respuestaYaRegistrada = true;
        }
    }
    
    public void confirmacionDeFirma(){
        
        if (HCid != null){
            yaSeleccionado = false;
            agradecimiento = true;
            Account relatedAccount = [SELECT id, Estado_del_consentimiento__c
                                      FROM Account
                                      WHERE id = :hc.Nombre_y_Apellido_del_Paciente__c
                                      LIMIT 1];
            relatedAccount.Estado_del_consentimiento__c = 'Aceptado';
            relatedAccount.Consentimiento_ya_registrado__c = true;
            if (esFirmante && nombreFirmante != '' && dniFirmante != ''){
                insertFirmante(hc);
            }
            acepto = true;
            
            update relatedAccount;
            insertPDF();
        }
    }
    
    public void rechazoDeConsentimiento(){
        
        if (checkRechazo && HCid != null){
            yaSeleccionado = false;
            agradecimientoSinLink = true;
            Account relatedAccount = [SELECT id, Estado_del_consentimiento__c
                                      FROM Account
                                      WHERE id = :hc.Nombre_y_Apellido_del_Paciente__c
                                      LIMIT 1];
            relatedAccount.Estado_del_consentimiento__c = 'Rechazado';
            relatedAccount.Consentimiento_ya_registrado__c = true;
            if (esFirmante){
                insertFirmante(hc);
            }
            acepto= false;
            
            update relatedAccount;
            insertPDF();
        }
    }
    
    public Formulario__c getHistoriaClinica(String hcid){
        return [SELECT id, Nombre_y_Apellido_del_Paciente__c,Nombre_y_Apellido_del_Paciente__r.Consentimiento_ya_registrado__c, Nombre_y_Apellido_del_Paciente__r.name, Nombre_y_Apellido_del_Paciente__r.dni__c, Nombre_y_Apellido_del_Paciente__r.direccion__c, Nombre_y_Apellido_del_Paciente__r.Provincia_localidad__c, owner.name, Nombre_y_Apellido_del_Paciente__r.personEmail, Nombre_y_Apellido__r.phone, Via_de_acceso__c, Patologia__c
                FROM Formulario__c
                WHERE id = :HCid
                ORDER BY createdDate DESC
                LIMIT 1];
    }
    
    public PageReference descargarFormulario(){
        PageReference formularioDeConcentimiento = new PageReference('/apex/FormularioConsentimiento');
        formularioDeConcentimiento.setRedirect(true);		
        formularioDeConcentimiento.getParameters().put('name', nombreFirmante);
        formularioDeConcentimiento.getParameters().put('dn', dniFirmante);
        formularioDeConcentimiento.getParameters().put('dom', domicilioFirmante);
        formularioDeConcentimiento.getParameters().put('em', emailFirmante);
        formularioDeConcentimiento.getParameters().put('ace', String.valueOf(acepto));
        formularioDeConcentimiento.getParameters().put('ce', celularFirmante);
        formularioDeConcentimiento.getParameters().put('hcid', HCid);
        
        
        return formularioDeConcentimiento;
    }
    
    public String getFechaActual(){
        Datetime todayDateTime = System.today();
        String mes = getMonth(todayDateTime.month());
        
        return System.today().day()+' de ' + mes + ' del ' + System.today().year();
    }
    
    public void insertPDF(){
        
        Pagereference reportPage = Page.FormularioConsentimiento;
        reportPage.getParameters().put('hcid', HCid);
        reportPage.getParameters().put('name', nombreFirmante);
        reportPage.getParameters().put('dn', dniFirmante);
        reportPage.getParameters().put('dom', domicilioFirmante);
        reportPage.getParameters().put('em', emailFirmante);
        reportPage.getParameters().put('ce', celularFirmante);
        reportPage.getParameters().put('ace', String.valueOf(acepto));
        
        
        Blob reportPdf;
        if(!Test.isRunningTest()){ //Necesario ya que las clases de test no permiten: getContent()
            reportPdf = reportPage.getContentAsPDF();
        }
        else{
            reportPdf = Blob.valueOf('Test');
        }
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = reportPdf;
        cv.Title = hc.Nombre_y_Apellido_del_Paciente__r.Name + 
            ' - Consentimiento informado de tratamiento - ' + System.now();
        cv.PathOnClient = hc.Nombre_y_Apellido_del_Paciente__r.Name + 
            ' - Consentimiento informado de tratamiento - ' + System.now()+'.pdf';
        
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId
                                 FROM ContentVersion
                                 WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = hc.Nombre_y_Apellido_del_Paciente__c;
        cdl.ShareType = 'V';
        
        insert cdl;
    }
    
    public void insertFirmante(Formulario__c hc){
        
        Firmante_de_Consentimiento__c firmante = new Firmante_de_Consentimiento__c();
        firmante.Name = nombreFirmante;
        firmante.Celular__c = celularFirmante;
        firmante.Correo_electronico__c = emailFirmante;
        firmante.Domicilio__c = domicilioFirmante;
        firmante.Documento_del_firmante__c = dniFirmante;
        firmante.Historia_clinica__c = hc.id;
        firmante.Paciente__c = hc.Nombre_y_Apellido_del_Paciente__c;
        firmante.Relacion_con_el_paciente__c = relacion;
        insert firmante;
    }
    public String getMonth(Integer monthNumber){
        Map<String,String>  monthNameMap = new Map<String, String> {
            '1'=>'Enero', '2'=>'Febrero', '3'=>'Marzo', '4'=>'Abril', '5'=>'Mayo', '6'=>'Junio',
                '7'=>'Julio', '8'=>'Agosto', '9'=>'Septiembre','10'=>'Octubre', '11'=>'Noviembre', '12'=>'Diciembre'
                };
                    return monthNameMap.get(String.valueOf(monthNumber));
    }
}