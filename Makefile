FORT = gfortran
CC   = gcc
OPTS = -march=native -ffast-math -fstrict-aliasing -Ofast -fPIC -Wunused -cpp

SRCDIR = ./src
OBJDIR = $(SRCDIR)/obj
BINDIR = ./test
LIBDIR = ./lib

LIBFILE = $(LIBDIR)/libemdee.a

LIBS = -L$(LIBDIR) -lemdee -lgfortran -lm

OBJ = $(OBJDIR)/mEmDee.o

.PHONY: all test lib testc testfortran

all: test

clean:
	rm -rf $(OBJDIR)
	rm -rf $(LIBDIR)
	rm -f $(BINDIR)/testfortran $(BINDIR)/testc

test: testfortran testc

testc: $(BINDIR)/testc

testfortran: $(BINDIR)/testfortran

lib: $(LIBFILE)

$(BINDIR)/testfortran: $(OBJDIR)/testfortran.o
	$(FORT) $(OPTS) -o $@ -J$(LIBDIR) $< $(LIBS)

$(OBJDIR)/testfortran.o: $(SRCDIR)/testfortran.f90 $(LIBFILE)
	$(FORT) $(OPTS) -c -o $@ -J$(LIBDIR) $<

$(BINDIR)/testc: $(OBJDIR)/testc.o
	$(CC) $(OPTS) -o $@ $< $(LIBS)

$(OBJDIR)/testc.o: $(SRCDIR)/testc.c $(SRCDIR)/EmDee.h $(LIBFILE)
	$(CC) $(OPTS) -c -o $@ $<

$(LIBFILE): $(OBJ)
	ar -cr $(LIBFILE) $(OBJ)

$(OBJDIR)/mEmDee.o: $(SRCDIR)/mEmDee.f90 $(SRCDIR)/pair_potentials.f90
	mkdir -p $(OBJDIR)
	mkdir -p $(LIBDIR)
	$(FORT) $(OPTS) -J$(LIBDIR) -c -o $@ $<

