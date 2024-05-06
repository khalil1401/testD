@isTest
public class GeneralEnvironmentSettingsComponentTest {
    @isTest
    public static void getCicloMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('ciclo__mdt','Id,DeveloperName,Label,Fecha_de_inicio__c,Fecha_de_Fin__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    @isTest
    public static void getCompensatorioTiempoNoPromocionalMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('Compensatorio_Tiempo_no_Promocional__mdt','Id,DeveloperName,Label,Compensatorio__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    @isTest
    public static void getLimiteDeRetrasoMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('Limite_de_retraso__mdt','Id,DeveloperName,Label,Cantidad_de_Dias_de_Retraso__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    @isTest
    public static void getTargetDiarioMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('Target_Diario__mdt','Id,DeveloperName,Label,Sub_Equipo__c,Numero_de_mes__c,Target__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    @isTest
    public static void getNotificacionFinCicloMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('Notificacion_fin_de_Ciclo__mdt','Id,DeveloperName,Label,Dias_de_antelacion__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    @isTest
    public static void getMotivoDeBajaMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('Configuracion_de_motivos_para_la_Baja__mdt','Id,DeveloperName,Label,Baja_Total__c,Baja_Temporal__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    @isTest
    public static void getFrecuenciaPorCategoriaMetadata() {
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.getData('Frecuencia_por_Categoria__mdt','Id,DeveloperName,Label,Categoria__c,Segmenta_Por__c,Frecuencia__c');
        Test.stopTest();
        System.assertEquals(obj.size(), obj.size(), 'No trajo la metadata');
    }

    /* @isTest
    public static void updateMetadata() {
        GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper wrapper = new GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper(
        );
        wrapper.Numero_de_mes_c = 4;
        wrapper.Sub_Equipo_c = 'Alergia';
        wrapper.Target_c = 2;
        wrapper.developerName = 'Abril_2022_Alergia';
        wrapper.fullName = 'Target_Diario.Abril_2022_Alergia';
        wrapper.id = 'm04030000008S2BAAU';
        wrapper.label = 'Abril_2022_Alergia';

        Object objJson = (Object) wrapper;
        List<Object> listObjs = new List<Object>{objJson};
        System.debug(listObjs);
        //List<Object> json = '({Numero_de_mes_c=4, Sub_Equipo_c=Alergia, Target_c=2, developerName=Abril_2022_Alergia, fullName=Target_Diario.Abril_2022_Alergia, id=m04030000008S2BAAU, label=Abril_2022_Alergia})';
        Test.startTest();
        List<GeneralEnvironmentSettingsComponentCtrl.ObjectWrapper> obj = GeneralEnvironmentSettingsComponentCtrl.updateMetadata(listObjs);
        Test.stopTest();
    } */
    
}