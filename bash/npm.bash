#!/bin/bash

npm_bin() {
    if [ -d node_modules ]; then
        export PATH=`npm bin`:$PATH
    else
        echo 'No node_modules path to set'
    fi
}

mocha_only () {
    if [ $# -lt 1 ]; then 
        echo 'Needs at least one argument. `mocha_only <filenames...>`'
        return 1
    fi

    if [ -f node_modules/mocha/bin/mocha ]; then
        node_modules/mocha/bin/mocha $@
    else
        echo 'Mocha is not installed. Try `npm install`'
    fi
}
