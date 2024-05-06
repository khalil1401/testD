public with sharing class BatchCuentaCorriente implements Database.Batchable<SObject>{
    List<Dan360_DocumentosCuentaCorriente__c> cuentasCorrientesLista = new List<Dan360_DocumentosCuentaCorriente__c>();
    List<Dan360_TablaIntermediaCuentaCorriente__c> datosDeTablaIntermedia = new List<Dan360_TablaIntermediaCuentaCorriente__c>();
    Boolean isOk;
    public Database.QueryLocator start (Database.BatchableContext bc) {
        String query ='SELECT Id, Name, Dan360_CodigoCliente__c,'+ 
                                'Dan360_CodigoEmpresaGrupo__c,'+ 
                                'Dan360_FechaDocumento__c,'+
                                'Dan360_IdRegistro__c,'+
                                'Dan360_ImporteDocumento__c,'+
                                'Dan360_Moneda__c,'+
                                'Dan360_OrdenAplicacion__c,'+
                                'Dan360_Saldo__c,'+
                                'Dan360_TipoDocumento__c,'+
                                'Dan360_Vencimiento__c,'+ 
                                'Dan360_Remito__c'+
                        ' FROM Dan360_TablaIntermediaCuentaCorriente__c';

        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext BC, List<Dan360_TablaIntermediaCuentaCorriente__c> scope) {
        //datosDeTablaIntermedia = scope;
        List<Dan360_DocumentosCuentaCorriente__c> cuentasCorrientesLista = CheckingAccountHelper.armarCuentaCorriente(scope);

        for (Dan360_TablaIntermediaCuentaCorriente__c registro : scope) {
            datosDeTablaIntermedia.add(registro);
        }

        System.debug('cuentasCorrientesLista');
        System.debug(cuentasCorrientesLista);

        Database.SaveResult[] result = Database.insert(cuentasCorrientesLista, false);

        for (Database.SaveResult sr : result) {
            System.debug(sr.isSuccess());
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }   
            }
        }
    }

    public void finish (Database.BatchableContext BC) {
    }
}