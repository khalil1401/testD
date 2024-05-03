import { LightningElement } from 'lwc';

export default class ContainerTipsCocinaMetabolicos extends LightningElement {

    tips = [
        {"id": "0", "title": "¿Cómo sustituir el huevo o la gelatina en una receta?", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono-Huevos.png"},
        {"id": "1", "title": "¿Cómo organizarte a la hora de hacer una receta?", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono%20-%20Organizacion.png"},
        {"id": "2", "title": "¿Por qué la fruta se oscurece cuando la cortamos?", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono-Fruta.png"},
        {"id": "3", "title": "¿Cómo conservar las hojas verdes por más tiempo?", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono%20-%20HojasVerdes.png"},
        {"id": "4", "title": "¿Cómo quitarse el olor a ajo/cebolla de las manos después de cocinar?", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono%20-%20Cebolla.png"},
        {"id": "5", "title": "¿Cómo sazonar mejor tus comidas?", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_4/PP-Metab%C3%B3licos%20-Icono%20Sazonar.png"}
    ];
    selectedTip = "0";
    previousIcon = true;
    nextIcon = this.tips.length < 1;

    handleClickTipCocina(event){
        this.selectedTip = event.detail;

        this.clearAndSelectTipCocina(event.detail);
        let index = parseInt(this.selectedTip);
        this.previousIcon = index <= 0;
        this.nextIcon = index + 1 >= this.tips.length;

        let divDesc = this.template.querySelector('[data-id="description-tip-cocina-meta"]');
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
        this.clearAndSelectTipCocina(""+nextIndex);
        this.previousIcon = nextIndex <= 0;
        this.nextIcon = nextIndex + 1 >= this.tips.length;
        this.selectedTip = ""+nextIndex;
        
        let divDesc = this.template.querySelector('[data-id="description-tip-cocina-meta"]');
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
        this.clearAndSelectTipCocina(""+nextIndex);
        this.previousIcon = nextIndex <= 0;
        this.nextIcon = nextIndex + 1 >= this.tips.length;
        this.selectedTip = ""+nextIndex;

        let divDesc = this.template.querySelector('[data-id="description-tip-cocina-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    clearAndSelectTipCocina(tip){
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