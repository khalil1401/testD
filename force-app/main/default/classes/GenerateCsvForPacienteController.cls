public class GenerateCsvForPacienteController {
    public String namePaciente{ get; set; }
    public Id IdDePaciente{ get; set; }
    public Account acc { get; set; }
    public ApexPages.StandardController sctrl;
    public boolean flagCSV{ get; set; }
    public boolean telephoneChar;
    public boolean referenciaChar;
    public boolean direccionChar;
    public boolean validateOs;
    public Long timeRemaining;
    public boolean addError;
    
    public GenerateCsvForPacienteController(ApexPages.StandardController controller) {
        addError =false;
        telephoneChar= false;
        referenciaChar= false;
        direccionChar= false;
        validateOs = false;
        this.sctrl = controller; 
        acc =  (Account) controller.getRecord();
        IdDePaciente = acc.Id;
        namePaciente = acc.NombreSAP__c;
        flagCSV = false;
        
    }
    public PageReference back()
    {
        PageReference cancel = sctrl.cancel();
        return cancel;
    }
    public void generateCsv(){
        /*El boton trabaja en conjunto con la integracion con jitterbit que setea el campo: Listo para jitterbit*/
        if(acc.Listo_para_Jitterbit__c){
            Long dt1Long = System.now().getTime();
            Long dt2Long = (Long)acc.Horario_de_ultimo_CSV__c;
            Long milliseconds = dt1Long - dt2Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            timeRemaining = 40 - minutes;
            
            if(timeRemaining<0){
                acc.addError('El CSV ya fue generado, esperando actualización');
                addError =true;
            }else{
                acc.addError('El CSV ya fue generado, volvera a estar disponible en: '+ timeRemaining + ' minutos');
            }
        }
        else{
            Id recordTypeIdBec = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;
            if(recordTypeIdBec == acc.RecordTypeId &&
               acc.Obra_social__pc== null &&
               acc.SalesGroup_paciente__c==null
              ){
                  validateOs = true;
              }
            /*Validacion de caracteres*/
            if(acc.Phone !=null){
                telephoneChar = acc.Phone.toLowerCase().containsAny('úóíéáñ') || acc.Phone.contains('  ');
            }
            if(acc.Referencia__c !=null){
                referenciaChar = acc.Referencia__c.toLowerCase().containsAny('úóíéáñ') || acc.Referencia__c.contains('  ');
            }
            if(acc.Direccion__c !=null){
                direccionChar = acc.Direccion__c.toLowerCase().containsAny('úóíéáñ') || acc.Direccion__c.contains('  ');
            }
            
            if(telephoneChar || referenciaChar || direccionChar){
                acc.addError(Label.Error_para_cuenta);
                flagCSV =false;
            }
            if(validateOs){
                acc.addError(Label.Error_para_cuenta_obra_social);  
                flagCSV =false;
            }
            if(!telephoneChar && 
               !referenciaChar && 
               !direccionChar&&
               !validateOs)
            {
                flagCSV =true;
                acc.Listo_para_Jitterbit__c = true;
                acc.Horario_de_ultimo_CSV__c = System.now().getTime();
                
                update acc;
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'CSV generado para paciente: '+namePaciente));
            }
        }
    } 
}