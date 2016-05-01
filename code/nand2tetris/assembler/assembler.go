package main

import (
	"bytes"
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"strconv"
)

func main() {
	var err error

	filename, outname := parseArgs()

	file, err := os.Open(filename)
	defer file.Close()
	failIfIs(err)
	outfile, err := os.Create(outname)
	defer outfile.Close()
	failIfIs(err)

	s := bufio.NewScanner(file)
	fmt.Println("Compiling '", filename, "' to '", outname, "'.")

	var lineNum int
	defer func(lineNum *int) {
		if r := recover(); r != nil {
			fmt.Println("On line", *lineNum)
			fmt.Println(r)
		}
	}(&lineNum)

	var buf bytes.Buffer
	doc := bufio.NewWriter(&buf)

	realLine := -1
	var codeMap = make([]int, 0)

	for lineNum = 0 ; s.Scan() ; lineNum++ {
		realLine ++

		line := strings.ToUpper(strings.Trim(s.Text(), " "))
		if (line == "") {
			lineNum--
			continue
		}

		if (strings.HasPrefix(line, "//")) {
			lineNum--
			continue
		}

		if (line[0] == '(') {
			if (line[len(line)-1] != ')') {
				panic("at the disco (unfinished label [missing closing ')'])")
			}

			if (len(line) < 3) {
				panic("at the disco (empty label)")
			}

			line = strings.TrimPrefix(line, "(")
			line = strings.TrimSuffix(line, ")")
			symbols.AddLabel(line, lineNum)
			lineNum--
			continue
		}

		doc.WriteString(line)
		doc.WriteString("\n")

		codeMap = append(codeMap, realLine)
	}
	doc.Flush()

	s = bufio.NewScanner(bufio.NewReader(&buf))

	for lineNum = 0 ; s.Scan() ; lineNum++ {
		line := s.Text()

		if (strings.Contains(line, "//")) {
			line = strings.TrimSpace(line[0:strings.Index(line, "//")])
		}

		fmt.Printf("%-3d %-30s %-2d  %s\n",
			codeMap[lineNum], line,
			lineNum+1, parseLine(line, lineNum))

		outfile.WriteString(parseLine(line, lineNum))
		outfile.WriteString("\n")
	}
}

// Parser

func parseLine(line string, lineNum int) string {
	switch(line[0]) {
	case '@':
		if (len(line) < 2) {
			panic("at the disco ('@' not followed by address or symbol)")
		}
		return addressingInstruction(line[1:])
	default:
		return parseC_Instruction(line)
	}
}

// constants and mappings

const (
	A_INSTRUCTION_HEAD = "0"
	C_INSTRUCTION_HEAD = "111"
)

var dest = map[string]string {
	"NUL": "000",
	"M"  : "001",
	"D"  : "010",
	"MD" : "011",
	"A"  : "100",
	"AM" : "101",
	"AD" : "110",
	"ADD": "111",
}

var jump = map[string]string {
	"NUL": "000",
	"JGT": "001",
	"JEQ": "010",
	"JGE": "011",
	"JLT": "100",
	"JNE": "101",
	"JLE": "110",
	"JMP": "111",
}

var instruction = map[string]string {
// this is a map to the ALU functions using A (rather than M)
	"0"  : "101010",
	"1"  : "111111",
	"-1" : "111010",
	"D"  : "001100",
	"A"  : "110000",
	"!D" : "001101",
	"!A" : "110001",
	"-D" : "001111",
	"-A" : "110011",
	"D+1": "011111",
	"A+1": "110111",
	"D-1": "001110",
	"A-1": "110010",
	"D+A": "000010",
	"D-A": "010011",
	"A-D": "000111",
	"D&A": "000000",
	"D|A": "010101",
	// NOTE These are commutative
	"A&D": "000000",
	"A|D": "010101",

// this is a map to the ALU functions using M (rather than A)
	// "0"  : "101010",
	// "1"  : "111111",
	// "-1" : "111010",
	// "D"  : "001100",
	"M"  : "110000",
	// "!D" : "001101",
	"!M" : "110001",
	// "-D" : "001111",
	"-M" : "110011",
	// "D+1": "011111",
	"M+1": "110111",
	// "D-1": "001110",
	"M-1": "110010",
	"D+M": "000010",
	"D-M": "010011",
	"M-D": "000111",
	"D&M": "000000",
	"D|M": "010101",
	// NOTE These are commutative
	"M&D": "000000",
	"M|D": "010101",
}

// inital symbol table and helper func

type SymbolTable struct {
	last int
	Table map[string]int
}

// Add a new symbol to the table and get the generated address back
func (st *SymbolTable) AddSymbol(symbol string) int {
	st.last++
	st.Table[symbol] = st.last
	return st.last
}

// Add a new label to the table
func (st *SymbolTable) AddLabel(label string, address int) {
	st.Table[label] = address
}

var symbols = &SymbolTable{
	last: 15,
	Table: map[string]int{
		"SP"    : 0,
		"LCL"   : 1,
		"ARG"   : 2,
		"THIS"  : 3,
		"THAT"  : 4,
		"SCREEN": 16384,
		"KBD"   : 24576,
	},
}

// add registers 0-15 and initalize
func init() {
	for i := 0; i <= 15; i++ {
		symbols.Table[fmt.Sprintf("R%d", i)] = i
	}
}

// Printers

func addressingInstruction(symbol string) string {
	address, err := strconv.Atoi(symbol)
	if ('0' <= symbol[0] && symbol[0] <= '9' && err != nil) {
		panic("at the disco (symbols must not start with a number)")
	}

	if err != nil {
		var exists bool
		address, exists = symbols.Table[symbol]
		if (!exists) {
			address = symbols.AddSymbol(symbol)
		}
	}

	binary := strconv.FormatInt(int64(address), 2)

	return A_INSTRUCTION_HEAD + fmt.Sprintf("%015s", binary)
}

func parseC_Instruction(line string) string {
	notJump := strings.Contains(line, "=")
	notComputation := strings.Contains(line, ";")

	if (notJump == true && true == notComputation) {
		panic("at the disco (can't have both jump and computation symbols)")
	}
	if (notJump == false && false == notComputation) {
		panic("at the disco (missing an actual computation)")
	}

	// NOTE RESEARCH can A and M be in an instruction?
	var compcode string
	if (notJump) {
		destination := strings.SplitN(line, "=", 2)[0]
		calculation := strings.SplitN(line, "=", 2)[1]

		compcode = useMem(calculation) +
				   instruction[calculation] +
				   dest[destination] +
				   jump["NUL"]
	} else {
		target := strings.SplitN(line, ";", 2)[0]
		condition := strings.SplitN(line, ";", 2)[1]

		compcode = "0" +
				   instruction[target] +
				   dest["NUL"] +
				   jump[condition]
	}

	return C_INSTRUCTION_HEAD  + compcode
}

func useMem(cpart string) string {
	if (strings.Contains(cpart, "M")) {
		return "1"
	} else {
		return "0"
	}
}

// Utility Functions

func parseArgs() (string, string) {
	filename := flag.String("file", "hack file to compile", "")
	flag.Parse()
	outname := strings.TrimSuffix(*filename, filepath.Ext(*filename)) + ".ours.hack"
	return *filename, outname
}

func failIfIs(err error, msgs ...string) {
	if err != nil {
		log.Fatalln(err, msgs)
	}
}