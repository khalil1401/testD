public with sharing class CreateContactAccountController {

    public Id IdAccount {get; set;}
    public Contacto_de_paciente__c contactoDePaciente {get; set;}
    
	public CreateContactAccountController() {
    	IdAccount = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(IdAccount)) {
        	ApexPages.Message mensajeError = new ApexPages.Message(
                ApexPages.Severity.ERROR,
                '¡Error al cargar datos del paciente!'
            );
			ApexPages.addMessage(mensajeError); 
        } else {
			contactoDePaciente = new Contacto_de_paciente__c();
        	contactoDePaciente.Paciente__c = IdAccount; 
        }
        
	}

    public PageReference guardar() {

        Database.SaveResult resultado = Database.insert(contactoDePaciente, false);
        if (!resultado.isSuccess()) {
			for (Database.Error msg : resultado.getErrors()) {
				ApexPages.Message mensajeError = new ApexPages.Message(
					ApexPages.Severity.ERROR,
					msg.getMessage()
				);
				ApexPages.addMessage(mensajeError);
			}
            return null;  
        }
        
        ApexPages.Message mensaje = new ApexPages.Message(
        	ApexPages.Severity.CONFIRM,
            '¡Se insertaron los datos correctamente!'
		);
		ApexPages.addMessage(mensaje);
		PageReference pagina = new PageReference('/' + contactoDePaciente.Id);
        return pagina;
    }

}