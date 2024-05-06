@IsTest
public with sharing class BatchCountLicenciasTest {
    @TestSetup
    private static void setup() {
        UserRole portalRole = [
            SELECT Id
            FROM UserRole
            WHERE PortalType = 'None'
            LIMIT 1
        ];

        Profile profile1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
                OR Name = 'Administrador del sistema'
        ];

        User anUser = Build.aUser()
                            .withUsername(
                                'newuser' + String.valueOf(System.now().getTime() + (Math.random() * 10)) + '@testorg.com'
                            )               
                            .withEmail('owner@xappia.com')
                            .withAlias('owner')
                            .withLastName('Owner')
                            .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                            .withLocaleSidKey('es_AR')
                            .withCommunityNickname('prueba2.xappia')
                            .withEmailEncodingKey('ISO-8859-1')
                            .withProfileId(profile1.Id)
                            .withUserRoleId(portalRole)				
                            .withLanguageLocaleKey('es')
                            .build();           
        anUser.ManagerId = UserInfo.getUserId();
        anUser.IsActive = true;
        anUser.VisMed_ContrasenaApp__c = 'TestOwner';
        insert anUser;

        System.runAs(anUser) {
            Account account = Build.anAccount()
                                .withName('Institucion')					
                                .build();
            insert account;

            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Visitador Medico').getRecordTypeId();
            Contact apm = Build.aContact()
                            .withAccount(account)
                            .withFirstName('NameTwo')
                            .withLastName('LastnameTwo')
                            .build();     
            apm.RecordTypeId = recordTypeId;
            apm.VisMed_DNI__c = '23234324';
            apm.Sub_Equipo__c = 'Metabólicos y Dieta';
            insert apm;

            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
                                    .withFechaInicio(today.toStartOfMonth())
                                    .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
                                    .build();
            insert ciclo;

            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
                                                .withVisMedAPM(apm)
                                                .withVisMedCiclo(ciclo)
                                                .build();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;
        }
    }

    @IsTest
    public static void testDaysOfLicenseWithMotiveStudyDay() {
        List<Dan360_Licencia__c> updateLicencia = new List<Dan360_Licencia__c>();
        Dan360_Licencia__c licencia = createLicenceWithMotive('Día de estudio',0);
        licencia.Estado__c = 'Aprobada';
        updateLicencia.add(licencia);        
        update updateLicencia;

        Test.startTest();
        Database.executeBatch(new BatchCountLicencias());
        Test.stopTest();

        Dan360_Efectividad__c efectividad = [
            SELECT Id, Name, Dias_de_Licencia_Transcurridos__c, VisMed_Dias_de_Licencia_Unicos__c, Dias_feriados_Transcurridos__c
            FROM Dan360_Efectividad__c
            WHERE Id =: licencia.Efectividad__c
            LIMIT 1
        ];

        System.assertEquals(1, efectividad.Dias_de_Licencia_Transcurridos__c);
        System.assertEquals(0, efectividad.Dias_feriados_Transcurridos__c);
        System.assertEquals(1, efectividad.VisMed_Dias_de_Licencia_Unicos__c);
    }

    private static Dan360_Licencia__c createLicenceWithMotive(String motive, Integer fechaInicio) {
        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'LastnameTwo'
            LIMIT 1
        ];

        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today().addDays(fechaInicio),
            Fecha_de_Fin__c = Date.Today().addDays(fechaInicio),
            Efectividad__c = [SELECT Id FROM Dan360_Efectividad__c WHERE VisMed_APM__c =: apm.Id].Id,
            Motivo__c = motive,
            Estado__c = 'Pendiente',
            VisMed_APM__c = apm.Id,            
            RecordTypeId = recordTypeLicencia
        );
        insert licencia;

        return licencia;
    }
}