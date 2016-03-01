package main

import (
    "flag"
    "log"
    "net/http"
)


func main() {
    var ADDR = flag.String("-addr", ":3000", "address")
    var DIR = flag.String("-dir", ".", "directory")
    flag.Parse()

    if (*ADDR)[0] == ':' {
        log.Println("listening at http://localhost:" + *ADDR)
    } else {
        log.Println("listening at http://" + *ADDR)
    }
    log.Fatalln(http.ListenAndServe(*ADDR, http.FileServer(http.Dir(*DIR))))
}
