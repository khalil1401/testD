@isTest
public class AprovacionLicencias_Controller_Test {
	@testSetup
    static void setup()
    {
        Ciclo__c ciclo = new Ciclo__c();
        insert ciclo;
        List<Licencia__c> licencias = new List<Licencia__c>();
        for(integer i = 0; i < 10; i++)
        {
            Licencia__c licencia = Build.aLicencia().withCiclo(ciclo).build();
        	licencias.add(licencia);
        }
        insert licencias;
    }
    @isTest
    static void AlPedirListaDeLicencias_DevolverLasRelacionadasAlCiclo_Insertarlas()
    {
        Ciclo__c ciclo = [SELECT Id FROM Ciclo__c LIMIT 1];
        ApexPages.StandardController stdLead = new ApexPages.StandardController(ciclo);
        AprovacionLicencias_Controller instance = new AprovacionLicencias_Controller(stdLead);
        instance.getHaveRecords();
        
       	Test.startTest();
        List<Licencia__c> results = instance.getLicencias();
        for(Licencia__c licencia : instance.licencias)
        {
            licencia.Aprobado__c = true;
        }
        instance.sendApproves();
        Test.stopTest();
        
        System.assertEquals(results.size(), 10, 'Algo salio mal. Tenes ' + results.size() + ' licencias');
        results = [SELECT Id, Aprobado__c FROM Licencia__c WHERE Ciclo__c = :ciclo.Id];
        for(Licencia__c licencia : results)
        {
            System.assert(licencia.Aprobado__c, 'No esta aprobada');
        }
    }
    @isTest
    static void SiNoHayLicenciasRelacionadas_EnviarBooleanoParaRenderearOtraInterfaz()
    {
        Ciclo__c ciclo = new Ciclo__c();
        insert ciclo;
        ApexPages.StandardController stdLead = new ApexPages.StandardController(ciclo);
        AprovacionLicencias_Controller instance = new AprovacionLicencias_Controller(stdLead);
        
        
       	Test.startTest();
        List<Licencia__c> results = instance.getLicencias();
        for(Licencia__c licencia : instance.licencias)
        {
            licencia.Aprobado__c = true;
        }
        instance.sendApproves();
        Test.stopTest();
        
        System.assertEquals(results.size(), 0, 'Algo salio mal. Tenes ' + results.size() + ' licencias y no deberias tenerlas.');
        results = [SELECT Id, Aprobado__c FROM Licencia__c WHERE Ciclo__c = :ciclo.Id];
        System.assertEquals(results.size(), 0, 'Algo salio mal. Tenes ' + results.size() + ' licencias y no deberias tenerlas.');
        System.assert(!instance.getHaveRecords(), 'Algo salio mal. Esta dando true');
    }
    
}