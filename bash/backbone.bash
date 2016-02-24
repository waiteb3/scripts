#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

backbone_view() {
    cat $DIR/templates/backbone/view.js
}

backbone_model() {
    cat $DIR/templates/backbone/model.js
}

backbone_relational_model() {
    cat $DIR/templates/backbone/relational_model.js
}

backbone_collection() {
    cat $DIR/templates/backbone/collection.js
}
