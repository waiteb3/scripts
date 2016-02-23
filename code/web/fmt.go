package main

import "C"

import "fmt"

//export Println
func Println(s *C.char) {
	fmt.Println(C.GoString(s))
}
