import { LightningElement, track, wire } from 'lwc';
import getData from '@salesforce/apex/GeneralEnvironmentSettingsComponentCtrl.getData';
import updateMetadata from '@salesforce/apex/GeneralEnvironmentSettingsComponentCtrl.updateMetadata';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getUserProfileName from '@salesforce/apex/GeneralEnvironmentSettingsComponentCtrl.getUserProfileName';



const columnsCiclo = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Fecha de Inicio',fieldName: 'fecha_De_Inicio_c',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {year: "numeric",month: "2-digit",day: "2-digit"}, editable: true},
    {label: 'Fecha de Fin',fieldName: 'fecha_De_Fin_c',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {year: "numeric",month: "2-digit",day: "2-digit"}, editable: true}
];
const columnsCNTP = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Compensatorio', fieldName: 'compensatorio_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true}
];
const columnsLimiteDeRetraso = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Limite de retraso', fieldName: 'Cantidad_de_Dias_de_Retraso_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true}
];
// const columnsTarget = [
//     {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
//     {label: 'Nicho', fieldName: 'target_Nicho_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true},
//     {label: 'Pediatricos General', fieldName: 'target_Pediatricos_General_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true},
//     {label: 'Pediatricos Alergia', fieldName: 'target_Pediatricos_Alergia_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true},
//     {label: 'Adultos General', fieldName: 'target_Adultos_General_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true},
//     {label: 'Oncologia', fieldName: 'target_Oncologia_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true}
// ];
const columnsTarget = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Sub Equipo', fieldName: 'Sub_Equipo_c', type: 'picklist', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Numero de mes', fieldName: 'Numero_de_mes_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Target', fieldName: 'Target_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true}

];
const columnsNotificacionDinDeCiclo = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Dias de antelacion', fieldName: 'Dias_de_antelacion_c', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}, editable: true}
];
const columnsMotivosDeBaja = [
    {label: 'Motivo', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Baja Total',fieldName: 'Baja_Total_c',type: 'boolean',sortable: true,cellAttributes: {alignment: 'left'}, editable: true},
    {label: 'Baja Temporal',fieldName: 'Baja_Temporal_c',type: 'boolean',sortable: true, cellAttributes: {alignment: 'left'}, editable: true}
];
const columnsFrecuenciaPorCategoria = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Categoria', fieldName: 'Categoria_c', type: 'picklist', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Equipo',fieldName: 'Segmenta_Por_c',type: 'picklist',sortable: true,cellAttributes: {alignment: 'left'}},
    {label: 'Frecuencia',fieldName: 'Frecuencia_c',type: 'number',sortable: true, cellAttributes: {alignment: 'left'}, editable: true}
];

const columnsClientEdi = [
    {label: 'Nombre', fieldName: 'Nombre_c', type: 'picklist', sortable: true, cellAttributes: {alignment: 'left'}, editable: true},
    {label: 'GLN',fieldName: 'GLN_c',type: 'picklist',sortable: true,cellAttributes: {alignment: 'left'}, editable: true},
];


export default class LwcPrueba extends LightningElement {

    @track data = [];
    @track records = [];
    wiredDataResult;
    newData = [];
    error;
    showSpinner = false;
    columns = [];
    @ track metadataSelected = '';
    fields = '';
    draftValues = [];
    channelName = '/event/Metadata_updated__e';
    subscription;
    currentUserProfile;
    modal = false;
    showAddButton = false;
    draftValue = [];

    connectedCallback() {
        this.handleSubscribe();
        getUserProfileName({recordId: this.recordId})
            .then((result) => {
                this.currentUserProfile = result;
                console.log(this.currentUserProfile);
            })
            .catch((error) => {
                console.log(error);
            });
    }

