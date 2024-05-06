import { LightningElement, track, wire } from 'lwc';
import getSupervisores from '@salesforce/apex/ficheroController.getSupervisores';
import getUserList from '@salesforce/apex/ficheroController.getUserList';
import getUserApm from '@salesforce/apex/ficheroController.getUserApm';
import getAccountTeam from '@salesforce/apex/ficheroController.getAccountTeam';
import getData from '@salesforce/apex/ficheroController.getData';
import getMetadataInfo from '@salesforce/apex/ficheroController.getMetadataInfo'
import transferirProfesional from '@salesforce/apex/ficheroController.transferirProfesional';
import compartirProfesional from '@salesforce/apex/ficheroController.compartirProfesional';
import bajaProfesional from '@salesforce/apex/ficheroController.bajaProfesional';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import PROVINCIA_FIELD from '@salesforce/schema/Account.Provincia__c';
import ESPECIALIDAD_FIELD from '@salesforce/schema/Account.Primera_especialidad__c';
import BAJA_OBJECT from '@salesforce/schema/VisMed_Bajas__c';
import MOTIVO_BAJA_FIELD from '@salesforce/schema/VisMed_Bajas__c.Motivo_de_la_Baja__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columnsInstitucion = [
    {label: 'Institucion',fieldName: 'institucionURL',type: 'url',sortable: true,cellAttributes: {alignment: 'left'}, typeAttributes: {label: { fieldName: 'institucion' }, target: '_parent'}},
    {label: 'Provincia',fieldName: 'provincia',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    {label: 'Localidad',fieldName: 'localidad',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}},
    {label: 'Codigo Postal',fieldName: 'codigoPostal',type: 'text',sortable: true,cellAttributes: {alignment: 'left'}}
];


export default class Fichero extends LightningElement {

    showTable = true;
    mostrarFiltros = true;
    mostrarBotones = true;
    columnsInstitucion = columnsInstitucion;
    error;
    showSpinner = true;
    @track cantidadDeRegistros = 0;
    @track supervisores;
    @track listaDeSupervisoresSeleccionados = [];
    @track users;
    @track usersList;
    @track usersSeleccionados = [];
    @track selectedSupervisor = [];
    @track selectedUser = [];
    @track listaDeProfesionales;
    @track objectInfo;
    @track profesionalSeleccionado = '';
    @track institucionSeleccionada = '';
    @track optionsLocalidad = [{ label: 'Todos', value: '' }];
    @track optionsCodigoPostal = [{ label: 'Todos', value: '' }];
    @track optionsProvincia = [{ label: 'Todos', value: '' }];
    @track optionsEspecialidad;
    @track ultimaVisitaSelected = '';
    @track especialidadSelected = '';
    @track provinciaSelected = '';
    @track localidadSelected = '';
    @track codigoPostalSelected = '';
    mapRows = new Map();
    modal;
    selectedAPMs;
    actionButton;
    isBajaProfesional;
    usersApms = [];
    @track acountTeams = [];
    userApmsSelecteds = [];
    profesionalsSelecteds = [];
    profesionalWasSelected = false;
    @track optionsMotivosBaja;
    @track motivoDeBaja;
    @track toggleValue = false;
    @track selectedrows = [];
    @track fechaDesactRequired = false;

    @wire(getSupervisores)
    WiredSupervisores({ error, data }) {
        if (data) { 
            this.supervisores = [];
            for(var i in data)  {
                this.supervisores = [...this.supervisores ,{label: data[i].Name, value: data[i].Id} ];
            }
            return refreshApex(this.supervisores);
        } else if (error) {
            console.log('ERROR: ' + JSON.stringify(error));
            this.error = error;
        }
    }

