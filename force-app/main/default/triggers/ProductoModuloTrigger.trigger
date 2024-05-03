trigger ProductoModuloTrigger on Producto_de_modulo__c(after insert, after delete,before delete, after update, after undelete,before insert) {

    /****ESTE TRIGGER EN PRODUCCION ESTABA DESACTIVADO, LO ACTIVE NUEVAMENTE PERO COMENTE LA FUNCIONALIDAD VIEJA****/
    
    if(Trigger.isAfter && Trigger.isInsert){
        ProductoModuloHelper.autoCompletaCampoModuloTipoDeProducto(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        ProductoModuloHelper.autoCompletaCampoModuloTipoDeProductoSiSeEliminaUnProducto(Trigger.old);
            
     }
    /*cList<id> productsIdToUpdateInAccounts = new List<id> ();

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {

            for (Producto_de_modulo__c pdt : Trigger.new) {
                productsIdToUpdateInAccounts.add(pdt.Formula__c);
            }
        }
        else if (Trigger.isUpdate) {

            for (Producto_de_modulo__c pdt : Trigger.new) {
                productsIdToUpdateInAccounts.add(pdt.Formula__c);
            }
        }
        else if (Trigger.isDelete) {

            for (Producto_de_modulo__c pdt : Trigger.old) {
                productsIdToUpdateInAccounts.add(pdt.Formula__c);
            }
        }
        else if (Trigger.isUndelete) {

            for (Producto_de_modulo__c pdt : Trigger.new) {
                productsIdToUpdateInAccounts.add(pdt.Formula__c);
            }
        }
    }

    if (!productsIdToUpdateInAccounts.isEmpty()){
        ProductoModuloHelper.SetProductsInAccounts(productsIdToUpdateInAccounts);
    }*/

}