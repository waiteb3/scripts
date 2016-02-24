var view = Backbone.View.extend({

    template: _.template('\
        '),

    defaults: { },

    events: {
        "event .event-target": "onEvent"
    },

    initialize: function(options) {
        _.bindAll(this, "onEvent");

        this.options = _.defaults(options || {}, this.defaults);
    },

    onEvent: function() { },

    validate: function() {
        return _.every(_.invoke(this.subViews, "validate"));
    },

    render: function() {
        this.$el.html(this.template(this.options));
        this.$el.html(this.template(this.model.toJSON()));

        return this;
    }

});
