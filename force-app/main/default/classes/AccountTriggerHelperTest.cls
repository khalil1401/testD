@isTest
public class AccountTriggerHelperTest {
    @testSetup
    private static void testSetup() {
        Id recordTypeProfesional = [
                    SELECT Id, Name, SobjectType,IsPersonType 
                    FROM RecordType 
                    WHERE SobjectType='Account' 
                    AND IsPersonType=True 
                    AND Name = 'Profesional de la Salud'
            ].Id;
            Account profesional = Build.aPersonalAccount()
            .withFirstName('Profesional') 
            .build();
            profesional.PAC_0_12_MESES_SEM_C_COB_SOC__c= '80-89';
            profesional.PAC_0_12_MESES_SEM_SIN_COB_SOC__c = '1-9';
            profesional.RecordTypeId = recordTypeProfesional;

        insert profesional;

        Account profesionalMetabolico = Build.aPersonalAccount()
            .withFirstName('Profesional Metabolico') 
            .build();
        profesionalMetabolico.KOL__c = 'KOL Nicho';
        profesionalMetabolico.RecordTypeId = recordTypeProfesional;
        insert profesionalMetabolico;

        Id recordTypeAlergia = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Alergia').getRecordTypeId();
        VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
            Profesional__c = profesional.id,                
            RecordTypeId = recordTypeAlergia
        );
        insert segmentacion;

        Id recordTypeMetabolicos = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Metabolicos').getRecordTypeId();
        VisMed_Segmentacion__c segmentacionMetabolicos = new VisMed_Segmentacion__c(
            Profesional__c = profesionalMetabolico.id,                
            RecordTypeId = recordTypeMetabolicos
        );
        insert segmentacionMetabolicos;
    }

    @isTest
    public static void whenInsertAnInstitucionalMustSaveCategoriaPrevious() {
       
        Id recordTypeInstitucion = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId();
        Account profesional = [
            SELECT Id, PAC_0_12_MESES_SEM_C_COB_SOC__c
            FROM Account
            WHERE FirstName = 'Profesional'
        ];
        // profesional.PAC_0_12_MESES_SEM_C_COB_SOC__c = '90-100';
        // profesional.PAC_0_12_MESES_SEM_SIN_COB_SOC__c = '10-19';
        profesional.Como_trabaja__c = 'Está formando equipo';
        // profesional.Promedio_de_pacientes_Nicho__c = 'Entre 1 y 5';
        Test.startTest();
            update profesional;
        Test.stopTest();
       
        VisMed_Segmentacion__c segmentacionToCompare = [
            SELECT ID, Categoria_Auxiliar__c, Categoria_Anterior__c
            FROM VisMed_Segmentacion__c
            WHERE Profesional__c = : profesional.Id            
        ];
        // Asserts
        system.assertEquals('A', segmentacionToCompare.Categoria_Auxiliar__c, 'Error al crear la segmentacion');
    }

    
    @isTest
    public static void whenChangeEdiCheckInParentAccountSucursalesMustChange() {
       
        Id recordTypeRetail = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Retail').getRecordTypeId();
        
        Account cuentaPadre = Build.anAccount()
                                    .withIdSap('0001')
                                    .withName('Dia Argentina S.A.')
                                    //.withRecordTypeId(recordTypeRetail)
                                    .withSalesDistric('Modern Trade')
                                    .withDistributionChannel('Venta Estándar')
                                    .build();
        cuentaPadre.Cuit__c = '30685849751';
        insert cuentaPadre;     
        
        Account cuentaHijo = Build.anAccount()
                                    .withIdSap('0002')
                                    .withName('Dia Argentina S.A.')
                                    //.withRecordTypeId(recordTypeRetail)
                                    .withSalesDistric('Modern Trade')
                                    .withDistributionChannel('Venta Estándar')
                                    .build();
        cuentaHijo.ParentId = cuentaPadre.Id;
        insert cuentaHijo;

        Account cuentaPadreSF = [SELECT Name, RecordTypeId, Cuit__c, ParentId, Cliente_EDI__c FROM Account WHERE Cuit__c = '30685849751'];
        cuentaPadreSF.Cliente_EDI__c = true;

        Test.startTest();
           update cuentaPadreSF;
        Test.stopTest();
        
        Account cuentaHijoToCheck = [SELECT Cliente_EDI__c FROM Account WHERE ParentId = :cuentaPadre.Id];
        System.assertEquals(true, cuentaHijoToCheck.Cliente_EDI__c, 'No cambio la marca en la sucursal correctamente.');
    }

    @isTest
    public static void whenCategoryInSegmentacionIsBlankFrecuenciaMustBeClean(){
        Id recordTypeMetabolicos = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Metabolicos').getRecordTypeId();
        Account cuenta = [SELECT id, KOL__c FROM Account WHERE FirstName = 'Profesional Metabolico'];
        cuenta.KOL__c = 'Sin Asignar';

        Test.startTest();
        Database.update(cuenta);
        Test.stopTest();

        VisMed_Segmentacion__c seg = [select id, Frecuencia__c, Categoria__c FROM VisMed_Segmentacion__c WHERE RecordTypeId = :recordTypeMetabolicos];
        System.debug(seg);

        System.assertEquals(null, seg.Frecuencia__c, 'La frecuencia no se borro');

    }
    //@isTest
    // public static void whenInsertAProfesionalAccountASegmentacionMustBeCreated() {
    //     List<VisMed_Segmentacion__c> segmentacionList = [
    //         SELECT ID
    //         FROM VisMed_Segmentacion__c            
    //     ];
    //     Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
    //     Account aPersonAccount = Build.aPersonalAccount()
    //     .withFirstName('Profesional')
    //     .withProfesionalActivo(true)
    //     .build();

    //     aPersonAccount.RecordTypeId = recordTypeProfesional;        
    //     // Actual test
    //     Test.startTest();
    //         insert aPersonAccount;
    //     Test.stopTest();

    //     List<VisMed_Segmentacion__c> segmentacionListToCompare = [
    //         SELECT ID, Profesional__c
    //         FROM VisMed_Segmentacion__c            
    //     ];
       
    //     // Asserts
    //     system.assertEquals(segmentacionList.size() + 5, segmentacionListToCompare.size(), 'Error al crear la segmentacion');
    //     system.assertEquals(aPersonAccount.Id, segmentacionListToCompare[0].Profesional__c, 'Error al crear la segmentacion');
       
    // }
}