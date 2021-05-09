#! /bin/bash

# mkdir venv
# python3 -m venv ./venv
# source ./venv/bin/activate
# pip install odfpy

# Be sure we have all folders ready
mkdir -p public/projects/
mkdir -p public/projects/images/
mkdir -p public/style/
rm -r public/images/

# Copy static content
cp -rp static/images public/images
cp -p static/main.css public/style/main.css

FILENAME="$1"

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/projects/$FILENAME.odt > public/projects/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|' public/projects/"${FILENAME}_converted".html

# To remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||' public/projects/"${FILENAME}_converted".html

# Duplicate, To have before and after applying index template
cp -frp content/projects/template -T public/projects/$FILENAME.html

#   -f, --force: if an existing destination file cannot be opened, remove it and try again)
#   -p:     same as --preserve=mode,ownership,timestamps
#   -R, -r, --recursive

# Adjust paths
sed -i 's|../static/main.css|../style/main.css|' public/projects/$FILENAME.html

# Modify content/projects/$FILENAME.html
# and insert contents from index template before and after
# https://www.linuxquestions.org/questions/linux-newbie-8/how-to-replace-string-pattern-with-multi-line-text-in-bash-script-212983/
sed -i '/<!-- content -->/ {r '"public/projects/${FILENAME}_converted.html"'
d;};' public/projects/$FILENAME.html

# Append project to projects list
echo $FILENAME >> content/projects/list-ids

# Get project's title and append it to the list of names
perl -ln0e '$,="\n";print /(?<=<h1>).*?(?=<\/h1)/sg' public/projects/$FILENAME.html >> content/projects/list-names

