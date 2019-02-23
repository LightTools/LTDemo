({
    initialize : function(component, event, helper) {
        // set title
        component.set("v.title", "Chart");
        // set config
        helper.createCharts(component);
    },
    showMore : function() {
        // just redirect to Chart.js documentation
        window.open("https://www.chartjs.org/samples/latest/");
    }
})