#!/bin/bash

psql_helper() {
    LOCAL_DB=${DB:-$(basename $(pwd))_test}

    RUN="docker exec postgres psql -U postgres"
    CMD="$RUN $LOCAL_DB"
    CMDi="docker exec -i postgres psql -U postgres $LOCAL_DB"

    if ! $CMD -c "SELECT 1;" >> /dev/null; then
        echo "FAIL: DB doesn't exist"
        kill -INT $$ # ctrl+c
    fi

    _drop() {
        $RUN -c "DROP DATABASE $LOCAL_DB;"
        $RUN -c "CREATE DATABASE $LOCAL_DB;"
    }
    _pwd() {
        PWD='$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy'
        $CMD -c "UPDATE users SET password = '$PWD';"
    }

    set -x
    case $1 in
    version)
        docker exec postgres psql --version
        ;;
    drop)
        _drop
        ;;
    reset_pwd)
        _pwd
        ;;
    apply_evolutions)
        _drop
        EVOLUTIONS="conf/evolutions/default"
        sbt up >> /dev/null
        #for evolution in $(ls --color=never $EVOLUTIONS | sort -g); do
        #    echo "$CMD < $EVOLUTIONS/$evolution"
        #    $CMD < $EVOLUTIONS/$evolution
        #done
        _pwd
        ;; 
    import)
        $CMDi < ${LOCAL_DB}_${2:-dump}.sql
        ;;
    save)
        docker exec -i postgres pg_dump -U postgres $LOCAL_DB > ${LOCAL_DB}_${2:-dump}.sql
        ;;
    repl)
        docker exec -it postgres psql -U postgres $LOCAL_DB
        ;;
    esac
    set +x
}

psql_pwd() {
    psql_helper reset_pwd
}

psql_drop() {
    psql_helper drop
}

psql_import() {
    psql_helper drop
    psql_helper import $1
    psql_helper reset_pwd
}

psql_save() {
    psql_helper save $1
}

psql_reset() {
    psql_helper drop
    psql_helper apply_evolutions
    psql_helper reset_pwd
}

psql_repl() {
    psql_helper repl
}

psql_version() {
    psql_helper version
}
