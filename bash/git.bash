#!/bin/bash

git_update() {
    if [[ $(git symbolic-ref --short HEAD) != "master" ]]; then
        echo "Use \`git pull --rebase upstream master\`"
        return 0
    fi

    git pull upstream master
    git push origin master
}

git_check_diverge() {
    if [[ $(git symbolic-ref --short HEAD) != "master" ]]; then
        echo "Will not run git_check_diverge on a branch other than master"
        return 0
    fi

    for branch in $(git branch | grep -v master); do
        git checkout --quiet $branch
        if git status --untracked-files=no | grep -q -i "diverge"; then
            echo $branch
        fi
    done
    git checkout --quiet master
}

git_remove_branch_non_diverged() {
    if [[ $(git symbolic-ref --short HEAD) != "master" ]]; then
        echo "Will not run git_check_diverge on a branch other than master"
        return 0
    fi

    DELETE=""
    for branch in $(git branch | grep -v master); do
        git checkout --quiet $branch
        if git status --untracked-files=no | grep -q -i "diverge"; then
            echo $branch "not being removed"
        else
            DELETE="$DELETE $branch"
        fi
    done
    git checkout --quiet master
}

git_show_stash_list() {
    DELETE=""
    for ref in $(git stash list | cut -d: -f1); do
        git show $ref
        echo "Drop ref $ref (d) or Continue (enter) or quit (q): "
        read OPTION
        if [[ $OPTION == "d" || $OPTION == "D" ]]; then
            DELETE="$ref $DELETE"
        elif [[ $OPTION == "q" || $OPTION == "Q" ]]; then
            break
        fi
    done
    for ref in $DELETE; do
        echo "Deleting $ref"
        git stash drop $ref
    done
}
