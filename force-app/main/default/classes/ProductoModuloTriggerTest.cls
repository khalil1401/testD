@isTest
private class ProductoModuloTriggerTest {
    
    public static List<Account> listNewAccounts = new List<Account> ();
    public static List<Product2> listNewProductos = new List<Product2> ();
    public static List<Modulo_de_paciente__c> listNewModuloPacientes = new List<Modulo_de_paciente__c> ();
    public static List<Producto_de_modulo__c> listNewProductoModulo = new List<Producto_de_modulo__c> ();
    public static String expectedResult;
    
    /* EL TRIGGER DE PRODUCTODEMODULO EN PRODUCCION ESTABA DESACTIVADO, LO ACTIVE NUEVAMENTE PERO COMENTE LA FUNCIONALIDAD VIEJA
@isTest private static void SeActivaUnProductoAsociadoAUnaCuenta() {

CreateSimpleScheme();

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}


@isTest private static void SeActivaVariosProductoAsociadoAUnaCuenta() {

CreateSimpleSchemeMultiProducts();

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);

}

@isTest private static void SeActivaVariosProductoAsociadoAUnaCuentaConVariosModulos() {

CreateSimpleSchemeMultiModulesAccount();

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);

}

@isTest private static void SeActivaVariosProductoAsociadoAUnaCuentaConVariosModulosYVariosProductos() {

CreateMultiScheme();

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}




@isTest private static void SeActivaProductoAsociadoAUnaCuentaConModuloInactivo() {

CreateSimpleScheme();

listNewModuloPacientes[0].Estado__c = 'Inactivo';
update listNewModuloPacientes;

listNewAccounts[0].Formulas_actuales__c = '';
update listNewAccounts;

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c,System.Label.testmsgValidNull);
}




@isTest private static void SeCreaUnModuloDeProductoAsociadoAUnaCuenta() {

CreateSimpleScheme();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();

expectedResult = expectedResult + '\r\n' + 'ProductName-P128, 8 Unidades';

Test.startTest();
insert mpd;
Test.stopTest();

List<Account> testAccount = QueryAccount();

System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}


@isTest private static void SeCreaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivos() {

CreateSimpleSchemeMultiProducts();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[2])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();

expectedResult = expectedResult + '\r\n' + listNewProductos[2].Name + ', 8 Unidades';

Test.startTest();
insert mpd;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}

@isTest private static void SeCreaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYUnoSoloProducto() {

CreateSimpleSchemeMultiModulesAccount();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();

expectedResult = listNewProductos[0].Name + ', 8 Unidades' + '\r\n' + expectedResult;

Test.startTest();
insert mpd;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}

@isTest private static void SeCreaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYVariosProductos() {

CreateMultiScheme();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();

expectedResult = listNewProductos[0].Name + ', 8 Unidades' + '\r\n' + expectedResult;

Test.startTest();
insert mpd;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
System.assertEquals(null, testAccount[1].Formulas_actuales__c,'Hay datos en la cuenta. Tiene que estar vacia.');
}


@isTest private static void SeCreaUnModuloDeProductoAsociadoAUnaCuentaConModuloInactivo() {

CreateSimpleScheme();
listNewModuloPacientes[0].Estado__c = 'Inactivo';
update listNewModuloPacientes;

listNewAccounts[0].Formulas_actuales__c = '';
update listNewAccounts;

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();

Test.startTest();
insert mpd;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testmsgValidNull);
}



@isTest private static void SeActualizoUnModuloDeProductoAsociadoAUnaCuenta() {

CreateSimpleScheme();

listNewProductoModulo[0].Cantidad__c = '10 Unidades';
expectedResult = 'ProductName-P128, 10 Unidades';

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}


@isTest private static void SeActualizoUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivos() {

CreateSimpleSchemeMultiProducts();

listNewProductoModulo[0].Cantidad__c = '10 Unidades';

expectedResult = 
'ProductName-P128, 10 Unidades' + '\r\n' + 'ProductName-O256, 3 Unidades' + '\r\n' + 'ProductName-I512, 4 Unidades';

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);

}

@isTest private static void SeActualizoUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYUnoSoloProducto() {

CreateSimpleSchemeMultiModulesAccount();

listNewProductoModulo[0].Cantidad__c = '10 Unidades';
expectedResult =
'ProductName-P128, 10 Unidades' + '\r\n' + 'ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades';

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c,System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}


@isTest private static void SeActualizoUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYVariosProductos() {

CreateMultiScheme();

listNewProductoModulo[0].Cantidad__c = '10 Unidades';
expectedResult = 'ProductName-O256, 3 Unidades' + '\r\n' + 'ProductName-P128, 10 Unidades' + '\r\n' + 'ProductName-I512, 4 Unidades';

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
System.assertEquals(null, testAccount[1].Formulas_actuales__c,'Hay datos en la cuenta. Tiene que estar vacia.');
}

@isTest private static void SeActualizoUnModuloDeProductoAsociadoAUnaCuentaConModuloInactivo() {

CreateSimpleScheme();
listNewModuloPacientes[0].Estado__c = 'Inactivo';
update listNewModuloPacientes;

listNewAccounts[0].Formulas_actuales__c = '';
update listNewAccounts;

listNewProductoModulo[0].Cantidad__c = '10 Unidades';

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c,System.Label.testmsgValidNull);
}

@isTest private static void SeActualizoUnModuloDeProductoAsociadoAUnaCuentaSinModulo() {

CreateSimpleScheme();
delete listNewModuloPacientes[0];

listNewAccounts[0].Formulas_actuales__c = '';
update listNewAccounts;

listNewProductoModulo[0].Cantidad__c = '10 Unidades';

Test.startTest();
update listNewProductoModulo;
Test.stopTest();

List<Account> testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testmsgValidNull);
}


@isTest private static void SeCreaYEliminaUnModuloDeProductoAsociadoAUnaCuenta() {

CreateSimpleScheme();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();

System.assertEquals(expectedResult + '\r\n' + 'ProductName-P128, 8 Unidades',
testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);

Test.startTest();
delete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c, System.label.testmsgNotMach);
}

@isTest private static void SeCreaYEliminoUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivos() {

CreateSimpleSchemeMultiProducts();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[2])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();
System.assertEquals(
expectedResult + '\r\n' + listNewProductos[2].Name + ', 8 Unidades',
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach
);

Test.startTest();
delete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c,System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}


@isTest private static void SeCreaYEliminaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYUnoSoloProducto() {

CreateSimpleSchemeMultiModulesAccount();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();
System.assertEquals(
'ProductName-P128' + ', 8 Unidades' + '\r\n' + expectedResult,
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach
);

Test.startTest();
delete mpd;
Test.stopTest();

testAccount = QueryAccount();

System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c, System.label.testmsgNotMach);
}




@isTest private static void SeCreaYEliminaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYVariosProductos() {

CreateMultiScheme();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();
System.assertEquals(
listNewProductos[0].Name + ', 8 Unidades' + '\r\n' + expectedResult,
testAccount[0].Formulas_actuales__c,
'Las formulas_actuales no son iguales entre la referencia y la extracción.'
);
System.assertEquals(null, testAccount[1].Formulas_actuales__c,System.Label.testmsgValidNull);

Test.startTest();
delete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c, System.label.testmsgNotMach);
System.assertEquals(null, testAccount[1].Formulas_actuales__c,System.Label.testmsgValidNull);
}


@isTest private static void SeCreaYEliminaUnModuloDeProductoAsociadoAUnaCuentaConModuloInactivo() {

CreateSimpleScheme();
listNewModuloPacientes[0].Estado__c = 'Inactivo';
update listNewModuloPacientes;

listNewAccounts[0].Formulas_actuales__c = '';
update listNewAccounts;

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;


List<Account> testAccount = QueryAccount();
System.assertEquals(null,testAccount[0].Formulas_actuales__c,System.Label.testmsgValidNull);

Test.startTest();
delete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testmsgValidNull);
}


/*
@isTest private static void SeCreaEliminaYRecuperaUnModuloDeProductoAsociadoAUnaCuenta() {

CreateSimpleScheme();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();
System.assertEquals(
expectedResult + '\r\n' + 'ProductName-P128, 8 Unidades',
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach
);

delete mpd;
testAccount = QueryAccount();
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c, System.label.testmsgNotMach);

Test.startTest();
undelete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult + '\r\n' + 'ProductName-P128, 8 Unidades',
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach
);
}
/*
@isTest private static void SeCreaEliminaYRecuperaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivos() {

CreateSimpleSchemeMultiProducts();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[2])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();
System.assertEquals(expectedResult + '\r\n' + listNewProductos[2].Name + ', 8 Unidades',
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach);

delete mpd;
testAccount = QueryAccount();
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);

Test.startTest();
undelete mpd;
Test.stopTest();

testAccount = QueryAccount();

System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals(expectedResult + '\r\n' + listNewProductos[2].Name + ', 8 Unidades', testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}

*/
    /*
@isTest private static void SeCreaEliminaYRecuperaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYUnoSoloProducto() {

CreateSimpleSchemeMultiModulesAccount();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;

List<Account> testAccount = QueryAccount();
System.assertEquals(
'ProductName-P128' + ', 8 Unidades' + '\r\n' + expectedResult,
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach
);

delete mpd;
testAccount = QueryAccount();
System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c, System.label.testmsgNotMach);

Test.startTest();
undelete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertNotEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testsmgInvalidNull);
System.assertEquals('ProductName-P128' + ', 8 Unidades' + '\r\n' + expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
}
*/
    
    
    /*
@isTest private static void SeCreaEliminaYRecuperaUnModuloDeProductoAsociadoAUnaCuentaConVariosModulosActivosYVariosProductos() {

CreateMultiScheme();

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();
insert mpd;


List<Account> testAccount = QueryAccount();
System.assertEquals(
listNewProductos[0].Name + ', 8 Unidades' + '\r\n' + expectedResult,
testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach
);

System.assertEquals(null, testAccount[1].Formulas_actuales__c, System.Label.testmsgValidNull);

delete mpd;
testAccount = QueryAccount();

System.assertEquals(expectedResult, testAccount[0].Formulas_actuales__c,System.label.testmsgNotMach);
System.assertEquals(null, testAccount[1].Formulas_actuales__c,System.Label.testmsgValidNull);

Test.startTest();
undelete mpd;
Test.stopTest();

testAccount = QueryAccount();

System.assertNotEquals(null, testAccount[0].Formulas_actuales__c,System.Label.testsmgInvalidNull);
System.assertEquals(listNewProductos[0].Name + ', 8 Unidades' + '\r\n' + expectedResult, testAccount[0].Formulas_actuales__c,
System.label.testmsgNotMach);
System.assertEquals(null, testAccount[1].Formulas_actuales__c, System.Label.testmsgValidNull);
}*/
    
