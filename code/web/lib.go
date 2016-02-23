package main

import "C"

//export Concat
func Concat(a, b *C.char) *C.char {
	return C.CString(C.GoString(a) + C.GoString(b))
}
