public class ServiciosDeModuloTriggerHelper{
    
    public static void completaTipoDeServicio(List<Servicios_del_Modulo__c> listaDeServicioDeModulo){
        Set<Id> idsDeServicios = new Set<Id> (); 
        Map<id, Modulo_de_paciente__c> modulosParaActualizar = new Map<id, Modulo_de_paciente__c> ();         
        Map<String, double> metadataNombreConJerarquia = new Map<String, double>();
        Map<String, String> serviciosConServiciosDeModulo = new Map<String, String>();
        Map<double, String> metadataFilterByNumber = new Map<double, String>();
        List<String> nombresDeProductosYaSeleccionados = new List<String>();
        Map<id, String> servicioConNombres = new Map<id, String>();
        List<double> serviciosPersonalizados = new List<double>();
        List<Servicios_generales_y_especialidades__mdt> serviciosMtdFilter = new List<Servicios_generales_y_especialidades__mdt>();
        /****Todos las jerarquias disponibles */
        List<Servicios_generales_y_especialidades__mdt> serviciosMtd =[
            SELECT id,Nombre_de_servicio__c,Numero_de_Jerarquia__c,Tipo_de_servicio_en_MDP__c
            FROM Servicios_generales_y_especialidades__mdt
            ORDER BY Numero_de_Jerarquia__c DESC
        ];
        
        for (Servicios_del_Modulo__c unServicio : listaDeServicioDeModulo) {    
            idsDeServicios.add(unServicio.Modulo_de_paciente__c);            
        }
        
        Map<id, Modulo_de_paciente__c> mapModulosPacientes = new Map<Id, Modulo_de_paciente__c> ([
            SELECT id, Tipo__c
            FROM Modulo_de_paciente__c
            WHERE Id IN :idsDeServicios
        ]);
        
        List<Servicios_del_Modulo__c> serviciosYaSeleccionados = [
            SELECT id,Modulo_de_paciente__c,Servicios_disponibles__c  
            FROM Servicios_del_Modulo__c 
            WHERE Modulo_de_paciente__c IN :mapModulosPacientes.keySet()
        ];
        
        for(Servicios_del_Modulo__c sModulo : serviciosYaSeleccionados){
            nombresDeProductosYaSeleccionados.add(sModulo.Servicios_disponibles__c);
            if(sModulo.Servicios_disponibles__c.contains('Motora')){
                servicioConNombres.put(sModulo.Modulo_de_paciente__c, sModulo.Servicios_disponibles__c);
            }
        }

        for(Servicios_generales_y_especialidades__mdt meta : serviciosMtd){
            metadataNombreConJerarquia.put(meta.Nombre_de_servicio__c, meta.Numero_de_Jerarquia__c);
            serviciosConServiciosDeModulo.put(meta.Nombre_de_servicio__c, meta.Tipo_de_servicio_en_MDP__c);
            metadataFilterByNumber.put(meta.Numero_de_Jerarquia__c,meta.Tipo_de_servicio_en_MDP__c);
            
            if(nombresDeProductosYaSeleccionados.contains(meta.Nombre_de_servicio__c)){
                serviciosMtdFilter.add(meta);
                if(meta.Numero_de_Jerarquia__c>= 1 && meta.Numero_de_Jerarquia__c<= 3){
                    serviciosPersonalizados.add(meta.Numero_de_Jerarquia__c);
                }     
            }
        }
        
        for (Servicios_del_Modulo__c servicio : listaDeServicioDeModulo) {
            String serviciosEnMdp = servicioConNombres.get(servicio.Modulo_de_paciente__c);

            if(servicio.Servicios_disponibles__c!=null){
            if(nombresDeProductosYaSeleccionados.contains(servicio.Servicios_disponibles__c)){
                servicio.addError(Label.Error_Motora + servicio.Servicios_disponibles__c);           

            }else if(servicio.Servicios_disponibles__c.contains('Motora') &&
                     serviciosEnMdp != null &&
                     serviciosEnMdp.contains('Motora'))
            {
                servicio.addError(Label.Error_Motora + servicio.Servicios_disponibles__c);                       
            }
            else{
                double numeroDeServicio = metadataNombreConJerarquia.get(servicio.Servicios_disponibles__c); 
                Modulo_de_paciente__c moduloDePaciente = mapModulosPacientes.get(servicio.Modulo_de_paciente__c); 
                
                if(numeroDeServicio!=null && moduloDePaciente!=null){  
                    /**Comparo jerarquia de producto actual con el primero de los existentes***/
                    if(!serviciosMtdFilter.isEmpty()){ 
                        if(numeroDeServicio >= serviciosMtdFilter.get(0).Numero_de_Jerarquia__c){
                            moduloDePaciente.Tipo__c = metadataFilterByNumber.get(numeroDeServicio);
                        }
                        modulosParaActualizar.put(moduloDePaciente.id, moduloDePaciente); 
                    }
                    else {
                        moduloDePaciente.Tipo__c = metadataFilterByNumber.get(numeroDeServicio);
                        modulosParaActualizar.put(moduloDePaciente.id, moduloDePaciente);                       
                    }
                }
            }
            servicio.Tarea_motora_generada__c = true;
        }
    }
        if (!modulosParaActualizar.isEmpty()) {               
            update modulosParaActualizar.values();
        } 
    
    }
    
