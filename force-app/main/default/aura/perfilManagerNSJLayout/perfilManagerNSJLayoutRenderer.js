({
    // Your renderer method overrides go here
    afterRender: function (component, helper) {
        this.superAfterRender();
        // interact with the DOM here
        let cmp = document.getElementById("nsj-body");
        if(cmp) {
            cmp.style.backgroundColor = "#F0ECE8";
        }
    },
})