({
   validarDNI: function(component, event, helper) {
      helper.getPacientes(component, event, helper);
   },
   handleOptionPacienteSelected: function(component, event, helper) {
      helper.setPaciente(component, event);
   },
   login: function(component, event, helper) {
      helper.logearse(component, event, helper);
   },
   ingresarPaciente: function(component, event, helper) {
      helper.getUsername(component, event, helper);
   },
   volverAIngresarDNI: function(component, event, helper) {
      helper.ingresarDNI(component, event, helper);
   },
   volverAElegirPaciente: function(component, event, helper) {
      helper.mostrarPacientes(component, event, helper);
   },
   volverAIngresarConstrasena: function(component, event, helper) {
      helper.mostrarIngresarContrasena(component, event, helper);
   },
   confirmarReestablecimientoContrasena : function(component, event, helper){
      helper.getEmailUsuario(component, event, helper);
   },
   resetPassword: function(component, event, helper) {
      helper.enviarMailResetPassword(component, event, helper);
   },
   likenClose: function(component, event, helper) {
      helper.close(component, event, helper);
   },
   pressEnterFormDNI : function(component, event, helper){
      helper.keyCheckFormDNI(component, event, helper);
   },
   pressEnterFormPacientes : function(component, event, helper){
      helper.keyCheckFormPacientes(component, event, helper);
   },
   pressEnterFormPass : function(component, event, helper){
      helper.keyCheckFormPass(component, event, helper);
   },
   togglePassword : function(component, event, helper) {
      if(component.get("v.showpassword",true)){
          component.set("v.showpassword",false);
      }else{
          component.set("v.showpassword",true);
      }
  },
})