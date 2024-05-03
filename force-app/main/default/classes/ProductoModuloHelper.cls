global class ProductoModuloHelper {
    
    
    /************ESTE TRIGGER EN PRODUCCION ESTABA DESACTIVADO, LO ACTIVE NUEVAMENTE PERO COMENTE LA FUNCIONALIDAD VIEJA*****************************************
A partir de una lista de productos actualiza la Formulas_actuales__c de las cuentas asociadas a esos productos. */
    
    /*global static void SetProductsInAccounts(List<id> productsIdsList) {

if (productsIdsList != null && !productsIdsList.isEmpty()) {

Set<Id> accountsIdToUpdate = GetListSetOfAccountFromIdsListProducts(productsIdsList);
UpdateFormulasActualesFromSetOfAccounts(accountsIdToUpdate);
}
}


/**********************************************************************************************
Devuelve un Set de Ids de cuentas a partir de una lista de Productos. */
    
    /*global static Set<Id> GetListSetOfAccountFromIdsListProducts(List<id> productsIdsList) {

if (productsIdsList == null) {
return null;
}

if (!productsIdsList.isEmpty()) {
Set<Id> accountsListIdFromProducts = new Set<Id> ();

List<Producto_de_modulo__c> ModuAccountToUpdate = [
SELECT Modulo_de_paciente__r.Cuenta__c
FROM Producto_de_modulo__c
WHERE formula__c IN :productsIdsList
];

for (Producto_de_modulo__c pdm : ModuAccountToUpdate) {
accountsListIdFromProducts.add(pdm.Modulo_de_paciente__r.Cuenta__c);
}

return accountsListIdFromProducts;
}

return null;
}*/
    
    
    /*================================================================================================
Modifica la casilla de texto de las Formulas Actuales en las cuentas asociadas a los Modulos de Paciente*/
    
    global static void UpdateFormulasActualesFromSetOfAccounts(Set<Id> accountsIdToUpdateFurmulasActuales) {
        
        if (accountsIdToUpdateFurmulasActuales != null && !accountsIdToUpdateFurmulasActuales.isEmpty()) {
            
            List<Modulo_de_paciente__c> listOfModules =
                GetPatientModulesActiveAndProducts(accountsIdToUpdateFurmulasActuales);
            
            Map<id, String> accountWithNewFormulaActuales = new Map<id, String> ();
            
            List<Id> listOfAccountsIds = new List<Id> (accountsIdToUpdateFurmulasActuales);
            for (id acId : listOfAccountsIds) {
                accountWithNewFormulaActuales.put(acId, ' ');
            }
            
            
            for (id accId : accountWithNewFormulaActuales.keySet()) {
                
                if (listOfModules.isEmpty()) {
                    break;
                }
                
                for (Modulo_de_paciente__c mdp : listOfModules) {
                    
                    if (mdp.Cuenta__c != accId) {
                        continue;
                    }
                    
                    String newFormulaActiva = '';
                    String[] formulasActivas = new String[] { };
                        
                        for (Producto_de_modulo__c pdm : mdp.Planes_de_cuidado__r) {
                            formulasActivas.add(pdm.Formula__r.Name + ', ' + pdm.Cantidad__c);
                        }
                    
                    if (formulasActivas.size() > 0) {
                        
                        newFormulaActiva = String.join(formulasActivas, '\r\n');
                        
                        accountWithNewFormulaActuales.put(mdp.Cuenta__c, accountWithNewFormulaActuales
                                                          .get(mdp.Cuenta__c) + newFormulaActiva + '\r\n');
                    }
                    
                }
            }
            
            
            
            if (!accountWithNewFormulaActuales.isEmpty()){ 
                
                List<Account> accountsToUpdateWithNewFormula = new List<Account> ();
                for (id idAcc : accountWithNewFormulaActuales.keySet()) {
                    
                    if (idAcc == null) {
                        continue;
                    }
                    
                    Account newAccount = new Account(id = idAcc, Formulas_actuales__c = accountWithNewFormulaActuales.get(idAcc));
                    accountsToUpdateWithNewFormula.add(newAccount);
                }
                update accountsToUpdateWithNewFormula;
            }
            
        }
        
    }
    
    /**********************************************************************************************
Devuleve una lista de Modulo_de_paciente__c el modulo y sus productos se encuentran activos a partir de un Set de IDs de cuentas. */
    
    global static List<Modulo_de_paciente__c> GetPatientModulesActiveAndProducts(Set<id> listAccounts) {
        
        if (listAccounts == null) {
            return null;
        }
        
        if (!listAccounts.isEmpty()) {
            return[
                SELECT id, Cuenta__c, Estado__c, (
                    SELECT Formula__c, Formula__r.Name, Cantidad__c, Formula__r.IsActive
                    FROM Planes_de_cuidado__r)
                FROM Modulo_de_paciente__c
                WHERE Cuenta__c IN : listAccounts AND Estado__c = 'Activo'
            ];
        }
        
        return null;
    }
    
    public static void autoCompletaCampoModuloTipoDeProducto(List<Producto_de_modulo__c> listaDeProductosDeModulo){
        
        List<Id> idPdm = new List<Id> (); 
        Map<id, Modulo_de_paciente__c> modulosDPToUpdate = new Map<id,Modulo_de_paciente__c> ();                 
        Map<String, Modulo__c> mapaModulos = new Map<String, Modulo__c>();
        Map<String, double> metadataNombreConJerarquia = new Map<String, double>();
        Map<double, String> metadataFilterByNumber = new Map<double, String>();
        List<String> nombresDeProductosYaSeleccionados = new List<String>();
        
        for (Producto_de_modulo__c pdm : listaDeProductosDeModulo) {    
            idPdm.add(pdm.Modulo_de_paciente__c);            
        }
        
        Map<id, Modulo_de_paciente__c> mapModulosPacientes = 
            new Map<Id, Modulo_de_paciente__c> ([
                SELECT id, Modulo_tipo_de_producto__c
                FROM Modulo_de_paciente__c
                WHERE Id IN :idPdm
            ]);
        
        List<Producto_de_modulo__c> pdmYaSeleccionados = [
            SELECT id,Modulo_de_paciente__c,Categoria_de_producto__c  
            FROM Producto_de_modulo__c 
            WHERE Modulo_de_paciente__c IN :mapModulosPacientes.keySet()
        ];
        
        for(Producto_de_modulo__c pdModulo : pdmYaSeleccionados){
            nombresDeProductosYaSeleccionados.add(pdModulo.Categoria_de_producto__c);
        }
        /****Todos las jerarquias disponibles */
        List<Modulo_disponible__mdt> modulosMtd = [
            SELECT Nombre_del_Modulo__c, Numero_de_Jerarquia__c
            FROM Modulo_disponible__mdt 
            WHERE Numero_de_Jerarquia__c != null
            ORDER BY Numero_de_Jerarquia__c ASC
        ];
        List<Modulo_disponible__mdt> modulosMtdFilter = new List<Modulo_disponible__mdt>();
        
        for(Modulo_disponible__mdt meta : modulosMtd){
            metadataNombreConJerarquia.put(meta.Nombre_del_Modulo__c, meta.Numero_de_Jerarquia__c);
            
            if(nombresDeProductosYaSeleccionados.contains(meta.Nombre_del_Modulo__c)){
                modulosMtdFilter.add(meta);
                metadataFilterByNumber.put(meta.Numero_de_Jerarquia__c,meta.Nombre_del_Modulo__c);
            }
            
        }        
        List<Modulo__c> modulosRelacionados = [
            SELECT id,Name 
            FROM Modulo__c 
            WHERE Name IN :nombresDeProductosYaSeleccionados
        ];
        
        if(!modulosRelacionados.isEmpty()){
            for(Modulo__c mod : modulosRelacionados){
                mapaModulos.put(mod.name, mod);
            }
        }
        for (Producto_de_modulo__c pdm : listaDeProductosDeModulo) {
            double codigoDeProducto = metadataNombreConJerarquia.get(pdm.Categoria_de_producto__c); 
            Modulo__c modulo = mapaModulos.get(pdm.Categoria_de_producto__c);
            Modulo_de_paciente__c moduloDePaciente = mapModulosPacientes.get(pdm.Modulo_de_paciente__c);    
             

            if(codigodeproducto!=null && modulo!=null && moduloDePaciente!=null){
                /**Comparo jerarquia de producto actual con el primero de los existentes***/
                if(codigoDeProducto <= modulosMtdFilter.get(0).Numero_de_Jerarquia__c){
                    moduloDePaciente.Modulo_tipo_de_producto__c = metadataFilterByNumber.get(codigoDeProducto);
                    moduloDePaciente.Modulo__c = mapaModulos.get(metadataFilterByNumber.get(codigoDeProducto)).id;
                    modulosDPToUpdate.put(moduloDePaciente.id, moduloDePaciente); 
                }
            } 
            if (!modulosDPToUpdate.isEmpty()) {               
                update modulosDPToUpdate.values();
            } 
        }
    }
    
    
    public static void autoCompletaCampoModuloTipoDeProductoSiSeEliminaUnProducto(List<Producto_de_modulo__c> listaDeProductosDeModulo){
        
        List<Id> idPdm = new List<Id> (); 
        Map<id, Modulo_de_paciente__c> modulosDPToUpdate = new Map<id,Modulo_de_paciente__c> ();                 
        Map<String, Modulo__c> mapaModulos = new Map<String, Modulo__c>();
        List<String> nombresDeProductosYaSeleccionados = new List<String>();
        List<Modulo_disponible__mdt> modulosMtdFilter = new List<Modulo_disponible__mdt>();
        
        for (Producto_de_modulo__c pdm : listaDeProductosDeModulo) {    
            idPdm.add(pdm.Modulo_de_paciente__c);            
        }
        
        Map<id, Modulo_de_paciente__c> mapModulosPacientes = 
            new Map<Id, Modulo_de_paciente__c> ([
                SELECT id, Modulo_tipo_de_producto__c
                FROM Modulo_de_paciente__c
                WHERE Id IN :idPdm
            ]);
        
        List<Producto_de_modulo__c> pdmYaSeleccionados = [
            SELECT id,Modulo_de_paciente__c,Categoria_de_producto__c  
            FROM Producto_de_modulo__c 
            WHERE Modulo_de_paciente__c IN :mapModulosPacientes.keySet()
        ];
        
        for(Producto_de_modulo__c pdModulo : pdmYaSeleccionados){
            nombresDeProductosYaSeleccionados.add(pdModulo.Categoria_de_producto__c);
        }
        /****Todos las jerarquias disponibles */
        List<Modulo_disponible__mdt> modulosMtd = [
            SELECT Nombre_del_Modulo__c, Numero_de_Jerarquia__c
            FROM Modulo_disponible__mdt 
            WHERE Numero_de_Jerarquia__c != null
            ORDER BY Numero_de_Jerarquia__c ASC
        ];
        
        for(Modulo_disponible__mdt meta : modulosMtd){           
            if(nombresDeProductosYaSeleccionados.contains(meta.Nombre_del_Modulo__c)){
                modulosMtdFilter.add(meta);
            }           
        }      
        
        List<Modulo__c> modulosRelacionados = [
            SELECT id,Name 
            FROM Modulo__c 
            WHERE Name IN :nombresDeProductosYaSeleccionados
        ];
        
        if(!modulosRelacionados.isEmpty()){
            for(Modulo__c mod : modulosRelacionados){
                mapaModulos.put(mod.name, mod);
            }
        }          
        for (Producto_de_modulo__c pdm : listaDeProductosDeModulo) {
            String nombreDelModuloConMayorJerarquia =modulosMtdFilter.get(0).Nombre_del_Modulo__c;
            Modulo__c modulo = mapaModulos.get(nombreDelModuloConMayorJerarquia);
            Modulo_de_paciente__c moduloDePaciente = mapModulosPacientes.get(pdm.Modulo_de_paciente__c); 
            
            if(modulo!=null && moduloDePaciente!=null){
                moduloDePaciente.Modulo_tipo_de_producto__c = nombreDelModuloConMayorJerarquia;
                moduloDePaciente.Modulo__c = mapaModulos.get(nombreDelModuloConMayorJerarquia).id;
                modulosDPToUpdate.put(moduloDePaciente.id, moduloDePaciente); 
            }
        }
        
        if (!modulosDPToUpdate.isEmpty()) {               
            update modulosDPToUpdate.values();
        } 
    }   

}