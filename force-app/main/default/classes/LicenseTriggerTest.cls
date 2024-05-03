@isTest
public class LicenseTriggerTest  {
    
    @IsTest public static void ShouldAddTheDailyDaysWithinASetDateRangeIfCreatedApprovedInTrue() {
        
        Licencia__c licencia = Build.aLicencia()
            .withCiclo(ciclo1)
            .withAprobado(true)
            .withFechaDeInicio(System.today())
            .withFechaDeFin(System.today().addDays(2))
            .build();
        
        Test.startTest();
        insert licencia;
        Test.stopTest();
        
        List<Licencia__c> licenciaBD = [
            SELECT Id, Cantidad_de_dias_de_la_licencia__c, Cantidad_de_dias__c
            FROM Licencia__c
        ];
        
        DateTime tomorrowDate = System.now().addDays(1);                
        String dayName = tomorrowDate.format('EEEE');
        
        if (dayName == 'Saturday' || dayName == 'Sunday'){     
            System.assertEquals(3.00, licenciaBD[0].Cantidad_de_dias__c);
            System.assertEquals(1.00, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
        }else{
            System.assertEquals(3.00, licenciaBD[0].Cantidad_de_dias__c);
            System.assertEquals(3.00, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
        }
    }
    
    @IsTest public static void ShouldAddTheDailyDaysWithinASetDateRangeIfCreatedApprovedInFalseAndChangeToTrue() {
        
        insert primeraLicencia;
        primeraLicencia.Aprobado__c = true;
        
        Test.startTest();
        update primeraLicencia;
        Test.stopTest();
        
        List<Licencia__c> licenciaBD = [
            SELECT Id, Cantidad_de_dias_de_la_licencia__c, Cantidad_de_dias__c
            FROM Licencia__c
        ];
        DateTime tomorrowDate = System.now().addDays(1);                
        String dayName = tomorrowDate.format('EEEE');
        
        if (dayName == 'Saturday' || dayName == 'Sunday'){     
            System.assertEquals(2, licenciaBD[0].Cantidad_de_dias__c);
            System.assertEquals(1, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
        }else{
            System.assertEquals(2, licenciaBD[0].Cantidad_de_dias__c);
            System.assertEquals(2, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
        }
    }
    
    @IsTest public static void ShouldAddTheDailyDaysWithinASetDateRangeIfNotApproved() {
        
        insert primeraLicencia;
        insert segundaLicencia;
        insert terceraLicencia;
        insert cuartaLicencia;
        
        segundaLicencia.Aprobado__c = true;
        terceraLicencia.Aprobado__c = true;
        cuartaLicencia.Aprobado__c = true;
        
        Test.startTest();
        update segundaLicencia;
        update terceraLicencia;
        update cuartaLicencia;
        Test.stopTest();
        
        List<Licencia__c> licenciaBD = [
            SELECT Id, Cantidad_de_dias_de_la_licencia__c, Cantidad_de_dias__c
            FROM Licencia__c
        ];
        DateTime tomorrowDate = System.now().addDays(1);                
        String dayName = tomorrowDate.format('EEEE');
        
        if (dayName == 'Saturday' || dayName == 'Sunday'){ 
            
            System.assertEquals(1.00, licenciaBD[2].Cantidad_de_dias_de_la_licencia__c);
            System.assertEquals(null, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
            System.assertEquals(0.1, licenciaBD[1].Cantidad_de_dias_de_la_licencia__c);
            System.assertEquals(1, licenciaBD[3].Cantidad_de_dias_de_la_licencia__c);
        }else{
            System.assertEquals(null, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
            System.assertEquals(0.1, licenciaBD[1].Cantidad_de_dias_de_la_licencia__c);
            System.assertEquals(2, licenciaBD[3].Cantidad_de_dias_de_la_licencia__c);
            System.assertEquals(3.00, licenciaBD[2].Cantidad_de_dias_de_la_licencia__c);
        }
    }
    
    @IsTest public static void ShouldEliminateLicenseDaysIfApprovedChangesFromTrueToFalse() {
        
        insert segundaLicencia;
        
        segundaLicencia.Aprobado__c = true;
        update segundaLicencia;
        
        segundaLicencia.Aprobado__c = false;
        
        Test.startTest();
        update segundaLicencia;
        Test.stopTest();
        
        List<Licencia__c> licenciaBD = [
            SELECT Id, Cantidad_de_dias_de_la_licencia__c, Cantidad_de_dias__c
            FROM Licencia__c
        ];
        
        System.assertEquals(0, licenciaBD[0].Cantidad_de_dias_de_la_licencia__c);
    }
    
    static Ciclo__c ciclo1, ciclo2;
    static Feriado__c feriado1;
    static Licencia__c primeraLicencia, segundaLicencia, terceraLicencia, cuartaLicencia;
    
    static {
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);        
        ciclo1 = Build.aCiclo()
            .withName('New Ciclo')
            .withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),firstDayOfMonth.day()))
            .withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),lastDayOfMonth.day()))
            .build();
        insert ciclo1;
        
        ciclo2 = Build.aCiclo()
            .withName('New Ciclo')
            .withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),firstDayOfMonth.day()))
            .withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),lastDayOfMonth.day()))
            .build();
        insert ciclo2;
        
        feriado1 = Build.aFeriado()
            .withFecha(Date.newInstance(System.today().year(),System.today().month(),16))
            .build();
        insert feriado1;
        
        primeraLicencia = Build.aLicencia()
            .withCiclo(ciclo1)
            .withAprobado(false)
            .withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day()))
            .withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(1))
            .build();
        
        segundaLicencia = Build.aLicencia()
            .withCiclo(ciclo2)
            .withAprobado(false)
            .withDuracionDeLicencia('1/10 día')
            .withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day()))
            .withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day()))
            .build();
        
        terceraLicencia = Build.aLicencia()
            .withCiclo(ciclo1)
            .withAprobado(false)
            .withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day()))
            .withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(2))
            .build();
        
        cuartaLicencia = Build.aLicencia()
            .withCiclo(ciclo2)
            .withAprobado(false)
            .withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day()))
            .withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(1))
            .build();
    }
    
}