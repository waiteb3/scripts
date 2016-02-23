#!/bin/bash

LOCAL_DB=${DB:-$(basename $(pwd))_test}

RUN="docker exec postgres psql"
EXEC="docker exec postgres psql -U postgres -c"
CMD="docker exec postgres psql -U postgres $LOCAL_DB"
CMDi="docker exec -i postgres psql -U postgres $LOCAL_DB"
TTY="docker exec -it postgres psql -U postgres"

psql_helper() {

    if ! $EXEC "SELECT 1;" >> /dev/null; then
        kill -INT $$ # ctrl+c
    fi

    set -x
    case $1 in
    version)
        $RUN --version
        ;;
    drop)
        $EXEC "DROP DATABASE $LOCAL_DB"
        $EXEC "CREATE DATABASE $LOCAL_DB"
        docker exec postgres psql -U postgres -c "DROP DATABASE $LOCAL_DB;"
        docker exec postgres psql -U postgres -c "CREATE DATABASE $LOCAL_DB;"
        ;;
    reset_pwd)
        PWD='$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy'
        $CMD -c "UPDATE users SET password = '$PWD';"
        ;;
    apply_evolutions)
        #EVOLUTIONS="conf/evolutions/default"
        #sbt up >> /dev/null
        #for evolution in $(ls --color=never $EVOLUTIONS | sort -g); do
        #    echo "$CMD < $EVOLUTIONS/$evolution"
        #    $CMD < $EVOLUTIONS/$evolution
        #done
        ;; 
    import)
        $CMDi < ${LOCAL_DB}${2:-dump.sql}
        ;;
    save)
        docker exec -i psql psqldump -proot $LOCAL_DB > ${LOCAL_DB}${2:-_dump.sql}
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
    psql_helper save "_${1:-_dump}.sql"
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
