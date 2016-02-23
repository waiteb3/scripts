#!/bin/bash

LOCAL_DB=${DB:-$(basename $(pwd))_test}

RUN="docker exec postgres psql"
EXEC="docker exec postgres psql -U postgres -c"
CMD="docker exec postgres psql -U postgres $LOCAL_DB"
CMDi="docker exec -i postgres psql -U postgres $LOCAL_DB"
TTY="docker exec -it postgres psql -U postgres"
# TODO fix
DBDUMP="docker exec -i postgres psqldump -U postgres $LOCAL_DB > ${LOCAL_DB}${2:-_dump.sql}"
DBRESTORE="docker exec -i postgres psqlrestore -U postgres $LOCAL_DB < ${LOCAL_DB}${2:-_dump.sql}"

psql_helper() {
    LOCAL_DB=${DB:-$(basename $(pwd))_test}

    if ! $CMD $LOCAL_DB -e "SELECT 1;"; then
        echo "FAIL: DB doesn't exist"
        kill -INT $$ # ctrl+c
    fi

    set -x
    case $1 in
    drop)
        docker exec mysql mysql -proot -e "drop database $LOCAL_DB;"
        docker exec mysql mysql -proot -e "create database $LOCAL_DB;"
        ;;
    reset_pwd)
        $CMD -e 'update users set password="$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy";'
        ;;
    apply_evolutions)
        EVOLUTIONS="conf/evolutions/default"
        sbt up >> /dev/null
        for evolution in $(ls --color=never $EVOLUTIONS | sort -g); do
            echo "$CMD < $EVOLUTIONS/$evolution"
            $CMD < $EVOLUTIONS/$evolution
        done
        ;; 
    import)
        $CMDi < ${LOCAL_DB}${2:-_dump.sql}
        ;;
    save)
        docker exec -i mysql mysqldump -proot $LOCAL_DB > ${LOCAL_DB}${2:-_dump.sql}
        ;;
    repl)
        docker exec -it mysql mysql -proot $LOCAL_DB
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
