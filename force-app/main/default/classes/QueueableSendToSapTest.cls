@isTest
public with sharing class QueueableSendToSapTest {
    @IsTest
    static void pruebaSimple(){
      Boolean colaCreada = false;
      ID jobID;

        Test.startTest();        
          QueueableSendToSap encolable  = new QueueableSendToSap();
          encolable.CreateCustomObject('ABC');
          jobID = System.enqueueJob(encolable);
        Test.stopTest();

      // System.debug('Informacion importante >>>> '+ [SELECT ApexClassId, Id, JobItemsProcessed, JobType, 
      // Status, NumberOfErrors, MethodName 
      // FROM AsyncApexJob]);
      if(jobID <> null){
        colaCreada = true;
      }
      System.assertEquals(true,colaCreada);
    }
}