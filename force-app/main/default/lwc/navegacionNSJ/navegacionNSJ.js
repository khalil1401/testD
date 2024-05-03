import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavegacionNSJ extends NavigationMixin(LightningElement) {

    dropdown = false;
    items = [
        {'dataId':'Alergia__c', 'label':'ALERGIA', 'class':'vl'},
        {'dataId':'Stroke__c', 'label':'DISFAGIA', 'class':'vl'},
        {'dataId':'custom_terapia_cetogenica__c', 'label':'TERAPIA CETOGÉNICA', 'class':'vl'},
        {'dataId':'digestivos__c', 'label':'DIGESTIVOS', 'class':'vl'},
        {'dataId':'malnutricion_home__c', 'label':'MALNUTRICIÓN', 'class':'vl'},
        {'dataId':'custom_oncologia__c', 'label':'ONCOLOGÍA', 'class':'vl'},
        {'dataId':'metabolicos__c', 'label':'METABÓLICOS', 'class':''},
    ];

    itemsMobile = [
        {'dataId':'Alergia__c', 'label':'Alergia', 'class':'vl'},
        {'dataId':'Stroke__c', 'label':'Disfagia', 'class':'vl'},
        {'dataId':'custom_terapia_cetogenica__c', 'label':'Terapía Cetogénica', 'class':'vl'},
        {'dataId':'digestivos__c', 'label':'Digestivos', 'class':'vl'},
        {'dataId':'malnutricion_home__c', 'label':'Malnutrición', 'class':'vl'},
        {'dataId':'custom_oncologia__c', 'label':'Oncología', 'class':'vl'},
        {'dataId':'metabolicos__c', 'label':'Metabólicos', 'class':''},
    ];

    redireccionar(event){
        let apiName = event.target.dataset.id;
        if(apiName == 'registro_y_solicitud__c'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                }
                ,
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
    }

    openDropdown(){
        this.dropdown = !this.dropdown;
    }

}