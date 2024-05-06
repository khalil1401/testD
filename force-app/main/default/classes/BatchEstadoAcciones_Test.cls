@IsTest
public class BatchEstadoAcciones_Test {
 
    @TestSetup
    static void makeData(){

        VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(Date.today().toStartOfMonth())
        .withVisMedFechaFin(Date.Today().addMonths(3))
        .build();
        
        insert obj;

    }

    @IsTest
    public static void testBatchEstadoAccionActivo(){
    List<VisMed_Accion__c> VisMedList = new List<VisMed_Accion__c>();

    for(Integer i=0;i<3 ;i++){
        VisMed_Accion__c accion = Build.aVisMedAccion()
        .withVisMedObjetivo(getVisMedObj())
        .withVisMedFechaInicio(Date.today())
        .withVisMedFechaFin(Date.today().addDays(1))        
        .build();

        VisMedList.add(accion);
    }
        insert VisMedList;

        Test.startTest();
            Database.executeBatch(new BatchEstadoAcciones()); 
        Test.stopTest();

        System.assertEquals('Activo', getVisMedAccion()[0].Estado__c);
        System.assertEquals(3, getVisMedAccion().size());

    }

    @IsTest
    public static void testBatchEstadoAccionInactivo(){
        
        VisMed_Accion__c accion2 = Build.aVisMedAccion()
        .withVisMedObjetivo(getVisMedObj())
        .withVisMedFechaInicio(Date.today().addDays(5))
        .withVisMedFechaFin(Date.today().addDays(7))        
        .build();

        insert accion2;

        Test.startTest();
            Database.executeBatch(new BatchEstadoAcciones()); 
        Test.stopTest();

        System.assertEquals('Inactivo', getVisMedAccion()[0].Estado__c);
    }

    public static VisMed_Objetivo__c getVisMedObj(){
        return [
            SELECT id 
            FROM VisMed_Objetivo__c
            LIMIT 1
        ];
    }
    public static List<VisMed_Accion__c> getVisMedAccion(){
        return [
            SELECT id ,Estado__c
            FROM VisMed_Accion__c
        ];
    }
}