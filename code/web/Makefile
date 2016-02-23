FLAGS := -Wall 
LIBS := -lpthread
OUT := lib.a

build:
	go build -buildmode=c-archive -o $(OUT) $(wildcard *.go)
	$(CC) $(FLAGS) -o run main.c $(OUT) $(LIBS)

clean:
	rm *.a *.h run
