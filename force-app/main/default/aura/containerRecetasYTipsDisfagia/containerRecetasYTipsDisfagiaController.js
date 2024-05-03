({
    doInit : function(component, event, helper) {
        //seteo atributos header
        let tituloHeader = '<p class="tituloHeaderAzulClaro">Recetas y Tips</p>';
        component.set("v.tituloHeader", tituloHeader);
        let lineaHeader = '<div class="lineaHeaderStrokeAzulClaro" style="width:50%"></div>';
        component.set("v.lineaHeader", lineaHeader);
        let primeraBajadaHeader = '<p class="subtituloHeaderStrokeAzulClaro">Videos del chef</p>';
        component.set("v.primeraBajadaHeader", primeraBajadaHeader);
        let segundaBajadaHeader = '<br/>';
        component.set("v.segundaBajadaHeader", segundaBajadaHeader);
        //seteo atributos contenedor imagen texto
        let tituloImagenTexto = '<p class="tituloImagenTextoStroke">Desde Nutricia</p> <div class="lineaImagenTextoImgCentroStroke slds-align_absolute-center" style="width: 200px;"><div/>';
        component.set("v.tituloImagenTexto", tituloImagenTexto);
        let textoPrimeraBajadaImagenTexto = '<p class="textoImagenTextoStrokeCentro slds-m-top_x-large">     En nuestro afán de trabajar por la calidad de vida de las personas con disfagia y de sus      familias, intentamos que puedan seguir disfrutando del placer de comer sin descuidar su      salud. Es por ese motivo, que ponemos a disposición de pacientes y cuidadores una larga      lista de recetas y tips para personas con disfagia. Platos adaptados para poder comer con      seguridad pero seguir disfrutando de los pequeños placeres de la vida. De esta forma      cumplimos con nuestra ambición de mejorar la calidad de vida de las personas con disfagia,      de sus cuidadores y de sus familias. </p>';
        component.set("v.textoPrimeraBajadaImagenTexto", textoPrimeraBajadaImagenTexto);
    },
    getValueFromLwc : function(component, event, helper) {
        let tipoReceta = event.getParam('value').tipoReceta;
		component.set("v.tipoDeReceta", tipoReceta);
		component.set("v.tituloHeader", '<p class="tituloHeaderAzulClaro">'+ tipoReceta +'</p>');
	}
})