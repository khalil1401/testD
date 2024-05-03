import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class NavegacionInternaNSJ extends NavigationMixin(LightningElement) {

    @api areaTerapeutica;
    @api private;
    @api pacientesRegulares;
    @api menuStyle;
    @api color;
    dropdown = false;
    itemsOncologia = [
        {'dataId':'custom_oncologia__c', 'label':'Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'registro_y_solicitud__c', 'label':' Solicitud de Kit de Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'Vivir_Mejor__c', 'label':'Vivir Mejor', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'Nutricion__c', 'label':'Nutrición Oncológica', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'productos_oncologia__c', 'label':'Productos', 'class':'text-item-nav-int-nsj', 'private': true},
    ];
    itemsTC = [
        {'dataId':'custom_terapia_cetogenica__c', 'label':'Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'registro_y_solicitud__c', 'label':' Solicitud de Kit de Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'custom_que_es_la_terapia_cetogenica__c', 'label':'La Terapia Cetogénica', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'Mapa__c', 'label':'Los Centros', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'custom_recetas_terapia_cetogenica__c', 'label':'Recetas', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'faq_terapia_cetognica__c', 'label':'Preguntas Frecuentes', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'custom_videos_terapia_cetogenica__c', 'label':'Videos', 'class':'text-item-nav-int-nsj', 'private': false},
    ];
    itemsMetabolicos = [
        {'dataId':'metabolicos__c', 'label':'Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'registro_y_solicitud__c', 'label':' Solicitud de Kit de Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'errores_congenitos_del_metabolismo__c', 'label':'Errores Congénitos del Metabolismo', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'articulos_de_interes__c', 'label':'Artículos de interés', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'nutricion_y_ecm__c', 'label':'Nutrición y ECM', 'class':'text-item-nav-int-nsj', 'private': false},
    ];
    itemsAlergia = [
        {'dataId':'Alergia__c', 'label':'Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'registro_y_solicitud__c', 'label':' Solicitud de Kit de Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'Alergia__c', 'label':'¿Qué es la APLV?', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'cuidados_y_recomendaciones_alergia__c', 'label':'Cuidados y recomendaciones', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'Recetario_Alergia__c', 'label':'Recetario', 'class':'text-item-nav-int-nsj', 'private': true},
        {'dataId':'camino_aplv_alergia__c', 'label':'El camino de la APLV', 'class':'text-item-nav-int-nsj', 'private': false},
    ];
    itemsDigestivos = [
        {'dataId':'digestivos__c', 'label':'Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'registro_y_solicitud__c', 'label':' Solicitud de Kit de Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
    ];
    itemsDesafiosDelCrecimiento = [
        {'dataId':'desafios_del_crecimiento__c', 'label':'Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'registro_y_solicitud__c', 'label':'Solicitud de Kit de Inicio', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'desafios_del_crecimiento__c', 'label':'Patologías crónicas', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'desafios_del_crecimiento__c', 'label':'Patologías agudas o traumatismos', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'desafios_del_crecimiento__c', 'label':'Tratamiento nutricional', 'class':'text-item-nav-int-nsj', 'private': false},
        {'dataId':'desafios_del_crecimiento__c', 'label':'Bomba de nutrición enteral', 'class':'text-item-nav-int-nsj', 'private': false},
    ];
    itemsOncologiaRS = [
        {'dataId':'https://www.facebook.com/comunidadmetabolica', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20FB.png', 'class':'img-rs-nav-int-nsj'},
        {'dataId':'https://www.instagram.com/comunidadmetabolica/', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20IG.png', 'class':'img-rs-nav-int-nsj'},
    ];
    itemsTCRS = [
        {'dataId':'https://www.facebook.com/DietaParaEpilepsia', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20FB.png', 'class':'img-rs-nav-int-nsj'},
        {'dataId':'https://www.instagram.com/dietaparaepilepsia/', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20IG.png', 'class':'img-rs-nav-int-nsj'},
    ];
    itemsMetabolicosRS = [
        {'dataId':'https://www.facebook.com/comunidadmetabolica', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20FB.png', 'class':'img-rs-nav-int-nsj'},
        {'dataId':'https://www.instagram.com/comunidadmetabolica/', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20IG.png', 'class':'img-rs-nav-int-nsj'},
    ];
    itemsAlergiaRS = [
        {'dataId':'https://www.instagram.com/nutriciacomunidad/', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_1/PP-Metab%C3%B3licos%20-Icono%20IG.png', 'class':'img-rs-nav-int-nsj'},
    ];
    items = [];
    itemsFiltered = [];
    itemsRS = [];
    currentPageReference = null;
    currentDataId;
    homeApiName;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            let apiNameCurrentPage = currentPageReference.attributes.name;
            this.currentDataId = apiNameCurrentPage;
        }
    }

    connectedCallback(){
        if(this.areaTerapeutica == 'Oncología'){
            this.items = this.itemsOncologia;
            this.itemsRS = this.itemsOncologiaRS;
        }
        else if(this.areaTerapeutica == 'Dieta Cetogénica'){
            this.items = this.itemsTC;
            this.itemsRS = this.itemsTCRS;
        }
        else if(this.areaTerapeutica == 'Metabólicos'){
            this.items = this.itemsMetabolicos;
            this.itemsRS = this.itemsMetabolicosRS;
        }
        else if(this.areaTerapeutica == 'Alergia'){
            this.items = this.itemsAlergia;
            this.itemsRS = this.itemsAlergiaRS;
        }
        else if(this.areaTerapeutica == 'Digestivos'){
            this.items = this.itemsDigestivos;
        }
        else if(this.areaTerapeutica == 'Disfagia'){
            this.items = this.itemsDisfagia;
            this.itemsRS = null;
        }
        else if(this.areaTerapeutica == 'Malnutricion'){
            this.items = this.itemsMalnutricion;
            this.itemsRS = null;
        }
        else if(this.areaTerapeutica == 'Desafíos del Crecimiento'){
            this.items = this.itemsDesafiosDelCrecimiento;
            this.itemsRS = null;
        }
        this.filterItems();
    }

    renderedCallback(){
        let div = this.template.querySelector('[data-id='+ this.currentDataId +']');
        if(div){
            if(!this.menuStyle){
                div.className = 'text-selected-item-nav-int-nsj';
            }
            else{
                div.className = 'selected-item-nav-int-nsj';
            }
        }

        let divMenu = this.template.querySelector('[data-id="menu-int-nsj"]');
        if(divMenu){
            divMenu.style.backgroundColor = this.color;
            divMenu.style.borderColor = this.color;
        }

        let divDropdownMenu = this.template.querySelector('[data-id="dropdown-menu-int-nsj"]');
        if(divDropdownMenu){
            divDropdownMenu.style.backgroundColor = this.color;
        }
    }

    redirect(event){
        let apiName = event.target.dataset.id;

        if(apiName == 'registro_y_solicitud__c'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                },
                state: {
                    area: this.areaTerapeutica
                }
            });
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                }
            });
        }
    }

    redirectRS(event){
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: apiName
            }
        });
    }

    filterItems(){
        for (let i in this.items) {
            if(!this.items[i].private){
                this.itemsFiltered.push(this.items[i]);
            }
            if(this.items[i].private && this.private){
                this.itemsFiltered.push(this.items[i]);
            }
            if(this.items[i].label == 'Inicio'){
                this.homeApiName = this.items[i].dataId;
            }
        }
        if(this.pacientesRegulares){
            this.itemsFiltered.splice(1,1);
        }
    }

    openDropdown(){
        this.dropdown = !this.dropdown;
    }
}