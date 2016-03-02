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

