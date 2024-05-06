@isTest
public class BatchQuarter_Test {
        @testSetup
        private static void testSetup() {
            List<VisMed_Cuatrimestre__c> quarters = new List<VisMed_Cuatrimestre__c>();

            for(Integer i=0; i<10 ; i++){

                VisMed_Cuatrimestre__c newQuarter = new VisMed_Cuatrimestre__c();
                newQuarter.Fecha_inicio__c = System.today().addMonths(-10);
                newQuarter.Fecha_fin__c = System.today().addMonths(-i);
                quarters.add(newQuarter);
            }
            insert quarters;
        }
        @isTest
        public static void testDeleteOldQuarters(){

            Test.startTest();
                BatchQuarter batch = new BatchQuarter();
                Database.executeBatch(batch);
            Test.stopTest();

            List<VisMed_Cuatrimestre__c> quarters = [
                SELECT id,Fecha_fin__c
                FROM VisMed_Cuatrimestre__c
                ORDER BY Fecha_fin__c DESC
            ];

            System.assertEquals(10, quarters.size());
            System.assert(quarters[0].Fecha_fin__c> System.today());
        }
}