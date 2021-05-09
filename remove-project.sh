#! /bin/bash

# Use this script to remove a project
# add parameter to remove source file as well (odt)

PROJECT="$1"
PURGE=
if [ "$PROJECT" == "--purge" ]; then
    shift
    PROJECT="$1"
    PURGE=1
fi

echo $PROJECT
echo $PURGE

LINENUM="$(grep -n "${PROJECT}" content/projects/list-ids | head -n 1 | cut -d: -f1)"

sed -i "${LINENUM}d" content/projects/list-ids
sed -i "${LINENUM}d"  content/projects/list-names

rm public/projects/"${PROJECT}".html
find public/projects/images/ -type f -name "${PROJECT}_*" -print -delete

if [ -n "$PURGE" ] ; then
	# Remove from sources
	rm content/projects/"${PROJECT}".odt
	find content/projects/images/ -type f -name "${PROJECT}_*" -print -delete
fi