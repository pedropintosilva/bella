#! /bin/bash

# Generates Ptoject HTML project and subsequent
# static files from .odt file

# mkdir venv
# python3 -m venv ./venv
# source ./venv/bin/activate
# pip install odfpy

FILENAME="$1"
TITLE="$2"

[ -z "$FILENAME" ] && read -p "Missing ODT filename. Enter it without file extension: " FILENAME

[ -z "$TITLE" ] && TITLE=$(echo "$FILENAME" | sed 's/.*/\L&/; s/[a-z]*/\u&/g' | tr '-' ' ')

# Be sure we have all folders ready
mkdir -p public/style/
rm -r public/images/

# Copy static content
cp -rp static/images public/images
cp -p static/main.css public/style/main.css

# Copy page's images
cp -rp content/images/. public/images

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/$FILENAME.odt > public/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|' public/"${FILENAME}_converted".html

# Go up one level in directory when placing img tags sources
sed -i 's|src="../images/|src="images/|' public/"${FILENAME}_converted".html

# To remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||' public/"${FILENAME}_converted".html

# Create temporary converted file where only inner html is kept
# (meta, html and body tags are removed)
cp -frp public/"${FILENAME}_converted".html -T public/"${FILENAME}_temp".html
# remove first 7 lines:
sed -i -e '1,7d' public/"${FILENAME}_temp".html
# remove last 2 lines
sed -i '$d' public/"${FILENAME}_temp".html
sed -i '$d' public/"${FILENAME}_temp".html

# Duplicate, To have before and after applying index template
cp -frp content/projects/template -T public/$FILENAME.html
#   -f, --force: if an existing destination file cannot be opened, remove it and try again)
#   -p:     same as --preserve=mode,ownership,timestamps
#   -R, -r, --recursive

# Adjust paths
sed -i 's|../static/main.css|style/main.css|' public/$FILENAME.html

# Modify content/$FILENAME.html
# and insert contents from index template before and after
sed -i '/<!-- content -->/ {r '"public/${FILENAME}_temp.html"'
d;};' public/$FILENAME.html

# Add aditional class to body
sed -i 's|<body>|<body class="about">|' public/$FILENAME.html

# Set current menu item
TITLE=$(echo $TITLE | tr "-" " ")
echo $TITLE
sed -i "s|>${TITLE}|class=\"selected\">${TITLE}|" public/$FILENAME.html

# Remove temporary file
rm public/"${FILENAME}_temp".html
