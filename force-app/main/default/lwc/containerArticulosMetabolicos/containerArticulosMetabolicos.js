import { LightningElement } from 'lwc';

export default class ContainerArticulosMetabolicos extends LightningElement {

    articles = [
        {"id": "0", "title": "Adherencia al tratamiento", "text": "La adherencia al tratamiento es la medida en que el comportamiento de una persona es consistente con las recomendaciones de los profesionales de la salud...", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_3/PP-Metab%C3%B3licos%20-Arti_Adherencia%20al%20tratamiento%20grande.png"},
        {"id": "1", "title": "Adolescencia y autocuidado", "text": "¿Cuándo es el mejor momento para trasladar el cuidado a nuestros hijos e hijas? ¿Por qué es importante ir delegando y no sobre protegerlos?...", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_3/PP-Metab%C3%B3licos%20-Arti_Adolescencia%20y%20autocuidado%20grande.png"},
        {"id": "2", "title": "Cuidando en equipo: cómo delegar tareas de cuidado", "text": "El desafío del cuidador es trabajar en equipo con el/la niño/a en cada etapa hasta que este logre la autonomía total en su tratamiento...", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_3/PP-Metab%C3%B3licos%20-Art-Cuidando%20en%20equipo%20grande.png"},
        {"id": "3", "title": "Pesquisa neonatal: la gotita de sangre del talón del bebé", "text": "Entre 500 y 700 niños/as nacen por año en Argentina con alguna de las enfermedades congénitas...", "img": "https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_METABOLICOS/PAGINA_3/PP-Metab%C3%B3licos%20-Art_PesquisaNeonatal%20grande.png"}
    ]
    selectedArticle = "0";
    previousIcon = true;
    nextIcon = this.articles.length < 1 ;

    handleClickArticulo(event){
        this.selectedArticle = event.detail;

        this.clearAndSelectArticle(event.detail);
        let index = parseInt(this.selectedArticle);
        this.previousIcon = index <= 0;
        this.nextIcon = index + 1 >= this.articles.length;

        let divDesc = this.template.querySelector('[data-id="description-article-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    previousStep(){
        let nextIndex = parseInt(this.selectedArticle) - 1;
        this.clearAndSelectArticle(""+nextIndex);
        this.previousIcon = nextIndex <= 0;
        this.nextIcon = nextIndex + 1 >= this.articles.length;
        this.selectedArticle = ""+nextIndex;

        let divDesc = this.template.querySelector('[data-id="description-article-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    nexStep(){
        let nextIndex = parseInt(this.selectedArticle) + 1;
        this.clearAndSelectArticle(""+nextIndex);
        this.previousIcon = nextIndex <= 0;
        this.nextIcon = nextIndex + 1 >= this.articles.length;
        this.selectedArticle = ""+nextIndex;

        let divDesc = this.template.querySelector('[data-id="description-article-meta"]');
        if(divDesc){
            setTimeout(() => {divDesc.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'start'
            });}, 200);
        }
    }

    clearAndSelectArticle(article){
        for(let article in this.articles){
            let dataid = this.articles[article].id;
            let div = this.template.querySelector('[data-id="'+ dataid +'"]');
            if(div){div.style.display = "none";}
        }

        let div = this.template.querySelector('[data-id="'+ article +'"]');
        if(div){
            div.style.display = "initial";
        }
    }
}