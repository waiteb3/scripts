var number = input.extend({

    initialize: function(options) {
    },

    render: function() {
        // on mobile switch to html5 number
        if (window.navigator.userAgent.match(/mobi/i)) {
            this.$el.prop("type", "number");
            this.unbind("keypress", this.whitelist);
        }

        if (this.options.readOnly) {
            this.$el.prop("disabled", true);
        }

        return this;
    }

});
