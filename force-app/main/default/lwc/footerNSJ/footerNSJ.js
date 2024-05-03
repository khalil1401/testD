import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FooterNSJ extends NavigationMixin(LightningElement) {

    @api textPrimeraLinea;
    @api textTerminos;
    @api textPoliticas;
    @api textFAQ;
    @api apiNameTerminos;
    @api apiNamePoliticas;
    @api apiNameFAQ;

    redirectTo(event){
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

}