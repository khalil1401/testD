@istest
public class GeneradorEnvioSinCargoTest {
    @istest
    static void siSeQuiereGenerarUnXML(){
        
        Account testAcc1 = Build.anAccount().withLastName('test')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .build();
        
        insert testAcc1;
        
        Envio_sin_Cargo__c testEnvSCargo = new Envio_sin_Cargo__c();
        testEnvSCargo.Paciente__c = testAcc1.id;

        insert testEnvSCargo;
        
        Producto_de_envio__c prDeEnvio = new Producto_de_envio__c();
        prDeEnvio.Envio_sin_cargo__c = testEnvSCargo.id;
        
        insert prDeEnvio;
        
        Producto_de_envio__c prDeEnvio2 = new Producto_de_envio__c();
        prDeEnvio2.Envio_sin_cargo__c = testEnvSCargo.id;
        
        insert prDeEnvio2;
        
        Test.startTest();
        String respuesta = GeneradorDeEnvioSinCargoParaJitterbit.generarNuevosEnviosParaJiter(testEnvSCargo.id);
        Test.stopTest();
        
        List<Envio_sin_Cargo__c> listEnvios = [
            SELECT Id,Estado_del_envio__c,Name
            FROM Envio_sin_Cargo__c
            WHERE id =:testEnvSCargo.id
        ];
        
        System.assertEquals(1,listEnvios.size());
        System.assertEquals('Reservado',listEnvios.get(0).Estado_del_envio__c);
        system.assertEquals('XML generado para envio: '+listEnvios.get(0).name,respuesta);
    }
    
    
     @istest
    static void ErrorSiSeQuiereGenerarUnXML(){
        
        Account testAcc1 = Build.anAccount().withLastName('test')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .build();
        
        insert testAcc1;
        
        Envio_sin_Cargo__c testEnvSCargo = new Envio_sin_Cargo__c();
        testEnvSCargo.Paciente__c = testAcc1.id;

        insert testEnvSCargo;
        
        Test.startTest();
        String respuesta = GeneradorDeEnvioSinCargoParaJitterbit.generarNuevosEnviosParaJiter(testEnvSCargo.id);
        Test.stopTest();
        
        system.assertEquals('Error. No se pueden generar XML vacios',respuesta);
    }
    
    @IsTest
    static void ErrorSiYaEstaReservado(){        
        Account testAcc1 = Build.anAccount().withLastName('test')
            .withDNI('1234567')
            .withRecordTypeId(XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
            .build();
        
        insert testAcc1;
        
        Envio_sin_Cargo__c testEnvSCargo = new Envio_sin_Cargo__c();
        testEnvSCargo.Paciente__c = testAcc1.id;

        insert testEnvSCargo;
        
        Producto_de_envio__c prDeEnvio = new Producto_de_envio__c();
        prDeEnvio.Envio_sin_cargo__c = testEnvSCargo.id;
        
        insert prDeEnvio;
        
        Producto_de_envio__c prDeEnvio2 = new Producto_de_envio__c();
        prDeEnvio2.Envio_sin_cargo__c = testEnvSCargo.id;
        
        insert prDeEnvio2;
        GeneradorDeEnvioSinCargoParaJitterbit.generarNuevosEnviosParaJiter(testEnvSCargo.id);
        
        Test.startTest();
        String respuesta = GeneradorDeEnvioSinCargoParaJitterbit.generarNuevosEnviosParaJiter(testEnvSCargo.id);
        Test.stopTest();
        
        system.assertEquals('Ya se genero un XML para este Envío sin Cargo.',respuesta);
    }
}