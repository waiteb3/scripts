var async = {
    parallel: function(functors) {
        const finalFn = this._getFinalFn(functors);

        const count = functors.length;
        const values = [];

        try {
            for (let fn of functors) {
                fn(this._parallel(count, values, finalFn));
            }
        } catch(err) {
            finalFn(err, null);
        }
    },

    series: function(functors) {
        const finalFn = this._getFinalFn(functors);

        const values = [];
        try {
            let first = functors.shift();

            while (functors.length > 0) {
                let next = functors.shift();
                
            }

            first(this._series(next, values, finalFn));
        } catch(err) {
            finalFn(err, null);
        }
    },

    _getFinalFn: function(functors) {
        if (functors.length < 2) {
            throw new Error(`Requires 2 arguments to form an async chain.`);
        }

        const finalFn = functors.pop();
        for (let fn of functors) {
            if (typeof fn !== 'function' && fn.length !== 1) {
                throw new Error(`All arguments for async must be a function with a callback as the only argument. See docs for details.`);
            }
        }
        return finalFn;
    },

    _parallel: function(count, values, finalFn) {
        return function(err, value) {
            if (err) throw new Error(err);

            values.push(value);

            if (values.length === count) {
                finalFn(null, values);
            }
        };
    },

    _series: function(next, values, finalFn) {
        return function(err, value) {
            if (err) throw new Error(err);

            values.push(value);

            if (next == null) {
                finalFn(values);
            } else {
                next();
            }
        };
    },

};

async.parallel([
    function(callback) {
        setTimeout(function() {
            console.log('100');
            callback(null, true);
        }, 100);
    },
    function(callback) {
        setTimeout(function() {
            console.log('500');
            callback(null, true);
        }, 500);
    },
    function(callback) {
        setTimeout(function() {
            console.log('1000');
            callback(null, true);
        }, 1000);
    },
    function(err, values) {
        if (err) throw err;
        console.log(values);
    },
]);

async.parallel([
    (cb) => cb('bad', null),
    (err) => console.warn(err),
]);

async.series([
    function(callback) {
        setTimeout(function() {
            console.log('100');
            callback(null, true);
        }, 100);
    },
    function(callback) {
        setTimeout(function() {
            console.log('500');
            callback(null, true);
        }, 500);
    },
    function(callback) {
        setTimeout(function() {
            console.log('1000');
            callback(null, true);
        }, 1000);
    },
    function(err, values) {
        if (err) throw err;
        console.log(values);
    },
]);
