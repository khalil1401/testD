import {LightningElement, api, track} from 'lwc';
import isDevliveryFromNotCharge from '@salesforce/apex/CaseController.isDevliveryFromNotCharge';
export default class TypeOfComplaint extends LightningElement {
    @track objectInfo;
    @track recordTypeName;
    @track recordTypeId;
    @api recordId;
    @api invoiceid;
    @api showSpinner = false;
    @api title;
    @api objapiname = 'Dan360_Remito__c';
    isFromNotCharge;
    blockContinue = true;
    isReturnComplaint = false;
    complaintSelected = '';
    
    connectedCallback(){
        console.log('recordId from type');
        console.log(this.invoiceid);
        console.log('objapiname from type');
        console.log(this.objapiname);
        if(this.objapiname == 'Dan360_Remito__c'){
            isDevliveryFromNotCharge({id: this.invoiceid, objApiName: this.objapiname}).then(data => {
                this.isFromNotCharge = data;
                console.log()
            }).catch(error => {
                console.log(error);
            });
        }
        
    }

    get typeOfComplaint () {
        if(this.objapiname == 'Dan360_Remito__c'){
            if(this.isFromNotCharge){
                return [
                    {
                        label: 'Devoluciones',
                        value: 'Dan360_DevolucionesPedidosSinCargo'
                    },
                    {
                        label: 'Servicios',
                        value: 'Dan360_Otros'
                    }
                ];  
            } else {
                return [
                    {
                        label: 'Servicios',
                        value: 'Dan360_Otros'
                    }
                ];
            }
            
        }
        return [
            {
                label: 'Devoluciones',
                value: 'Dan360_Devoluciones'
            },
            {
                label: 'Diferencia de precios y descuentos',
                value: 'Dan360_DiferenciaPreciosDescuentos'
            },
            {
                label: 'Faltantes',
                value: 'Dan360_ReclamoPorFaltantes'
			}
        ];
    }

    onComplaintSelected (event) {
        this.complaintSelected = event.detail.value;

        if (this.complaintSelected != null) {
            this.blockContinue = false;
        }
    }

    onContinue () {
        let custEvent = new CustomEvent(
            'complaintselected',
            {
                detail: this.complaintSelected
            });
        this.dispatchEvent(custEvent);
    }

    closeAction () {
        this.dispatchEvent(
            new CustomEvent('cancel')
        );
    }
}