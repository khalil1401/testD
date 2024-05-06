@isTest
public with sharing class FeatureManagerTest {
    //Para utilizar en otro entorno se debe remplazar SLA_Assignment__c de la siguiente linea
    // por un campo que exista en la Custom Setting Feature_Switch dentro del entorno.
    static FeatureSwitch__c slaOption = new FeatureSwitch__c(Dan360_Cuota_Duplicated_Cuotas__c = false);
	
    @IsTest
    private static void requestAnFeatureDeactivatedShouldReturnFalse() {
        insert slaOption;

        Test.startTest();
        Boolean res = FeatureManager.isFeatureTurnedOn('Dan360_Cuota_Duplicated_Cuotas');
        Test.stopTest();

        System.assertEquals(false, res);
    }

    @IsTest
    private static void requestAnFeatureActivatedShouldReturnTrue() {
        insert slaOption = new FeatureSwitch__c(Dan360_Cuota_Duplicated_Cuotas__c = true);

        Test.startTest();
        Boolean res = FeatureManager.isFeatureTurnedOn('Dan360_Cuota_Duplicated_Cuotas');
        Test.stopTest();

        System.assertEquals(true, res);
    }

    @IsTest
    private static void requestAnUndefinedFeatureShouldReturnTrue() {
        
        Test.startTest();
        Boolean res = FeatureManager.isFeatureTurnedOn('Testing_Feature');
        Test.stopTest();

        System.assertEquals(true, res);
    }
}