@isTest
public with sharing class CierreDeInternacionControllerTest {


    @TestSetup
    static void makeData(){

        Account anAccount = Build.anAccount()
        .withLastName('Test')
        .withAreaTerapeutica('Alergia')
        .build();
        anAccount.recordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Sanatorio').Id;
        insert anAccount;

        Internacion__c testInternacion = new Internacion__c();
        testInternacion.Paciente__c = anAccount.Id;
        testInternacion.Estado_de_Fin_Internaci_n__c = 'Internación Domiciliaria/3er nivel';
        insert testInternacion;

        ApexPages.StandardController sc = new ApexPages.StandardController(testInternacion);
        CierreDeInternacionController controller = new CierreDeInternacionController(sc);
        controller.internacion = testInternacion;
        
    }

    @isTest
    public static void testGetInternacion(){
        System.assertEquals(getInternacion().Id, CierreDeInternacionController.getInternacion(getInternacion().Id).Id);
    }

    @isTest
    public static void testCerrarInternacion(){
        CierreDeInternacionController.cerrarInternacion(
            getInternacion().Id, System.today(),
            CierreDeInternacionController.getPickListValues().get(0)
            );

        System.assertEquals(System.today(), getInternacion().Fecha_de_Fin_Internaci_n__c);
        System.assertEquals(System.today(), getInternacion().Paciente__r.Fecha_de_obito__c);
    }

    public static Internacion__c getInternacion(){
        return [
            SELECT id,Fecha_de_Fin_Internaci_n__c, Paciente__r.Fecha_de_obito__c
			FROM Internacion__c
        ];
    }
}