var input = Backbone.View.extend({

    tag: "input",

    defaults: { },
    
    events: {
        "keypress" : "filter",
        "keyup" : "format"
    },

    initialize: function(options) {
        this.options = _.defaults(options || {}, this.defaults);

        this.initializeField();
    },

    initializeField: function() {
        Must.beExtended();
    },

    validate: function() {
        Must.beExtended();
    },

    render: function() {
        return this;
    }

});
