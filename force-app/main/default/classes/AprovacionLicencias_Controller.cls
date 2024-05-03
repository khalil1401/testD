public with sharing class AprovacionLicencias_Controller {
    public List<Licencia__c> licencias;
    public boolean haveRecords = false;
    public boolean todosAprobados {get;set;}
    public AprovacionLicencias_Controller(ApexPages.StandardController stdController)
    {
        String currentId = stdController.getId();
        todosAprobados = true;
        licencias = [SELECT Id, Name, 
                     Aprobado__c, Fecha_de_inicio__c,
                     Fecha_de_fin__c, Motivo__c, Duracion_de_Licencia__c 
                     FROM Licencia__c 
                     WHERE Ciclo__c =:currentId
                     ORDER BY Name];
        if(licencias.size() != null && licencias.size() > 0)
        {
            haveRecords = true;
            for(Licencia__c licencia : licencias)
            {
                if(!licencia.Aprobado__c)
                    todosAprobados = false;
            }
        }
    }
	public List<Licencia__c> getLicencias()
    {
        return licencias;
    }
   	public boolean getHaveRecords()
    {
        return haveRecords;
    }
    public void approveAll()
    {
        for(Licencia__c licencia : licencias)
        {
           	if(!licencia.Aprobado__c)
                licencia.Aprobado__c = true;
        }
      	sendApproves();
    }
    public void sendApproves()
    {
        update licencias;
    }
}