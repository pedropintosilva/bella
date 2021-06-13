#! /bin/bash

# Generates Ptoject HTML project and subsequent 
# static files from .odt file

# mkdir venv
# python3 -m venv ./venv
# source ./venv/bin/activate
# pip install odfpy

# Be sure we have all folders ready
mkdir -p public/style/
rm -r public/images/

# Copy static content
cp -rp static/images public/images
cp -p static/main.css public/style/main.css

# Copy page's images
cp -rp content/images/. public/images

FILENAME="$1"

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/$FILENAME.odt > public/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|' public/"${FILENAME}_converted".html

# Do up one level in directory when placing img tags sources
sed -i 's|src="../projects/images/|src="images/|' public/"${FILENAME}_converted".html

# To remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||' public/"${FILENAME}_converted".html

# Duplicate, To have before and after applying index template
cp -frp content/projects/template -T public/$FILENAME.html

#   -f, --force: if an existing destination file cannot be opened, remove it and try again)
#   -p:     same as --preserve=mode,ownership,timestamps
#   -R, -r, --recursive

# Adjust paths
sed -i 's|../static/main.css|style/main.css|' public/$FILENAME.html

# Modify content/$FILENAME.html
# and insert contents from index template before and after
# https://www.linuxquestions.org/questions/linux-newbie-8/how-to-replace-string-pattern-with-multi-line-text-in-bash-script-212983/
sed -i '/<!-- content -->/ {r '"public/${FILENAME}_converted.html"'
d;};' public/$FILENAME.html

