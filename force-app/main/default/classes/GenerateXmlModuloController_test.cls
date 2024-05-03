@isTest
public class GenerateXmlModuloController_test {
    
    @isTest
    static void siSeGeneraUnXMLSeActualizaElEstadoDelModuloDePaciente(){
        
        Account accTest = Build.anAccountPacienteBestCare()
            .withLastName('BestCare')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En tratamiento')
            .withSubestadoDePaciente('Tratamiento Efectivo')
            .build();
        accTest.N_SHIP_TO__c = '456789';
        
        insert accTest;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        accObraSocial.N_SOLD_TO__c = '789456';       
        insert accObraSocial;
        
        Tratamiento__c Tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(accTest)
            .build();
            Tratamiento.Area_terapeutica__c = 'Alergia';
        Tratamiento.Patologia__c = 'Asma';
        insert tratamiento;
        
        Modulo__c testModulo = new modulo__c();
        testModulo.Name = 'Alergia';
        testModulo.N_de_Material__c = 123456;
        insert testModulo;
        
        Product2 prdTest = new Product2();
        prdTest.Name = 'Producto prueba';
        
        insert PrdTest;
        
        
        Modulo_de_paciente__c mdpTest= Build.aModulodepaciente()
            .withDuracion(5)
            .withModulodesde(Date.newInstance(2020, 2, 13))
            .withEstado('Activo')
            .withCuenta(accTest)
            .build();
        mdpTest.Modulo__c= testModulo.id;
        mdpTest.Obra_Social_Tratamiento__c=tratamiento.id;
        mdpTest.Fecha_de_despacho__c = System.today();
        mdpTest.Valor_total_pesos__c = 4500;
        mdpTest.Nro_de_autorizacion__c = '12346578';
        
        insert mdpTest;
        
        Producto_de_modulo__c pdmTest = new Producto_de_modulo__c();
        pdmTest.Cantidad__c = '2';
        pdmTest.Formula__c = prdTest.id;
        pdmTest.Modulo_de_paciente__c = mdpTest.id;
        
        insert pdmTest;
        
        PageReference pageRef = Page.GenerateCsvFromModuloDePaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(mdpTest.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(mdpTest);
        
        Test.startTest();
        GenerateXmlModuloController gXml= new GenerateXmlModuloController(sc);
        gXml.insertXml();
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT id,Estado_de_modulo__c
            FROM Modulo_de_paciente__c
            WHERE id =:mdpTest.id];
        
        System.assertEquals('Reservado', mdpDb.Estado_de_modulo__c);
    }    
    
    
    @isTest
    static void siSeGeneraUnXMLperoFaltaAlgunoDeLosCamposObligatorios(){
        
        Account accTest = Build.anAccountPacienteBestCare()
            .withLastName('BestCare')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En tratamiento')
            .withSubestadoDePaciente('Tratamiento Efectivo')
            .build();
        
        insert accTest;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert accObraSocial;
        
        Tratamiento__c Tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(accTest)
            .build();
            Tratamiento.Area_terapeutica__c = 'Alergia';
            Tratamiento.Patologia__c = 'Asma';
        insert tratamiento;
        
        Modulo__c testModulo = new modulo__c();
        testModulo.Name = 'Alergia';
        insert testModulo;
        
        Product2 prdTest = new Product2();
        prdTest.Name = 'Producto prueba';
        
        insert PrdTest;
        
        
        Modulo_de_paciente__c mdpTest= Build.aModulodepaciente()
            .withDuracion(5)
            .withModulodesde(Date.newInstance(2020, 2, 13))
            .withEstado('Activo')
            .withCuenta(accTest)
            .build();
        mdpTest.Modulo__c= testModulo.id;
        mdpTest.Obra_Social_Tratamiento__c=tratamiento.id;
        mdpTest.Fecha_de_despacho__c = System.today();
        
        insert mdpTest;
        
        Producto_de_modulo__c pdmTest = new Producto_de_modulo__c();
        pdmTest.Cantidad__c = '2';
        pdmTest.Formula__c = prdTest.id;
        pdmTest.Modulo_de_paciente__c = mdpTest.id;
        
        insert pdmTest;
        
        PageReference pageRef = Page.GenerateCsvFromModuloDePaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(mdpTest.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(mdpTest);
        
        Test.startTest();
        GenerateXmlModuloController gXml= new GenerateXmlModuloController(sc);
        gXml.insertXml();
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT id,Estado_de_modulo__c
            FROM Modulo_de_paciente__c
            WHERE id =:mdpTest.id];
        
        System.assertNotEquals('Reservado', mdpDb.Estado_de_modulo__c);
    }    
    
    @isTest
    static void siSeIntentaGeneraUnXMLDuplicado(){
        
        Account accTest = Build.anAccountPacienteBestCare()
            .withLastName('BestCare')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En tratamiento')
            .withSubestadoDePaciente('Tratamiento Efectivo')
            .build();
        accTest.N_SHIP_TO__c = '456789';
        
        insert accTest;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        accObraSocial.N_SOLD_TO__c = '789456';       
        insert accObraSocial;
        
        Tratamiento__c Tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(accTest)
            .build();
            Tratamiento.Area_terapeutica__c = 'Alergia';
            Tratamiento.Patologia__c = 'Asma';
        insert tratamiento;
        
        Modulo__c testModulo = new modulo__c();
        testModulo.Name = 'Alergia';
        testModulo.N_de_Material__c = 123456;
        insert testModulo;
        
        Product2 prdTest = new Product2();
        prdTest.Name = 'Producto prueba';
        
        insert PrdTest;
        
        
        Modulo_de_paciente__c mdpTest= Build.aModulodepaciente()
            .withDuracion(5)
            .withModulodesde(Date.newInstance(2020, 2, 13))
            .withEstado('Activo')
            .withCuenta(accTest)
            .build();
        mdpTest.Modulo__c= testModulo.id;
        mdpTest.Obra_Social_Tratamiento__c=tratamiento.id;
        mdpTest.Fecha_de_despacho__c = System.today();
        mdpTest.Valor_total_pesos__c = 4500;
        mdpTest.Nro_de_autorizacion__c = '12346578';
        
        insert mdpTest;
        
        Producto_de_modulo__c pdmTest = new Producto_de_modulo__c();
        pdmTest.Cantidad__c = '2';
        pdmTest.Formula__c = prdTest.id;
        pdmTest.Modulo_de_paciente__c = mdpTest.id;
        
        insert pdmTest;
        
        Modulo_Jitterbit__c newModulo1 = new Modulo_Jitterbit__c();
        newModulo1.Modulo_de_paciente__c = mdpTest.id;
        newModulo1.Name = 'MDP - Producto test';
        newModulo1.Material__c = pdmTest.Id_de_SAP__c;
        
        insert newmodulo1;
        
        PageReference pageRef = Page.GenerateCsvFromModuloDePaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(mdpTest.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(mdpTest);
        
        Test.startTest();
        GenerateXmlModuloController gXml= new GenerateXmlModuloController(sc);
        gXml.insertXml();
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT id,Estado_de_modulo__c
            FROM Modulo_de_paciente__c
            WHERE id =:mdpTest.id];
        
        System.assertNotEquals('Reservado', mdpDb.Estado_de_modulo__c);
    }      
}