import { LightningElement, api } from 'lwc';

export default class TaskGeneratorModal extends LightningElement {
    @api messaggeFromParent;

    back() {
        let url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
    }
}