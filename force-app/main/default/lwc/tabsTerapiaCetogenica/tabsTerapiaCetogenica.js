import { LightningElement } from 'lwc';

export default class TabsTerapiaCetogenica extends LightningElement {

    showDetail(event){
        let tab = '' + event.target.dataset.id;
        this.template.querySelector('[data-id="dieta-cetogenica-clasica"]').className='container-item slds-align_absolute-center';
        this.template.querySelector('[data-id="dieta-atkins-modificada"]').className='container-item slds-align_absolute-center';
        this.template.querySelector('[data-id="dieta-modificada"]').className='container-item slds-align_absolute-center';
        this.template.querySelector('[data-id="dieta-trigliceridos"]').className='container-item slds-align_absolute-center';
        this.template.querySelector('[data-id="dieta-bajo-indice"]').className='container-item slds-align_absolute-center';
        this.template.querySelector('[data-id="'+tab+'"]').className='container-item-selected slds-align_absolute-center';
        
        let tabDetail = tab + '-details';
        this.template.querySelector('[data-id="dieta-cetogenica-clasica-details"]').className='hide-container-details';
        this.template.querySelector('[data-id="dieta-atkins-modificada-details"]').className='hide-container-details';
        this.template.querySelector('[data-id="dieta-modificada-details"]').className='hide-container-details';
        this.template.querySelector('[data-id="dieta-trigliceridos-details"]').className='hide-container-details';
        this.template.querySelector('[data-id="dieta-bajo-indice-details"]').className='hide-container-details';
        this.template.querySelector('[data-id="'+tabDetail+'"]').className='show-container-details';
    }

}