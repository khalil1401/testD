global without sharing class GeneralEnvironmentSettingsComponentCtrl {
    
    @AuraEnabled (cacheable=true) 
    public static List<ObjectWrapper> getData(String metadata, String fields){

        List<ObjectWrapper> response = new List<ObjectWrapper>();
        String query = 'SELECT ' + fields + ' FROM ' + metadata;
        if (metadata.equals('ciclo__mdt')) {
            List<ciclo__mdt> records = Database.query(query);
            for (ciclo__mdt ciclo : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = ciclo.Id;
                obj.developerName = ciclo.DeveloperName;
                obj.fullName = 'ciclo.' + ciclo.DeveloperName;
                obj.label = ciclo.Label;
                obj.fecha_De_Inicio_c = Date.newInstance(ciclo.Fecha_de_inicio__c.year(), ciclo.Fecha_de_inicio__c.month(),ciclo.Fecha_de_inicio__c.day());
                obj.fecha_De_Fin_c =   Date.newInstance(ciclo.fecha_De_Fin__c.year(), ciclo.fecha_De_Fin__c.month(), ciclo.fecha_De_Fin__c.day());
                response.add(obj);
            }
        } else if (metadata.equals('Compensatorio_Tiempo_no_Promocional__mdt')) {
            List<Compensatorio_Tiempo_no_Promocional__mdt> records = Database.query(query);
            for (Compensatorio_Tiempo_no_Promocional__mdt compensatorio : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = compensatorio.Id;
                obj.developerName = compensatorio.DeveloperName;
                obj.fullName = 'Compensatorio_Tiempo_no_Promocional.' + compensatorio.DeveloperName;
                obj.label = compensatorio.Label;
                obj.compensatorio_c = compensatorio.Compensatorio__c;
                response.add(obj);
            }
        } else if (metadata.equals('Limite_de_retraso__mdt')) {
            List<Limite_de_retraso__mdt> records = Database.query(query);
            for (Limite_de_retraso__mdt limite : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = limite.Id;
                obj.developerName = limite.DeveloperName;
                obj.fullName = 'Limite_de_retraso.' + limite.DeveloperName;
                obj.label = limite.Label;
                obj.Cantidad_de_Dias_de_Retraso_c = limite.Cantidad_de_Dias_de_Retraso__c;
                response.add(obj);
            }
        } else if (metadata.equals('Target_Diario__mdt')) {
            List<Target_Diario__mdt> records = Database.query(query);
            System.debug('records: ' + records);
            for (Target_Diario__mdt target : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = target.Id;
                obj.developerName = target.DeveloperName;
                obj.fullName = 'Target_Diario.' + target.DeveloperName;
                obj.label = target.Label;                
                obj.Sub_Equipo_c = target.Sub_Equipo__c;
                obj.Numero_de_mes_c = target.Numero_de_mes__c;
                obj.Target_c = target.Target__c;
                response.add(obj);
            }
        } else if (metadata.equals('Notificacion_fin_de_Ciclo__mdt')) {
            List<Notificacion_fin_de_Ciclo__mdt> records = Database.query(query);
            System.debug('records: ' + records);
            for (Notificacion_fin_de_Ciclo__mdt finDeCiclo : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = finDeCiclo.Id;
                obj.developerName = finDeCiclo.DeveloperName;
                obj.fullName = 'Notificacion_fin_de_Ciclo.' + finDeCiclo.DeveloperName;
                obj.label = finDeCiclo.Label;
                obj.Dias_de_antelacion_c = finDeCiclo.Dias_de_antelacion__c;
                response.add(obj);
            }
        } else if (metadata.equals('Configuracion_de_motivos_para_la_Baja__mdt')) {
            List<Configuracion_de_motivos_para_la_Baja__mdt> records = Database.query(query);
            System.debug('records: ' + records);
            for (Configuracion_de_motivos_para_la_Baja__mdt motivo : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = motivo.Id;
                obj.developerName = motivo.DeveloperName;
                obj.fullName = 'Configuracion_de_motivos_para_la_Baja.' + motivo.DeveloperName;
                obj.label = motivo.Label;
                obj.Baja_Total_c = motivo.Baja_Total__c;
                obj.Baja_Temporal_c = motivo.Baja_Temporal__c;
                response.add(obj);
            }
        } else if (metadata.equals('Frecuencia_por_Categoria__mdt')) {
            List<Frecuencia_por_Categoria__mdt> records = Database.query(query);
            System.debug('records: ' + records);
            for (Frecuencia_por_Categoria__mdt frecuencia : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = frecuencia.Id;
                obj.developerName = frecuencia.DeveloperName;
                obj.fullName = 'Frecuencia_por_Categoria.' + frecuencia.DeveloperName;
                obj.label = frecuencia.Label;
                obj.Categoria_c = frecuencia.Categoria__c;
                obj.Segmenta_Por_c = frecuencia.Segmenta_Por__c;
                obj.Frecuencia_c = frecuencia.Frecuencia__c;
                response.add(obj);
            }
        } else if (metadata.equals('Clientes_No_EDI__mdt')) {
            List<Clientes_No_EDI__mdt> records = Database.query(query);
            System.debug('records: ' + records);
            for (Clientes_No_EDI__mdt clientesEdi : records) {
                ObjectWrapper obj = new ObjectWrapper();
                obj.id = clientesEdi.Id;
                obj.developerName = clientesEdi.DeveloperName;
                obj.fullName = 'Clientes_No_EDI.' + clientesEdi.DeveloperName;
                obj.label = clientesEdi.Label;
                obj.GLN_c = clientesEdi.GLN__c;
                obj.Nombre_c = clientesEdi.Nombre__c;
                response.add(obj);
            }
        }
        return response; 

    }

    @AuraEnabled
    public static List<ObjectWrapper> updateMetadata (List<Object> jsonString) {
       
        System.debug('JSON como viene: ' + jsonString);
        List<ObjectWrapper> response = new List<ObjectWrapper>();
        List<Id> listJobsId = new List<Id>();
        for (Object obj : jsonString) {
            String stringObj = JSON.serialize(obj);
            System.debug(stringObj);
            ObjectWrapper wrapper = (ObjectWrapper)JSON.deserialize(stringObj, ObjectWrapper.class);
            if(String.isBlank(wrapper.label)){
                wrapper.label = 'X'+wrapper.GLN_c;
                wrapper.fullName = 'Clientes_No_EDI.'+wrapper.label;
            }
            System.debug(wrapper.fullName);
            System.debug(wrapper.label);
            
            Map<String, Object> fields =  (Map<String,Object>) JSON.deserializeUntyped(stringObj);
            System.debug(fields);
            MetadataInsertUpdate.handleInsertAndUpdate(wrapper.fullName, wrapper.label, fields);
        }
        return response; 

    }

    @AuraEnabled
    public static string getUserProfileName(){
        id profileId = userinfo.getProfileId();
        String profileName = [SELECT Name FROM profile WHERE id = :profileId].Name;
        return profileName;
    }

    global class ObjectWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String developerName {get;set;}
        @AuraEnabled
        public String fullName {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Date fecha_De_Inicio_c {get;set;}
        @AuraEnabled
        public Date fecha_De_Fin_c {get;set;}
        @AuraEnabled
        public Decimal compensatorio_c {get;set;}
        @AuraEnabled
        public Decimal Cantidad_de_Dias_de_Retraso_c {get;set;}
        @AuraEnabled
        public String Sub_Equipo_c {get;set;}
        @AuraEnabled
        public Decimal Numero_de_mes_c {get;set;}
        @AuraEnabled
        public Decimal Target_c {get;set;}
        public Decimal Dias_de_antelacion_c {get;set;}
        @AuraEnabled
        public Boolean Baja_Total_c {get;set;}
        @AuraEnabled
        public Boolean Baja_Temporal_c {get;set;}
        @AuraEnabled
        public String Categoria_c {get;set;}
        @AuraEnabled
        public String Segmenta_Por_c {get;set;}
        @AuraEnabled
        public Decimal Frecuencia_c {get;set;}
        @AuraEnabled
        public String GLN_c {get;set;}
        @AuraEnabled
        public String Nombre_c {get;set;}
    }

}