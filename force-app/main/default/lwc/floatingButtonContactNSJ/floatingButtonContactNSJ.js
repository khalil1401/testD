import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import iconFAQRS from '@salesforce/resourceUrl/iconHelpFAQNSJ';

export default class FloatingButtonContactNSJ extends NavigationMixin(LightningElement) {

    iconFAQ = iconFAQRS;
    spanFAQs = false;
    
    get isMobile(){
        return FORM_FACTOR === 'Small';
    }

    connectedCallback() {        
        if(this.isMobile){
            // Listen for scroll events on the window
            window.addEventListener('scroll', () => {
                // Get the height of the entire page (including content below the viewport)
                const pageHeight = document.documentElement.scrollHeight;
                const pageWidth = document.documentElement.scrollWidth;
        
                // Get the current position of the viewport relative to the top of the page
                const scrollPosition = window.scrollY + window.innerHeight;
    
                let elem = this.template.querySelector('[data-id="faq-button"]');
                const bottom = elem.offsetTop + elem.offsetHeight;
    
                if(pageWidth <= 412){
                    if (scrollPosition >= pageHeight-64) {
                        if(bottom < 660){
                            elem.style.bottom = "15%";
                        }
                        else{
                            elem.style.bottom = "12%";
                        }
                    } else {
                        if(bottom < 660){
                            elem.style.bottom = "11.25%";
                        }
                        else{
                            elem.style.bottom = "8.63%";
                        }
                    }
                }
            });
        }
    }

    navigateTo(event) {
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

    showSpanFAQs() {
        this.spanFAQs = true;
    }

    hideSpanFAQs() {
        this.spanFAQs = false;
    }

}