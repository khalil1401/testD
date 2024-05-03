import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import iconosotrosNSJ from '@salesforce/resourceUrl/iconNosotrosNSJ';
import iconpatologiasNSJ from '@salesforce/resourceUrl/iconPatologiasNSJ';
import iconPatologiasSelectedNSJ from '@salesforce/resourceUrl/iconPatologiasSelectedNSJ';
import iconproductosNSJ from '@salesforce/resourceUrl/iconproductosNSJ';

export default class MenuBotoneraNSJ extends NavigationMixin(LightningElement) {

    iconosotros = iconosotrosNSJ;
    iconpatologias = iconpatologiasNSJ;
    iconPatologiasSelected = iconPatologiasSelectedNSJ;
    iconproductos = iconproductosNSJ;

    items = [
        {'dataId':'Alergia__c', 'label':'Alergia', 'url':'alergia'},
        {'dataId':'Stroke__c', 'label':'Disfagia', 'url':'disfagia'},
        {'dataId':'custom_terapia_cetogenica__c', 'label':'Terapia Cetogénica', 'url':'terapia-cetogenica'},
        {'dataId':'digestivos__c', 'label':'Digestivos', 'url':'digestivos'},
        {'dataId':'malnutricion_home__c', 'label':'Malnutrición', 'url':'malnutricion'},
        {'dataId':'desafios_del_crecimiento__c', 'label':'Desafíos del Crecimiento', 'url':'desafios'},        
        {'dataId':'metabolicos__c', 'label':'Metabólicos', 'url':'metabolicos'},
        {'dataId':'custom_oncologia__c', 'label':'Oncología', 'url':'oncologia'},
    ];

    renderedCallback() {
        let urlString = window.location.href;
        let baseURL = urlString.substring(urlString.indexOf("/s/")+3, urlString.length);
        let ta = baseURL.split('/');

        for(let i = 0; i < this.items.length; i++){
            if(this.items[i].url == ta[0]){
                let divItem = this.template.querySelector('[data-id="'+this.items[i].dataId+'"]');
                if(divItem){
                    divItem.classList.add('item-botonera-selected-mobile-nsj');
                }
            }
        }
    }

    selectItem() {
        //show items
        let divItems = this.template.querySelector('[data-id="items-patologias-mobile"]');
        if(divItems){
            let display = window.getComputedStyle(divItems).display;
            if(display == 'none'){
                divItems.style.display = "initial";
            }
            else{
                divItems.style.display = "none";
            }
        }
    }

    redirecTo(event){
        //set style to items
        let divItem = this.template.querySelector('[data-id="items-patologias-mobile"]');
        if(divItem) {
            divItem.style.display = "none";
        }
        //redirect to ta
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
        
        //Redireccion directa a digestivos
        /**
        if(apiName == 'digestivos__c'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'registro_y_solicitud__c'
                },
				state: {
					area: 'Digestivos'
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
         */
    }
}