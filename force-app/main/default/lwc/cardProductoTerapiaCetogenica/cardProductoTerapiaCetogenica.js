import { api, LightningElement } from 'lwc';

export default class CardProductoTerapiaCetogenica extends LightningElement {

    @api title;
    @api img;

    selectProduct(){
        console.log("producto seleccionado");
    }

}