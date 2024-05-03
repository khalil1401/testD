({
    doInit : function(component, event, helper) {
        var currentUrl = window.location.href;
        var formularioId = currentUrl.split("/");
        var action = component.get('c.getPDFInfo');
        action.setParams({ formularioId:formularioId[formularioId.length - 1]});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('State: ' , state);
            if(state === 'SUCCESS'){
                var pdfInfo = response.getReturnValue();
                var href = 'data:application/octet-stream;base64,' + pdfInfo.pdfInfoBase64;
                
                //Crea un elemento <a> para ser la funcionalidad de descarga de documentos de javascript
                //Desde el controlador APEX se está recibiendo un String en formato Base64
                //que es decoded con 'data:application/octet-stream;base64,'
                let downloadLink = document.createElement("a"); //a = <a></a> (HTML)
                downloadLink.href = href;
                downloadLink.download = 'Formulario ' + pdfInfo.formularioName + '.pdf';
                downloadLink.click();      
                setTimeout(function(){
                    $A.get("e.force:closeQuickAction").fire();
                }, 1);
            }
        });
        $A.enqueueAction(action);
        
    }
})