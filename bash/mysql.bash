#!/bin/bash

mysql_helper() {
    LOCAL_DB=$(get_local_play_db)

    RUN="docker exec mysql mysql -proot"
    CMD="docker exec mysql mysql -proot $LOCAL_DB"
    CMDi="docker exec -i mysql mysql -proot $LOCAL_DB"

    if ! $CMD -e "SELECT 1;"; then
        kill -INT $$ # ctrl+c
    fi

    _drop() {
        $RUN -e "drop database $LOCAL_DB;"
        $RUN -e "create database $LOCAL_DB;"
    }

    _pwd() {
        $CMD -e 'update users set password="$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy";'
    }

    set -x
    case $1 in
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
        # for evolution in $(ls --color=never $EVOLUTIONS | sort -g); do
        #     echo "$CMDi < $EVOLUTIONS/$evolution"
        #     $CMDi < $EVOLUTIONS/$evolution
        # done
        _pwd
        ;; 
    import)
        $CMDi < ${LOCAL_DB}_${2:-dump}.sql
        ;;
    save)
        docker exec -i mysql mysqldump -proot $LOCAL_DB > ${LOCAL_DB}_${2:-dump}.sql
        ;;
    repl)
        docker exec -it mysql mysql -proot $LOCAL_DB
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
    mysql_helper save $1
}

mysql_reset() {
    mysql_helper drop
    mysql_helper apply_evolutions
    mysql_helper reset_pwd
}

mysql_fetch_dev() {
    mysql_helper drop
    mysql_helper reset_pwd
    mysql_helper save dev
}

mysql_repl() {
    mysql_helper repl
}
