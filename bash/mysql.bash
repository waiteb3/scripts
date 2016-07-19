#!/bin/bash

mysql_helper() {
    ARG=$1

    get_db_command() {
        CMD=$1
        shift
        USER=$1
        shift
        PASS=$1
        shift
        echo "$CMD -h localhost --protocol tcp -u $USER -p$PASS $@"
    }

    set -- $(get_local_db_config)
    DB=$1
    USER=$2
    PASS=$3
    unset $1 $2 $3

    RUN=$( get_db_command mysql $USER $PASS )
    CMD=$( get_db_command mysql $USER $PASS $DB )
    DUMP=$( get_db_command mysqldump $USER $PASS $DB )

    if ! $CMD -e "SELECT 1;" >> /dev/null; then
        echo "FAIL: DB doesn't exist"
        kill -INT $$ # ctrl+c
    fi

    _drop() {
        $RUN -e "drop database $DB;"
        $RUN -e "create database $DB;"
    }

    _pwd() {
        $CMD -e 'update users set password="$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy";'
    }

    set -x
    case $ARG in
    version)
        $RUN -e "SELECT VERSION();"
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
        # for evolution in $(ls --color=never $EVOLUTIONS | sort -g); do
        #     echo "$CMDi < $EVOLUTIONS/$evolution"
        #     $CMDi < $EVOLUTIONS/$evolution
        # done
        _pwd
        ;; 
    import)
        $CMD < ${DB}_${2:-dump}.sql
        ;;
    save)
        $DUMP > ${DB}_${2:-dump}.sql
        ;;
    repl)
        $CMD
        ;;
    esac
    set +x
}

mysql_version() {
    mysql_helper version
}

mysql_repl() {
    mysql_helper repl
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
