@isTest
public class RenovationOSPECONControllerTest {
    public static String str =JSON.serialize('ID_de_paciente__c,DNI\nP-039359,16656\nP-039190,321324');


    @TestSetup
    static void makeData(){

        Account acc1 = Build.anAccountPacienteBestCare()
            .withFirstName('test4')
            .withLastName('Names Test1')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')				   
            .build();
            acc1.DNI__c= '321324';
            acc1.Canal_para_Consumidor_Baby__c ='Farmacias';

        Account acc2 = Build.anAccountPacienteBestCare()
            .withFirstName('test4')
            .withLastName('Name Test2')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')				   
            .build();
            acc2.Modulo_hasta__c = System.today();
            acc2.DNI__c= '16656';
            acc2.Canal_para_Consumidor_Baby__c ='Farmacias';

        insert new List<Account>{acc1,acc2};
    }


    @isTest
    public static void testCSVLoad(){

        Test.startTest();
            List<Account> accs= RenovationOSPECONController.updateAccounts(str);
        Test.stopTest();

        System.assertEquals(2,accs.size());
      }
}