    /*
@isTest private static void SeCreaEliminaYRecuperaUnModuloDeProductoAsociadoAUnaCuentaConModuloInactivo() {

CreateSimpleScheme();
listNewModuloPacientes[0].Estado__c = 'Inactivo';
update listNewModuloPacientes;

listNewAccounts[0].Formulas_actuales__c = '';
update listNewAccounts;

Producto_de_modulo__c mpd = Build.aProductodemodulo().withFormula(listNewProductos[0])
.withCantidad('8 Unidades').withModulodepaciente(listNewModuloPacientes[0]).build();

insert mpd;
List<Account> testAccount = QueryAccount();
System.assertEquals(null,testAccount[0].Formulas_actuales__c,System.Label.testmsgValidNull);


delete mpd;
testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testmsgValidNull);

Test.startTest();
undelete mpd;
Test.stopTest();

testAccount = QueryAccount();
System.assertEquals(null, testAccount[0].Formulas_actuales__c, System.Label.testmsgValidNull);
}*/
    /*
@IsTest static void MetodoGetPatientModulesActiveAndProductsActiveEnHelperConUnSetCompleto() {
CreateMultiScheme();
Test.startTest();
Set<Id> listIdAccounts = new Set<Id> (new Map<Id, Account> (listNewAccounts).keyset());
List<Modulo_de_paciente__c> testList = ProductoModuloHelper.GetPatientModulesActiveAndProducts(listIdAccounts);
Test.stopTest();
System.assertEquals(listNewModuloPacientes[0].Id, 
testList[0].Id,'No coinciden los IDs entre los modulos de referencia y el extraido.');
}


@IsTest static void MetodoGetPatientModulesActiveAndProductsActiveEnHelperConUnSetNulo() {
Test.startTest();
List<Modulo_de_paciente__c> testList = ProductoModuloHelper.GetPatientModulesActiveAndProducts(null);
System.assertEquals(null, testList, 
'Se encontro elementos en la lista cuando esta tiene que estar vacia.');
Test.stopTest();
}*/
    
    
    /*@IsTest static void MetodoGetPatientModulesActiveAndProductsActiveEnHelperConUnSetVacio() {
Test.startTest();
List<Modulo_de_paciente__c> testList = ProductoModuloHelper.GetPatientModulesActiveAndProducts(new Set<Id> ());
System.assertEquals(null, testList, 
'Se encontro elementos en la lista cuando esta tiene que estar vacia.');
Test.stopTest();
}*/
    /*
@IsTest static void MetodoGetListOfAccountFromIdsListProductsEnHelperConUnSetCompleto() {
CreateSimpleScheme();
Test.startTest();
List<Id> listIdProducts = new List<Id> (new Map<Id, Product2> (listNewProductos).keyset());
Set<id> testSet = ProductoModuloHelper.GetListSetOfAccountFromIdsListProducts(listIdProducts);
Set<Id> listIdAccounts = new Set<Id> (new Map<Id, Account> (listNewAccounts).keyset());
Test.stopTest();
System.assertEquals(listIdAccounts, testSet,
'No coinciden los IDs entre los modulos de referencia y el extraido.');
}

@IsTest static void MetodoGetListOfAccountFromIdsListProductsEnHelperConUnSetNulo() {
Test.startTest();
Set<id> testSet = ProductoModuloHelper.GetListSetOfAccountFromIdsListProducts(null);
System.assertEquals(null, testSet,
'Se encontro elementos en la lista cuando esta tiene que estar vacia.');
Test.stopTest();
}

@IsTest static void MetodoGetListOfAccountFromIdsListProductsEnHelperConUnSetVacio() {

Set<id> testSet = ProductoModuloHelper.GetListSetOfAccountFromIdsListProducts(new List<id> ());
System.assertEquals(null, testSet,
'Se encontro elementos en la lista cuando esta tiene que estar vacia.');
}

@IsTest static void MetodoSetActiveProductsInAccountsEnHelperConUnListaNula() {
Test.startTest();
ProductoModuloHelper.SetProductsInAccounts(null);
Test.stopTest();
}

@IsTest static void MetodoSetActiveProductsInAccountsEnHelperConUnListaVacia() {
Test.startTest();
ProductoModuloHelper.SetProductsInAccounts(new List<id> ());
Test.stopTest();
}


@IsTest static void MetodoSetActiveProductsInAccountsEnHelperConUnProductoNoActivo() {
CreateSimpleScheme();
listNewProductos[0].IsActive = false;

List<Id> listIdProducts = new List<Id> (new Map<Id, Product2> (listNewProductos).keyset());

Test.startTest();
ProductoModuloHelper.SetProductsInAccounts(listIdProducts);
Test.stopTest();

System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.Label.testmsgValidNull);
}
*/
    
