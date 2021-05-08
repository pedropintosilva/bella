#! /bin/bash

#mkdir venv
#python3 -m venv ./venv
#source ./venv/bin/activate
#pip install odfpy

FILENAME="$1"

# CONVERT With python, --plain to get without css
odf2xhtml --plain projects/$FILENAME.odt > projects/"${FILENAME}_converted".html

# To remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||' projects/"${FILENAME}_converted".html

#Duplicate, To have before and after applying index template
cp -frp projects/template -T projects/$FILENAME.html

#   -f, --force: if an existing destination file cannot be opened, remove it and try again)
#   -p:     same as --preserve=mode,ownership,timestamps
#   -R, -r, --recursive

# Modify projects/$FILENAME.html
# and insert contents from index template before and after
# https://www.linuxquestions.org/questions/linux-newbie-8/how-to-replace-string-pattern-with-multi-line-text-in-bash-script-212983/
sed -i '/<!-- content -->/ {r '"projects/${FILENAME}_converted.html"'
d;};' projects/$FILENAME.html