    //Combobox Methods
    get optionsMetadata() {
        if(this.currentUserProfile == 'Administrador del sistema'){
            return [
                { label: 'Limites', value: 'Limite_de_retraso__mdt' },
                { label: 'Target de visitas', value: 'Target_Diario__mdt' },
                { label: 'Notificacion de Fin de Ciclo', value: 'Notificacion_fin_de_Ciclo__mdt' },
                { label: 'Configuracion de motivos para la Baja', value: 'Configuracion_de_motivos_para_la_Baja__mdt' },
                { label: 'Configuracion Frecuencia por categoria', value: 'Frecuencia_por_Categoria__mdt' },
                { label: 'Clientes', value: 'Clientes_No_EDI__mdt' }
             ];
             
        }
        if(this.currentUserProfile == 'Administración de venta'){
            return [
                { label: 'Clientes', value: 'Clientes_No_EDI__mdt' }
             ];
        }
        return [
           // { label: 'Ciclo', value: 'ciclo__mdt' },
           // { label: 'Compensatorio Tiempo no Promocional', value: 'Compensatorio_Tiempo_no_Promocional__mdt' },
            { label: 'Limites', value: 'Limite_de_retraso__mdt' },
            { label: 'Target de visitas', value: 'Target_Diario__mdt' },
            { label: 'Notificacion de Fin de Ciclo', value: 'Notificacion_fin_de_Ciclo__mdt' },
            { label: 'Configuracion de motivos para la Baja', value: 'Configuracion_de_motivos_para_la_Baja__mdt' },
            { label: 'Configuracion Frecuencia por categoria', value: 'Frecuencia_por_Categoria__mdt' },
        ];
    }
    handleFilterMetadataChange(event) {
        this.showSpinner = true;
        let metadataSelected = this.metadataSelected = event.detail.value;
        if(metadataSelected == 'ciclo__mdt'){
            this.showAddButton = false;
            this.columns = columnsCiclo;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Fecha_de_inicio__c, Fecha_de_Fin__c, Numero_de_mes__c';
        }
        else if(metadataSelected == 'Compensatorio_Tiempo_no_Promocional__mdt'){
            this.columns = columnsCNTP;
            this.showAddButton = false;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Compensatorio__c';
        }
        else if (metadataSelected == 'Limite_de_retraso__mdt'){
            this.columns = columnsLimiteDeRetraso;
            this.showAddButton = false;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Cantidad_de_Dias_de_Retraso__c';
        } else if (metadataSelected == 'Target_Diario__mdt'){
            this.columns = columnsTarget;
            this.showAddButton = false;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Sub_Equipo__c, Numero_de_mes__c, Target__c';
        } else if (metadataSelected == 'Notificacion_fin_de_Ciclo__mdt'){
            this.columns = columnsNotificacionDinDeCiclo;
            this.showAddButton = false;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Dias_de_antelacion__c';
        } else if (metadataSelected == 'Configuracion_de_motivos_para_la_Baja__mdt'){
            this.columns = columnsMotivosDeBaja;
            this.showAddButton = false;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Baja_Total__c, Baja_Temporal__c';
        } else if (metadataSelected == 'Frecuencia_por_Categoria__mdt'){
            this.columns = columnsFrecuenciaPorCategoria;
            this.showAddButton = false;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Categoria__c, Segmenta_Por__c, Frecuencia__c';
        } else if (metadataSelected == 'Clientes_No_EDI__mdt'){
            this.showAddButton = true;
            this.columns = columnsClientEdi;
            this.fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, GLN__c, Nombre__c';
        }
    }

    @wire(getData , {
        metadata: "$metadataSelected",
        fields: '$fields'
    })
    wiredData(value) {
        this.wiredDataResult = value;
        const { data, error } = value;
        if (data) {
            this.data = data;
            this.showSpinner = false;
            this.error = undefined;
            console.log('data::: ' + JSON.stringify(data));
        } else if (error) {
            console.log('error: ' + error);
            this.error = error;
            this.data = undefined;
            this.showSpinner = false;
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    showToast(titulo, mensaje, tipo, modo) {
        const event = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo,
            mode: modo
        });
        this.dispatchEvent(event);
    }

    handleSave(event) {
        this.showSpinner = true;
        console.log(event.detail.draftValues);
        for (let i = 0;  i < event.detail.draftValues.length; i++) {
            for (let j = 0;  j <this.data.length; j++) {
                if (event.detail.draftValues[i].id == this.data[j].id) { // Doble FOR porque el drafValues de salesforce no trae todos los datos del registro por lo que tengo que buscarlos a mano.
                    const target = this.data[j];
                    const source = event.detail.draftValues[i];
                    const flag = Object.assign({}, target, source); 
                    this.newData.push(flag);
                }
            }
        }
        console.log(this.newData);
        updateMetadata({
            jsonString : JSON.stringify(this.newData)
        })
        .then((data)=>{
            if(data.length < 1){
                this.showToast('Configuracion guardada correctamente', 'Podra ver los cambios en la configuracion.','success', 'dismissible');
                this.draftValues = [];
                refreshApex(this.wiredDataResult);
                eval("$A.get('e.force:refreshView').fire();");
                console.log(JSON.stringify(this.data));
            }
        })
        .catch((error) =>{
            this.showToast('Error', 'Se genero un error', 'error', 'dismissible');
        })
        this.showSpinner = false;
    }

    handleSubscribe() {
        subscribe(this.channelName, -1, this.messageCallback).then((response) => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    messageCallback = (response) => {
        refreshApex(this.wiredDataResult);
        this.showSpinner = false;
        console.log("caso desde evento " + JSON.stringify(this.data));
    }

    closeModal(){
        this.modal = false;
    }

    openModal(){
        this.modal = true;
    }

    addRow() {
        let randomId = Math.random() * 16;
        let myNewElement = {Nombre_c: "", GLN_c: "", id: randomId};
        console.log(myNewElement);
        this.data = [...this.data, myNewElement];
        console.log(this.data);
    }

    handleSaveInsertMetadata(event){
        console.log(event.detail);
        console.log(event.detail.draftValue);
    }
}