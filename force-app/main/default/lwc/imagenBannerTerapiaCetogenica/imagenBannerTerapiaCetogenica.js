import { LightningElement } from 'lwc';
import banner from '@salesforce/resourceUrl/bannerHomeOncologia';
import logoTC from '@salesforce/resourceUrl/LogoNutricia';

export default class ImagenBannerTerapiaCetogenica extends LightningElement {

    logo = logoTC;

    get backgroundStyleDesktop() {
        return `height:300px;background:linear-gradient(rgba(0,0,0,0.2), rgba(0,0,0,0.2)), url(${banner});`;
    }

    get backgroundStyleMobile() {
        return `height:200px;background-image:url(${banner})`;
    }

}