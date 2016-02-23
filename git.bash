#!/bin/bash

git_update() {
    if [[ $(git symbolic-ref --short HEAD) != "master" ]]; then
        echo "Use \`git pull --rebase upstream master"
    else
        git pull upstream master
        git push origin master
    fi
}

git_check_diverge() {
    for branch in $(git branch | grep -v master); do
        git checkout --quiet $branch
        if git status --untracked-files=no | grep -q -i "diverge"; then
            echo $branch
        fi
    done
}
