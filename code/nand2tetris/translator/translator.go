package main

import (
	// "bytes"
	"bufio"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

type Type string

const (
	NAC     Type = "NAC"     // not a command
	COMMENT Type = "COMMENT" // comments

	C_ARITHMETIC Type = "C_ARITHMETIC"
	C_PUSH       Type = "C_PUSH"
	C_POP        Type = "C_POP"
	C_LABEL      Type = "C_LABEL"
	C_GOTO       Type = "C_GOTO"
	C_IF_GOTO    Type = "C_IF_GOTO"
	C_FUNCTION   Type = "C_FUNCTION"
	C_CALL       Type = "C_CALL"
	C_RETURN     Type = "C_RETURN"
)

type Command struct {
	Type Type
	Cmd  string
	Args []string
	Line int
	Text string
	Asm  string // TODO this should probably not be part of Command
	Err  error
}

func NewCommand(text string, line int) *Command {
	// probs won't work right on multiple spaces between things
	parts := strings.Split(text, " ")
	cmd := strings.ToUpper(parts[0])

	_type, err := getCommandType(cmd)

	return &Command{
		_type,
		cmd,
		parts[1:],
		line,
		text,
		"",
		err,
	}
}

func getCommandType(cmd string) (Type, error) {
	switch cmd {
	case "PUSH":
		return C_PUSH, nil
	case "POP":
		return C_POP, nil
	case "LABEL":
		return C_LABEL, nil
	case "GOTO":
		return C_GOTO, nil
	case "IF-GOTO":
		return C_IF_GOTO, nil
	case "FUNCTION":
		return C_FUNCTION, nil
	case "CALL":
		return C_CALL, nil
	case "RETURN":
		return C_RETURN, nil
	case "ADD", "SUB", "NEG", "EQ", "GT", "LT", "AND", "OR", "NOT":
		return C_ARITHMETIC, nil
	}
	return NAC, errors.New("Cannot determin command type for '" + cmd + "'")
}

// TODO rename
type Register struct {
	Name  string
	Value int
}

func (r Register) Repr() (asm string) {
	asm += fmt.Sprintf("@%-20s // = %d\n", r.Name, r.Value)
	return asm
}

func (r Register) SaveFrom(register string) (asm string) {
	asm += r.Repr()
	asm += "A=A-1" + NL
	asm += "M=" + register + NL
	return asm
}

func (r Register) LoadTo(register string) (asm string) {
	asm += r.Repr()
	asm += "A=A-1" + NL
	asm += register + "=M" + NL
	return asm
}

func (r *Register) Inc() (asm string) {
	asm += r.Repr()
	asm += "M=M+1" + NL
	r.Value++
	return asm
}

func (r *Register) Dec() (asm string) {
	asm += r.Repr()
	asm += "M=M-1" + NL
	asm += "A=M" + NL
	asm += "D=M" + NL
	asm += "M=0" + NL
	asm += "A=A-1" + NL

	r.Value--
	return asm
}

var StackPointer = &Register{"SP", 256}

type Segment struct {
	Name string
}

func (s Segment) Offset(index int) (asm string) {
	asm += "@" + s.Name + NL
	// TODO can skip zero?
	if index >= 0 {
		asm += "A=+" + strconv.Itoa(index) + NL
	} else {
		asm += "A=" + strconv.Itoa(index) + NL
	}
	return asm
}

// Push the value at segment[index] onto the stack
func (s Segment) Push(index int) (asm string) {
	asm += s.Offset(index)
	asm += "D=M" + NL
	asm += StackPointer.SaveFrom("D")
	return asm
}

// Pop the value off the stack and save into segment[index]
func (s Segment) Pop(index int) (asm string) {
	asm += StackPointer.LoadTo("D")
	asm += s.Offset(index)
	asm += "M=D" + NL
	return asm
}

const NL = "\n"

func writePush(c *Command) (asm string) {
	// if c.Arg[0] == P_CONSTANT
	asm += "@" + c.Args[1] + NL
	asm += "D=A" + NL
	asm += StackPointer.Repr()
	asm += "A=M" + NL
	asm += "M=D" + NL
	asm += StackPointer.Inc()
	return asm
}

func writePop(c *Command) (asm string) {
	// if c.Arg[0] == P_CONSTANT
	// TODO segments
	return asm
}

type LabelGenerator struct {
	Name string
	Count int
}

func (l* LabelGenerator) Next() string {
	l.Count++
	return l.Name + strconv.Itoa(l.Count)
}

var TrueLabels = LabelGenerator{"TRUE", 0}
var FalseLabels = LabelGenerator{"FALSE", 0}

func unaryArithmetic(op string) (asm string) {
	asm += StackPointer.Repr()
	asm += "A=M" + NL
	asm += "A=A-1" + NL
	asm += "M=" + op + "M" + NL
	return asm
}

func binary(op string) (asm string) {
	asm += StackPointer.Dec()
	asm += "M=M" + op + NL
	return asm
}

func comparator(op string) (asm string) {
	truthy := TrueLabels.Next()
	falsy := FalseLabels.Next()

	asm += StackPointer.Dec()
	asm += "D=M-D" + NL
	asm += "@" + truthy + NL
	asm += "D;" + op + NL
	asm += StackPointer.Repr()
	asm += "A=M-1" + NL
	asm += "M=0" + NL
	asm += "@" + falsy + NL
	asm += "0;JMP" + NL
	asm += "(" + truthy + ")" + NL
	asm += StackPointer.Repr()
	asm += "A=M-1" + NL
	asm += "M=-1" + NL
	asm += "(" + falsy + ")" + NL
	return asm
}

func writeArithmetic(c *Command) (asm string) {
	switch c.Cmd {
	case "ADD":
		return binary("+D")
	case "SUB":
		return binary("-D")
	case "AND":
		return binary("&D")
	case "OR":
		return binary("|D")
	case "NEG":
		return unaryArithmetic("-")
	case "NOT":
		return unaryArithmetic("!")
	case "EQ":
		return comparator("JEQ")
	case "GT":
		return comparator("JGT")
	case "LT":
		return comparator("JLT")
	default:
		panic("HERE!!!!!")
	}
}

func main() {
	var err error

	filename, outname := parseArgs()

	file, err := os.Open(filename)
	defer file.Close()
	failIfIs(err)

	outfile, err := os.Create(outname)
	defer outfile.Close()
	failIfIs(err)

	fmt.Println("Compiling '", filename, "' to '", outname, "'.")

	commands := make([]*Command, 0, 0)
	s := bufio.NewScanner(file)

	// Pass 1: Parse the file into lines with the command type
	for line := 1; s.Scan(); line++ {
		text := strings.TrimSpace(s.Text())
		if text == "" {
			continue
		}

		if strings.HasPrefix(text, "//") {
			// commands = append(commands, Command{COMMENT, nil, line, text, "", nil})
			continue
		}

		c := NewCommand(text, line)

		commands = append(commands, c)
	}

	// Pass 2: Convert command list to hack
	for _, c := range commands {
		switch c.Type {
		case C_PUSH:
			c.Asm = writePush(c)
		case C_POP:
			c.Asm = writePop(c)
		case C_ARITHMETIC:
			c.Asm = writeArithmetic(c)
		}
	}

	// Pass 3: Write out
	dashes := ""
	for i := 0; i < 100; i++ {
		dashes += "-"
	}

	fmt.Printf("%-4s |  %-15s  |  %-30s  | %-30s \n", "line", "type", "VM", "HACK")
	fmt.Println(dashes)
	for _, c := range commands {
		outfile.WriteString(fmt.Sprintf("// %-3d:  %s\n", c.Line, c.Text))
		outfile.WriteString(c.Asm)
		fmt.Printf("%-3d  |  %-15s  |  %-30s  | %-30s \n", c.Line, c.Type, c.Text, strings.Replace(c.Asm, NL, " \\n ", -1))
	}
}

// Utility Functions
func parseArgs() (string, string) {
	filename := flag.String("file", "vm file to compile", "")
	flag.Parse()
	outname := strings.TrimSuffix(*filename, filepath.Ext(*filename)) + ".asm"
	return *filename, outname
}

func failIfIs(err error, msgs ...string) {
	if err != nil {
		log.Fatalln(err, msgs)
	}
}
