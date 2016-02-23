#!/bin/bash

source db_helper.sh

LOCAL_DB=${DB:-$(basename $(pwd))_test}
RUN="docker exec mysql mysql"
EXEC="docker exec mysql mysql -e"
CMD="docker exec mysql mysql -proot $LOCAL_DB"
CMDi="docker exec -i mysql mysql -proot $LOCAL_DB"
TTY="docker exec -it mysql mysql -proot $LOCAL_DB"

mysql_helper() {

    if ! $CMDi -e "SELECT 1"; then
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
        ;;
    esac
    set +x
}

mysql_pwd() {
    mysql_helper reset_pwd
}

mysql_drop() {
    mysql_helper drop
}

mysql_import() {
    mysql_helper drop
    mysql_helper import $1
    mysql_helper reset_pwd
}

mysql_save() {
    mysql_helper save "_${1:-dump}.sql"
}

mysql_reset() {
    mysql_helper drop
    mysql_helper apply_evolutions
    mysql_helper reset_pwd
}

mysql_repl() {
    mysql_helper repl
}
