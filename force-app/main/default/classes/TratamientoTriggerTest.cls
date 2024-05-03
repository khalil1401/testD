@isTest
public class TratamientoTriggerTest {

    @isTest
    static void siSeInsertaUnNuevoTratamientoSeDesactivanLosOtrosYseSeteaLaObraSocialEnCuenta(){
        
        Account accTest = New Account();
      	accTest.LastName = 'test Name';  
      
        insert accTest;
        
        Account obraSocialTest = Build.anAccountObrasocial()
            .Build();
        obraSocialTest.name = 'test ob';
        insert obraSocialTest;
        
        Tratamiento__c tratTest1 = new Tratamiento__c();
        tratTest1.Cuenta__c = accTest.id;
        tratTest1.Activo__c = true;
        tratTest1.Obra_social__c = obraSocialTest.id;
        
        insert tratTest1;
        
        Tratamiento__c tratTest2 = new Tratamiento__c();
        tratTest2.Cuenta__c = accTest.id;
        tratTest2.Activo__c = true;
        tratTest2.Obra_social__c = obraSocialTest.id;
        
        insert tratTest2;
 
        Test.startTest();
        
        Tratamiento__c tratTest = new Tratamiento__c();
        tratTest.Cuenta__c = accTest.id;
        tratTest.Activo__c = true;
        tratTest.Obra_social__c = obraSocialTest.id;
        
        insert tratTest;
        
        Test.stopTest();
        
        Account accDB = [
            SELECT id, Obra_social__pc
            FROM Account
            WHERE id =:accTest.id
        ];
        
        List<Tratamiento__c> tratListDb = [
            SELECT id , Activo__c
            FROM Tratamiento__c
            WHERE Cuenta__c = :accTest.id
        ];

          System.assertEquals(obraSocialTest.id, accDB.Obra_social__pc);
          System.assertEquals(false, tratListDb.get(0).Activo__c);
          System.assertEquals(false, tratListDb.get(1).Activo__c);
    }
    
    
    @isTest
    static void siSeActualizaLaObraSocialDelTratamientoSeModificaElLookupEnCuenta(){
        
        Account accTest = New Account();
      	accTest.LastName = 'test Name';  
      
        insert accTest;
        
        Account obraSocialTest = Build.anAccountObrasocial()
            .Build();
        obraSocialTest.name = 'test ob';
        
        insert obraSocialTest;
        
        Account obraSocialTest2 = Build.anAccountObrasocial()
            .Build();
        obraSocialTest2.name = 'test ob2';
        
        insert obraSocialTest2;
        
        Tratamiento__c tratTest1 = new Tratamiento__c();
        tratTest1.Cuenta__c = accTest.id;
        tratTest1.Activo__c = true;
        tratTest1.Obra_social__c = obraSocialTest.id;
        
        insert tratTest1;
        
        Tratamiento__c tratTest2 = new Tratamiento__c();
        tratTest2.Cuenta__c = accTest.id;
        tratTest2.Activo__c = true;
        tratTest2.Obra_social__c = obraSocialTest.id;
        
        insert tratTest2;
 
        Test.startTest();
        
        tratTest2.Obra_social__c = obraSocialTest2.id;
		update tratTest2;
        
        Test.stopTest();
        
        Account accDB = [
            SELECT id, Obra_social__pc
            FROM Account
            WHERE id =:accTest.id
        ];
        
          System.assertEquals(obraSocialTest2.id, accDB.Obra_social__pc);

    }
    
}