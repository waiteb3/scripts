has_db_in_docker() {
    DB=$1
    if docker > /dev/null; then
        if docker ps --format="{{ .Image }} {{ .Names }}" | grep -i $DB > /dev/null; then
            return 0
        fi
    fi

    return 1
}

get_db_command() {
    DB=$1
    CMD=$2
    ARGS=$3
    FLAGS=$4
    if has_db_in_docker $1; then
        CONTAINER=$(docker ps --format="{{ .Image }} {{ .Names }}" | grep -i $DB | awk '{print $2}')
        echo "docker exec $FLAGS $CONTAINER $CMD $ARGS"
    else
        echo "$CMD $ARGS"
    fi
}

get_local_db() {
    if grep -E "addSbtPlugin.+\"com\.typesafe\.play\"" project/plugins.sbt 2> /dev/null > /dev/null; then
        get_local_play_db
    else
        get_local_folder_db
    fi
}

get_local_play_db() {
    echo $(sed -n 's|^db\.default\.url="jdbc\:[a-z]\+\://localhost/\(.*\)?.*|\1|p' conf/application.conf)
}

get_local_folder_db() {
    echo $(basename $(pwd))
}

compare_dbs() {
    LOCAL_DB=$(get_local_play_db)
    TABLES=${1:-$(docker exec mysql mysql -proot ${LOCAL_DB} -e "show tables;" 2> /dev/null | sed '1d')}
    for table in $TABLES; do
        echo
        echo "-------------------------      $table     ------------------------------"
        echo
        docker exec mysql mysql -proot ${LOCAL_DB} -e "SHOW CREATE TABLE $table \G" 2> /dev/null
        echo
        docker exec postgres psql -U postgres ${LOCAL_DB} -c "\d $table"
        echo "------------------------------------------------------------------------"
        echo
    done
}

table_sizes() {
    LOCAL_DB=$(get_local_play_db)
    TABLES=${1:-$(docker exec mysql mysql -proot ${LOCAL_DB} -e "show tables;" 2> /dev/null | sed '1d')}
    for table in $TABLES; do
        echo "$table size: " $(docker exec mysql mysql -proot ${LOCAL_DB} -e "SELECT count(*) FROM $table;" 2> /dev/null)
    done
}

ring_alarm() {
    for i in {1..10}; do
        echo -en "\a"
        sleep .1
        echo -en "\a"
        sleep 1
    done
}

rainbow() {
    echo -n "Can you taste it? can you feel it"
    time=1
    while [ $time -le 3 ]; do
        echo -n ".."
        sleep $time
        : $((time++))
    done
    echo
    print_color() {
        color=$1
        # echo -ne "${color}\t"
        for mod in {1..9}; do
            echo -en "\e[${color};${mod}mWARNING\e[0m "
        done
        echo
    }
    for color in {30..37}; do print_color $color; done
    for color in {40..47}; do print_color $color; done
}

do_locked() {
   if [ -v $1 ]; then
       echo "Needs a file to use as the lock as the first argument (written to /tmp)"
       return 1
   fi

   file="/tmp/$1"
   shift

   if [[ $@ == "" ]]; then
       echo "Needs a command to be run when unlocked as second argument"
   fi

   touch $file

   eval "$@"

   rm $file
}

wait_locked() {
   if [ -v $1 ]; then
       echo "Needs a lock file to wait on as first argument (relative to /tmp)"
       return 1
   fi

   file="/tmp/$1"
   shift

   if [[ $@ == "" ]]; then
       echo "Needs a command to be run when unlocked as second argument"
   fi

   echo -n "Waiting on '$file'..."
   while [ -f $file ]; do
       sleep 2
       echo -n "."
   done
   echo

   eval $@
}
