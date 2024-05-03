@isTest
public class CustomRelatedListAccountControllerTest {

    @testSetup
	static void setup() {
        Account acc1 = Build.anAccountPacienteBestCare()
            .withLastName('defaultName 1')
            .withDNI('10000000')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .withFechaDeNacimiento(date.parse('01/06/2019'))
            .withTelefono('9115555555')
            .build();
        
        Account acc2 = Build.anAccountPacienteBestCare()
            .withLastName('defaultName 2')
            .withDNI('20000000')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .withFechaDeNacimiento(date.parse('01/07/2019'))
            .withTelefono('9116666666')
            .build();
        
        Account acc3 = build.anAccountBaby()
            .withLastName('value')
            .withDNI('36647895')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .build();
        List<Account> accsList = new List<Account>{acc1, acc2, acc3};
        insert accsList;
        
        Modulo_de_paciente__c modDePac1 = Build.aModulodepaciente()
            .withCuenta(acc1)
            .withEstado('Activo')
            .build();
        Modulo_de_paciente__c modDePac2 = Build.aModulodepaciente()
            .withCuenta(acc2)
            .withEstado('Activo')
            .build();
        
        List<Modulo_de_paciente__c> mdDePacList = new List<Modulo_de_paciente__c>{modDePac1, modDePac2};
        insert mdDePacList;
        
        Task tsk0 = Build.aTaskTarea()
            .withWhatId(acc1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk01 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk02 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk03 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk04 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk05 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk06 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk07 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk08 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk09 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk1 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk2 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk3 = Build.aTaskTarea()
            .withWhatId(modDePac1)
            .withCargaDeTareaEnOracle(true)
            .build();
        Task tsk4 = Build.aTaskTarea()
            .withWhatId(modDePac2)
            .withCargaDeTareaEnOracle(true)
            .build();
        
        List<Task> tsksList = new List<Task>{tsk0,  tsk01, tsk02, tsk03, tsk04, tsk05, tsk06, tsk07, tsk08, tsk09, tsk1, tsk2, tsk3, tsk4};
        insert tsksList;

	}

    @isTest
    public static void whenAnAccountRecordIsOpenTheVfShowsTheNumberOfRecordsOfThePaginationPlusAnAccountRecordOnlyInTheFirstPage(){
        Account acc1 = [SELECT Id FROM Account WHERE LastName =: 'defaultName 1' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc1);

        Test.startTest();
        CustomRelatedListAccountController openVf = new CustomRelatedListAccountController(sc);
        Test.stopTest();
        
        System.assertEquals(4, openVf.tskListToDisplay.size());
    }
    
    @isTest
    public static void whenAnAccountRecordIsOpenAndHasNoRelatedRecordsForTheVfCriteriaNoRecordsAreDisplayed(){
        Account acc3 = [SELECT Id FROM Account WHERE LastName =: 'value' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acc3);

        Test.startTest();
        CustomRelatedListAccountController openVf = new CustomRelatedListAccountController(sc);
        Test.stopTest();
        
        System.assert(
            openVf.tskListToDisplay.isEmpty(),
            '[!] Account ' + acc3.Id + ' has tasks.'
        );
    }
    
    @isTest
    public static void whenUserDoesClickOnNextButtonAndThereArePagesAHeadPageNumberMustIncreaseIn1(){
        Account acc1 = [SELECT Id FROM Account WHERE LastName =: 'defaultName 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acc1);
        CustomRelatedListAccountController openVf = new CustomRelatedListAccountController(sc);
        
        Test.startTest();
		openVf.next();
        Test.stopTest();
        
        System.assertEquals(2, openVf.navigation.pageNumber);
    }
    
    @isTest
    public static void whenUserDoesClickOnPreviousButtonAndThereArePagesBackPageNumberMustDecreaseIn1(){
        Account acc1 = [SELECT Id FROM Account WHERE LastName =: 'defaultName 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acc1);
        CustomRelatedListAccountController openVf = new CustomRelatedListAccountController(sc);
        openVf.next();
        
        Test.startTest();
        openVf.previous();
        Test.stopTest();
        
        System.assertEquals(1, openVf.navigation.pageNumber);
    }
    
    @isTest
    public static void whenUserChangeTheSizeOfThePageRecordsToDisplayMustChangeDueTheValueSelected(){
        Account acc1 = [SELECT Id FROM Account WHERE LastName =: 'defaultName 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acc1);
        CustomRelatedListAccountController openVf = new CustomRelatedListAccountController(sc);
        openVf.recordsPerPage = 10;
        
        Test.startTest();
        openVf.updatePageSize();
        Test.stopTest();
        
        System.assertEquals(11, openVf.tskListToDisplay.size());
    }
    
    @isTest
    public static void selectOptionMustDisplayInTheVfTheAmountOfOptionsAddedToTheMethodGetOptionsInTheController(){
        Account acc1 = [SELECT Id FROM Account WHERE LastName =: 'defaultName 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acc1);
        CustomRelatedListAccountController openVf = new CustomRelatedListAccountController(sc);
        
        Test.startTest();
        List<SelectOption> results = openVf.getItems();
        Test.stopTest();
        
        System.assertEquals(2, results.size());
    }

       
}