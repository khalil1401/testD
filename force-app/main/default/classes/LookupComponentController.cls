public without sharing class LookupComponentController {

    @AuraEnabled(cacheable=true)
    public static List<Localidad__c> getLocalidades(String idMunicipio) {
        List<Localidad__c> lista = [
            SELECT      Id, Name
            FROM        Localidad__c
            WHERE       Municipio__c =: idMunicipio
            ORDER BY    Name
        ];

        return lista;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getProfesionales() {
        List<Account> profesionales = [
            SELECT  Id, Name
            FROM    Account
            WHERE   RecordType.Name =: 'Profesional de la salud'
                OR  RecordType.Name =: 'Otro profesional'
        ];

        return profesionales;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getInstituciones() {
        List<Account> instituciones = [
            SELECT  Id, Name
            FROM    Account
            WHERE   RecordType.Name =: 'Institución'
            ORDER BY Name
        ];

        return instituciones;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getObrasSociales() {
        List<Account> obraSociales = [
            SELECT  Id, Name
            FROM    Account
            WHERE   RecordType.Name =: 'Obra social'
            ORDER BY Name
        ];

        return obraSociales;
    }

}