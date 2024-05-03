@isTest
public class InternacionTriggerTest {

    @TestSetup
    static void makeData(){

        Product2 productEnteral = Build.aProduct2().build();
        productEnteral.Producto_SAP__c = true;
        productEnteral.Modulo__c = 'Enteral Advanced';
        insert productEnteral;

        Modulo__c moduloEnteral = Build.aModulo()
        .withName('Enteral Advanced')
        .withDescripcion('Test')
        .build();
        insert moduloEnteral;

        Account accountTest = new Account();
        accountTest.LastName = 'Test acc';
        accountTest.recordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Sanatorio').Id;
        insert accountTest;
        
        Internacion__c internacionTest = new Internacion__c();
        internacionTest.Paciente__c = accountTest.Id;

        insert internacionTest;

        Producto_de_Internacion__c productTest = new Producto_de_Internacion__c();
        productTest.Internacion__c= internacionTest.Id;
        productTest.Producto__c = productEnteral.Id;
        insert productTest;
        
        Producto_de_Internacion__c productTestWithEndDate = new Producto_de_Internacion__c();
        productTestWithEndDate.Internacion__c= internacionTest.Id;
        productTestWithEndDate.Fecha_Fin_Producto__c = system.today().addDays(-3);
        
        insert productTestWithEndDate;
    }


    @isTest
    public static void if_An_Internacion_Is_CLosed_The_Related_Products_Must_Be_Closed() {

        Test.startTest();
        Internacion__c internacionToUpdate= getInternacionWithoutEndDate();
        internacionToUpdate.Fecha_de_Fin_Internaci_n__c = system.today();
        update internacionToUpdate;

        Test.stopTest();
        
        List<Producto_de_Internacion__c> productDB = [
            SELECT id,Fecha_Fin_Producto__c
            FROM Producto_de_Internacion__c
            WHERE Fecha_Fin_Producto__c = : internacionToUpdate.Fecha_de_Fin_Internaci_n__c
        ];
        
        System.assertEquals(System.today(), productDB[0].Fecha_Fin_Producto__c);
        System.assertEquals(1, productDB.size());
    }
    
    @isTest
    public static void if_an_account_already_has_an_active_internacion_it_cannot_create_another_one() {
        
        Internacion__c newInternacion = new Internacion__c();
        newInternacion.Paciente__c = getAccount().Id;
        
        Test.startTest();
        Boolean expectedExceptionThrown = false;
        try {
            insert newInternacion;
        }
        catch(Exception ex){
            expectedExceptionThrown =  ex.getMessage().contains('internación activa') ? true : false;
        }
        Test.stopTest();
        
        System.assertEquals(true, expectedExceptionThrown);
        
    }
    @isTest
    public static void if_An_Internacion_Is_Created_Closed_The_Related_Account_Must_Be_Updated() {

        Internacion__c internacionToUpdate= getInternacionWithoutEndDate();
        internacionToUpdate.Fecha_de_Fin_Internaci_n__c = system.today();
        update internacionToUpdate;

        Internacion__c internacionTest = new Internacion__c();
        internacionTest.Paciente__c = getAccount().Id;
        internacionTest.Estado_de_Fin_Internaci_n__c ='Alta';
        internacionTest.Fecha_de_Fin_Internaci_n__c = system.today();
        
        Test.startTest();
        insert internacionTest;
        Test.stopTest();

        System.assertEquals('No tratamiento', getAccount().Estado_de_paciente__c);
        System.assertEquals('Alta', getAccount().Subestado_del_paciente__c);
    }
        
