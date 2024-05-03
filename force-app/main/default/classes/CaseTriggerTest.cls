@isTest
public class CaseTriggerTest  {
    final static Id RT_CASE_GESTION = Case.getSObjectType()
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Gestion')
        .getRecordTypeId();
    
    @testSetup
    static void setup() {
        SlaProcess slaProces = [
            SELECT Id, Name
            FROM SlaProcess
            WHERE IsActive = true
            LIMIT 1
        ];
        
        insert new SlaProcessId_by_name__c(
            Name = 'Consulta',
            SlaProcess_Id__c = slaProces.Id
        );
        
        Account anAccount = Build.anAccount()
            .withLastName('Test')
            .withAreaTerapeutica('Alergia')
            .build();
        insert anAccount;
        
        
        Case aCase = Build.aCase()
            .forAccount(anAccount)
            .withType('Consulta')
            .withStatus('Abierto')
            .build();
        insert aCase;
        
        List<SlaProcessId_by_name__c> config_Sla = new List<SlaProcessId_by_name__c> {
            Build.aSlaProcessIdByName()
                .withName('Consulta')
                .withSlaProcess_Id(slaProces.Id)
                .build(),
                
                Build.aSlaProcessIdByName()
                .withName('Reclamo')
                .withSlaProcess_Id(slaProces.Id)
                .build()
                };
                    
                    insert config_Sla;
    }
    
    @isTest
    static void ShouldCreateAnAssignmentDependingOnTheRecordWhenACaseIsCreatedWithCreationDateOneDayBeforeAndEndDate2048() {		
        List<Case> caseBD = [
            SELECT Id, Entitlement.SlaProcessId
            FROM Case
            WHERE Type = 'Consulta'
        ];
        
        List<Entitlement> EntitlementBD = [
            SELECT Id, SlaProcessId, StartDate, EndDate
            FROM Entitlement
            WHERE SlaProcessId = :caseBD[0].Entitlement.SlaProcessId
        ];
        
        Id consultaSla = SlaProcessId_by_name__c.getValues('Consulta').SlaProcess_Id__c;
        
        System.assertEquals(1, caseBD.size());
        System.assertEquals(consultaSla, caseBD[0].Entitlement.SlaProcessId);
        System.assertEquals(Date.today().addDays(-1), EntitlementBD[0].StartDate);
        System.assertEquals(Date.newInstance(2048, 01, 1), EntitlementBD[0].EndDate);		
    }
    
    /*@isTest
static void whenIUpdateTheStatusOfACaseToClose_ClosedAllTheMilestoneCorresponding() {
insert aCase;
Test.startTest();
aCase.Status = 'Cerrado';
update aCase;
Test.stopTest();

List<CaseMilestone> caseMilestone = [
SELECT Id, IsCompleted, CompletionDate, milestonetype.name
FROM CaseMilestone 
WHERE CaseId = :aCase.id 
];

System.assertEquals(1, caseMilestone.size());
System.assertEquals(Date.today(), caseMilestone[0].CompletionDate.date());
System.assert(caseMilestone[0].isCompleted);
}*/
    
    @isTest
    static void ifTheCaseClientIsUpdatedTheEntitlementFieldIsUpdated() { 	
        
        Case case1 = [
            SELECT Id, Type 
            FROM Case 
            WHERE Type='Consulta' 
            LIMIT 1
        ];
        
        SlaProcess  slaProces = [
            SELECT Id, Name
            FROM SlaProcess
            WHERE IsActive = true
            LIMIT 1
        ];
        
        Test.startTest();
        case1.Type = 'Reclamo';
        update case1;
        Test.stopTest();
        
        List<Case> aCaseBD = [
            SELECT Id, EntitlementId, AccountId, Entitlement.SlaProcessId
            FROM Case 
            WHERE Id = :case1.Id
        ];
        
        List<Entitlement> newEntitlements = new List<Entitlement>([
            SELECT Id 
            FROM Entitlement 
            WHERE AccountId = :aCaseBD[0].AccountId
            AND SlaProcessId = :slaProces.Id
        ]);
        
        Id reclamoSla = SlaProcessId_by_name__c.getValues('Reclamo').SlaProcess_Id__c;
        
        System.assert(!newEntitlements.isEmpty());
        System.assertEquals(1, newEntitlements.size());
        System.assertEquals(reclamoSla, aCaseBD[0].Entitlement.SlaProcessId);
    }	
    
