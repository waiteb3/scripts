package main

import "C"

import "net/http"

//export Bind
func Bind(s *C.char) {
	http.ListenAndServe("localhost:9000", http.FileServer(http.Dir(C.GoString(s))))
}

func main() {}
