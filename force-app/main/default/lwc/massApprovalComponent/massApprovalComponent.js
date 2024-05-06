import { LightningElement, track, api, wire } from 'lwc';
import getData from '@salesforce/apex/MassApprovalComponentController.getData';
import getUser from '@salesforce/apex/MassApprovalComponentController.getUser';
import getSupervisores from '@salesforce/apex/MassApprovalComponentController.getSupervisores';
import updateRecord from '@salesforce/apex/MassApprovalComponentController.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

    const columnsLicencia =  [
        {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Fecha Solicitud',fieldName: 'createdDate',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha Inicio',fieldName: 'fechaDeInicio',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha Fin',fieldName: 'fechaDeFin',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Dias',fieldName: 'cantidadDeDias',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Motivo',fieldName: 'motivo',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Usuario',fieldName: 'ownerUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'owner' }, target: '_parent'}},
        {label: 'Comentario',fieldName: 'comentario',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    ];
    const columnsTNP =  [
        {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Fecha Solicitud',fieldName: 'createdDate',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha',fieldName: 'fechaDeInicio',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Horas',fieldName: 'cantidadDeHoras',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Motivo',fieldName: 'motivo',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Usuario',fieldName: 'ownerUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'owner' }, target: '_parent'}},
        {label: 'Comentario',fieldName: 'comentario',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    ];
    const columnsInteraccion =  [
        {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Tipo de Registro',fieldName: 'recordType',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Tipo de Visita',fieldName: 'tipoDeVisita',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Fecha Solicitud',fieldName: 'createdDate',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha',fieldName: 'fechaDeInicio',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Profesional',fieldName: 'profesionalUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'profesional' }, target: '_parent'}},
        {label: 'Institucion',fieldName: 'institucionUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'institucion' }, target: '_parent'}},
        {label: 'Usuario',fieldName: 'ownerUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'owner' }, target: '_parent'}},
        {label: 'Comentario',fieldName: 'comentario',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    ];
    const columnsBajasProfesional = [
        {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Tipo de Registro',fieldName: 'recordType',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Usuario',fieldName: 'ownerUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'owner' }, target: '_parent'}},
        {label: 'Fecha Solicitud',fieldName: 'createdDate',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha Inicio',fieldName: 'fechaDeInicio',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha Fin',fieldName: 'fechaDeFin',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Profesional',fieldName: 'profesionalUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'profesional' }, target: '_parent'}},
        {label: '1er Especialidad',fieldName: 'especialidad',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Matricula Nacional',fieldName: 'matriculaNacional',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Matricula Provincial',fieldName: 'matriculaProvincial',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Motivo',fieldName: 'motivo',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Comentario',fieldName: 'comentario',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    ];
    const columnsBajasDomicilio = [
        {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Usuario',fieldName: 'ownerUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'owner' }, target: '_parent'}},
        {label: 'Fecha Solicitud',fieldName: 'createdDate',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Fecha',fieldName: 'fechaDeInicio',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Profesional',fieldName: 'profesionalUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'profesional' }, target: '_parent'}},
        {label: '1er Especialidad',fieldName: 'especialidad',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Matricula Nacional',fieldName: 'matriculaNacional',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Matricula Provincial',fieldName: 'matriculaProvincial',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Institucion',fieldName: 'institucionUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'institucion' }, target: '_parent'}},
        {label: 'Motivo',fieldName: 'motivo',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Comentario',fieldName: 'comentario',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    ];
    const columnsSeguimiento = [
        // {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Nombre',fieldName: 'nameUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'},  typeAttributes: {label: { fieldName: 'name' }, target: '_parent'}},
        {label: 'Usuario',fieldName: 'ownerUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'owner' }, target: '_parent'}},
        {label: 'Fecha Solicitud',fieldName: 'fechaSolicitud',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
        {label: 'Profesional',fieldName: 'profesionalUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'profesional' }, target: '_parent'}},
        {label: 'Tipo de alta',fieldName: 'tipo',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: '1er Especialidad',fieldName: 'especialidad',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Matricula Nacional',fieldName: 'matriculaNacional',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Matricula Provincial',fieldName: 'matriculaProvincial',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
        {label: 'Institucion',fieldName: 'institucionUrl',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'institucion' }, target: '_parent'}},
        {label: 'Comentario',fieldName: 'comentario',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    ];
    

    export default class MassApprovalComponent extends LightningElement {
        
        @track page = 1; //this will initialize 1st page
        @track items = []; //it contains all the records.
        @track data = []; //data to be displayed in the table
        @track columns = columnsLicencia; //holds column info.
        @track startingRecord = 1; //start record position per page
        @track endingRecord = 0; //end record position per page
        @track totalRecountCount = 0; //total record count received from all retrieved records
        @track totalPage = 0; //total number of page is needed to display all records
        @track users = [];
        @track supervisores = [];
        @track pageSize = 10; //default value we are assigning
        selectedRows = [];
        selectedRowsIds = [];
        estadoSelected = 'Pendiente';
        objetoSelected = 'licencia';
        fechaInicioSelected = null;
        fechaFinSelected = null;
        disableApproval = true;
        disableReject = true;
        updating = false;
        disableFiltroFechaInicio = false;
        disableFiltroFechaFin = false;
        hideCheckboxes = false;
        usuarioSelected = '';
        usersList = [];
        supervisorSelected = '';
        isModalOpen = false;
        labelRecjectApproval = '';
        cantidadDeRegistros = 0;
        comentario = '';
        objetoSf = 'Dan360_Licencia__c';
        recordTypeSf = 'Licencia';
        wiredDataResult;
        showSpinner = true;
        dataAux = [];

        //Combobox Methods
        get optionsObjeto() {
            return [
                { label: 'Licencia', value: 'licencia' },
                { label: 'Tiempo no Promocional', value: 'tiempoNoPromocional' },
                { label: 'Interaccion', value: 'interaccion' },
                { label: 'Altas', value: 'seguimiento' },
                { label: 'Bajas Profesional', value: 'bajasProfesional' },
                { label: 'Bajas Domicilio', value: 'bajasSeguimientos' },
            ];
        }

        get optionsEstado() {
            return [
                { label: 'Pendiente', value: 'Pendiente' },
                { label: 'Aprobada', value: 'Aprobada' },
                { label: 'Rechazada', value: 'Rechazada' },
            ];
        }

        handleFilterObjectChange(event) {
            this.showSpinner = true;
            let objectSelect = this.objetoSelected = event.detail.value;
            if(objectSelect == 'licencia'){
                this.columns = columnsLicencia;
                this.objetoSf = 'Dan360_Licencia__c';
                this.recordTypeSf = 'Licencia';
            }
            else if(objectSelect == 'tiempoNoPromocional'){
                this.columns = columnsTNP;
                this.objetoSf = 'Dan360_Licencia__c';
                this.recordTypeSf = 'Tiempo_no_Promocional';
            }
            else if (objectSelect == 'interaccion'){
                this.columns = columnsInteraccion;
                this.objetoSf = 'Dan360_Interacciones__c';
                this.recordTypeSf = '';
            } else if (objectSelect == 'bajasProfesional'){
                this.columns = columnsBajasProfesional;
                this.objetoSf = 'VisMed_Bajas__c';
                this.recordTypeSf = 'Profesional_de_la_Salud';
            } else if (objectSelect == 'seguimiento'){
                this.columns = columnsSeguimiento;
                this.objetoSf = 'VisMed_Contacto_Cuenta_Usuario__c';
                this.recordTypeSf = '';
            } else if (objectSelect == 'bajasSeguimientos'){
                this.columns = columnsBajasDomicilio;
                this.objetoSf = 'VisMed_Bajas__c';
                this.recordTypeSf = 'Seguimiento';
            }
        }

        handleFilterStatusChange(event) {
            this.showSpinner = true;
            this.estadoSelected = event.detail.value;
            console.log(this.estadoSelected);
            if (this.estadoSelected != 'Pendiente') {
                if (this.estadoSelected == 'Rechazada'){
                    this.disableReject = true;
                    this.hideCheckboxes = false;
                } else {
                    this.disableApproval = true;               
                    this.hideCheckboxes = true;
                }
            }  else {
                this.hideCheckboxes = false;
            }
        }

        @wire(getSupervisores)
        WiredSupervisores({ error, data }) {
            if (data) { 
                if (data.length > 1) {
                    this.supervisores.push({label: 'Todos', value: ''});
                } 
                for(var i in data)  {
                    this.supervisores = [...this.supervisores ,{label: data[i].Name, value: data[i].Id} ];   
                }          
                this.error = undefined;
                console.log('supervisores: ' + this.supervisores);
            } else if (error) {
                console.log('ERROR: ' + JSON.stringify(error));
                this.error = error;
            }
        }
        get optionsSupervisores() {
            if (this.supervisores.length == 1) {
                this.supervisorSelected = this.supervisores[0].value;
            }
            return this.supervisores;
        }

        handleFilterSupervisorChange(event) {
            this.supervisorSelected = event.detail.value;
        }

        
        @wire(getUser, {
            supervisor: "$supervisorSelected"
        })
        WiredUsers({ error, data }) {
            if (data) { 
                this.users = [];
                this.usersList = [];
                this.users.push({label: 'Todos', value: ''});
                for(var i in data)  {
                    this.users = [...this.users ,{label: data[i].Name, value: data[i].ContactId} ];   
                    this.usersList.push(data[i].ContactId);
                }       
                this.error = undefined;
                console.log('Users: ' + this.users);
                console.log(this.columns);
            } else if (error) {
                console.log('ERROR: ' + error);
                this.error = error;
            }
        }
        get optionsUsuarios() {
            return this.users;
        }

        handleFilterUserChange(event) {
            this.showSpinner = true;
            this.usuarioSelected = event.detail.value;
        }
        
        //Eventos de filtro para las fechas.
        handleFilterFechaInicioChange(event) {
            this.showSpinner = true;
            this.fechaInicioSelected = event.detail.value;
        }
        handleFilterFechaFinChange(event) {
            this.showSpinner = true;
            this.fechaFinSelected = event.detail.value;
        }

        ////////////////////////// Metodos de recuperacion y update de datos/////////////////////////////////
        // Get Data Licencias e Interacciones
        @wire(getData , {
            objeto: "$objetoSf",
            recordTypeName: "$recordTypeSf",
            estado: "$estadoSelected",
            user: "$usuarioSelected",
            users: "$usersList",
            fechaInicio: "$fechaInicioSelected",
            fechaFin: "$fechaFinSelected",
        })
        wiredData(value) {
            this.wiredDataResult = value;
            const { data, error } = value;
            if (data) {
                this.items = data;
                this.dataAux = data;
                this.totalRecountCount = data.length; //here it is 23
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
                this.data = this.items.slice(0,this.pageSize); 
                this.endingRecord = this.pageSize;
                this.showSpinner = false;
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.data = undefined;
                this.showSpinner = false;
            }
        }

        update() {
            for (let i = 0; i < this.selectedRows.length; i++){
              this.selectedRowsIds[i] = this.selectedRows[i].id;
            }
            let  mensaje = this.labelRecjectApproval == 'Aprobada' ? 'Se aprobaron ' + this.selectedRows.length + ' registros' : 'Se rechazaron ' + this.selectedRows.length + ' registros';
            this.showSpinner = true;
            this.updating = true;
            updateRecord({
                recordsId: this.selectedRowsIds,
                objeto: this.objetoSf,
                comentario: this.comentario,
                estado: this.labelRecjectApproval,
                user: this.usuarioSelected})
                .then((data)=>{
                    if(data.length < 1){
                        this.comentario  = '';
                        this.closeModal();
                        this.showToast(this.labelRecjectApproval + ' correctamente', mensaje, 'success', 'dismissible');
                        this.showSpinner = false;
                        this.updating = false;
                        return refreshApex(this.wiredDataResult);
                    }
                    this.showSpinner = false;
                    this.updating = false;
                })
                .catch((error) =>{
                    this.comentario  = '';
                    this.showSpinner = false;
                    this.updating = false;
                    this.closeModal();
                    this.showToast('Error', 'Se genero un error', 'error', 'dismissible');
            })
        }
  
        // Sort  Methods
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

              /////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //clicking on previous button this method will be called
        previousHandler() {
            if (this.page > 1) {
                this.page = this.page - 1; //decrease page by 1
                this.displayRecordPerPage(this.page);
            }
        }

        //clicking on next button this method will be called
        nextHandler() {
            if((this.page<this.totalPage) && this.page !== this.totalPage){
                this.page = this.page + 1; //increase page by 1
                this.displayRecordPerPage(this.page);            
            }             
        }

        //this method displays records page by page
        displayRecordPerPage(page){
            this.startingRecord = ((page -1) * this.pageSize) ;
            this.endingRecord = (this.pageSize * page);
            this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                                ? this.totalRecountCount : this.endingRecord; 
            this.data = this.dataAux.slice(this.startingRecord, this.endingRecord);
            this.startingRecord = this.startingRecord + 1;
        }    

        onHandleSort(event) {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const cloneData = [...this.items];            
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
            this.dataAux = cloneData;
            this.data = cloneData;
            this.data = this.data.slice(0,this.pageSize); 
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;    
            this.displayRecordPerPage(this.page);   
        }
        
        getSelectedById(event) {
            this.selectedRows = event.detail.selectedRows;
            for (let i = 0; i < this.selectedRows.length; i++){
                console.log("You selected: " + this.selectedRows[i].id);
            }
            this.disableApproval = (this.selectedRows.length == 0 || this.estadoSelected == 'Aprobada') ? true : false
            this.disableReject = (this.selectedRows.length == 0 || this.estadoSelected == 'Rechazada') ? true : false
        }

        setComentario(event) {
            this.comentario = event.detail.value;
        }

        handleApprovalClick(event) {
            this.isModalOpen = true;
            this.updating = false;
            this.labelRecjectApproval = 'Aprobada';
            this.cantidadDeRegistros =  this.selectedRows.length;
            console.log(this.selectedRows);
        }
        handleRejectClick(event) {
            this.isModalOpen = true;
            this.updating = false;
            this.labelRecjectApproval = 'Rechazada';
            this.cantidadDeRegistros =  this.selectedRows.length;
            console.log(this.selectedRows);
        }
        
        closeModal() {
            this.isModalOpen = false;
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

}