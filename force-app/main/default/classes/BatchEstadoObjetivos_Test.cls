@IsTest
public class BatchEstadoObjetivos_Test {
 
    @IsTest
    public static void testBatchEstadoObjetivoInactivo(){
        List<VisMed_Objetivo__c> VisMedList = new List<VisMed_Objetivo__c>();

        for(Integer i=0;i<3 ;i++){

            VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
            .withName('Objetivo Test'+i)
            .withVisMedFechaInicio(System.today().addDays(-3))
            .withVisMedFechaFin(System.today().addDays(-1))
            .build();
            VisMedList.add(obj);
        }

        insert VisMedList;

        Test.startTest();
            Database.executeBatch(new BatchEstadoObjetivos()); 
        Test.stopTest();

        System.assertEquals('Inactivo', getVisMedObjetivo()[0].Estado__c);
        System.assertEquals(3, getVisMedObjetivo().size());

    }

    @IsTest
    public static void testBatchEstadoObjetivoActivo(){
        
        VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(System.today())
        .withVisMedFechaFin(System.today().addDays(3))
        .build();
    
        insert obj;

        Test.startTest();
            Database.executeBatch(new BatchEstadoObjetivos()); 
        Test.stopTest();

        System.assertEquals('Activo', getVisMedObjetivo()[0].Estado__c);
    }

    public static List<VisMed_Objetivo__c> getVisMedObjetivo(){
        return [
            SELECT id ,Estado__c
            FROM VisMed_Objetivo__c
        ];
    }
}