import { LightningElement, api } from 'lwc';
import imgHeaderHomeSR from '@salesforce/resourceUrl/malnutricionImgHeaderHome';

export default class PreguntasRespuestasMalnutricion extends LightningElement {

    @api izquierda = false;
    @api primerPregunta;
    @api primerRespuesta;
    @api segundaPregunta;
    @api segundaRespuesta;
    @api tercerPregunta;
    @api tercerRespuesta;
    img = imgHeaderHomeSR;

}