    @isTest
    public static void if_An_Internacion_Is_Created_Open_The_Related_Account_Must_Be_Updated() {

        Internacion__c internacionToClose= getInternacionWithoutEndDate();
        internacionToClose.Fecha_de_Fin_Internaci_n__c = system.today();
        internacionToClose.Estado_de_Fin_Internaci_n__c ='Alta';
        update internacionToClose;

        Internacion__c internacionTest = new Internacion__c();
        internacionTest.Paciente__c = getAccount().Id;
        
        Test.startTest();
        insert internacionTest;
        Test.stopTest();

        System.assertEquals('En tratamiento', getAccount().Estado_de_paciente__c);
        System.assertEquals(null, getAccount().Subestado_del_paciente__c);
    }

        @isTest
    public static void if_An_Internacion_Is_Created_With_Check_internacion_domiciliaria_The_Related_Account_Must_Be_Updated() {

        Internacion__c internacionToClose= getInternacionWithoutEndDate();
        internacionToClose.Fecha_de_Fin_Internaci_n__c = system.today();
        internacionToClose.Estado_de_Fin_Internaci_n__c ='Alta';
        
        update internacionToClose;

        Internacion__c internacionTest = new Internacion__c();
        internacionTest.Paciente__c = getAccount().Id;
        internacionTest.Paciente_Aguarda_Internaci_n_domiciliari__c=true;

        Test.startTest();
        insert internacionTest;
        Test.stopTest();

        System.assertEquals('En tratamiento', getAccount().Estado_de_paciente__c);
        System.assertEquals('Aguarda Internación domiciliaria', getAccount().Subestado_del_paciente__c);
    }
    
    @isTest
    public static void if_An_Internacion_Is_updated_With_Check_internacion_domiciliaria_The_Related_Account_Must_Be_Updated() {

        Internacion__c internacionTest= getInternacionWithoutEndDate();
        internacionTest.Paciente_Aguarda_Internaci_n_domiciliari__c=true;

        Test.startTest();
        update internacionTest;
        Test.stopTest();

        System.assertEquals('En tratamiento', getAccount().Estado_de_paciente__c);
        System.assertEquals('Aguarda Internación domiciliaria', getAccount().Subestado_del_paciente__c);
    }
    
    @isTest
    public static void if_An_Internacion_Is_Closed_The_Related_Account_Must_Be_Updated() {

        Internacion__c internacionToUpdate= getInternacionWithoutEndDate();
        internacionToUpdate.Fecha_de_Fin_Internaci_n__c = system.today();
        internacionToUpdate.Estado_de_Fin_Internaci_n__c ='Alta';
        
        Test.startTest();
        update internacionToUpdate;
        Test.stopTest();

        System.assertEquals('No tratamiento', getAccount().Estado_de_paciente__c);
        System.assertEquals('Alta', getAccount().Subestado_del_paciente__c);
    }

    @isTest
    public static void if_An_Internacion_Is_Created_The_Related_Account_Must_Not_have_Fecha_de_baja() {

        Account accTest = getAccount();
        accTest.Fecha_de_obito__c = system.today();
        update accTest;

        Internacion__c internacionToClose= getInternacionWithoutEndDate();
        internacionToClose.Fecha_de_Fin_Internaci_n__c = system.today();
        internacionToClose.Estado_de_Fin_Internaci_n__c ='Alta';
        
        update internacionToClose;

        Internacion__c internacionTest = new Internacion__c();
        internacionTest.Paciente__c = accTest.Id;
        internacionTest.Paciente_Aguarda_Internaci_n_domiciliari__c=true;

        Test.startTest();
        insert internacionTest;
        Test.stopTest();

        Account accDb= getAccount();

        System.assertEquals(null, accDb.Fecha_de_obito__c);
    }

    public static Account getAccount(){
        return [
            SELECT id,Subestado_del_paciente__c,Estado_de_paciente__c,Fecha_de_obito__c
            FROM Account
            LIMIT 1
        ];
    }
    public static Internacion__c getInternacionWithoutEndDate(){
        return [
            SELECT id
            FROM Internacion__c
            WHERE Fecha_de_Fin_Internaci_n__c = NULL
            LIMIT 1
        ];
    }
}