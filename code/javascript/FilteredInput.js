var FilteredInput = Backbone.View.extend({

    tagName: "input",

    events: {
        "keydown": "filter"
    },

    initialize: function(options) {
        //Must.beExtended();
    },

    filter: function(event) {
        if (_.contains([46, 8, 9, 27, 13, 110, 190], event.keyCode) ||
             // Allow: Ctrl+A, Command+A
            (event.keyCode == 65 && ( event.ctrlKey === true || event.metaKey === true ) ) || 
             // home, end, left, right, down, up
            (event.keyCode >= 35 && event.keyCode <= 40)) {
                 return;
        }

        if (this.allowed(event.keyCode)) {
            event.preventDefault();
        }
    },

    allowed: Must.beImplementedAs(function(event) { return true || false; }),

    render: function() {
        return this;
    }

});
