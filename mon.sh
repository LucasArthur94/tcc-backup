#!/bin/bash
#
# Simple xgh script for monitoring .tex and .bib files changes to auto compile pdf
# Author: Daniel Norio (dnorio, danieltakasu@gmail.com)
#
## Modes of operation (use options or arguments)
# No arguments - Normal : show only status messages
# -v           - Verbose: show status messages and texlive and bibtex messages
# -s           - Silent : show no message at all
#
## Other arguments:
# -b           - Run compile at beggining
#
#
## Other options:
# --file or --f <filename>: Set new main tex file path
##

#Compilation sequence
compile()
{
  latex ${MAINFILE}
  bibtex tcc
  latex ${MAINFILE}
  pdflatex  --shell-escape ${MAINFILE}
}

printTodo()
{
  grep '\(% TODO\)\|\(%TODO\)' $FILENAME
}
# Set relative path to packages directory
export TEXINPUTS=./packages//:${TEXINPUTS}

# Constants
MAINFILE="tcc.tex"

# Main logic, do not change code below

TEXFILES=(`find . -name '*.tex' -o -name '*.bib'`)
NUMFILES=${#TEXFILES[@]}

VERBOSE=false
NOTSILENT=true
COMPILE_AT_START=false

EXPECTFILEARG=false
while test $# -gt 0
do
    case "$1" in
        --v) VERBOSE=true
            ;;
        --s) NOTSILENT=false;VERBOSE=false;
            ;;
        --b) COMPILE_AT_START=true
            ;;
        v) VERBOSE=true
            ;;
        s) NOTSILENT=false;VERBOSE=false;
            ;;
        b) COMPILE_AT_START=true
            ;;
        --file) EXPECTFILEARG=true
            ;;
        --f) EXPECTFILEARG=true
            ;;
        --*) echo "Bad option $1"
            ;;
        *) echo "argument $1"; if $EXPECTFILEARG; then MAINFILE="$1 "; EXPECTFILEARG=false; echo "Main file is: $MAINFILE"; fi
            ;;
    esac
    shift
done

if $NOTSILENT; then
echo "List of files being watched:"
  for v1 in "${TEXFILES[@]}"
    do
      echo $v1
  done
fi

for v1 in "${TEXFILES[@]}"; do
  FILENAME=$v1
  printTodo
done

# Save file time
for (( i = 0; i <${NUMFILES}; i++));
do
  TEXFILE="${TEXFILES[$i]}"
  LTIMES[$i]=`stat -c %Z "$TEXFILE"`
done

if $COMPILE_AT_START; then
  if $VERBOSE; then
    compile
    else
    {
      compile
    } &> /dev/null
  fi
  echo "Document compiled!"
fi

while true
do

  # Checks if some file changed
  for (( i = 0; i <${NUMFILES}; i++));
  do
    TEXFILE="${TEXFILES[$i]}"
    ATIMES[$i]=`stat -c %Z "$TEXFILE"`
    if [[ "${ATIMES[$i]}" != "${LTIMES[$i]}" ]]; then
      if $NOTSILENT; then
        echo "Recompiling due changes of ${TEXFILES[$i]} ..."
      fi
      LTIMES[$i]=${ATIMES[$i]}
      if $VERBOSE; then
        compile
      else
        {
          compile
        } &> /dev/null
      fi
      if $NOTSILENT; then
        echo "Compilation succeeded!"
      fi
    fi
  done

  sleep 0.5
done
