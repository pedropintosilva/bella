#! /bin/bash

# Generates Project HTML project and subsequent
# static files from .odt file

# mkdir venv
# python3 -m venv ./venv
# source ./venv/bin/activate
# pip install odfpy

FILENAME="$1"
REMOVE="$2"

[ -z "$FILENAME" ] && read -p "Missing ODT filename. Enter it without file extension: " FILENAME

if [ -n "$REMOVE" ]; then
	# Be sure we have all folders ready
	mkdir -p public/projects/
	mkdir -p public/projects/images/
	mkdir -p public/style/
	rm -r public/images/
fi

# Copy static content
cp -p static/main.css public/style/main.css

# Copy project's images
cp -rp content/projects/images/. public/projects/images

# Create new empty project page following template
cp -frp content/projects/template -T public/projects/$FILENAME.html

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/projects/$FILENAME.odt > public/projects/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|' public/projects/"${FILENAME}_converted".html

# Go up one level in directory when placing img tags sources
sed -i 's|src="../images/|src="images/|' public/projects/"${FILENAME}_converted".html

# Remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||' public/projects/"${FILENAME}_converted".html

# Remove any div tags
sed -i -e 's|<div>||;s|</div>||' public/projects/"${FILENAME}_converted".html

# Get project's title
TITLE=$(perl -ln0e '$,="\n";print /(?<=<h1>).*?(?=<\/h1)/sg' public/projects/"${FILENAME}_converted".html)
echo "Title: "${TITLE}
# Add title from h1. Converted html is used for RSS feed (so it's just the content of the page)
sed -i -e 's|<title></title>|<title>'${TITLE}'</title>|' public/projects/"${FILENAME}_converted".html
# Add title from h1, converted html to final html is used for RSS feed (so it's just the content of the page)
sed -i -e 's|<title></title>|<title>'${TITLE}'</title>|' public/projects/$FILENAME.html

# Create temporary converted file where only inner html is kept
# (meta, html and body tags are removed)
cp -frp public/projects/"${FILENAME}_converted".html -T public/projects/"${FILENAME}_temp".html
# remove first 7 lines:
sed -i -e '1,7d' public/projects/"${FILENAME}_temp".html
# remove last 2 lines
sed -i '$d' public/projects/"${FILENAME}_temp".html
sed -i '$d' public/projects/"${FILENAME}_temp".html

# Adjust paths
sed -i 's|../static/main.css|../style/main.css|' public/projects/$FILENAME.html

# Modify content/projects/$FILENAME.html
# and insert contents from index template before and after
sed -i '/<!-- content -->/ {r '"public/projects/${FILENAME}_temp.html"'
d;};' public/projects/$FILENAME.html

# Add additional class to content box: 'page'
sed -i 's|box content|box content page|' public/projects/$FILENAME.html

# Append project to projects list
echo $FILENAME >> content/projects/list-ids

# Append it to the list of names
echo $TITLE >> content/projects/list-names

# Remove temporary file
rm public/projects/"${FILENAME}_temp".html

echo "???? $(tail -n 1 content/projects/list-names)"
echo '  ??? public/projects/'$FILENAME'.html'



