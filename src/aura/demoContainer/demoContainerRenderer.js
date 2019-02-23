({
    afterRender : function(component, helper) {
        this.superAfterRender();
        // set photo url
        helper.setPhotoUrl(component);
        // create demo items
        helper.createDemoItems(component);
    }
})