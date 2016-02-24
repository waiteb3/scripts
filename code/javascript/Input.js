var Input = Backbone.View.extend({

    tagName: "input",

    events: {
        "blur": "onBlur"
    },

    defaults: { },

    initialize: function(options) {
        this.options = _.defaults(options || {}, this.defaults);

        this.property = options.property;

        // get the value, parse it, print it, then format it
        this.process = _.compose(
            this.$el.val,
            this.formatter,
            this.setOnModel,
            this.printer,
            this.parser,
            this.$el.val
        );

        this.fieldInitialize();
    },

    fieldInitialize: function() { /** no op if desired */ },

    onBlur: function() {
        this.process();
        this.trigger("input:blur", this);
    },

    parser: function(value) { },

    setOnModel: function(value) {
        this.model.set(this.property, value);
        return value;
    },

    printer: function(value) { },

    formatter: function(value) { },

    isMobile: function() {
        return (window.navigator.userAgent.match(/mobi/i) !== null);
    },

    validate: function() {
        return true;
    },

    render: function() {
        this.$el.prop("disabled", this.options.disabled || false);

        return this;
    },

});
