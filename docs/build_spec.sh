#!/bin/bash

if [ -n "$1" ]
then
  export VERSION="$1"
else
  echo "VERSION argument is mantatory"
  echo "Example: $0 0.4"
  exit 1
fi
shift

ROOT_DIR="specs/design/${VERSION}"
FILE_NAME="DESIGN_DOC_v${VERSION}.md"
GLOBAL_FILE_NAME="specs/${FILE_NAME}"
SPEC_FILE_NAME="${ROOT_DIR}/${FILE_NAME}"
DIRECTORIES="syntax semantics design_principles appendix ecosystem tooling"
FOOTER="\n© $(date +%Y) Ori Language — Design Spec"

> ${GLOBAL_FILE_NAME}
> ${SPEC_FILE_NAME}

for file in $(find ${ROOT_DIR} -maxdepth 1 -type f -name "*.md" |grep -vE "README.md|ROADMAP|${FILE_NAME}" | sort)
do
  echo "${file}"
  cat ${file} >> ${SPEC_FILE_NAME}
  >> ${SPEC_FILE_NAME}
done

for dir in ${DIRECTORIES}
do
  for file in $(find ${ROOT_DIR}/${dir} -type f -name "*.md" | sort)
  do
    echo "${file}"
    cat ${file} >> ${SPEC_FILE_NAME}
    echo -e "\n---\n\n" >> ${SPEC_FILE_NAME}
  done
done

echo -e ${FOOTER} >> ${SPEC_FILE_NAME}
cp ${SPEC_FILE_NAME} ${GLOBAL_FILE_NAME}

