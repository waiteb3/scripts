function propToTitle(property) {
    var str = property.charAt(0).toUpperCase();

    for (var i = 1; i < property.length; i++) {
        var prev = property[i-1];
        var char = property[i];
        if ('A' <= prev && prev <= 'Z') {
            str += char;
        }
        else if ('A' <= char && char <= 'Z') {
            str += " " + char;
        }
        else {
            str += char;
        }
    }

    return str;
}

Backbone.Form = Backbone.View.extend({

    tagName: "form",

    template: _.template('<div class="form-header"></div>\
               <div class="form-body"></div>\
               <div class="form-footer"></div>'),

    defaultButtons: {
        "save": Save,
        "cancel": Cancel
    },

    defaults: {
        required: []
    },

    /** requires: `model` (Backbone.Model), `fields` (array of fields)
     *  optional: `header` (template), `body` (template),  */
    initialize: function(options) {
        this.options = _.defaults(options, this.defautls);

        if (options.fields) {
            this.fields = _.map(options.fields, function(field) {
                // invoke default rules
                return new field.type(field);
            });
        }
        else {
            this.fields = _.map(this.model.keys(), function(property) {
                var view = SimpleInput;

                var overrides = options.overrides[property] || {};
                if (!_.isUndefined(overrides) && overrides.type) {
                    view = overrides.type;
                }

                var isRequired = options.required.indexOf(property);
                return new view(_.extend({
                    model: model,
                    title: propToTitle(property), // TODO title case
                    property: property,
                    rules: (isRequired) ? [Required()] : []
                }, overrides));
            });
        }
    },

    validate: function() {
        return _.every(_.invoke(this.fields, "validate"));
    },

    render: function() {
        this.$el.html(this.template());

        this.$(".form-header").append(this.options.header(this.model.toJSON()));

        _.each(this.fields, function(field) {
            this.$(".form-body").append(field.render().el);
        }, this);


        _.each(this.options.buttons, function(button) {
            if (_.isString(button)) {
                button =  new this.defaultButtons[button]();
            }
            else if (!(button instanceof Backbone.View) && _.isObject(button)) {
                button = new this.defaultButtons[button.type](button);
            }

            this.$(".form-footer").append(button.render().el);
        }, this);

        return this;
    }

});