    handleChange(e) {
        this.listaDeSupervisoresSeleccionados = undefined; // cambio la definicion de la lista para que el decorador track reconozca el cambio y actualice el combobox.
        this.listaDeSupervisoresSeleccionados = e.detail;
        this.users = null; // cambio la definicion de la lista para que el decorador track reconozca el cambio y actualice el combobox.
        this.usersList = undefined;
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.listaDeSupervisoresSeleccionados);
    }

    @wire(getUserList, {
        supervisores: '$listaDeSupervisoresSeleccionados'
    })
    WiredUsers({ error, data }) {
        if (data) { 
            this.users = [];
            this.usersList = [];
            for(const user of data)  {
                const option = {
                    label: user.Name,
                    value: user.ContactId                    
                };
                               
                this.users = [...this.users , option];   
                this.usersList = [...this.usersList , user.ContactId];
                
            }       
            this.showSpinner = false;
            return refreshApex(this.usersList);
        } else if (error) {
            this.showToast('Error', 'Se genero un error al buscar la data', 'error', 'dismissible');
            this.showSpinner = false;
            console.log('ERROR: ' + error);
            console.log(error);
            this.error = error;
        }
    }   

    handleChange2(e) {        
        this.usersSeleccionados = undefined;
        this.usersSeleccionados = e.detail;
        if(this.toggleValue){
            this.resetToggle();
        }
        console.log('detail: ' + e.detail);
       
    }

    @wire(getUserApm, {
        apms: '$usersSeleccionados'
    })WiredUserApm({ error, data }) {
        if (data) {   
            this.usersApms = [];
            console.log('user selecc: '+this.usersSeleccionados);
            for(const user of data)  {  
                this.usersApms.push(user.Id);
            }
            
            console.log('userApm: '+JSON.stringify(this.usersApms));
         }else if (error) {
            this.showToast('Error', 'Se genero un error al buscar la data', 'error', 'dismissible');
            this.showSpinner = false;
            console.log('ERROR: ' + error);
            console.log(error);
            this.error = error;
        }
    }
    @wire(getAccountTeam, {
        users: '$usersApms'
    })WiredAccountTeam({ error, data }) {
        if (data) {   
            this.acountTeams = [];            
            for(const accTeam of data)  {  
                this.acountTeams.push(accTeam.AccountId);
            }
            
            //console.log('Account team:: '+JSON.stringify(this.acountTeams));
            console.log('Account team size: '+this.acountTeams.length);
         }else if (error) {
            this.showToast('Error', 'Se genero un error al buscar la data', 'error', 'dismissible');
            this.showSpinner = false;
            console.log('ERROR: ' + error);
            console.log(error);
            this.error = error;
        }
    }
    handleProfesionalSelection(event) {
        this.profesionalSeleccionado = event.detail;        
        // console.log('profesional');
        // console.log(event.detail);
        // console.log('profesional List');
        // console.log(this.profesionalsSelecteds);
        
        if(this.profesionalsSelecteds.includes(this.profesionalSeleccionado) && this.profesionalSeleccionado){
            this.profesionalWasSelected = true;            
        }else{
            if (this.profesionalSeleccionado) {
                this.profesionalsSelecteds.push(this.profesionalSeleccionado);                
            }
            this.profesionalWasSelected = false;
        }        

        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.profesionalSeleccionado);
    }
    handleInstitucionSelection(event) {
        this.institucionSeleccionada = event.detail;
        console.log(event.detail.value);
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.institucionSeleccionada);
    }

    get optionsUltimaVisita() {
        return [
                { label: 'Todos', value: '' },
                { label: '+30', value: '30' },
                { label: '+45', value: '45' },
                { label: '+60', value: '60' },
                { label: '+90', value: '90' },
                { label: '+180', value: '180' },
                { label: '+365', value: '365' },
        ];
    }
    handleFilterUltimaVisitaChange(event) {
        this.ultimaVisitaSelected = event.detail.value;
        console.log(event.detail.value);
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.ultimaVisitaSelected);
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    /*@wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: PROVINCIA_FIELD
    })
    setOptionsProvincia(result) {
        if (result.data) {
            this.optionsProvincia = [{ label: 'Todos', value: '' }, ...result.data.values];
        }
    }*/
    handleFilterProvinciaChange(event) {
        this.provinciaSelected = event.detail.value;
        console.log(event.detail.value);
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.provinciaSelected);
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: ESPECIALIDAD_FIELD
    })
    setOptionsEspecialidad(result) {
        if (result.data) {
            this.optionsEspecialidad = [{ label: 'Todos', value: '' }, ...result.data.values];
        }
    }
    handleFilterEspecialidadChange(event) {
        this.especialidadSelected = event.detail.value;
        console.log(event.detail.value);
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.especialidadSelected);
    }

    handleFilterLocalidadChange(event) {
        this.localidadSelected = event.detail.value;
        console.log(event.detail.value);
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.localidadSelected);
    }

    handleFilterCodigoPostalChange(event) {
        this.codigoPostalSelected = event.detail.value;
        console.log(event.detail.value);
        if(this.toggleValue){
            this.resetToggle();
        }
        return refreshApex(this.codigoPostalSelected);
    }

    @track _wiredData;
    @wire(getData, {
        usuariosHabiles: '$usersList',
        usuariosSeleccionados: '$usersSeleccionados',
        profesional: '$profesionalSeleccionado',
        institucionSeleccionada: '$institucionSeleccionada',
        ultimaVisita: '$ultimaVisitaSelected',
        especialidad: '$especialidadSelected',
        provincia: '$provinciaSelected',
        localidad: '$localidadSelected',
        codigoPostal: '$codigoPostalSelected'
    })
    WiredData(wireResult) {
        const { error, data } = wireResult;
        this._wiredData = wireResult;
        if (data) {
            this.showSpinner = false;
            
            const listDeLocalidades =[];
            const listDeCP =[];
            const listProvincias =[];
            this.cantidadDeRegistros = 0;
            this.listaDeProfesionales = [];
            this.listaDeProfesionales = JSON.parse(data);
            //console.log('lista profesionales: '+JSON.stringify(this.listaDeProfesionales));
            //this.optionsLocalidad = [{ label: 'Todos', value: '' }];
            //this.optionsCodigoPostal = [{ label: 'Todos', value: '' }];
            for(const fichero of JSON.parse(data)) {
                for(const institucion of fichero.instituciones) {
                    if (institucion.localidad && !listDeLocalidades.includes(institucion.localidad)) {
                        this.optionsLocalidad = [...this.optionsLocalidad,{label: institucion.localidad, value: institucion.localidad}];
                        listDeLocalidades.push(institucion.localidad);
                    }
                    if (institucion.codigoPostal && !listDeCP.includes(institucion.codigoPostal)) {
                        this.optionsCodigoPostal = [...this.optionsCodigoPostal,{label: institucion.codigoPostal, value: institucion.codigoPostal}];
                        listDeCP.push(institucion.codigoPostal);
                    }
                    if (institucion.provincia && !listProvincias.includes(institucion.provincia)) {
                        this.optionsProvincia = [...this.optionsProvincia,{label: institucion.provincia, value: institucion.provincia}];
                        listProvincias.push(institucion.provincia);
                    }
                }
                this.cantidadDeRegistros ++;
            }
            this.showSpinner = false;
           // console.log('lista profesionales: '+ JSON.stringify(this.listaDeProfesionales) );
            return refreshApex(this.listaDeProfesionales);
        } else if (error) {
            this.showToast('Error', 'Se genero un error al buscar la data', 'error', 'dismissible');
            this.showSpinner = false;
            console.log(error);
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

    mostrarInstituciones(event) {
        this.listaDeInstitucionesDelProfesional = [];
        this.listaDeProfesionales.forEach(element => {
            if (event.target.title == element.idFichero) {
                element.mostrar = !element.mostrar;
//                console.log(element.mostrar);
            }
        });
    }

    //METODOS NUEVOS
    verDetalleInstitucion(event){
        const selectedRows = event.detail.selectedRows;
        let profId = event.currentTarget.dataset.id;
        console.log(profId);
        let selecetedRowIds = [];
        for(let i = 0; i<selectedRows.length; i++){
            selecetedRowIds.push(selectedRows[i].idInstitucion);
        }
        this.mapRows[profId] = selecetedRowIds;
        //this.mapRows.set(profId, selecetedRowIds);
        console.log(this.mapRows);
    }

    openModal(){
        this.modal = true;
        console.log('this.mapRows');
        console.log(this.mapRows);
    }

    closeModal(){
        this.modal = false;
        this.isBajaProfesional = false;
        this.selectedAPMs = '';
        this.motivoDeBaja = '';
        //this.showSpinner = false;
    }

    handleSelectedAPMs(event){
        this.selectedAPMs = event.detail.value;
        console.log('selectedApm: '+ this.selectedAPMs);        
    }

    handleTransferOrShare(event){
        
        this.actionButton = event.target.label;
        if(this.actionButton == 'Baja de Profesional'){
            this.isBajaProfesional = true;
        }
        this.openModal();
    }

    actionModal(){
        if(this.actionButton == 'Transferir'){
            this.showSpinner = true;
            console.log('Contenido del map rows> '+ JSON.stringify(this.mapRows));
            // console.log('this.mapRows', JSON.stringify(this.mapRows));
            // console.log('this.listaDeProfesionales', JSON.stringify(this.listaDeProfesionales));



            let newMapRows = new Map();
            // this.listaDeProfesionales.forEach(fichero => {
            //     console.log('this.mapRows[fichero.idFichero]:', this.mapRows[fichero.idFichero]);
            //     if(this.mapRows[fichero.idFichero]) {
            //         let institucioneIds = [];
                    
            //         fichero.instituciones.forEach(institucion => {
            //             institucioneIds.push(institucion.idInstitucion);
            //         });
            //         newMapRows[fichero.idFichero] = institucioneIds;
            //     }
            // });
            for(const fichero of this.listaDeProfesionales) {
                console.log('this.mapRows[fichero.idFichero]:', this.mapRows[fichero.idFichero]);
                if(this.mapRows[fichero.idFichero]) {
                    let institucioneIds = [];
                    
                    for(const institucion of fichero.instituciones) {
                        institucioneIds.push(institucion.idInstitucion);
                    }
                    newMapRows[fichero.idFichero] = institucioneIds;
                }
            }
            console.log('this.mapRows', JSON.stringify(this.mapRows));
            console.log('JSON.stringify(newMapRows)', JSON.stringify(this.newMapRows));



            console.log("APMs: " + this.selectedAPMs);
            var comentariomotivo = this.template.querySelector('[data-id="comentariomotivo"]').value;
            console.log("comentariomotivo: " + comentariomotivo);
            transferirProfesional({
                ficheros: this.mapRows,
                // ficheros: newMapRows,
                apms: this.selectedAPMs,
                comentario: comentariomotivo
            })
            .then((data)=>{
                console.log('****Entro al then');
                console.log(data);
                // return refreshApex(this.listaDeProfesionales);
                this.showToast('Exito', 'Se realizo la accion con exito.', 'success', 'dismissible');
                this.showSpinner = false;
                this.mapRows = new Map();
                return refreshApex(this._wiredData);
            })
            .catch(error => {
                this.showToast('Error', 'Se genero un error', 'error', 'dismissible');
                this.showSpinner = false;
                console.log('Error: ', error);
                console.log('Error: ', JSON.stringify(error));
            });
        }
        else if(this.actionButton == 'Compartir'){
            this.showSpinner = true;
            console.log(this.mapRows);
            let newMapRows = new Map();
            for(const fichero of this.listaDeProfesionales) {
                console.log('this.mapRows[fichero.idFichero]:', this.mapRows[fichero.idFichero]);
                if(this.mapRows[fichero.idFichero]) {
                    let institucioneIds = [];
                    
                    for(const institucion of fichero.instituciones) {
                        institucioneIds.push(institucion.idInstitucion);
                    }
                    newMapRows[fichero.idFichero] = institucioneIds;
                }
            }
            console.log("APMs: " + this.selectedAPMs);
            var comentariomotivo = this.template.querySelector('[data-id="comentariomotivo"]').value;
            console.log("comentariomotivo: " + comentariomotivo);
            console.log(newMapRows);
            compartirProfesional({
                //ficheros: this.mapRows,
                ficheros: newMapRows,
                apms: this.selectedAPMs,
                comentario: comentariomotivo
            })
            .then((data)=>{
                console.log(data);
                this.showToast('Exito', 'Se realizo la accion con exito.', 'success', 'dismissible');
                this.showSpinner = false;
                this.mapRows = new Map();
                return refreshApex(this._wiredData);
            })
            .catch(error => {
                this.showToast('Error', 'Se genero un error', 'error', 'dismissible');
                this.showSpinner = false;
                //newMapRows = [];
                console.log('Error: ', error);
            });
        }
        else if(this.actionButton == 'Baja de Profesional'){
            this.showSpinner = true;
            console.log(this.mapRows);
            console.log("motivoDeBaja: " + this.motivoDeBaja);
            var fechaDesactivacion;
            var fechaReactivacion;
            if(this.motivoDeBaja == 'Enfermedad' || this.motivoDeBaja == 'Maternidad' || this.motivoDeBaja == 'Viaje'){
                fechaDesactivacion = this.template.querySelector('[data-id="fechadesactivacion"]').value;
                fechaReactivacion = this.template.querySelector('[data-id="fechareactivacion"]').value;
            }
            var comentariomotivo = this.template.querySelector('[data-id="comentariomotivo"]').value;
            console.log("comentariomotivo: " + comentariomotivo);
            bajaProfesional({
                ficheros: this.mapRows,
                comentario: comentariomotivo,
                fechaDesactivacion: fechaDesactivacion,
                fechaReactivacion: fechaReactivacion,
                motivoDeBaja: this.motivoDeBaja
            })
            .then((data)=>{
                console.log(data);
                this.showToast('Exito', 'Se realizo la accion con exito.', 'success', 'dismissible');
                this.showSpinner = false;
                //newMapRows = [];
                this.mapRows = new Map();
                return refreshApex(this._wiredData);
            })
            .catch(error => {
                this.showToast('Error', 'Se genero un error.Por favor, compruebe las FECHAS', 'error', 'dismissible');
                this.showSpinner = false;
                console.log('Error: ', error);
            });
        }
        
        this.closeModal();
        this.isBajaProfesional = false;
        this.selectedAPMs = '';
        this.motivoDeBaja = '';
    }

    @wire(getObjectInfo, { objectApiName: BAJA_OBJECT })
    objectInfoBaja;
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfoBaja.data.defaultRecordTypeId",
        fieldApiName: MOTIVO_BAJA_FIELD
    })
    setOptionsMotivos(result) {
        if (result.data) {
            let allData = result.data.values;
            const motivos = [];
            for (let index = 0; index < allData.length; index++) {
                if( allData[index].value != 'Transferido a otro Visitador'){
                    console.log(allData[index].value);
                    motivos.push(allData[index]);
                }
            }
            console.log(motivos);
            //this.optionsMotivosBaja = result.data.values.value.filter(item => item !== value);
            this.optionsMotivosBaja = [...motivos];
        }
    }

    handleOptionMotivos(event){
        this.motivoDeBaja = event.target.value;

        getMetadataInfo({ 
            MtdLabel: this.motivoDeBaja 
        })
        .then((data) => {
            this.fechaDesactRequired = data;
            console.log('this.fechaDesactRequired');
            console.log(this.fechaDesactRequired);
            this.error = undefined;
        })
        .catch(error => {
            console.log('Error: ' + error);
            this.error = error;
        });
    }


    onChangeToggle(){
        this.toggleValue = !this.toggleValue;
        if(this.toggleValue){
            const listDeIdInstituciones = [];
            for(const fichero of this.listaDeProfesionales){
                const listDeIdInstitucionesPorFichero = [];
                for(const inst of fichero.instituciones){
                    listDeIdInstitucionesPorFichero.push(inst.idInstitucion);
                    listDeIdInstituciones.push(inst.idInstitucion);
                    this.mapRows[fichero.idFichero] = listDeIdInstitucionesPorFichero;
                    //this.mapRows.set(fichero.idFichero, listDeIdInstitucionesPorFichero);
                }
            }
            this.selectedrows = listDeIdInstituciones;
            console.log(this.mapRows);
        }
        else{
            for(const fichero of this.listaDeProfesionales){
                    this.mapRows[fichero.idFichero] = [];
            }
            this.selectedrows = [];
            console.log(this.mapRows);
        }
    }

    resetToggle(){
        this.toggleValue = !this.toggleValue;
        for(const fichero of this.listaDeProfesionales){
            this.mapRows[fichero.idFichero] = [];
        }
        this.selectedrows = [];
        console.log(this.mapRows);
    }
}