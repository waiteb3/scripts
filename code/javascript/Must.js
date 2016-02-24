var Must = {

    beExtended: new Error("This class must be extended since it is abstract."),

    beImplementedAs: function(func) {
        return new Error("This function must be overridden with expected signiture: " + func.toString());
    }

};