    public static void completaTipoDeServicioDespuesDeEliminar(List<Servicios_del_Modulo__c> listaDeServicioDeModulo){
        
        List<Id> idSvm = new List<Id>();
        List<String> serviciosYaSeleccionadosEnMDP = new List<String>();
        List<Modulo_de_paciente__c> modulosParaActualizar = new List<Modulo_de_paciente__c>();
        Map<String, double> metadataNombreConJerarquia = new Map<String, double>();
        Map<String, String> serviciosConServiciosDeModulo = new Map<String, String>();
        List<String> nombresDeServiciosYaSeleccionados = new List<String>();
        Map<double, String> metadataPorNumero = new Map<double, String>();
        List<double> serviciosPersonalizados = new List<double>();
        
        List<Servicios_generales_y_especialidades__mdt> modulosMtd =[
            SELECT id,Nombre_de_servicio__c,Numero_de_Jerarquia__c,Tipo_de_servicio_en_MDP__c
            FROM Servicios_generales_y_especialidades__mdt
            ORDER BY Numero_de_Jerarquia__c DESC
        ];
        
        for (Servicios_del_Modulo__c sdm : listaDeServicioDeModulo){
            idSvm.add(sdm.Modulo_de_paciente__c);                                        
        }
        
        Map<id, Modulo_de_paciente__c> mapModulosPacientes = new Map<Id, Modulo_de_paciente__c>([
            SELECT id, Modulo_tipo_de_servicio__c
            FROM Modulo_de_paciente__c
            WHERE Id IN :idSvm
        ]);
        
        List<Servicios_del_Modulo__c> serviciosYaSeleccionados = [
            SELECT id,Modulo_de_paciente__c,Servicios_disponibles__c  
            FROM Servicios_del_Modulo__c 
            WHERE Modulo_de_paciente__c IN :mapModulosPacientes.keySet()
        ];
        
        for(Servicios_del_Modulo__c sModulo : serviciosYaSeleccionados){
            nombresDeServiciosYaSeleccionados.add(sModulo.Servicios_disponibles__c);      
        }
        
        for(Servicios_generales_y_especialidades__mdt meta : modulosMtd){
            metadataPorNumero.put(meta.Numero_de_Jerarquia__c,meta.Tipo_de_servicio_en_MDP__c);
            
            if(nombresDeServiciosYaSeleccionados.contains(meta.Nombre_de_servicio__c)){
                metadataNombreConJerarquia.put(meta.Nombre_de_servicio__c, meta.Numero_de_Jerarquia__c);
                serviciosConServiciosDeModulo.put(meta.Nombre_de_servicio__c, meta.Tipo_de_servicio_en_MDP__c);
                serviciosYaSeleccionadosEnMDP.add(meta.Tipo_de_servicio_en_MDP__c);
                if(meta.Numero_de_Jerarquia__c>= 1 && meta.Numero_de_Jerarquia__c<= 3){
                    serviciosPersonalizados.add(meta.Numero_de_Jerarquia__c);
                }     
            }   
        }
        
        for (Servicios_del_Modulo__c servicio : listaDeServicioDeModulo){           
            Modulo_de_paciente__c moduloDePaciente = mapModulosPacientes.get(servicio.Modulo_de_paciente__c);
            if(!serviciosYaSeleccionadosEnMDP.isEmpty()){
                String mayorServicio = serviciosYaSeleccionadosEnMDP.get(0);
                if(moduloDePaciente!=null){                  
                    moduloDePaciente.Tipo__c = mayorServicio;
                }
            }else{
                moduloDePaciente.Tipo__c = metadataPorNumero.get(0);
            }
            modulosParaActualizar.add(moduloDePaciente);
        }           
        if (!modulosParaActualizar.isEmpty()){
            update modulosParaActualizar;
        }
    }  
}