@isTest
public without sharing class NICTrigger_Test {
    @isTest
    public static void if_a_nic_is_created_it_must_be_related_to_an_accountif_a_nic_is_created_it_must_be_related_to_an_account(){

        Account acc = Build.anAccountPacienteBestCare()
				   .withLastName('Name Test acc')
				   .withRegimenDeInternacionDomiciliaria('Sí')			   
				   .build();
        acc.DNI__c= '45642123';

    insert acc;

    String accSapIdNumber = [
        SELECT id,ID_de_paciente__c
        FROM Account
        WHERE id =:acc.id
    ].ID_de_paciente__c;

    NIC_Envio__c aNic = new NIC_Envio__c();
    aNic.Fecha_Ingreso__c = '11/11/2021 17:04';
    aNic.Fecha_Despacho__c = '11/11/2021 14:04';
    aNic.Id_de_cuenta_SAP__c = accSapIdNumber+ ' Name Test acc';
    aNic.NIC__c = '751622656';

    NIC_Envio__c sameNic = new NIC_Envio__c();
    sameNic.Fecha_Ingreso__c = '11/11/2021 19:04';
    sameNic.Fecha_Despacho__c = '11/11/2021 20:04';
    sameNic.Direccion_de_Envio__c = 'TEst domicilio';
    sameNic.Id_de_cuenta_SAP__c = accSapIdNumber+ ' Name Test acc';
    sameNic.NIC__c = '751622656';

    Test.startTest();
    upsert aNic NIC__c;
    upsert sameNic NIC__c;
    Test.stopTest();

    List<NIC_Envio__c> nicsDb = [ 
        SELECT Id,Cuenta__c,Fecha_Despacho__c
        FROM NIC_Envio__c
        ];

    System.assertEquals(1, nicsDb.size());
    System.assertEquals(acc.id, nicsDb[0].Cuenta__c);
    System.assertEquals('11/11/2021 20:04', nicsDb[0].Fecha_Despacho__c);

    }

    
}