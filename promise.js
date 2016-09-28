function MyPromise(executor) {
    this.state = MyPromise.PENDING;
    this.value = null;

    this._resolve = (value) => {
        this.value = value;
        this.state = MyPromise.prototype.FULLFILLED;

        if (typeof this._then === 'function') {
            this._then(value);
        }
    };

    this._rejected = (value) => {
        this.value = value;
        this.state = MyPromise.prototype.REJECTED;

        if (typeof this._catch === 'function') {
            this._catch(value);
        }
    };

    this.then = (functor) => {
        this._then = functor;
        return this;
    };

    this.catch = (functor) => {
        this._catch = functor;
        return this;
    }

    executor(this._resolve, this._rejected);
}

MyPromise.prototype.PENDING = 0;
MyPromise.prototype.FULLFILLED = 1;
MyPromise.prototype.REJECTED = 2;

var pass = new MyPromise(function(resolve, reject) {
    setTimeout(resolve, 1000, true);
}).then(function(value) {
    console.log(`pass ${value}`);
}).catch(function(error) {
    console.warn(`error ${error}`);
});

var fail = new MyPromise(function(resolve, reject) {
    setTimeout(reject, 3000, false);
}).then(function(value) {
    console.log(`pass ${value}`);
}).catch(function(error) {
    console.warn(`error ${error}`);
});
