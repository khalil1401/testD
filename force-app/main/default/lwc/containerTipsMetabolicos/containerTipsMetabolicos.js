import { LightningElement } from 'lwc';

export default class ContainerTipsMetabolicos extends LightningElement {

    tips = [
        {"id": "0", "title": "ACTIVIDAD FÍSICA", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono-Mujer-Corriendo.png"},
        {"id": "1", "title": "ALIMENTACIÓN PERCEPTIVA", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono-Alimentacion-perceptiva.png"},
        {"id": "2", "title": "BABY LED WEANING (BLW)", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono-Bebe.png"},
        {"id": "3", "title": "¡MI HIJO NO QUIERE COMER!", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono-No-comer.png"}
    ];
    selectedTip = "0";
    previousIcon = true;
    nextIcon = this.tips.length < 1 ;

    handleClickTip(event){
        this.selectedTip = event.detail;

        this.clearAndSelectTip(event.detail);
        let index = parseInt(this.selectedTip);
        this.previousIcon = index <= 0;
        this.nextIcon = index + 1 >= this.tips.length;

        let divDesc = this.template.querySelector('[data-id="description-tip-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    previousStep(){
        let nextIndex = parseInt(this.selectedTip) - 1;
        this.clearAndSelectTip(""+nextIndex);
        this.previousIcon = nextIndex <= 0;
        this.nextIcon = nextIndex + 1 >= this.tips.length;
        this.selectedTip = ""+nextIndex;
        
        let divDesc = this.template.querySelector('[data-id="description-tip-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    nexStep(){
        let nextIndex = parseInt(this.selectedTip) + 1;
        this.clearAndSelectTip(""+nextIndex);
        this.previousIcon = nextIndex <= 0;
        this.nextIcon = nextIndex + 1 >= this.tips.length;
        this.selectedTip = ""+nextIndex;

        let divDesc = this.template.querySelector('[data-id="description-tip-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    clearAndSelectTip(tip){
        for(let tip in this.tips){
            let dataid = this.tips[tip].id;
            let div = this.template.querySelector('[data-id="'+ dataid +'"]');
            if(div){div.style.display = "none";}
        }

        let div = this.template.querySelector('[data-id="'+ tip +'"]');
        if(div){
            div.style.display = "initial";
        }
    }

}