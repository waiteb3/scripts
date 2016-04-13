#!/bin/bash

psql_helper() {
    RUN=$(get_db_command postgres psql "-U postgres")
    CMD=$(get_db_command postgres psql "-U postgres $(get_local_db)")
    CMDi=$(get_db_command postgres psql "-U postgres $(get_local_db)" -i)
    DUMP=$(get_db_command postgres pg_dump "-U postgres $(get_local_db)" -i)
    REPL=$(get_db_command postgres psql "-U postgres $(get_local_db)" -it)

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
        $RUN -c "SELECT VERSION();"
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
        $CMDi < $(get_local_db)_${2:-dump}.sql
        ;;
    save)
        $DUMP > $(get_local_db)_${2:-dump}.sql
        ;;
    repl)
        $REPL
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
