import { LightningElement, api } from 'lwc';

export default class CardsDesafiosCrecimiento extends LightningElement {

    @api
    page;

    cardDesafiosCrecimiento;
    cardBombaEnteral;
    cardPatologiasCronicas;

    showDetailsCardLeft;
    showDetailsCardRight;

    connectedCallback() {
        if(this.page == 'Home') {
            this.cardDesafiosCrecimiento = true;
        }
        else if(this.page == 'Bomba de Nutrición Enteral') {
            this.cardBombaEnteral = true;            
        }
        else if(this.page == 'Patologías Crónicas') {
            this.cardPatologiasCronicas = true;            
        }
    }

    openDetailsLeft() {
        this.showDetailsCardLeft = !this.showDetailsCardLeft;
        if(this.showDetailsCardLeft) {
            this.showDetailsCardRight = false;
        }
    }

    openDetailsRight() {
        this.showDetailsCardRight = !this.showDetailsCardRight;
        if(this.showDetailsCardRight) {
            this.showDetailsCardLeft = false;
        }
    }
}