    @IsTest static void MetodoSetFormulasActualesForListOfModuloDePacienteEnHelperConUnaCuentaconProductos(){
        
        CreateSimpleScheme();
        
        listNewAccounts[0].Formulas_actuales__c = '';
        update listNewAccounts;
        
        Set<Id> accountId = new Set<Id>();
        accountId.add(listNewAccounts[0].Id);
        
        Test.startTest();
        ProductoModuloHelper.UpdateFormulasActualesFromSetOfAccounts(accountId);
        Test.stopTest();
        
        listNewAccounts = [select id,Formulas_actuales__c from Account];
        System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
    } 
    
    @IsTest static void MetodoSetFormulasActualesForListOfModuloDePacienteEnHelperConUnaCuentaNula(){
        
        Test.startTest();
        ProductoModuloHelper.UpdateFormulasActualesFromSetOfAccounts(new Set<Id>());
        Test.stopTest();
    } 
    
    
    @IsTest 
    static void siSeInsertaUnNuevoProductoSeDebeCompletarELCampocoModuloTipoDeProductoDeModuloDePaciente(){
        Modulo__c mod = new Modulo__c();
        mod.name= 'Enteral Advanced';
        
        insert mod;
        
        Account testAccount = Build.anAccountPacienteBestCare()
            .withLastName('CuentaLastName')
            .withCanalParaConsumidorBaby('Farmacias')
            .withDNI('123456')
            .build();
        
        insert testAccount;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert accObraSocial;
        
        Tratamiento__c Tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(testAccount)
            .build();
        
        insert tratamiento;
        
        Modulo_de_paciente__c testMdp = Build.aModulodepaciente()
            .withCuenta(testAccount)
            .withEstado('Activo')
            .build();
        testMdp.Obra_Social_Tratamiento__c=tratamiento.id;
        insert testMdp;
        
        Product2 testProduc =  Build.aProduct2()
            .withName('ProductName-P128')
            .build();
        testProduc.Modulo__c = 'Enteral Advanced';
        insert testProduc;
        
        Producto_de_modulo__c  testpdm = Build.aProductodemodulo()
            .withFormula(testProduc)
            .withCantidad('1 Unidad')
            .withModulodepaciente(testMdp)
            .build();
        
        insert testpdm;
        
        Test.startTest();
        
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT Id, Modulo_tipo_de_producto__c,Modulo__r.Name
            FROM Modulo_de_paciente__c
            WHERE id= :testMdp.id
        ];
        
