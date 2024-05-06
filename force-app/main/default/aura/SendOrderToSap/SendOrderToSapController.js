({
    handleUpdate: function (component, event, helper) {
        let changeType = event.getParams().changeType;
        let status;
        let recordType = JSON.stringify(component.get("v.orderShowData").RecordType.Name).toString();
        if (changeType === "CHANGED" || changeType === "LOADED") {
            let recordId = component.get('v.recordId');
            status = JSON.stringify(component.get("v.orderShowData").Status).toString();
			console.log(recordType);
            if(recordType == '"Pedido de Venta Directa"' || recordType == '"Pedido sin Cargo"'){

                if(status == '"Confirmado"'){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Enviado!",
                        "message": "El Pedido ha sido enviado a SAP",
                        "type" : 'success'
                    });
                    toastEvent.fire();

                    component.set('v.sucess', true);

                    helper.sendOrder(component, recordId);
    
                    setTimeout(function(){
                        $A.get('e.force:refreshView').fire();
                    },6000);
                   /*  setTimeout(function(){
                        let quickActionClose = $A.get("e.force:closeQuickAction");
                        quickActionClose.fire();
                    },2000); */
                    
                    
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Solo se puede enviar los Pedidos Confirmados",
                        "type" : 'error'
                    });
                    toastEvent.fire();

                    $A.get("e.force:closeQuickAction").fire()
                }
            }
            if(recordType == '"Devoluciones"' || recordType == '"Reclamo por faltantes"' || recordType == '"Diferencia de precios y descuentos"' || recordType == '"Devoluciones de pedidos sin cargo"'){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Enviado!",
                        "message": "El Reclamo ha sido enviado",
                        "type" : 'success'
                    });
                    toastEvent.fire();

                    component.set('v.sucess', true);

                    helper.sendCase(component, recordId);
                    $A.get("e.force:closeQuickAction").fire()
                    
            }
            
        }   
    }
})