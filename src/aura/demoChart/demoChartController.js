({
    initialize : function(component, event, helper) {
        helper.createCharts(component);
    },
    showMore : function() {
        // just redirect to Chart.js documentation
        window.open("https://www.chartjs.org/samples/latest/");
    }
})