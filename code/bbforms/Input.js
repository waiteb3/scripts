var Must = {
    extendProperty: function(obj, prop) {
        return new Error("Must extend " + obj + "'s " + prop);
    }
};

var Input = Backbone.View.extend({

    tagName: "input",

    className: "form-control",

    events: {
        "blur": "onBlur"
    },

    initialize: function(options) {
        _.bindAll(this, "onBlur");

        this.options = options || {};

        this.fieldInitialize(options);
    },

    fieldInitialize: function(options) {
        // throw Must.extendProperty("Input", "fieldInitialize");
    },

    onBlur: function() {
        this.trigger("field:blur", this);
    },

    setValue: function(value) {
        this.$el.val(value);
    },

    getValue: function() {
        return this.$el.val();
    },

    render: function() {
        return this;
    }

});

var SimpleInput = Backbone.View.extend({

    tagName: "div",

    template: _.template('<label><%= title %></label>'),

    className: "form-group col-sm-3",

    initialize: function(options) {
        _.bindAll(this, "onInputBlur");

        this.options = options || {};

        this.input = new Input();

        this.fieldInitialize();
    },

    fieldInitialize: function() { },

    onInputBlur: function() {
        if (this.validate()) {
            this.model.set(this.options.property, this.input.getValue());
        }
    },

    render: function() {
        if (this.options.title) {
            this.$el.append(this.template(this.options));
        }

        this.$el.append(this.input.render().el);

        if (!_.isUndefined(this.options.property)) {
            this.listenTo(this.input, "field:blur", this.onInputBlur);
        }

        return this;
    }

});

var Email = SimpleInput.extend({

    fieldInitialize: function(options) {
        console.log("Email");
    }

});

var DateTime = SimpleInput.extend({

    fieldInitialize: function(options) {
        console.log("Date");
    }

});

var Time = SimpleInput.extend({

    fieldInitialize: function(options) {
        console.log("Time");
    }

});

var Phone = SimpleInput.extend({

    fieldInitialize: function(options) {
        console.log("Phone");
    }

});

var Numeric = SimpleInput.extend({

    fieldInitialize: function(options) {
        console.log("Numeric");
    }

});

var Save = Backbone.View.extend({
    tagName: "button",
    className: "btn btn-primary",
    events: { "click": "action" },
    initialize: function(options) {
        _.bindAll(this, "action");
        this.options = options || {};
        this.action = this.options.action || this.action;
    },
    action: function() { alert("Saved!"); },
    render: function() { this.$el.text("Save"); this.$el.prop("type", "button"); return this; }
});

var Cancel = Backbone.View.extend({
    tagName: "button",
    className: "btn btn-secondary",
    events: { "click": "action" },
    initialize: function(options) {
        _.bindAll(this, "action");
        this.options = options || {};
        this.action = this.options.action || this.action;
    },
    action: function() { alert("Cancel!"); },
    render: function() { this.$el.text("Cancel"); this.$el.prop("type", "button"); return this; }
});
