@IsTest
public class LookupComponentControllerTest {

    @testSetup
    static void setup() {
        Municipio__c municipio = new Municipio__c();
        municipio.Name = 'Municipio';
        municipio.Descripcion_Provincia__c = 'BUENOS AIRES';
        insert municipio;

        Localidad__c localidad = new Localidad__c();
        localidad.Name = 'Localidad';
        localidad.Municipio__c = municipio.Id;
        insert localidad;
    }

    @IsTest
    static void testSiConsultoLasLocalidadesDeUnMunicipioSeDevuelvenLosExistentes() {
        List<Municipio__c> municipios = [
            SELECT Id
            FROM Municipio__c
            LIMIT 1
        ];

        Test.startTest();
            List<Localidad__c> localidades = LookupComponentController.getLocalidades(municipios.get(0).Id);
        Test.stopTest();

        System.assertNotEquals(0, localidades.size(),
            'No se encontraron las localidades del municipio');
    }

    @IsTest
    static void testSiConsultoLosProfesionalesSeDevuelvenLosExistentes() {
        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Apellido')
            .build();
        insert profesional;

        Test.startTest();
            List<Account> profesionales = LookupComponentController.getProfesionales();
        Test.stopTest();

        System.assertNotEquals(0, profesionales.size(),
            'No se encontraron los profesionales esperados');
    }

    @IsTest
    static void testSiConsultoLasInstitucionesSeDevuelvenLasExistentes() {
        Account centroTratamiento = Build.anAccountInstitucion()
            .withName('Centro')
            .build();
        insert centroTratamiento;

        Test.startTest();
            List<Account> instituciones = LookupComponentController.getInstituciones();
        Test.stopTest();

        System.assertNotEquals(0, instituciones.size(),
            'No se encontraron las instituciones esperadas');
    }

    @IsTest
    static void testSiConsultoLasObrasSocialesSeDevuelvenLasExistentes() {
        Account os = Build.anAccountObrasocial()
            .withName('Obra Social')
            .build();
        insert os;

        Test.startTest();
            List<Account> obrasSociales = LookupComponentController.getObrasSociales();
        Test.stopTest();

        System.assertNotEquals(0, obrasSociales.size(),
            'No se encontraron las obras Sociales esperadas');
    }

}