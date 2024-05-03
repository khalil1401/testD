import { api, LightningElement } from 'lwc';

export default class CardTipMetabolicos extends LightningElement {

    @api tipId;
    @api title;
    @api image;

    handleClickTip(){
        const clickEvent = new CustomEvent("clicktip",{
            detail: this.tipId
        });
        this.dispatchEvent(clickEvent);
    }

}