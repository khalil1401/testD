import { LightningElement, api } from 'lwc';

export default class CmpDigestivos extends LightningElement {

    @api
    page;

    diagnosticoPage;
    microbiotaPage;

    connectedCallback() {
        if(this.page == 'Diagnóstico') {
            this.diagnosticoPage = true;
        }
        else if(this.page == 'Microbiota Intestinal') {
            this.microbiotaPage = true;
        }
    }

}