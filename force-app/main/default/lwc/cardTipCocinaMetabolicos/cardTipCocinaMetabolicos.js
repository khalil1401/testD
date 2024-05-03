import { api, LightningElement } from 'lwc';

export default class CardTipCocinaMetabolicos extends LightningElement {

    @api tipCocinaId;
    @api title;
    @api image;

    handleClickTipCocina(){
        const clickEvent = new CustomEvent("clicktipcocina",{
            detail: this.tipCocinaId
        });
        this.dispatchEvent(clickEvent);
    }

}