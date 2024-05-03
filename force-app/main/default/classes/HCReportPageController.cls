public without sharing class HCReportPageController {
    public String fechaDeInforme { get; set; }
    public Formulario__c historiaClinica{get; set;}
    public String fechaMediciones{get; set;}
    public String fechaVisita{get; set;}
    public String ultimoRecambio{get; set;}
    public List<String> viasDeAcceso{get; set;}
    public List<String> complicacionesDeAcceso{get; set;}
    public List<String> modalidades{get; set;}
    public List<String> digestivo{get; set;}
    public List<String> metabolicas{get; set;}
    public Boolean pediatricos{get; set;}
    public Boolean nurtricion{get; set;}
    public String edadEnMesesOAnios{get; set;}

    public HCReportPageController() {


        viasDeAcceso = new List<String>();
        complicacionesDeAcceso = new List<String>();
        historiaClinica = new Formulario__c();
        pediatricos=false;
        nurtricion=false;

        historiaClinica = obtenerHC();

        if(historiaClinica.RecordType.DeveloperName=='Historia_Cl_nica_Pedi_trica_de_Nutrici_n'){
            pediatricos=true;
        }else if(historiaClinica.RecordType.DeveloperName=='Historia_Clinica_de_Nutricion'){
            nurtricion=true;
        }

        fechaMediciones= historiaClinica.Fecha_de_la_medici_n__c==null ? null:  historiaClinica.Fecha_de_la_medici_n__c.day() +'/'+ historiaClinica.Fecha_de_la_medici_n__c.month() + '/'+historiaClinica.Fecha_de_la_medici_n__c.year();
        fechaVisita = historiaClinica.Fecha_de_la_visita__c==null ? null:  historiaClinica.Fecha_de_la_visita__c.day() +'/'+ historiaClinica.Fecha_de_la_visita__c.month() + '/'+historiaClinica.Fecha_de_la_visita__c.year();
        ultimoRecambio= historiaClinica.Fecha_ultimo_recambio__c==null ? null: historiaClinica.Fecha_ultimo_recambio__c.day() +'/'+ historiaClinica.Fecha_ultimo_recambio__c.month() + '/'+historiaClinica.Fecha_ultimo_recambio__c.year();
        complicacionesDeAcceso = historiaClinica.Complicacion_actual__c==null ? null: historiaClinica.Complicacion_actual__c.split(';');
        viasDeAcceso = historiaClinica.Via_de_acceso__c==null ? null: historiaClinica.Via_de_acceso__c.split(';');
        modalidades=historiaClinica.Modalidad__c==null ? null: historiaClinica.Modalidad__c.split(';');
        digestivo= historiaClinica.Sistema_digestivo__c==null ? null: historiaClinica.Sistema_digestivo__c.split(';');
        metabolicas= historiaClinica.Complicaciones_metabolicas__c==null ? null: historiaClinica.Complicaciones_metabolicas__c.split(';');
        edadEnMesesOAnios = historiaClinica.Edad__c == 0 ? String.valueOf(historiaClinica.Edad_en_meses__c) + ' meses' : String.valueOf(historiaClinica.Edad__c);
    }

    public Formulario__c obtenerHC(){
        return
            [
            SELECT Id, Name, Peso_ajustado__c,Nombre_y_Apellido_del_Paciente__c ,Peso_Estimado__c,Nombre_y_Apellido_del_Paciente__r.Nutricionista_Asignado__r.Name,
            Nombre_y_Apellido_del_Paciente__r.Enfermero_Asignado__r.Name,Nombre_y_Apellido_del_Paciente__r.Medico_Asignado__r.Name,Patologia__c,Estado_Actual_medico__c,  
            Nombre_y_Apellido_del_Paciente__r.Obra_social__pc,Nombre_y_Apellido_del_Paciente__r.Estado_de_paciente__c,Peso_actual_Talla__c, Talla__c, IMC__c,
            VGS__c, Circunferencia_del_brazo_cm__c, Percentilo_circunferencia_del_Brazo__c, Pliegue_tricipital__c, Percentilo_pliegue_tricipital__c, Edemas1__c,
            area_muscular_del_brazo__c, Percentilo_Area_Muscular_del_Brazo__c, Edemas__c, Sarcopenia__c, Aporte_proteico_total_g_dia__c, Grado_escara__c, Fecha_ultimo_recambio__c,
            Enteral__c,Requerimiento_calorico__c, Requerimiento_Proteico__c, Meta__c, Modalidad__c, Aporte_cal_rico_total_Kcal_d_a__c,Edad__c,Escaras_examen_medico__c,
            Producto__c, Producto2__c, Producto_nro_3__c, Sistema_digestivo__c, Complicaciones_metabolicas__c, Comentarios__c,Aporte_proteico_total_g_d_a__c,
            Fecha__c,Via_de_acceso__c,Complicacion_actual__c,Nombre_y_Apellido_del_Paciente__r.Name,Nombre_y_Apellido_del_Paciente__r.Nutricionista_Asignado__r.Matricula__c,
            Nombre_y_Apellido_del_Paciente__r.Comentarios_coordinador_medico__c, Lugar_de_residencia__c,Visita__c,Fecha_de_la_medici_n__c,peso__c,Calorias_n_2__c,
            Calor_as_n_3__c,Unidades_de_producto_1__c,Unidades_de_producto_n_2__c,Unidades_de_producto_n_3__c,RecordType.DeveloperName,Edad_en_meses__c,Otra_patolog_a__c,
            Estado_nutricional__c,Percentiles_peso_edad__c,Percentiles_talla_edad__c,Percentiles_IMC_edad__c,Fecha_de_la_visita__c,Nombre_y_Apellido_del_Paciente__r.Obra_social__pr.Name,
            Nombre_y_Apellido_del_Paciente__r.Medico_Asignado__r.Matricula__c,
            Nombre_y_Apellido_del_Paciente__r.Nutricionista_Asignado__c
            FROM Formulario__c 
            WHERE Id = :ApexPages.currentPage().getParameters().get('hcid')
            ];
    }
}