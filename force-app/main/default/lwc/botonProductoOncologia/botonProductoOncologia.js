import { api, LightningElement} from 'lwc';

export default class BotonProductoOncologia extends LightningElement {

    @api text;
    @api buttonId;
    @api typeRedirect;
    @api classTag;

    clickButton(){
        let buttonId = this.buttonId;
        let typeRedirect = this.typeRedirect;
        let value = {
            'buttonId':buttonId,
            'typeRedirect':typeRedirect
        }
        const event = new CustomEvent('senddata', {
            detail: {value}
        });
        this.dispatchEvent(event);
    }

}