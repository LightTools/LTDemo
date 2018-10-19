({
    createCharts : function(component) {
        // define common data for charts
        const chartData = {
            "labels": ["Prospecting", "Qualification", "Needs Analysis", "Closed Won", "Closed Lost"],
            "datasets": [{
                "label": "Opportunities",
                "data": [10, 12, 19, 30, 21],
                "backgroundColor": [
                    "rgba(120, 144, 156, 0.8)",
                    "rgba(255, 202, 40, 0.8)",
                    "rgba(41, 182, 246, 0.8)",
                    "rgba(102, 187, 106, 0.8)",
                    "rgba(239, 83, 80, 0.8)"
                ],
                "borderWidth": 0,
                "fill": false
            }]
        };
        // create charts configurations
        component.set("v.charts", [{
            // tab configuration
            "tabTitle": "Line",
            // chart configuration
            "type": "line",
            "data": Object.assign({}, chartData, {
                "labels": [
                    new Date(new Date().getFullYear(), 0, 1),
                    new Date(new Date().getFullYear(), 1, 1),
                    new Date(new Date().getFullYear(), 2, 1),
                    new Date(new Date().getFullYear(), 3, 1),
                    new Date(new Date().getFullYear(), 4, 1)
                ],
                "datasets": [Object.assign({}, chartData.datasets[0], {
                    "borderColor": "rgba(41, 182, 246, 0.8)",
                    "pointBackgroundColor": "rgba(41, 182, 246, 0.8)"
                })]
            }),
            "options": {
                "title": {
                    "display": true,
                    "text": "Number of Closed-Won Opportunities by Month"
                },
                "legend": {
                    "display": false
                },
                "scales": {
                    "yAxes": [{
                        "ticks": {
                            "max": 35,
                            "beginAtZero": true
                        }
                    }],
                    "xAxes": [{
                        "type": 'time',
                        "time": {
                            "unit": "month",
                            "displayFormats": {
                                "month": "MMMM"
                            }
                        }
                    }]
                }
            }
        },{
            // tab configuration
            "tabTitle": "Bar",
            // chart configuration
            "type": "bar",
            "data": chartData,
            "options": {
                "title": {
                    "display": true,
                    "text": "Opportunities by Stages"
                },
                "legend": {
                    "display": false
                },
                "scales": {
                    "yAxes": [{
                        "ticks": {
                            "max": 35,
                            "beginAtZero": true
                        }
                    }]
                }
            }
        },{
            // tab configuration
            "tabTitle": "Radar",
            // chart configuration
            "type": "radar",
            "data": Object.assign({}, chartData, {
                "datasets": [Object.assign({}, chartData.datasets[0], {
                    "borderColor": "rgba(41, 182, 246, 0.8)",
                    "pointBackgroundColor": "rgba(41, 182, 246, 0.8)",
                    "backgroundColor": "rgba(41, 182, 246, 0.4)",
                    "fill": true
                })]
            }),
            "options": {
                "title": {
                    "display": true,
                    "text": "Opportunities by Stages"
                },
                "legend": {
                    "display": false
                },
                "scale": {
                    "ticks": {
                        "max": 35,
                        "beginAtZero": true
                    }
                }
            }
        },{
            // tab configuration
            "tabTitle": "Pie",
            // chart configuration
            "type": "pie",
            "data": chartData,
            "options": {
                "title": {
                    "display": true,
                    "text": "Opportunities by Stages"
                },
                "legend": {
                    "position": "bottom"
                }
            }
        },{
            // tab configuration
            "tabTitle": "Doughnut",
            // chart configuration
            "type": "doughnut",
            "data": chartData,
            "options": {
                "title": {
                    "display": true,
                    "text": "Opportunities by Stages"
                },
                "legend": {
                    "position": "bottom"
                }
            }
        },{
            // tab configuration
            "tabTitle": "More...",
            // show more button
            "type": "showMore"
        }]);
    }
})