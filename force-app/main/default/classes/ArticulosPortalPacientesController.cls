public without sharing class ArticulosPortalPacientesController {

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getTecnicasDeBellezaOncologia() {

        List<Knowledge__kav> tecnicas = [
            SELECT  Id, Title, Descripcion__c, Imagen__c, Historia_tecnica_peinado__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Técnicas de belleza (Oncología)' AND
                    PublishStatus = 'Online'
        ];

        return tecnicas;

    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getEjercicios(String tipoEjercicio) {
        String query = 'SELECT Id, Title, Descripcion__c, Imagen__c, Consejos__c, Ejercicio__c FROM Knowledge__kav WHERE Tipo_de_articulo__c = \'Ejercicios (Oncología)\' AND PublishStatus = \'Online\' AND Ejercicio__c = \'' + String.escapeSingleQuotes(tipoEjercicio) + '\'';

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getTiposDeEjerciciosOncologia() {
        Map<String,Knowledge__kav> mapArticulos = new Map<String,Knowledge__kav>();

        List<Knowledge__kav> ejercicios = [
            SELECT  Ejercicio__c, Imagen__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Ejercicios (Oncología)' AND
                    PublishStatus = 'Online'
        ];

        for (Knowledge__kav ejercicio : ejercicios) {
            if(!mapArticulos.containsKey(ejercicio.Ejercicio__c)){
                mapArticulos.put(ejercicio.Ejercicio__c, ejercicio);
            }
        }

        return mapArticulos.values();
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTiposDeRecetaOncologia() {
        List<String> tiposDeRecetas = new List<String>();

        List<Knowledge__kav> recetas = [
            SELECT  Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Oncología)' AND
                    PublishStatus = 'Online'
        ];

        for (Knowledge__kav receta : recetas) {
            if(!tiposDeRecetas.contains(receta.Tipo_de_receta__c)){
                tiposDeRecetas.add(receta.Tipo_de_receta__c);
            }
        }

        return tiposDeRecetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getRecetasOncologia(String tipoDeReceta) {
        String tipoArticulo = 'Recetas (Oncología)';
        String publishStatus = 'Online';
        String query = 'SELECT Id, Title, Tipo_de_receta__c, Imagen__c FROM Knowledge__kav WHERE ';
        String condicion = (String.isNotBlank(tipoArticulo) ? 'Tipo_de_articulo__c = \'' + tipoArticulo + '\'' : '');
        condicion += (String.isNotBlank(publishStatus) ? ' AND PublishStatus = \'' + publishStatus + '\'' : '');
        condicion += (String.isNotBlank(tipoDeReceta) ? ' AND Tipo_de_receta__c = \'' + String.escapeSingleQuotes(tipoDeReceta) + '\'' : '');
        query += + condicion;

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getRecetaOncologia(String tituloReceta) {
        String query = 'SELECT Title, Imagen__c, Ingredientes_de_recetas__c, Preparacion_receta__c, Tipo_de_receta__c, Consejos_recetas__c, Cantidad_porciones_receta__c, Tiempo_preparacion_receta__c FROM Knowledge__kav WHERE Tipo_de_articulo__c = \'Recetas (Oncología)\' AND PublishStatus = \'Online\' AND Title = \'' + String.escapeSingleQuotes(tituloReceta) + '\' LIMIT 1';

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getDescubriRecetasOncologia() {

        List<Knowledge__kav> recetas = [
            SELECT  Title, Imagen__c, Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Oncología)' AND
                    PublishStatus = 'Online'
            LIMIT 3
        ];

        return recetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTiposDeRecetaAlergia() {
        List<String> tiposDeRecetas = new List<String>();

        List<Knowledge__kav> recetas = [
            SELECT  Tipo_de_receta__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Alergia)' AND
                    PublishStatus = 'Online'
        ];

        for (Knowledge__kav receta : recetas) {
            if(!tiposDeRecetas.contains(receta.Tipo_de_receta__c)){
                tiposDeRecetas.add(receta.Tipo_de_receta__c);
            }
        }

        return tiposDeRecetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getRecetasDeTipoAlergia(String tipoReceta) {
        String tipoArticulo = 'Recetas (Alergia)';
        String publishStatus = 'Online';
        String query = 'SELECT Id, Title, Imagen__c FROM Knowledge__kav WHERE ';
        String condicion = (String.isNotBlank(tipoArticulo) ? 'Tipo_de_articulo__c = \'' + tipoArticulo + '\'' : '');
        condicion += (String.isNotBlank(publishStatus) ? ' AND PublishStatus = \'' + publishStatus + '\'' : '');
        condicion += (String.isNotBlank(tipoReceta) ? ' AND Tipo_de_receta__c = \'' + String.escapeSingleQuotes(tipoReceta) + '\'' : '');
        query += + condicion;
        List<Knowledge__kav> recetas = Database.query(query);

        return recetas;
    }

    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getRecetaAlergia(String tituloReceta) {
        String tipoArticulo = 'Recetas (Alergia)';
        String publishStatus = 'Online';
        String query = 'SELECT  Title, Imagen__c, Ingredientes_de_recetas__c, Preparacion_receta__c, Tipo_de_receta__c, Consejos_recetas__c, Imagen_alergenos__c, Imagen_producto__c FROM Knowledge__kav WHERE ';
        String condicion = (String.isNotBlank(tipoArticulo) ? 'Tipo_de_articulo__c = \'' + tipoArticulo + '\'' : '');
        condicion += (String.isNotBlank(publishStatus) ? ' AND PublishStatus = \'' + publishStatus + '\'' : '');
        condicion += (String.isNotBlank(tituloReceta) ? ' AND Title = \'' + String.escapeSingleQuotes(tituloReceta) + '\'' : '');
        query += + condicion;
        List<Knowledge__kav> recetas = Database.query(query);

        if(!recetas.isEmpty()){
            return recetas.get(0);
        }
        else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getRecetasDisfagia() {
        List<Knowledge__kav> recetas = [
            SELECT  Id, Title, Tipo_de_receta__c, URL_Video__c
            FROM    Knowledge__kav
            WHERE   Tipo_de_articulo__c = 'Recetas (Disfagia)' AND
                    PublishStatus = 'Online'
        ];

        return recetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getVideosTerapiaCetogenica() {
        String tipoArticulo = 'Videos (Terapia Cetogénca)';
        String publishStatus = 'Online';
        String query = 'SELECT Id, Title, URL_Video__c FROM Knowledge__kav WHERE ';
        String condicion = (String.isNotBlank(tipoArticulo) ? 'Tipo_de_articulo__c = \'' + tipoArticulo + '\'' : '');
        condicion += (String.isNotBlank(publishStatus) ? ' AND PublishStatus = \'' + publishStatus + '\'' : '');
        query += + condicion;
        List<Knowledge__kav> videos = Database.query(query);
        
        return videos;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTiposRecetasTerapiaCetogenica() {
        List<String> tiposDeRecetas = new List<String>();

        String tipoArticulo = 'Recetas (Terapia Cetogénica)';
        String publishStatus = 'Online';
        String query = 'SELECT Id, Tipo_de_receta__c FROM Knowledge__kav WHERE ';
        String condicion = (String.isNotBlank(tipoArticulo) ? 'Tipo_de_articulo__c = \'' + tipoArticulo + '\'' : '');
        condicion += (String.isNotBlank(publishStatus) ? ' AND PublishStatus = \'' + publishStatus + '\'' : '');
        query += + condicion;
        List<Knowledge__kav> recetas = Database.query(query);

        for (Knowledge__kav receta : recetas) {
            if(!tiposDeRecetas.contains(receta.Tipo_de_receta__c)){
                tiposDeRecetas.add(receta.Tipo_de_receta__c);
            }
        }

        return tiposDeRecetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getRecetasTerapiaCetogenica(String tipoReceta) {
        String tipoArticulo = 'Recetas (Terapia Cetogénica)';
        String publishStatus = 'Online';
        String query = 'SELECT Id, Title, Tipo_de_receta__c, Imagen__c, URL_Video__c, Imagen_producto__c, Ingredientes_de_recetas__c, Preparacion_receta__c FROM Knowledge__kav WHERE ';
        String condicion = (String.isNotBlank(tipoArticulo) ? 'Tipo_de_articulo__c = \'' + tipoArticulo + '\'' : '');
        condicion += (String.isNotBlank(publishStatus) ? ' AND PublishStatus = \'' + publishStatus + '\'' : '');
        condicion += (String.isNotBlank(tipoReceta) ? ' AND Tipo_de_receta__c = \'' + String.escapeSingleQuotes(tipoReceta) + '\'' : '');
        query += + condicion;
        List<Knowledge__kav> recetas = Database.query(query);
        
        return recetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<NIC_Envio__c> getPedidos(String userId) {
        String queryUsers = 'SELECT AccountId FROM User WHERE Id = \'' + String.escapeSingleQuotes(userId) + '\'';
        List<User> users = Database.query(queryUsers);

        if(!users.isEmpty()){
            Id accountId = users.get(0).AccountId;

            List<NIC_Envio__c> envios = [
                SELECT  Name, Link_Seguimiento_completo__c, Cuenta__r.Name, Direccion_de_Envio__c, Localidad_de_Envio__c, NIC__c, CreatedDate
                FROM    NIC_Envio__c
                WHERE   Cuenta__c =: accountId
            ];

            return envios;
        }

        return null;
    }

}