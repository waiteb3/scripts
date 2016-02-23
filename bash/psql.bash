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

psql_pwd() {
    db_helper reset_pwd
}

psql_drop() {
    db_helper drop
}

psql_import() {
    db_helper drop
    db_helper import $1
    db_helper reset_pwd
}

psql_save() {
    db_helper save "_${1:-_dump}.sql"
}

psql_reset() {
    db_helper drop
    db_helper apply_evolutions
    db_helper reset_pwd
}

psql_repl() {
    db_helper repl
}

psql_version() {
    db_helper version
}
