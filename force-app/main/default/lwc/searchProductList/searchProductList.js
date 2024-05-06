import { LightningElement, api, track } from 'lwc';

export default class SearchProductList extends LightningElement {
    
    @api products;
    @api selectedproducts;
    @track protuctsToShow;

    handleKeyChange(event) {
        let termSearch = event.target.value;
        if(termSearch.length < 3 ){
            this.protuctsToShow = [];
            return;
        }
        let options = [];
        this.products.forEach(element => {
            if(element.name.toLowerCase().includes(termSearch.toLowerCase()) || element.productCode.toLowerCase().includes(termSearch.toLowerCase())){
                options.push(element);
            }
        });
        //Se filtran los items que ya estan seleccionados
        let result = options.filter(
            item => !this.selectedproducts.some(
                item2 => item.productoId === item2.productoId
        ));
        
        this.protuctsToShow = result;
    }

    handleSelect(event){
        let recordId = event.currentTarget.dataset.id;
        const selection = new CustomEvent('select',{
            detail: recordId
        });
        this.dispatchEvent(selection);
        
        //Limpiar la busqueda
        let input = this.template.querySelector('lightning-input');
        input.value = null;
        this.protuctsToShow = [];
    }

}