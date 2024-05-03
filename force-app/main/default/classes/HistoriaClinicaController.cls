public without sharing class HistoriaClinicaController {
    public map<string,string> datosPaciente { get; set; }//recorrido logico (A)
    public map<string,string> label { get; set; }
    public map<String,Boolean> secciones { get; set; }  //regular que secciones mostrar en la vf
    public map<String,List<String>> camposSecciones { get; set; } //recorrido logico (b)
    public User profesional {get;set;}
    public map<String,List<String>> seccionesLabel  {get;set;} //SE USA EN LA VF  -- SECCION Y LISTA DE ETIQUETAS
    public map<String, String>  valores  {get;set;}  // SE USA EN LA VF --- ETIQUETA Y VALOR
    
    public List<Metadata.LayoutSection> layout {get; set;} //SE USA PARA OBTENER SECCIONESLABEL Y VALORES
    public string recordId{ get; set; }
    public boolean showLaboratory{ get; set; }
    private String recordTypeName;
    public String button;
    public String mensual{ get; set; }
    public String infusion{ get; set; }
    public String otrosAportes{ get; set; }
    public String antecedentes{ get; set; }
    public String observaciones{ get; set; }
    public String resumenHC{ get; set; }
    Formulario__c relatedHistoria;
    public HistoriaClinicaController(ApexPages.StandardController stdController) {
        
        
        recordId = stdController.getId();  
        
        relatedHistoria = [SELECT id,name 
                           FROM Formulario__c 
                           WHERE id = :recordId];
        
        button = Apexpages.currentPage().getParameters().get('button'); 
        
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' 
                                                 + relatedHistoria.name+'.pdf');
        
        label = getLabel();
        datosPaciente = getData();
        system.debug(datosPaciente.get('Nombre_y_Apellido_del_Paciente__c'));
        layout = getLayout();
        armandoMapas();
        getSeccionesConValores();
        
    }
    
    public List<Metadata.LayoutSection> getLayout() {
        
        recordTypeName = [SELECT RecordType.Name FROM Formulario__c WHERE Id =: recordId].RecordType.Name;
        system.debug(recordTypeName);
        if (recordTypeName=='Historia Clínica de Nutrición Pediátrica'){
            recordTypeName='Historia Clínica Pediátrica de Nutrición';       
        }
        
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(
            Metadata.MetadataType.Layout,
            new List<String> {
                'Formulario__c-' + recordTypeName
                    }
        );//objeto-Nombre de Layout
        
        system.debug(layouts);
        
        System.debug('NOMBRE DE RECORDTYPE '+ recordTypeName);
        Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
        List<Metadata.LayoutSection> layoutSections = new List<Metadata.LayoutSection>();
        
        for (Metadata.LayoutSection laySect : layoutMd.layoutSections) {
            if (laySect.style != Metadata.LayoutSectionStyle.CustomLinks) {
                layoutSections.add(laySect);
                System.debug('LINEA 52 - GETLAYOUT() ' + laySect);
            }
        }
        
        return layoutSections;
    }
    
    public void armandoMapas(){
        //ARMO LOS MAPAS PARA EL FILTRADO DE SECCIONES SIN VALORES
        camposSecciones = new Map<String,List<String>>();
        secciones = new Map<String,Boolean>();
        //layoutItems
        List<String> lista ;
        for (Metadata.LayoutSection laySect : getLayout()) {
            lista = new List<String>();
            secciones.put(laySect.label,false);
            String secc = laySect.label;
            if(!secc.contains('Indice de Katz')){
                for(Metadata.LayoutColumn colum : laySect.layoutColumns){
                    if(colum.layoutItems != null) {
                        for(Metadata.LayoutItem campo : colum.layoutItems){
                            lista.add(campo.field);
                        }
                    }
                }
                
            }
            else{
                for(Metadata.LayoutColumn colum : laySect.layoutColumns){
                    if(colum.layoutItems != null) {
                        for(Metadata.LayoutItem campo : colum.layoutItems){
                            if(campo.field == 'Puntuacion_total_Katz__c'){
                                lista.add(campo.field);
                            }
                        }
                    }
                }
                
            }
            //seccion y etiquetas de los campos de la seccion
            //aca tengo la seccion y la lista de campos por seccion 
            camposSecciones.put(laySect.label,lista);
            
            
        }
    }
    
    private map<string,string> getData() {
        showLaboratory = recordTypeName != 'Historia Clínica Medica de Seguimiento';
        list<string> campos = new list<string>();
        map<string,string> mapCampos = new map<string,string>();
        
        String query = 'SELECT ';
        for (Metadata.LayoutItem item :getLayoutColumns()) {
            if(item.field != null ) {
                //System.debug('LINEA 67 - GETDATA() - ItemField: ' + item.field);
                campos.add(item.field);
                query += item.field + ', ';
            }
        } 
        
        if (!query.containsIgnoreCase('ownerid')) query+= 'ownerId,';
        if (!query.containsIgnoreCase('Tipo_de_formula_relacion__c')) query+= 'Tipo_de_formula_relacion__c,';
        if (!query.containsIgnoreCase('Producto__c')) query+= 'Producto__c,';
        if (!query.containsIgnoreCase('Producto2__c')) query+= 'Producto2__c,';
        if (!query.containsIgnoreCase('Producto_nro_3__c')) query+= 'Producto_nro_3__c,';
        
        query += 'Id FROM Formulario__c WHERE Id =:recordId';
        Formulario__c formulario = Database.query(query);
        Id idPaciente = (Id) formulario.get('Nombre_y_Apellido_del_Paciente__c');
        Id idDoc = (Id)formulario.get('OwnerId');
        Id idProduct;
        Id idProductoFormula;
        Id idProducto2Formula;
        List<Id> idsProductos = new List<Id>();
        if(formulario.Tipo_de_formula_relacion__c!= null){
            idProduct = (Id)formulario.get('Tipo_de_formula_relacion__c');
            idsProductos.add((Id)formulario.get('Tipo_de_formula_relacion__c'));
        }
        if(formulario.Producto__c != null){
            idProductoFormula = (Id)formulario.get('Producto__c');
            idsProductos.add((Id)formulario.get('Producto__c'));
        }
        if(formulario.Producto2__c != null){
            idProductoFormula = (Id)formulario.get('Producto2__c');
            idsProductos.add((Id)formulario.get('Producto2__c'));
        }
        if(formulario.Producto_nro_3__c != null){
            idProductoFormula = (Id)formulario.get('Producto_nro_3__c');
            idsProductos.add((Id)formulario.get('Producto_nro_3__c'));
        }
        
        
        
        String nombreDoc = [Select Name from User where id=:idDoc].Name;
        
        Account paciente = [SELECT Id,Name,PersonBirthdate
                            FROM Account
                            WHERE id =: idPaciente
                           ];
        Map<Id,Product2> products = new Map<Id,Product2>();
        if(!idsProductos.isEmpty()){
            products = new Map<Id,Product2>([
                SELECT Id,Name
                FROM Product2
                WHERE Id = :idsProductos
            ]);
        }
        for(string campo :campos){
            if(campo != null){
                if(formulario.get(campo) != null){
                    string value = String.valueOf(formulario.get(campo));
                    value = value.replace(';', '<br/>');
                    if (value == 'Si'  && campo == 'Laboratorio__c') {
                        showLaboratory = true;
                    }
                    
                    /*if (value != null && (campo == 'Producto2__c'|| campo =='Producto__c')) {
value = [
SELECT Name
FROM Product2
WHERE id = :value
].Name;	
}*/
                    if (value != null && campo == 'Caso__c') {
                        value = [
                            SELECT Casenumber
                            FROM Case
                            WHERE id = :value
                        ].Casenumber;	
                    }
                    
                    switch on value {
                        when 'false' {
                            value = 'NO';
                        }
                        when 'true'{
                            value = 'SI';
                        }
                    }
                    //  mapCampos.put(campo,products.get(value).Name);
                    
                    if(
                        campo == 'Nombre_y_Apellido_del_Paciente__c' || 
                        campo == 'Tipo_de_formula_relacion__c' ||
                        campo == 'Producto__c' ||
                        campo == 'Producto2__c' ||
                        campo == 'Producto_nro_3__c'
                    ){
                        system.debug(campo);
                        system.debug(products);
                        if(campo == 'Nombre_y_Apellido_del_Paciente__c'){
                            mapCampos.put(campo,paciente.Name);
                        }
                        else if(campo == 'Tipo_de_formula_relacion__c' && products.containsKey(value)){
                            mapCampos.put(campo,products.get(value).Name);
                        }
                        else if(campo == 'Producto__c' && products.containsKey(value)){
                            mapCampos.put(campo,products.get(value).Name);
                        }
                        else if(campo == 'Producto2__c' && products.containsKey(value)){
                            mapCampos.put(campo,products.get(value).Name);
                        }else if(campo == 'Producto_nro_3__c' && products.containsKey(value)){
                            mapCampos.put(campo,products.get(value).Name);
                        }
                        
                    }
                    else{
                        mapCampos.put(campo,value);
                    }
                    if(String.valueOf(formulario.get(campo)).contains('<')){
                        mapCampos.put(campo, String.valueOf(formulario.get(campo)).replace('<','< ')); 
                    }
                }
                else{
                    mapCampos.put(campo,'null');
                }
                
            }
        }
        mensual=  formatLongString(mapCampos.get('Mensual__c')) ;   
        observaciones=  formatLongString(mapCampos.get('Observaciones__c')) ;
        resumenHC=  formatLongString(mapCampos.get('Resumen_de_Historia_Cl_nica__c')) ;
        antecedentes = formatLongString(mapCampos.get('Antecedentes__c')) ;
        otrosAportes=  formatLongString(mapCampos.get('Otros_aportes__c')) ;
        infusion= formatLongString(mapCampos.get('Infusi_n__c')) ;
        
        if(observaciones!=''){
            
            mapCampos.put('Observaciones__c', observaciones);
        }
        mapCampos.put('Mensual__c', mensual);
        mapCampos.put('Resumen_de_Historia_Cl_nica__c', resumenHC);
        mapCampos.put('Antecedentes__c', antecedentes);
        mapCampos.put('Otros_aportes__c', otrosAportes);
        mapCampos.put('Infusi_n__c', infusion);
        //LE CAMBIO EL FORMATO A LA FECHA DD/MM/YYYY
        //DECIMALES CON COMA Y SI TIENEN ',00' REDONDEO A ENTERO
        
        formatoFecha(mapCampos);
        decimalesConComa(mapCampos);    
        
        List<User> cuenta = [ SELECT Id,FirstName,LastName ,Matricula__c
                             FROM User
                             WHERE Id =: mapCampos.get('CreatedById')];
        
        
        if(!cuenta.isEmpty()){
            profesional = cuenta[0];
        }
        return mapCampos;
    }
    
    public list<Metadata.LayoutItem> getLayoutColumns() {
        
        List<Metadata.LayoutItem> columns = new List<Metadata.LayoutItem>();
        for (Metadata.LayoutSection section :getLayout()) {
            for (Metadata.LayoutColumn column :section.layoutColumns) {
                if(column.layoutItems != null) {
                    for (Metadata.LayoutItem item :column.layoutItems) {
                        //system.debug('LINEA 149 - GETLAYOUTColumns() '+item);
                        
                        columns.add(item);
                    }
                }
            }
        }
        
        return columns;
    }
    
    public map<string,string> getLabel() {
        
        map<string,string> Labels = new map<string,string>();
        Map<String, Schema.SObjectField> fieldsMaps = 
            Schema.getGlobalDescribe().get('Formulario__c').getDescribe().fields.getMap();
        for(Metadata.LayoutItem item : getLayoutColumns()) {
            if(item.field != null) {
                
                Labels.put(item.field,fieldsMaps.get(item.field).getDescribe().getLabel());
            }
        }
        
        return Labels;
    } 
    
    public void updateForm() {
        blockForm(recordId);
        //para evitar recursividad
        if(button == 'true'){
            if(HistoriaClinicaHelper.noTienePdfHistoriaClinica(recordId,null)){
                HistoriaClinicaHelper.makeAttachedPdf(recordId);
            }
            List<Formulario__c> historiaClinica = [
                SELECT ID,Nombre_y_Apellido_del_Paciente__c,Name,mensual__c
                FROM Formulario__c
                WHERE Id = : recordId
            ];
            system.debug(historiaClinica);
            if(!historiaClinica.isEmpty() && String.isNotBlank(historiaClinica.get(0).Nombre_y_Apellido_del_Paciente__c)){
                if(HistoriaClinicaHelper.noTienePdfHistoriaClinica(historiaClinica.get(0).Nombre_y_Apellido_del_Paciente__c,historiaClinica.get(0).Name)){
                    HistoriaClinicaHelper.linkPdfHistoriaClinicaToAccountAndCase(recordId);
                }
            }
        }
    }
    
    @future
    public static void blockForm(String recordId) {   
        Formulario__c form = [
            SELECT Id, Estado_de_Historia_Clinica__c
            FROM Formulario__c
            WHERE Id = :recordId
        ];
        if (form.Estado_de_Historia_Clinica__c  != 'Definitivo') {
            form.Estado_de_Historia_Clinica__c  = 'Definitivo';
            update form;
        }
    }
    public static void formatoFecha(Map<String,String> mapa){
        String[] camposFecha = new String[]{'Fecha_de_nacimiento__c','Fecha_Laboratorio__c',
            'Fecha_de_carga_del_peso__c',	'Fecha_ultimo_recambio__c','Fecha_de_la_medici_n__c',
            'Fecha__c',	'Fecha_y_hora_de_la_visita_virtual__c','Fecha_de_la_visita__c',	
            'Fecha_nacimiento__c'};
                for(String campo:camposFecha){
                    if(mapa.containsKey(campo) && mapa.get(campo) != 'null'){
                        List<String> myDateOnly = mapa.get(campo).split(' ');
                        List<String> dayMonthYear = myDateOnly.get(0).split('-');
                        Integer anio = Integer.valueOf(dayMonthYear.get(0));
                        Integer mes = Integer.valueOf(dayMonthYear.get(1));
                        Integer dia = Integer.valueOf(dayMonthYear.get(2));
                        Date myDate = date.newinstance(anio, mes,dia);
                        String dateOutput = myDate.format();
                        mapa.put(campo,dateOutput);
                    }                                            
                }                                    
        
    }
    
    public static void decimalesConComa(Map<String,String> mapa){
        String[] camposConDecimales = new String[]{ 'Creatinina__c', 'Fosforo__c', 'Magnesio__c', 'Proteinas_Totales__c',
            'Transferrina__c','Urea__c','GR__c','HG__c','Ionograma__c',	
            'Perdida_de_Peso_en_1_Mes_Kg__c',
            'Perdida_de_Peso_en_3_Meses_Kg__c','Velocidad_de_infusion_ml_h__c',
            'Temperatura__c', 'Porcentaje_de_perdida__c', 'Perdida_de_Peso_en_6_Meses__c',
            'Peso__c', 'Peso_habitual__c',	'Perdida_de_peso_en_6_meses_Kg__c',
            'Peso_ajustado__c', 'Circunferencia_de_la_pantorrilla__c', 'Peso_Estimado__c',
            'BT__c','Calcio_Total__c','Cloro__c','Glucosa__c','Hematocrito__c',
            'Hemoglobina__c','KPTT__c','FAL__c','Leucocitos__c',	
            'Percentilo_pliegue_tricipital__c','Plaquetas__c','Pliegue_tricipital__c',
            'Potasio__c',	'Percentilo_Area_Muscular_del_Brazo__c',
            'Percentilo_circ_de_la_pantorrilla__c',	'Percentilo_circunferencia_del_Brazo__c',
            'Sodio__c','TGO__c','TGP__c',	'TP__c','Trigliceridos__c',
            'area_muscular_del_brazo__c','Promedio_semanal_de_formula_administrada__c',	
            'Perimetro_cef_lico__c','HDL__c',
            'LDL__c','Peso_de_nacimiento__c','Percentiles_IMC_edad__c',
            'Percentiles_per_metro_cef_lico__c',	'Percentiles_peso_edad__c',
            'Percentiles_talla_edad__c'};
                
                
                for(String campo:camposConDecimales){
                    if(mapa.containsKey(campo)){
                        String numero = mapa.get(campo);
                        String target = '.';
                        String replacement = ',';
                        numero = numero.replace(target, replacement);
                        
                        if(numero.contains('00')||numero.contains(',0')){
                            String[] num = numero.split(',');
                            numero = num[0];
                        }
                        mapa.put(campo,numero);
                    }                                                    
                }
    }
    
    public void getSeccionesConValores(){
        
        seccionesLabel = new Map<String,List<String > >();
        valores = new Map<String,String>(); 
        
        
        for (Metadata.LayoutSection laySect : layout) {
            System.debug('=======   LA SECCION '+  laySect.label + ' ======');
            Map<String,String > mapa = new Map<String,String>();
            List<String> lista = camposSecciones.get(laySect.label);
            List<String> tag = new List<String>();
            
            //RETIRO EL CAMPO CASO  
            for(String campo : lista){
                if(datosPaciente.get(campo) != 'null'  && datosPaciente.get(campo) != null 
                   && campo != 'Caso__c' ){
                       //&& campo != 'Fecha_ultimo_recambio__c'
                       secciones.put(laySect.label,true);
                       //LE CAMBIO LA ETIQUETA A OOSS
                       if(campo=='OOSS__c'){
                           tag.add('Prepaga/Obra Social');
                           valores.put('Prepaga/Obra Social',datosPaciente.get(campo));
                       }
                       else{
                           tag.add(label.get(campo));
                           valores.put(label.get(campo),datosPaciente.get(campo));
                       }              
                       System.debug('campo '+ datosPaciente.get(campo));
                   }
                else{
                    System.debug('campo '+ datosPaciente.get(campo));
                    datosPaciente.put(campo,'null');
                }
            }
            if(laySect.label=='Profesional'){
                tag.clear();
                tag.add('Nombre');
                valores.put('Nombre',profesional.FirstName);
                tag.add('Apellido');
                valores.put('Apellido',profesional.LastName);
                if(String.isNotBlank(profesional.Matricula__c)){
                    tag.add('Matricula');
                    valores.put('Matricula',profesional.Matricula__c);
                }
                
                
                system.debug(tag);
                
                
            }
            if(tag.isEmpty()!=true){
                seccionesLabel.put(laySect.label,tag);
            }
            
            
            /*
if(secciones.get(laySect.label) == true){
System.debug('LA SECCION '+ String.valueOf(laySect.label) + '   TIENE VALOR');
}
else{
System.debug('LA SECCION '+ String.valueOf(laySect.label) + ' NO TIENE VALOR');
}*/
            
        }
    }
    public String formatLongString(String longField){
        /*String finalFieldFormat ='';
String auxField='';
integer count=0;

if(!String.isBlank(longField) && longField!= 'null'){           
String[] stringCharacters = longField.split('');
for(integer i=0;i< stringCharacters.size();i++){   
auxField += stringCharacters[i];       
count++;           
if(count>90 && stringCharacters[i]!='<br/>'){               
finalFieldFormat+=auxField + '<br/>';
auxField='';
count=0;
}else if(i== stringCharacters.size()-1){
finalFieldFormat+=auxField + '<br/>';
}
}
}
if(String.isBlank(finalFieldFormat)){
return longField;
}
return  finalFieldFormat;*/
        
        String concatenacion='';        
        Integer posicion;

        if(!String.isBlank(longField)){  
        List<String> listString = longField.split('\n');
        for(integer i=0;i<listString.size();i++){ 

            if(listString.get(i).length()>90){

                String renglonACortar = listString.get(i);
                for(integer z=0;z<renglonACortar.length();z++){

                    if(renglonACortar.substring(z,z+1)==' ' && z<90 && z>75){
                        concatenacion =concatenarOIgualar(concatenacion,renglonACortar.substring(0,z)+'<br/>');
                        renglonACortar = renglonACortar.substring(z,renglonACortar.length());
                        z= 0;
                    }
                }
                if(String.isNotBlank(renglonACortar)){
                    concatenacion =concatenarOIgualar(concatenacion,renglonACortar +'<br/>');
                }
            }
            else{
                concatenacion =concatenarOIgualar(concatenacion,listString.get(i)+'<br/>');
            }

        }
    }
        return concatenacion;
    }
    
    public String concatenarOIgualar(String retorno,String conca){
        if(String.isBlank(retorno)){
            retorno = conca;
        }
        else{
            retorno +=conca;
        }
        return retorno;
    } 
    
}