    @isTest
    static void whenAClosedCaseWithGestionTypeIsCreated_theCantidadDeCasosDeRetiroDeActivosFieldInTheRelatedAccountShouldBeEqualToOne() {	
        
        List<Account> accList = [SELECT Id, Name FROM Account WHERE LastName='Test'];
        
        Case aCase = Build.aCase()
            .forAccount(accList[0])
            .withType('Gestión')
            .withStatus('Cerrado')
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withRecordType(RT_CASE_GESTION)
            .build();
        
        
        Test.startTest();
        insert aCase;
        Test.stopTest();
        
        Account accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertEquals(1, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
    }	
    
    @isTest
    static void whenACaseWithGestionTypeIsClosed_theCantidadDeCasosDeRetiroDeActivosFieldInTheRelatedAccountShouldBeEqualToOne() {	
        List<Account> accList = [SELECT Id, Name FROM Account WHERE LastName='Test'];
        
        Case aCase = Build.aCase()
            .forAccount(accList[0])
            .withType('Gestión')
            .withStatus('Abierto')
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withRecordType(RT_CASE_GESTION)
            .build();
        
        Case aCase2 = Build.aCase()
            .forAccount(accList[0])
            .withType('Gestión')
            .withStatus('Abierto')
            .withSubtipo('Comercial')
            .withMotivo('Faltan datos de contacto')
            .withRecordType(RT_CASE_GESTION)
            .build();
        insert aCase2;
        insert aCase;
        Account accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertNotEquals(1, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
        
        Test.startTest();
        aCase.Status = 'Cerrado';
        update aCase;
        Test.stopTest();
        
        accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertEquals(1, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
    }
    
    /*@isTest
static void whenTheAccountOfAClosedCaseWithGestionTypeIsChanged_theCantidadDeCasosDeRetiroDeActivosFieldInTheRelatedAccountShouldBeUpdated() {	
aCase.Status = 'Cerrado';
aCase.Type = 'Gestión';
aCase.Subtipo__c = 'Retiro de Activos';
aCase.Motivo__c = 'Alta/Fin de tratamiento';

insert aCase;
Account accountInDb = [
SELECT Cantidad_de_casos_de_retiro_de_activos__c
FROM Account
WHERE Id =:anAccount.Id
];

System.assertEquals(1, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);

Test.startTest();
aCase.AccountId = null;
update aCase;
Test.stopTest();

accountInDb = [
SELECT Cantidad_de_casos_de_retiro_de_activos__c
FROM Account
WHERE Id =:anAccount.Id
];

System.assertEquals(0, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
}*/
    
    @isTest
    static void whenAClosedCaseWithGestionTypeIsDeleted_theCantidadDeCasosDeRetiroDeActivosFieldInTheRelatedAccountShouldBeUpdated() {	
        List<Account> accList = [SELECT Id, Name FROM Account WHERE LastName='Test'];
        
        Case aCase = Build.aCase()
            .forAccount(accList[0])
            .withType('Gestión')
            .withStatus('Cerrado')
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withRecordType(RT_CASE_GESTION)
            .build();
        
        insert aCase;
        Account accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertEquals(1, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
        
        Test.startTest();
        delete aCase;
        Test.stopTest();
        
        accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertEquals(0, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
    }
    
    @isTest
    static void whenTwoClosedCasesWithGestionTypeIsCreated_theCantidadDeCasosDeRetiroDeActivosFieldInTheRelatedAccountShouldBeEqualToTwo() {	
        List<Account> accList = [SELECT Id, Name FROM Account WHERE LastName='Test'];
        
        Case aCase = Build.aCase()
            .forAccount(accList[0])
            .withType('Gestión')
            .withStatus('Cerrado')
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withRecordType(RT_CASE_GESTION)
            .build();
        
        Case otherCase = Build.aCase()
            .forAccount(accList[0])
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withType('Gestión')
            .withStatus('Cerrado')
            .withRecordType(RT_CASE_GESTION)
            .build();
        Test.startTest();
        insert new List<Case> { aCase, otherCase };
            Test.stopTest();
        
        Account accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertEquals(2, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
    }
    
    @isTest
    static void whenTwoClosedCaseWithGestionTypeWasDeleted_theCantidadDeCasosDeRetiroDeActivosFieldInTheRelatedAccountShouldBeUpdated() {	
        List<Account> accList = [SELECT Id, Name FROM Account WHERE LastName='Test'];
        
        Case aCase = Build.aCase()
            .forAccount(accList[0])
            .withType('Gestión')
            .withStatus('Cerrado')
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withRecordType(RT_CASE_GESTION)
            .build();
        
        Case otherCase = Build.aCase()
            .forAccount(accList[0])
            .withSubtipo('Retiro de Activos')
            .withMotivo('Alta/Fin de tratamiento')
            .withType('Gestión')
            .withStatus('Cerrado')
            .withRecordType(RT_CASE_GESTION)
            .build();
        
        insert new List<Case> { aCase, otherCase };
            
            Account accountInDb = [
                SELECT Cantidad_de_casos_de_retiro_de_activos__c
                FROM Account
                WHERE Id =:accList[0].Id
            ];
        
        System.assertEquals(2, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
        
        Test.startTest();
        delete new List<Case> { aCase, otherCase };
            Test.stopTest();
        
        accountInDb = [
            SELECT Cantidad_de_casos_de_retiro_de_activos__c
            FROM Account
            WHERE Id =:accList[0].Id
        ];
        
        System.assertEquals(0, accountInDb.Cantidad_de_casos_de_retiro_de_activos__c);
    }
    
    @isTest
    static void validateIfYoHaveAFormRelatedToTheCaseByWantingToTransferItOrChangeTheStatusToTrabajandoInBecOrRegularOrBabyAccount() {
        
        Account acc = Build.anAccountPacienteBestCare()
            .withLastName('Name Test')
            .withDNI('12346789')
            .build();
        
        insert acc;

        Case aCase = Build.aCase()
            .withType('Reclamo')
            .withStatus('Nuevo')
            .withSubtipo('Calidad')
            .withMotivo('Mal olor')
            .withRecordType(XappiaHelper.getRecordType('Case', 'Reclamo').Id)
            .forAccount(acc)
            .build();
        insert aCase;
        Boolean expectedExceptionThrown = false;    
        
        Test.startTest();
        try{
            aCase.Status = 'Trabajando';
            update aCase; 
        }
        catch(Exception e)
        {
            expectedExceptionThrown =  e.getMessage().contains('Para transferir o cambiar el status') ? true : false;    
        } 
        Test.stopTest();
        
        System.assertEquals(true, expectedExceptionThrown); 
    }
    
}