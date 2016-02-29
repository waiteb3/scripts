var Required = function(message) {
    return function() {

        this.validator = function(value) {
            return value !== "";
        };

        this.message = message || "This field is required.";

    };
};

var GreaterThan = function(num, inclusive, message) {
    return function() {

        this.validator = function(value) {
            return (inclusive) ? (value >= num) : (value > num);
        };

        this.message = message || "Must be " +
            ((inclusive) ? "at least" : "greater than") + " " + num;

    };
};

var LessThan = function(num, inclusive, message) {
    return function() {

        this.validator = function(value) {
            return (inclusive) ? (value <= num) : (value < num);
        };

        this.message = message || "Must be " +
            ((inclusive) ? "at most" : "less than") + " " + num;

    };
};
