CC = gcc
CFLAGS = -Wall
LIBS = -lm

all: calc

calc: cal.tab.c lex.yy.c
	$(CC) $(CFLAGS) cal.tab.c lex.yy.c -o calc $(LIBS)

cal.tab.c cal.tab.h: cal.y
	bison -d cal.y

lex.yy.c: cal.l
	flex cal.l

clean:
	rm -f calc calc.exe lex.yy.c cal.tab.c cal.tab.h