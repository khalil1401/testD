import { LightningElement, api } from 'lwc';
import iconEnvioNSJRS from '@salesforce/resourceUrl/iconEnvioNSJ';

export default class FormPerfilPedidos extends LightningElement {

    @api
    envio;

    iconEnvio = iconEnvioNSJRS;
    
}