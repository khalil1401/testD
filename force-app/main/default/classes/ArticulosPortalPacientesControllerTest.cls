@IsTest
public class ArticulosPortalPacientesControllerTest {

    @testSetup
    static void setup() {
        Knowledge__kav tecnicaBelleza = new Knowledge__kav();
        tecnicaBelleza.Title = 'tecnica';
        tecnicaBelleza.UrlName = 'tecnica';
        tecnicaBelleza.Descripcion__c = 'descripcion tecnica';
        tecnicaBelleza.Tipo_de_articulo__c = 'Técnicas de belleza (Oncología)';
        insert tecnicaBelleza;
 
        Knowledge__kav ejercicio1 = new Knowledge__kav();
        ejercicio1.Title = 'ejercicio1';
        ejercicio1.UrlName = 'ejercicio1';
        ejercicio1.Ejercicio__c = 'Tipo ejercicio';
        ejercicio1.Tipo_de_articulo__c = 'Ejercicios (Oncología)';
        insert ejercicio1;

        Knowledge__kav ejercicio2 = new Knowledge__kav();
        ejercicio2.Title = 'ejercicio2';
        ejercicio2.UrlName = 'ejercicio2';
        ejercicio2.Ejercicio__c = 'Tipo ejercicio';
        ejercicio2.Tipo_de_articulo__c = 'Ejercicios (Oncología)';
        insert ejercicio2;

        Knowledge__kav recetaOncologia = new Knowledge__kav();
        recetaOncologia.Title = 'recetaOncologia';
        recetaOncologia.UrlName = 'receta-oncologia';
        recetaOncologia.Tipo_de_articulo__c = 'Recetas (Oncología)';
        recetaOncologia.Tipo_de_receta__c = 'Sopas';
        insert recetaOncologia;

        Knowledge__kav recetaDisfagia = new Knowledge__kav();
        recetaDisfagia.Title = 'recetaDisfagia';
        recetaDisfagia.UrlName = 'receta-disfagia';
        recetaDisfagia.Tipo_de_articulo__c = 'Recetas (Disfagia)';
        recetaDisfagia.Tipo_de_receta__c = 'Sopas';
        insert recetaDisfagia;

        Knowledge__kav recetaAlergia = new Knowledge__kav();
        recetaAlergia.Title = 'recetaAlergia';
        recetaAlergia.UrlName = 'receta-alergia';
        recetaAlergia.Tipo_de_receta__c = 'Sopas';
        recetaAlergia.Tipo_de_articulo__c = 'Recetas (Alergia)';
        insert recetaAlergia;

        Knowledge__kav videoCetogenica = new Knowledge__kav();
        videoCetogenica.Title = 'videoCetogenica';
        videoCetogenica.UrlName = 'video-cetogenica';
        videoCetogenica.Tipo_de_articulo__c = 'Videos (Terapia Cetogénca)';
        insert videoCetogenica;

        Knowledge__kav recetaCetogenica = new Knowledge__kav();
        recetaCetogenica.Title = 'recetaCetogenica';
        recetaCetogenica.UrlName = 'receta-cetogenica';
        recetaCetogenica.Tipo_de_articulo__c = 'Recetas (Terapia Cetogénica)';
        recetaCetogenica.Tipo_de_receta__c = 'Sopas';
        insert recetaCetogenica;
    }

    @IsTest
    static void testSiConsultoLasTecnicasDeBellezaSeDebenDevolverCorrectamente(){

        Knowledge__kav articulo = [
            SELECT  Id, KnowledgeArticleId
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Técnicas de belleza (Oncología)'
            LIMIT 1
        ];

        KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);

        Test.startTest();
            List<Knowledge__kav> tecnicas = ArticulosPortalPacientesController.getTecnicasDeBellezaOncologia(); 
        Test.stopTest();

