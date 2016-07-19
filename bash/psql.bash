#!/bin/bash

psql_helper() {
    ARG=$1

    get_db_command() {
        CMD=$1
        shift
        USER=$1
        shift
        # PASS=$1
        # shift
        echo "$CMD -h localhost -U $USER $@"
    }

    set -- $(get_local_db_config)
    DB=$1
    USER=$2
    PASS=$3
    unset $1 $2 $3

    # use the postgres default database to run commands
    RUN=$( get_db_command psql postgres postgres )
    CMD=$( get_db_command psql $USER $DB )
    DUMP=$( get_db_command pg_dump $USER $DB )

    if ! $CMD -c "SELECT 1;" >> /dev/null; then
        echo "FAIL: DB doesn't exist"
        kill -INT $$ # ctrl+c
    fi

    _drop() {
        $RUN -c "DROP DATABASE $DB;"
        $RUN -c "CREATE DATABASE $DB;"
    }
    _pwd() {
        PWD='$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy'
        $CMD -c "UPDATE users SET password = '$PWD';"
    }
    _run() {
        $CMD -c "$@"
    }

    set -x
    case $ARG in
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
        $CMD < $(get_local_db)_${2:-dump}.sql
        ;;
    save)
        $DUMP > $(get_local_db)_${2:-dump}.sql
        ;;
    run)
        shift
        _run "$@"
        ;;
    repl)
        $CMD
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
