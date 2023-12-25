CC := gcc
CFLAGS := -Wall -g 

.PHONY: all clean

all: app

app: main.o stack.o student.o
	$(CC) $(CFLAGS) $^ -o $@

stack.o: stack.c stack.h
	$(CC) $(CFLAGS) -c $< -o $@

student.o: student.c student.h
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c stack.h student.h
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f *.o
	rm -f app