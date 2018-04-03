#!/bin/bash
#
# Simple xgh script for monitoring .tex and .bib files changes to auto compile pdf
# Author: Daniel Norio (dnorio, danieltakasu@gmail.com)
#
## Modes of operation
# No arguments - Normal : show only status messages
# -v           - Verbose: show status messages and texlive and bibtex messages
# -s           - Silent : show no message at all
##

#Compilation sequence
compile()
{
  latex ${MAINFILE}
  bibtex tcc
  latex ${MAINFILE}
  pdflatex ${MAINFILE}
}

# Constants
MAINFILE="tcc.tex"

# Main logic, do not change code below

TEXFILES=(`find . -name '*.tex' -o -name '*.bib'`)
NUMFILES=${#TEXFILES[@]} 

VERBOSE=false
NOTSILENT=true

# Simple check for verbose
if [[ "$@" == "v" ]]
then
  VERBOSE=true
fi

# Simple check for silent
if [[ "$@" == "s" ]]
then
  NOTSILENT=false
  VERBOSE=false
fi

if $NOTSILENT; then
echo "List of files being watched:"
  for v1 in "${TEXFILES[@]}"
    do
      echo $v1
  done
fi

# Save file time
for (( i = 0; i <${NUMFILES}; i++));
do
  TEXFILE="${TEXFILES[$i]}"
  LTIMES[$i]=`stat -c %Z "$TEXFILE"`
done

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
    fi
  done

  sleep 0.5
done
