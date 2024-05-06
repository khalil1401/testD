import LightningDatatable from 'lightning/datatable';
import customPicklist from './customPicklist.html';

export default class CustomTypes extends LightningDatatable {
      
    static customTypes ={
        unidadMedidaPicklist : {
            template: customPicklist,
            standardCellLayout: true,
            typeAttributes: ['value', 'options', 'contex', 'placeholder'],
        }
    }
    
}