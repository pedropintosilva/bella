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
cp -p static/fonts.css public/style/fonts.css

# Copy project's images
cp -rp content/projects/images/. public/projects/images

# Create new empty project page following template
cp -frp content/projects/template -T public/projects/$FILENAME.html

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/projects/$FILENAME.odt > public/projects/"${FILENAME}_converted".html

# Remove any spans
sed -i -e 's|<span>||g;s|</span>||g' public/projects/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|g' public/projects/"${FILENAME}_converted".html

# Go up one level in directory when placing img tags sources
sed -i 's|src="../images/|src="images/|g' public/projects/"${FILENAME}_converted".html

# Add frames to images that require that style
sed -i 's|frmd.png"|frmd.png" class="frmd"|g' public/projects/"${FILENAME}_converted".html

# Remove anchors from headings
sed -i -e 's|<a id="anchor001"></a>||g' public/projects/"${FILENAME}_converted".html

# Remove any div tags
sed -i -e 's|<div>||;s|</div>||g' public/projects/"${FILENAME}_converted".html

# Get project's title
TITLE=$(perl -ln0e '$,="\n";print /(?<=<h1>).*?(?=<\/h1)/sg' public/projects/"${FILENAME}_converted".html)
echo "Title: "${TITLE}
# Add title from h1. Converted html is used for RSS feed (so it's just the content of the page)
sed -i 's|<title></title>|<title>'"$TITLE"'</title>|' public/projects/"${FILENAME}_converted".html
# Add title from h1, converted html to final html is used for RSS feed (so it's just the content of the page)
sed -i -e 's|<title></title>|<title>'"$TITLE"'</title>|' public/projects/$FILENAME.html

# Create temporary converted file where only inner html is kept
# (meta, html and body tags are removed)
cp -frp public/projects/"${FILENAME}_converted".html -T public/projects/"${FILENAME}_temp".html
# remove first 7 lines:
sed -i '1,7d' public/projects/"${FILENAME}_temp".html
# remove last 2 lines
sed -i '$d' public/projects/"${FILENAME}_temp".html
sed -i '$d' public/projects/"${FILENAME}_temp".html

# Adjust paths
sed -i 's|../static/main.css|../style/main.css|' public/projects/$FILENAME.html
sed -i 's|../static/fonts.css|../style/fonts.css|' public/projects/$FILENAME.html

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

# Add social media menu
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/projects/$FILENAME.html

# Add main menu
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/projects/$FILENAME.html

# Set dir level to the main menu's href (one level up)
sed -i 's|href="this.|href="../|' public/projects/$FILENAME.html

# Set page title
sed -i 's|<!-- currentPage -->|Selected Works: '"$TITLE"'|' public/projects/$FILENAME.html

# Add SEO bits
sed -i '/<!-- SEOTemplate -->/ {r '"SEOTemplate"'
d;};' public/projects/$FILENAME.html
# Add SEO bits: set URLs
sed -i 's|this.html|projects/'"$FILENAME"'.html|' public/projects/$FILENAME.html
# Add SEO bits: set title
sed -i 's|this.title|'"$TITLE"'|' public/projects/$FILENAME.html
# Add SEO bits: set image
sed -i 's|this.image|'"projects/images/$FILENAME-cover.png"'|' public/projects/$FILENAME.html
# Add SEO bits: set description
sed -i 's|this.description|'"$TITLE"': Project from Pedro Pinto Silva|' public/projects/$FILENAME.html
# Add SEO bits: set og type
sed -i 's|this.type|article|' public/projects/$FILENAME.html

echo "👾 $(tail -n 1 content/projects/list-names)"
echo '  ⮡ public/projects/'$FILENAME'.html'
