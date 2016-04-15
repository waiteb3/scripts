package main

import (
    "flag"
    "log"
    "net/http"
    "strconv"
)


func main() {
    var ADDR = flag.String("addr", "3000", "address (")
    var DIR = flag.String("dir", ".", "directory")
    flag.Parse()

    var message = `Serving "` + *DIR + `" on http://`

    if (*ADDR)[0] == ':' {
        log.Println("listening at http://localhost" + *ADDR)
        message += "localhost" + *ADDR
    } else if _, err := strconv.Atoi(*ADDR); err == nil {
        *ADDR = ":" + *ADDR
        message += "localhost" + *ADDR
    } else {
        message += *ADDR
    }

    log.Println(message)
    log.Fatalln(http.ListenAndServe(*ADDR, http.FileServer(http.Dir(*DIR))))
}
