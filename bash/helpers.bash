ring_alarm() {
    for i in {1..10}; do
        echo -en "\a"
        sleep .1
        echo -en "\a"
        sleep 1
    done
}
