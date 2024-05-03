import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class MenuAlergia extends NavigationMixin(LightningElement) {

    dropdown = false;
    @api privado = false;
    currentPageReference = null;
    currentDataId;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            let apiNameCurrentPage = currentPageReference.attributes.name;
            this.currentDataId = apiNameCurrentPage;
       }
    }

    renderedCallback(){
        let div = this.template.querySelector('[data-id='+ this.currentDataId +']')
        if(div){
            div.className = 'text-selected-item-menu-alergia';
        }
    }

    redireccionar(event){
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

    openDropdown(){
        this.dropdown = !this.dropdown;
    }

}