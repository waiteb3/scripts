var Form = Backbone.View.extend({

    tagName: "form",

    /** requires: `model` (Backbone.Model), `fields` (array of fields)
     *  optional: `header` (template), `body` (template),  */
    initialize: function(options) {
        this.options = options;

        this.fields = _.map(options.fields, function(field) {
            // invoke default rules
            return new field.type({
                model: this.model,
                property: field.property,
                rules: field.rules
            });
        });
    },

    validate: function() {
        return _.every(_.invoke(this.fields, "validate"));
    },

    render: function() {
        this.$el.append(this.options.header(this.model.toJSON()));

        _.each(this.fields, function(field) {
            this.$el.append(field.render().el);
        }, this);

        return this;
    }

});
