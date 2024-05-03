public class ChangeOfProfessionalsController {

	
	public static Id recordTypeProfesionalSalud = XappiaHelper.getRecordType('Account', 'Profesional de la salud').Id;
	public static Id recordTypeOtroProfesional = XappiaHelper.getRecordType('Account', 'Otro profesional').Id;
    
	public Account acct {get;set;}
	public Boolean rend {get;set;}
	public List<WrapperAccount> accountList {get;set;}
	ApexPages.StandardSetController controller;
    
    
	public ChangeOfProfessionalsController(ApexPages.StandardSetController controller) {
		this.controller = controller;
		this.acct = (Account)controller.getRecord();
        //Aca la modificacion temporal
        getCuentas();
		
	}

	public List<Account> getSelected() {
		return controller.getSelected();
	}

	public List<WrapperAccount> getCuentas() {
	List<Account> listaSelecionada = getSelected();  
        if(accountList == NULL) {
            accountList = New List<WrapperAccount>();
            for(Account cuenta: [
				SELECT Id, FirstName, LastName 
				FROM Account WHERE Id = :listaSelecionada 
					AND (recordTypeId = :recordTypeProfesionalSalud OR recordTypeId = :recordTypeOtroProfesional)
			]) {
                accountList.add(New WrapperAccount(cuenta));
            }
        }

		if(accountList.size() == 0 || accountList.size() != listaSelecionada.size()) {
			ApexPages.Message msg = new ApexPages.Message(
				ApexPages.Severity.Error, 'Esta funcionalidad solo permite cambiar el propietario de Profesionales'
        	);
        	ApexPages.addMessage(msg);

			rend = false;
        	return null;
		} 

		rend = true;
		return accountList;
    }

	public PageReference save() {  
		List<Account> selectedAccounts = new List<Account>();
        for(WrapperAccount selectionAccount: getCuentas()) {
            if(selectionAccount.selected == true) {
                selectedAccounts.add(selectionAccount.cuenta);
            }
        }

		List<Account> changeVisitadorMedico = new List<Account>();
		for(Account changeAccount : selectedAccounts) {
			changeAccount.OwnerId = acct.Usuario_Visitador_medico__c;
			changeVisitadorMedico.add(changeAccount);
		}

		if(!changeVisitadorMedico.isEmpty()) {
			update changeVisitadorMedico;
		}
		
        return controller.cancel();    
    }

	public PageReference volver() {
		return controller.cancel();     
    }

	public class WrapperAccount {    
        public Account cuenta {get; set;}
        public Boolean selected {get; set;}
        public WrapperAccount(Account cuenta) {
            this.cuenta = cuenta;
            this.selected = true;
		}
    }

}