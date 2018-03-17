#!/bin/bash

# Nomes dos arquivos para serem vigiados
MAINNAME="tcc.tex"

CAPSNAMES=("tcc.tex" "refs.bib" "introducao/objetivo.tex" "introducao/motivacao.tex" "introducao/justificativa.tex" "introducao/organizacao_do_trabalho.tex")

# Salva o horario de cada arquivo
for v1 in 0 1 2 3 4 5
do
  CAPNAME="${CAPSNAMES[$v1]}"
  LTIMECAPS[$v1]=`stat -c %Z "$CAPNAME"`
done

while true    
do

  # Verifica se algum capitulo foi alterado
  for v1 in 0 1 2 3 4 5
  do
    CAPNAME="${CAPSNAMES[$v1]}"
    ATIMECAPS[$v1]=`stat -c %Z "$CAPNAME"`
    if [[ "${ATIMECAPS[$v1]}" != "${LTIMECAPS[$v1]}" ]]
    then
      echo "Recompiling due changes of ${CAPSNAMES[$v1]}..."
      LTIMECAPS[$v1]=${ATIMECAPS[$v1]}
      latex ${MAINNAME}
      bibtex tcc
      latex ${MAINNAME}
      pdflatex ${MAINNAME}
    fi
  done

  sleep 0.5
done
