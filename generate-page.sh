#! /bin/bash

# Generates Page HTML page and subsequent
# static files from .odt file

# mkdir venv
# python3 -m venv ./venv
# source ./venv/bin/activate
# pip install odfpy

FILENAME="$1"
TITLE="$2"
REMOVE="$3"

[ -z "$FILENAME" ] && read -p "Missing ODT filename. Enter it without file extension: " FILENAME

[ -z "$TITLE" ] && TITLE=$(echo "$FILENAME" | sed 's/.*/\L&/; s/[a-z]*/\u&/g' | tr '-' ' ')

if [ -n "$REMOVE" ]; then
	# Be sure we have all folders ready
	mkdir -p public/style/
	rm -r public/images/
fi

# Copy static content
cp -rp static/images public/images
cp -p static/main.css public/style/main.css
cp -p static/fonts.css public/style/fonts.css

# Copy page's images
cp -rp content/images/. public/images

# Create new empty page following template
cp -frp content/pageTemplate -T public/$FILENAME.html

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/$FILENAME.odt > public/"${FILENAME}_converted".html

# Replace TOC (Table of contents), Index uggly bullets
sed -i 's|<span>•</span>||' public/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|' public/"${FILENAME}_converted".html

# Go up one level in directory when placing img tags sources
sed -i 's|src="../images/|src="images/|' public/"${FILENAME}_converted".html

# Remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||' public/"${FILENAME}_converted".html

# Remove any div tags
sed -i -e 's|<div>||;s|</div>||' public/"${FILENAME}_converted".html

# Create temporary converted file where only inner html is kept
# (meta, html and body tags are removed)
cp -frp public/"${FILENAME}_converted".html -T public/"${FILENAME}_temp".html
# remove first 7 lines:
sed -i -e '1,7d' public/"${FILENAME}_temp".html
# remove last 2 lines
sed -i '$d' public/"${FILENAME}_temp".html
sed -i '$d' public/"${FILENAME}_temp".html

# Adjust paths
sed -i 's|../static/main.css|style/main.css|' public/$FILENAME.html
sed -i 's|../static/fonts.css|style/fonts.css|' public/$FILENAME.html

# Modify content/$FILENAME.html
# and insert contents from index template before and after
sed -i '/<!-- content -->/ {r '"public/${FILENAME}_temp.html"'
d;};' public/$FILENAME.html

# Add aditional class to body
sed -i 's|<body>|<body class="'$FILENAME'">|' public/$FILENAME.html

# Add social media menu
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/$FILENAME.html

# Add main menu
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/$FILENAME.html

# Set dir level to the main menu's href (already in the correct level)
sed -i 's|href="this.|href="|' public/$FILENAME.html

# Set page title
sed -i 's|<!-- currentPage -->|'"$TITLE"'|' public/$FILENAME.html

# Add SEO bits
sed -i '/<!-- SEOTemplate -->/ {r '"SEOTemplate"'
d;};' public/$FILENAME.html
# Add SEO bits: set URLs
sed -i 's|this.html|'"$FILENAME"'.html|' public/$FILENAME.html
# Add SEO bits: set title
sed -i 's|this.title|'"$TITLE"'|' public/$FILENAME.html
# Add SEO bits: set image
sed -i 's|this.image|images/avatar.jpeg|' public/$FILENAME.html
# Add SEO bits: set description
sed -i 's|this.description|'"$TITLE"': Pedro Pinto Silva|' public/$FILENAME.html
# Add SEO bits: set og type
sed -i 's|this.type|website|' public/$FILENAME.html

# Set current menu item
TITLE=$(echo $TITLE | tr "-" " ")
echo -e '📘'$TITLE'\n  ⮡ public/'$FILENAME'.html'

sed -i 's|data-filename="'$FILENAME'"|class="selected"|' public/$FILENAME.html

# Remove temporary file
rm public/"${FILENAME}_temp".html
