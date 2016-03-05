get_local_play_db() {
    echo $(sed -n 's|^db\.default\.url="jdbc\:[a-z]\+\://localhost/\(.*\)?.*|\1|p' conf/application.conf)
}

get_local_folder_db() {
    echo $(basename $(pwd))
}

compare_dbs() {
    VALUES=${1:-$(docker exec mysql mysql -proot ${LOCAL_DB}_test -e "show tables;" 2> /dev/null | sed '1d')}
    for table in $VALUES; do
        echo
        echo "-------------------------      $table     ------------------------------"
        echo
        docker exec mysql mysql -proot ${LOCAL_DB}_test -e "SHOW CREATE TABLE $table \G" 2> /dev/null
        echo
        docker exec postgres psql -U postgres ${LOCAL_DB}_test -c "\d $table"
        echo "------------------------------------------------------------------------"
        echo
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

