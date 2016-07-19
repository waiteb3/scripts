var Git = require('nodegit');

Git.Repository.open('go')
.then((repo) => {
    console.log(one);
    return [1, 2, 3]; 
})
.then((x) => {
    var a = x[0], b = x[1], c = x[2];
    console.log('two');
    return a + b + c;
})
.then((a) => {
    console.warn('three'); 
    return a * 10;
})
.catch((err) => {
    console.warn('four'); 
    return err;
})
.done((result) => {
    if (result instanceof Error) {
        console.warn('err: ' + result);
    }
    else {
        console.info('result: ' + result);
    }
});