        System.assertEquals('Enteral Advanced', mdpDb.Modulo_tipo_de_producto__c);
        System.assertEquals('Enteral Advanced', mdpDb.Modulo__r.Name);
        
    } 

    @IsTest 
    static void siSeEliminaUnProductoSeDebeCompletarELCampocoModuloTipoDeProductoDeModuloDePaciente(){
        
        Account testAccount = Build.anAccountPacienteBestCare()
            .withLastName('CuentaLastName')
            .withCanalParaConsumidorBaby('Farmacias')
            .withDNI('123456')
            .build();
        
        insert testAccount;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert accObraSocial;
        
        Tratamiento__c Tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(testAccount)
            .build();
        
        insert tratamiento;
        
        Modulo__c moduloToTest = Build.aModulo()
            .withName('Alergia')
            .withDescripcion('Test')
            .build();
        insert moduloToTest;
        
        Modulo_de_paciente__c testMdp = Build.aModulodepaciente()
            .withCuenta(testAccount)
            .withEstado('Activo')
            .build();
        testMdp.Obra_Social_Tratamiento__c=tratamiento.id;
        insert testMdp;
        
        Modulo__c moduloToTest2 = Build.aModulo()
            .withName('Enteral Advanced')
            .withDescripcion('Despacho de productos para terapia nutricional: APLV/Alergias alimentarias múltiples Gold- oral h/10')
            .build();
        
        insert moduloToTest2;
        
        Product2 testProduc =  Build.aProduct2()
            .withName('ProductName-P128')
            .build();
        testProduc.Modulo__c = 'Enteral Advanced';
        insert testProduc;
        
        Product2 testProduc2 =  Build.aProduct2()
            .withName('ProductName-P129')
            .build();
        testProduc2.Modulo__c = 'Alergia';
        insert testProduc2;
        
        Producto_de_modulo__c testpdm = Build.aProductodemodulo()
            .withFormula(testProduc)
            .withCantidad('1 Unidad')
            .withModulodepaciente(testMdp)
            .build();
        
        insert testpdm;
        
        Producto_de_modulo__c  testpdm2 = Build.aProductodemodulo()
            .withFormula(testProduc2)
            .withCantidad('1 Unidad')
            .withModulodepaciente(testMdp)
            .build();
        
        insert testpdm2;
        
        Test.startTest();
        delete testpdm;
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT Id, Modulo_tipo_de_producto__c,Modulo__r.Name, modulo__c
            FROM Modulo_de_paciente__c
            WHERE id= :testMdp.id
        ];
        
        System.assertEquals('Alergia', mdpDb.Modulo_tipo_de_producto__c);
        System.assertEquals('Alergia', mdpDb.Modulo__r.Name);
    } 
    
    static public void CreateSimpleScheme() {
        
        listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
        
        insert listNewAccounts;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert accObraSocial;
        
        Tratamiento__c tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(listNewAccounts[0])
            .build();
        insert tratamiento;
        
        listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withObrasocialTratamiento(tratamiento.id).build());
        insert listNewModuloPacientes;
        
        listNewProductos.add(Build.aProduct2().withName('ProductName-P128').build());
        insert listNewProductos;
        
        listNewProductoModulo.add(
            Build.aProductodemodulo()
            .withFormula(listNewProductos[0])
            .withCantidad('1 Unidad')
            .withModulodepaciente(listNewModuloPacientes[0]).build()
        );
        insert listNewProductoModulo;
        expectedResult = 'ProductName-P128, 1 Unidad';
    }
    /*
static public void CreateSimpleSchemeMultiProducts() {

listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
insert listNewAccounts;

listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
insert listNewModuloPacientes;

listNewProductos.add(Build.aProduct2().withName('ProductName-P128').build());
listNewProductos.add(Build.aProduct2().withName('ProductName-O256').build());
listNewProductos.add(Build.aProduct2().withName('ProductName-I512').build());
insert listNewProductos;

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[0])
.withCantidad('2 Unidades')
.withModulodepaciente(listNewModuloPacientes[0]).build()
);

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[1])
.withCantidad('3 Unidades')
.withModulodepaciente(listNewModuloPacientes[0]).build()
);

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[2])
.withCantidad('4 Unidades')
.withModulodepaciente(listNewModuloPacientes[0]).build()
);

insert listNewProductoModulo;
expectedResult = 'ProductName-P128, 2 Unidades' + '\r\n' + 'ProductName-O256, 3 Unidades' + '\r\n' + 'ProductName-I512, 4 Unidades';
}

static public void CreateSimpleSchemeMultiModulesAccount() {

listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
insert listNewAccounts;

listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
insert listNewModuloPacientes;

listNewProductos.add(Build.aProduct2().withName('ProductName-P128').build());
insert listNewProductos;

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[0])
.withCantidad('2 Unidades')
.withModulodepaciente(listNewModuloPacientes[0]).build()
);

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[0])
.withCantidad('3 Unidades')
.withModulodepaciente(listNewModuloPacientes[1]).build()
);

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[0])
.withCantidad('4 Unidades')
.withModulodepaciente(listNewModuloPacientes[2]).build()
);

insert listNewProductoModulo;
expectedResult = 'ProductName-P128, 2 Unidades' + '\r\n' + 'ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades';
}

static public void CreateMultiScheme() {

listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastNameClear').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
insert listNewAccounts;

listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[1]).withEstado('Activo').build());
insert listNewModuloPacientes;

listNewProductos.add(Build.aProduct2().withName('ProductName-P128').build());
listNewProductos.add(Build.aProduct2().withName('ProductName-O256').build());
listNewProductos.add(Build.aProduct2().withName('ProductName-I512').build());
insert listNewProductos;

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[0])
.withCantidad('2 Unidades')
.withModulodepaciente(listNewModuloPacientes[0]).build()
);

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[1])
.withCantidad('3 Unidades')
.withModulodepaciente(listNewModuloPacientes[0]).build()
);

listNewProductoModulo.add(
Build.aProductodemodulo()
.withFormula(listNewProductos[2])
.withCantidad('4 Unidades')
.withModulodepaciente(listNewModuloPacientes[1]).build()
);

insert listNewProductoModulo;
expectedResult = 'ProductName-O256, 3 Unidades' + '\r\n' + 'ProductName-P128, 2 Unidades' + '\r\n' + 'ProductName-I512, 4 Unidades';
}

static List<Account> QueryAccount(){
return [Select Id,Formulas_actuales__c FROM Account WHERE Id=:listNewAccounts];
}
*/
}