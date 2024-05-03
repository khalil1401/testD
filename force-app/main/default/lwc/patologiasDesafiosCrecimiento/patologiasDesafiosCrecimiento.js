import { LightningElement } from 'lwc';

export default class PatologiasDesafiosCrecimiento extends LightningElement {

    patologias = [ 
        {id: '0', name: 'cardiopatia-congenita'},
        {id: '1', name: 'enfermedad-oncologica'},
        {id: '2', name: 'paralisis-cerebral'},
        {id: '3', name: 'fibrosis-quistica'},
    ];
    selectedPatologia;
    showArrows;
    disabledNext;
    disabledBack = true;
    footer;

    showDetails(event) {
        let patologia = event.target.dataset.patologia;
        for(let i = 0; i<this.patologias.length; i++) {
            let nameContainerI = 'container-' + this.patologias[i].name;
            let divI = this.template.querySelector('[data-id="'+ nameContainerI +'"]');
            if(divI) {
                divI.style.display = 'none';
            }

            if(patologia == this.patologias[i].name) {
                this.disabledBack = i == 0 ? true : false ;
                this.disabledNext = i < this.patologias.length -1 ? false : true;
            }
        }

        let nameContainer = 'container-' + patologia;
        let div = this.template.querySelector('[data-id="'+ nameContainer +'"]');
        if(div) {
            div.style.display = 'flex';
            this.footer = true;
            this.selectedPatologia = patologia;
            this.showArrows = true;
        }

        this.scrollToInfo();
    }

    next() {
        for(let i = 0; i<this.patologias.length; i++) {
            let nameContainerI = 'container-' + this.patologias[i].name;
            let divI = this.template.querySelector('[data-id="'+ nameContainerI +'"]');
            if(divI) {
                divI.style.display = 'none';
            }
        }

        for(let i = 0; i<this.patologias.length; i++) {
            if(this.selectedPatologia == this.patologias[i].name) {
                let nameContainer = 'container-' + this.patologias[i+1].name;
                let div = this.template.querySelector('[data-id="'+ nameContainer +'"]');
                if(div) {
                    div.style.display = 'flex';
                    this.footer = true;
                    this.selectedPatologia = this.patologias[i+1].name;
                    this.disabledBack = false;
                    this.disabledNext = i+1 < this.patologias.length -1 ? false : true;
                    this.scrollToInfo();
                    break;
                }
            }
        }
    }

    back() {
        for(let i = 0; i<this.patologias.length; i++) {
            let nameContainerI = 'container-' + this.patologias[i].name;
            let divI = this.template.querySelector('[data-id="'+ nameContainerI +'"]');
            if(divI) {
                divI.style.display = 'none';
            }
        }

        for(let i = 0; i<this.patologias.length; i++) {
            if(this.selectedPatologia == this.patologias[i].name) {
                let nameContainer = 'container-' + this.patologias[i-1].name;
                let div = this.template.querySelector('[data-id="'+ nameContainer +'"]');
                if(div) {
                    div.style.display = 'flex';
                    this.footer = true;
                    this.selectedPatologia = this.patologias[i-1].name;
                    this.disabledBack = i-1 <= 0 ? true : false ;
                    this.disabledNext = false;
                    this.scrollToInfo();
                    break;
                }
            }
        }
    }

    scrollToInfo() {
        let div = this.template.querySelector('[data-id="container-info"]');
        if(div) {
            div.scrollIntoView({
                behavior: "smooth", 
                block: "start", 
                inline: "nearest"
            });
        }
    }

    scrollTo() {
        let div = this.template.querySelector('[data-id="main-menu"]');
        if(div) {
            div.scrollIntoView({
                behavior: "smooth", 
                block: "center", 
                inline: "nearest"
            });
        }
    }

    go() {
        for(let i = 0; i<this.patologias.length; i++) {
            if (this.selectedPatologia == this.patologias[i]) {
                
            }
        }
    }
}