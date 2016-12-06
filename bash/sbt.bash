#!/bin/bash

_sbt() {
    LOCAL="conf/env/local.conf"
    FLAGS="-mem 2048 -Dehcacheplugin=disabled -Dmemcachedplugin=enabled -Dauth.sessionTimeout=604800"

    if [[ -e $LOCAL ]]; then
        FLAGS="-Dconfig.file=$LOCAL $FLAGS"
    fi

    /usr/bin/sbt $FLAGS $@
}

sbt() {
    TZ=UTC _sbt $@
}

sbt_email() {
    sbt -Demails.enabled=true -Dsmtp.mock=false -Dsmtp.port=1025 $@
}

sbt_notz() {
    _sbt $@
}
