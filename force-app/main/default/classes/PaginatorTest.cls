@isTest
public class PaginatorTest {
    
    @isTest
    public static void getSObjectsMethodMustReturnAnAmountOfObjectsDuePageSizeIfTheRecordsReturnedByTheQueryExceedPageSize(){
                
        pageSize = 3;

        Paginator pg = new Paginator(query, countQuery, pageSize);
        
        Test.startTest();
        tsksList = pg.getSObjects();
        Test.stopTest();
        
        System.assertEquals(3, tsksList.size());
    }
    
    @isTest
    public static void nextMethodMustIncreaseIn1TheValueOfPageNumber(){
                
        pageSize = 3;

        Paginator pg = new Paginator(query, countQuery, pageSize);
        Test.startTest();
        pg.next();
        Test.stopTest();
        
        System.assertEquals(2, pg.pageNumber);
    }
    
    @isTest
    public static void nextMethodMustDecreaseIn1TheValueOfPageNumber(){     
        
        pageSize = 3;

        Paginator pg = new Paginator(query, countQuery, pageSize);
        pg.next();

        Test.startTest();
        pg.previous();
        Test.stopTest();
        
        System.assertEquals(1, pg.pageNumber);
    }
    
    @isTest
    public static void pageNumberMustBe1IfPreviousMethodIsExcecutedAndPageNumberIs1(){     
        
        pageSize = 3;

        Paginator pg = new Paginator(query, countQuery, pageSize);

        Test.startTest();
        pg.previous();
        Test.stopTest();
        
        System.assertEquals(1, pg.pageNumber);
    }
    
    @isTest
    public static void hasPreviousMustBeFalseAndHasNextMustBeTrueIfPageNumberIs1AndTotalPagesIsNot1(){     
        
        pageSize = 3;
        
        Test.startTest();
        Paginator pg = new Paginator(query, countQuery, pageSize);
        Test.stopTest();
        
        System.assertEquals(false, pg.hasPrevious);
        System.assertEquals(true, pg.hasNext);
    }
    
    @isTest
    public static void hasNextAndHasPreviousMustBeTrueIfTherePageNumberNeitherIsTheFirstNorTheLast(){     
        
        pageSize = 3;
        
        Test.startTest();
        Paginator pg = new Paginator(query, countQuery, pageSize);
        pg.Next();
        Test.stopTest();
        
        System.assertEquals(true, pg.hasPrevious);
        System.assertEquals(true, pg.hasNext);
    }


    @isTest
    public static void hasNextMustBeFalseAndHasPreviousMustBeTrueIfPageNumberIsTheLast(){     
        
        pageSize = 9;
        
        Test.startTest();
        Paginator pg = new Paginator(query, countQuery, pageSize);
        pg.Next();
        Test.stopTest();
        
        System.debug('Values: ' + pg.pageNumber + ' ' + pg.totalPages);
        
        System.assertEquals(true, pg.hasPrevious);
        System.assertEquals(false, pg.hasNext);
    } 
    
    @isTest
    public static void hasNextAndHasPreviousMustBeFalseIfTotalPagesIs1(){     
        
        pageSize = 20;
        
        Test.startTest();
        Paginator pg = new Paginator(query, countQuery, pageSize);
        pg.Next();
        Test.stopTest();
        
        System.assertEquals(false, pg.hasPrevious);
        System.assertEquals(false, pg.hasNext);
    }  
    
    @isTest
    public static void setPageSizeMustUpdateTheAmountOfRecordsReturnedByGetSOjectsIfThereWereMoreRecordsThanThePreviousPageSize(){     
        
        pageSize = 5;
        Paginator pg = new Paginator(query, countQuery, pageSize);
        
        Test.startTest();
        pg.setPageSize(7);
        Test.stopTest();
        
        tsksList = pg.getSObjects();
        
        System.assertEquals(7, tsksList.size());

    }   
    
    /*--------------------------------------------------------------------------------*/
    
    static Account acc1;
    static List<Account> accsList;
    static Task tsk0, tsk01, tsk02, tsk03, tsk04, tsk05, tsk06, tsk07, tsk08, tsk09, tsk10, tsk11, tsk12, tsk13, tsk14, tsk15;
    static List<Task> tsksList;
    static String fieldsQ, fromQ, whereQ, whereQForCount, countQuery, query;
    static Integer pageSize, currentPage;

    static{
        acc1 = Build.anAccountPacienteBestCare()
            .withLastName('defaultName 1')
            .withDNI('10000000')
            .withFechaDeNacimiento(date.parse('01/06/2019'))
            .withTelefono('9115555555')
            .build();
        
        
        accsList = new List<Account>{acc1};
        insert accsList;
        
        
        tsk0 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk01 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk02 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk03 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk04 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk05 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk06 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk07 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk08 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk09 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk10 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk11 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk12 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk13 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk14 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        tsk15 = Build.aTaskTarea()
            .withWhatId(acc1)
            .build();
        
        tsksList = new List<Task>{tsk0,  tsk01, tsk02, tsk03, tsk04, tsk05, tsk06, tsk07, tsk08, tsk09, tsk10, tsk11, tsk12, tsk13, tsk14, tsk15};
        insert tsksList;
         
        /*----------Paginator Constructor------------*/
        
        fieldsQ = 'SELECT Id, Subject, Owner.Name, Status, ActivityDate, WhatId, What.Name '; 
        
        fromQ = 'FROM Task';
        
        whereQ = 'WHERE WhatId = \'' + acc1.Id + '\'';
        
        countQuery = String.join(new String[] { 'SELECT Count()', fromQ, whereQForCount }, ' ');
        
        query = String.join(new String[] { fieldsQ, fromQ, whereQ }, ' '); 
  
        /*------------------*------------------------*/
    }
}