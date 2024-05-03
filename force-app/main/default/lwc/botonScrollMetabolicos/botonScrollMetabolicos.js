import { api, LightningElement } from 'lwc';

export default class BotonScrollMetabolicos extends LightningElement {

    @api seccion;
    @api label;
    @api icon = false;
    
    goTo(){
        let value = this.seccion;
        const clickEvent = new CustomEvent("clickbuttonscroll",{
            detail: {value}
        });
        this.dispatchEvent(clickEvent);
    }
}