        System.assertEquals(1, tecnicas.size());

    }

    @IsTest
    static void testSiConsultoLosTiposDeEjercicioSeDebenDevolverCorrectamente(){

        List<Knowledge__kav> articulosEjercicios = [
            SELECT  Id, KnowledgeArticleId
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Ejercicios (Oncología)'

        ];

        for(Knowledge__kav articulo : articulosEjercicios){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<Knowledge__kav> ejercicios = ArticulosPortalPacientesController.getTiposDeEjerciciosOncologia(); 
        Test.stopTest();

        System.assertEquals(1, ejercicios.size());

    }

    @IsTest
    static void testSiConsultoLosEjercicioDeDeterminadoTipoSeDebenDevolverCorrectamente(){

        List<Knowledge__kav> articulosEjercicios = [
            SELECT  Id, KnowledgeArticleId
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Ejercicios (Oncología)'

        ];

        for(Knowledge__kav articulo : articulosEjercicios){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<Knowledge__kav> ejercicios = ArticulosPortalPacientesController.getEjercicios('Tipo ejercicio'); 
        Test.stopTest();

        System.assertEquals(2, ejercicios.size());

    }

    @IsTest
    static void testSiConsultoRecetasDeDisfagiaSeDebenDevolverCorrectamente(){

        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Disfagia)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<Knowledge__kav> ejerciciosDB = ArticulosPortalPacientesController.getRecetasDisfagia(); 
        Test.stopTest();

        System.assertNotEquals(0, ejerciciosDB.size());

    }

    @IsTest
    static void testSiConsultoTiposDeRecetasDeOncologiaSeDebenDevolverCorrectamente(){

        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Oncología)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposDeRecetaOncologia(); 
        Test.stopTest();

        System.assertNotEquals(0, tiposDeRecetas.size());

    }

    @IsTest
    static void testSiConsultoRecetasDeOncologiaSeDebenDevolverCorrectamente(){

        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Oncología)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposDeRecetaOncologia(); 
        List<Knowledge__kav> articulosDB = new List<Knowledge__kav>();

        Test.startTest();
            if (!tiposDeRecetas.isEmpty()) {
                articulosDB = ArticulosPortalPacientesController.getRecetasOncologia(tiposDeRecetas.get(0)); 
            }
        Test.stopTest();

        System.assertNotEquals(0, articulosDB.size());

    }

    @IsTest
    static void testSiConsultoRecetaDeOncologiaSeDebenDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Oncología)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposDeRecetaOncologia(); 
        List<Knowledge__kav> articulosDB = new List<Knowledge__kav>();
        if(!tiposDeRecetas.isEmpty()){
            articulosDB = ArticulosPortalPacientesController.getRecetasOncologia(tiposDeRecetas.get(0));
        }

        Test.startTest();
            Knowledge__kav articuloDB = ArticulosPortalPacientesController.getRecetaOncologia(articulosDB.get(0).Title);
        Test.stopTest();

        System.assertNotEquals(null, articuloDB);
    }

    @IsTest
    static void testSiConsultoDescubriRecetaDeOncologiaSeDebenDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Oncología)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<Knowledge__kav> articulosDB = ArticulosPortalPacientesController.getDescubriRecetasOncologia();
        Test.stopTest();

        System.assertNotEquals(0, articulosDB.size());
    }

    @IsTest
    static void testSiConsultoTiposDeRecetasDeAlergiaSeDebenDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Alergia)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposDeRecetaAlergia(); 
        Test.stopTest();

        System.assertNotEquals(0, tiposDeRecetas.size());
    }

    @IsTest
    static void testSiConsultoRecetasDeAlergiaSeDebenDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Alergia)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposDeRecetaAlergia(); 
        List<Knowledge__kav> articulosDB = new List<Knowledge__kav>();

        Test.startTest();
            articulosDB = ArticulosPortalPacientesController.getRecetasDeTipoAlergia(tiposDeRecetas.get(0));
        Test.stopTest();

        System.assertNotEquals(0, articulosDB.size());
    }

    @IsTest
    static void testSiConsultoRecetaDeAlergiaSeDebeDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c, Title
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Alergia)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposDeRecetaAlergia(); 
        List<Knowledge__kav> articulosDB = ArticulosPortalPacientesController.getRecetasDeTipoAlergia(tiposDeRecetas.get(0));

        Test.startTest();
            Knowledge__kav articuloDB = ArticulosPortalPacientesController.getRecetaAlergia(articulosDB.get(0).Title);
        Test.stopTest();

        System.assertNotEquals(null, articuloDB);
    }

    @IsTest
    static void testSiConsultoRecetasDeDisfagiaSeDebeDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c, Title
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Disfagia)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<Knowledge__kav> articulosDB = ArticulosPortalPacientesController.getRecetasDisfagia();
        Test.stopTest();

        System.assertNotEquals(0, articulosDB.size());
    }

    @IsTest
    static void testSiConsultoVideosCetogenicaSeDebeDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId, Tipo_de_receta__c, Title
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Videos (Terapia Cetogénca)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<Knowledge__kav> articulosDB = ArticulosPortalPacientesController.getVideosTerapiaCetogenica();
        Test.stopTest();

        System.assertNotEquals(0, articulosDB.size());
    }

    @IsTest
    static void testSiConsultoTiposDeRecetasCetogenicaSeDebenDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Terapia Cetogénica)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        Test.startTest();
            List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposRecetasTerapiaCetogenica(); 
        Test.stopTest();

        System.assertNotEquals(0, tiposDeRecetas.size());
    }

    @IsTest
    static void testSiConsultoRecetaCetogenicaSeDebenDevolverCorrectamente(){
        List<Knowledge__kav> articulos = [
            SELECT  Id, KnowledgeArticleId
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Terapia Cetogénica)'
        ];

        for(Knowledge__kav articulo : articulos){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        }

        List<String> tiposDeRecetas = ArticulosPortalPacientesController.getTiposRecetasTerapiaCetogenica(); 

        Test.startTest();
            List<Knowledge__kav> articulosDB = ArticulosPortalPacientesController.getRecetasTerapiaCetogenica(tiposDeRecetas.get(0));
        Test.stopTest();

        System.assertNotEquals(0, articulosDB.size());
    }

    @IsTest
    static void testSiIngresoElIdDeUnUsuarioSeDebenDevolverSusPedidos(){

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente; 

        Account pacienteDB = [
            SELECT  PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        User usuarioDePaciente = new User();
        usuarioDePaciente.ProfileId = profile.Id;
        usuarioDePaciente.Username = paciente.PersonEmail;
        usuarioDePaciente.Alias = '3243';
        usuarioDePaciente.Email = 'test@test.com';
        usuarioDePaciente.EmailEncodingKey = 'UTF-8';
        usuarioDePaciente.FirstName = paciente.FirstName;
        usuarioDePaciente.Lastname = paciente.LastName;
        usuarioDePaciente.LanguageLocaleKey = 'es';
        usuarioDePaciente.LocaleSidKey = 'es';
        usuarioDePaciente.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        usuarioDePaciente.ContactId = pacienteDB.PersonContactId;
        insert usuarioDePaciente;

        NIC_Envio__c envio = new NIC_Envio__c();
        envio.Cuenta__c = paciente.Id;
        envio.Fecha_Ingreso__c = '11/11/2021 17:04';
        envio.Fecha_Despacho__c = '11/11/2021 14:04';
        envio.Id_de_cuenta_SAP__c = paciente.Id + ' Name Test acc';
        envio.NIC__c = '751622656';
        insert envio;

        Test.startTest();
            List<NIC_Envio__c> enviosDB = ArticulosPortalPacientesController.getPedidos(usuarioDePaciente.Id);
        Test.stopTest();

        System.assert(!enviosDB.isEmpty());

    }
}