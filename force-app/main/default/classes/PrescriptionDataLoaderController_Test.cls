@isTest
public class PrescriptionDataLoaderController_Test {
    
    @TestSetup
    static void makeData(){
        Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        Account aPersonAccount = Build.aPersonalAccount()
        .withFirstName('Profesional')
        .withProfesionalActivo(true)
        .build();

        aPersonAccount.RecordTypeId = recordTypeProfesional;   
        insert aPersonAccount;
 
        VisMed_ProductoDeReceta__c product = Build.aPrescriptionProduct().Build();
        insert product;

        VisMed_Cuatrimestre__c newQuarter = new VisMed_Cuatrimestre__c();
		newQuarter.Fecha_inicio__c = System.today();
		newQuarter.Fecha_fin__c = System.today().addMonths(4);

		insert newQuarter;

    }

    @isTest
    public static void testPrescriptionDataLoaderControllerSuccessCSV(){
        String profesionalId= getRecord('Account').Id;
        String quarterId= getRecord('VisMed_Cuatrimestre__c').Id;
        String productoId= getRecord('VisMed_ProductoDeReceta__c').Id;
        String data = 'Profesional,Cuatrimestre,Producto,Cantidad\r\n'+ profesionalId+','+quarterId+','+productoId+',3,2\r\n' +
                                                                        profesionalId+','+quarterId+','+productoId+',4,1\r\n';   

        Test.startTest();       
            ServerResponse res=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
        Test.stopTest();

        List<VisMed_Receta__c> newPrescriptions = [
            SELECT Id
            FROM VisMed_Receta__c
        ];

        System.assertEquals(2, newPrescriptions.size());
        System.assertEquals('SUCCESS', res.state);
    }

    @isTest
    public static void testPrescriptionDataLoaderControllerErrorUploadCSV(){
        Test.startTest();       
            ServerResponse res=  PrescriptionDataLoaderController.saveData('');
        Test.stopTest();

        System.assertEquals('ERROR', res.state);
    }

    @isTest
    public static void testPrescriptionDataLoaderControllerSuccessCSVWithExistentVisMedReceta(){

        String profesionalId= getRecord('Account').Id;
        String quarterId= getRecord('VisMed_Cuatrimestre__c').Id;
        String productoId= getRecord('VisMed_ProductoDeReceta__c').Id;
        String data = 'Profesional,Cuatrimestre,Producto,Cantidad\r\n'+profesionalId+','+quarterId+','+productoId+',3,2\r\n';   

        VisMed_Receta__c vis = new VisMed_Receta__c();
        vis.Profesional_de_la_receta__c = profesionalId;
        vis.Cuatrimestre__c= quarterId;

        insert vis;

        Test.startTest();       
        ServerResponse res=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
        Test.stopTest();

        List<VisMed_Receta__c> newPrescriptions = [
            SELECT Id
            FROM VisMed_Receta__c
        ];

        System.assertNotEquals(0, newPrescriptions.size());
        System.assertEquals('SUCCESS', res.state);
    }

    @isTest
    public static void testPrescriptionDataLoaderControllerErrorInHeadersCSV(){

        String profesionalId= getRecord('Account').Id;
        String quarterId= getRecord('VisMed_Cuatrimestre__c').Id;
        String productoId= getRecord('VisMed_ProductoDeReceta__c').Id;
        String data = 'Profesional,Cuatrimestre,ErrorProducto,Cantidad\r\n'+profesionalId+','+quarterId+','+productoId+',3,2\r\n';   

        Test.startTest();  
            ServerResponse resErrorProd=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
            data = 'ErrorProfesional,Cuatrimestre,Producto,Cantidad\r\n'+profesionalId+','+quarterId+','+productoId+',3,2\r\n';   
            ServerResponse resErrorProf=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
            data = 'Profesional,ErrorCuatrimestre,Producto,Cantidad\r\n'+profesionalId+','+quarterId+','+productoId+',3,2\r\n';   
            ServerResponse resErrorQuarter=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
            data = 'Profesional,Cuatrimestre,Producto,ErrorCantidad\r\n'+profesionalId+','+quarterId+','+productoId+',3,2\r\n';   
            ServerResponse resErrorCantidad=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
        Test.stopTest();

        System.assertEquals('ERROR', resErrorProd.state);
        System.assertEquals('ERROR', resErrorProf.state);
        System.assertEquals('ERROR', resErrorQuarter.state);
        System.assertEquals('ERROR', resErrorCantidad.state);

    }

    @isTest
    public static void testPrescriptionDataLoaderControllerErrorInValuesCSV(){

        String profesionalId= getRecord('Account').Id;
        String quarterId= getRecord('VisMed_Cuatrimestre__c').Id;
        String productoId= getRecord('VisMed_ProductoDeReceta__c').Id;
        String data = 'Profesional,Cuatrimestre,Producto,Cantidad\r\n'+profesionalId+','+quarterId+','+productoId+',"error"\r\n';   

        Test.startTest();       
            ServerResponse res=  PrescriptionDataLoaderController.saveData(JSON.serialize(data));
        Test.stopTest();

        System.assertEquals('ERROR', res.state);

    }

    private static SObject getRecord(String ObjectType){
        String query = 'SELECT Id FROM '+ObjectType + ' LIMIT 1';
            return Database.query(query);
        }
}