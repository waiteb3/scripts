#!/bin/bash

db_helper() {
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
        ;;
    reset_pwd)
        PWD='$2a$10$oZrZHDLFU3nVpLdiZomYtu1OHSDJ8ILFp8fwKiM5iMBrPchbTUgHy'
        $EXEC "UPDATE users SET password = '$PWD';"
        ;;
    apply_evolutions)
        EVOLUTIONS="conf/evolutions/default"
        sbt up >> /dev/null
        for evolution in $(ls --color=never $EVOLUTIONS | sort -g); do
            echo "$CMDi < $EVOLUTIONS/$evolution"
            $CMDi < $EVOLUTIONS/$evolution
        done
        ;; 
    import)
        $CMDi < ${LOCAL_DB}${2:-_dump.sql}
        ;;
    save)
        $DBDUMP $LOCAL_DB > ${LOCAL_DB}${2:-_dump.sql}
        ;;
    repl)
        $TTY
        ;;
    esac
    set +x
}
DBDUMP="docker exec -i postgres psqldump -U postgres $LOCAL_DB > ${LOCAL_DB}${2:-_dump.sql}"
DBRESTORE="docker exec -i postgres psqlrestore -U postgres $LOCAL_DB < ${LOCAL_DB}${2:-_dump.sql}"
