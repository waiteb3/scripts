get_local_db_config() {
    if grep -E "addSbtPlugin.+\"com\.typesafe\.play\"" project/plugins.sbt 2> /dev/null > /dev/null; then
        get_local_play_db_config
    elif grep -E 'gem\s+"rails.+"[[:digit:]].[[:digit:]].[[:digit:]]+"' Gemfile 2> /dev/null > /dev/null; then
        get_local_rails_db_config
    else
        get_local_folder_db_config
    fi
}

get_local_rails_db_config() {
    echo $(sed -n 's|database\:\s\([a-zA-Z]\+\)|\1|p' config/database.yml)
    echo $(sed -n 's|username\:\s\([a-zA-Z]\+\)|\1|p' config/database.yml)
    echo $(sed -n 's|password\:\s\([a-zA-Z]\+\)|\1|p' config/database.yml)
}

get_local_play_db_config() {
    echo $(sed -n 's|^db\.default\.url="jdbc\:[a-z]\+\://localhost/\([_a-zA-Z0-9]\+\)?*.*|\1|p' conf/application.conf)
    echo $(sed -n 's|^db\.default\.user\(name\)*="*\([^"]*\)"*|\2|p' conf/application.conf)
    echo $(sed -n 's|^db\.default\.password="*\([^"]*\)"*|\1|p' conf/application.conf)
}

get_local_folder_db_config() {
    echo $(basename $(pwd))
    echo $USER
    echo ""
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
    _ring() {
        echo -en "\a"
        sleep .1
        echo -en "\a"
    }

    END=${1:-10}
    _ring
    for i in $(seq 2 $END); do
        sleep 1
        _ring
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

concat_dir_into_single_file() {
    DIR=$1
    PATTERN=$2
    for file in $(find $DIR -name $PATTERN); do
        echo "--->>$file<<---"
        cat $file
        echo
    done
}

rebuild_concat_file_to_dir() {
    FILE=$1
    # FILE_NAMES=$( sed -n 's,\-\-\->>\(\S\+\)<<\-\-\-,\1,p' $FILE )
    for line_num in $(grep -En "\-\-\->>(\S+)<<\-\-\-" $FILE | cut -d':' -f1); do
        file_name=$(tail -n+$line_num $FILE | head -n 1)
        file_name=${file_name#"--->>"}
        file_name=${file_name%"<<---"}
        echo $file_name
    done
}
