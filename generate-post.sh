#! /bin/bash

# Generates Project HTML post and subsequent
# static files from .odt file

# mkdir venv
# python3 -m venv ./venv
# source ./venv/bin/activate
# pip install odfpy

FILENAME="$1"
REMOVE="$2"

[ -z "$FILENAME" ] && read -p "Missing ODT filename. Enter it without file extension: " FILENAME

# if [ -n "$REMOVE" ]; then
# 	# Be sure we have all folders ready
# 	mkdir -p public/blog/
# 	mkdir -p public/blog/images/
# fi

# Copy static content
cp -p static/main.css public/style/main.css
cp -p static/fonts.css public/style/fonts.css

# Copy post's images
[ ! -d public/blog ] && mkdir -p public/blog/
cp -rp content/blog/images/. public/blog/images

# Copy the ODT source so it can be downloaded from the rendered post
cp -p content/blog/$FILENAME.odt public/blog/$FILENAME.odt

# Create new empty project page following template
cp -frp content/blog/template -T public/blog/$FILENAME.html

# CONVERT With python, --plain to get without css
odf2xhtml --plain content/blog/$FILENAME.odt > public/blog/"${FILENAME}_converted".html

# Remove any spans
sed -i -e 's|<span>||g;s|</span>||g' public/blog/"${FILENAME}_converted".html

# Replace LO pictures with images
sed -i 's|src="Pictures/|src="images/|g' public/blog/"${FILENAME}_converted".html

# Go up one level in directory when placing img tags sources
sed -i 's|src="../images/|src="images/|g' public/blog/"${FILENAME}_converted".html

# Remove the trailing <a id="anchorN"></a> that odf2xhtml emits inside every heading.
# Anchored to </h[1-6]> so anchors elsewhere (e.g. from a Table of Contents) are not touched.
sed -i 's|<a id="anchor[0-9]\+"></a></h\([1-6]\)>|</h\1>|g' public/blog/"${FILENAME}_converted".html

# Remove any div tags
sed -i -e 's|<div>||g;s|</div>||g' public/blog/"${FILENAME}_converted".html

# Get project's title
TITLE=$(perl -ln0e '$,="\n";print /(?<=<h1>).*?(?=<\/h1)/sg' public/blog/"${FILENAME}_converted".html)
echo "Title: "${TITLE}
# Add title from h1. Converted html is used for RSS feed (so it's just the content of the page)
sed -i 's|<title></title>|<title>'"$TITLE"'</title>|' public/blog/"${FILENAME}_converted".html
# Add title from h1, converted html to final html is used for RSS feed (so it's just the content of the page)
sed -i 's|<title></title>|<title>'"$TITLE"'</title>|' public/blog/$FILENAME.html

# Create temporary converted file where only inner html is kept
# (meta, html and body tags are removed)
cp -frp public/blog/"${FILENAME}_converted".html -T public/blog/"${FILENAME}_temp".html
# remove first 7 lines:
sed -i '1,7d' public/blog/"${FILENAME}_temp".html
# remove last 2 lines
sed -i '$d' public/blog/"${FILENAME}_temp".html
sed -i '$d' public/blog/"${FILENAME}_temp".html

# Adjust paths
sed -i 's|../static/main.css|../style/main.css|' public/blog/$FILENAME.html
sed -i 's|../static/fonts.css|../style/fonts.css|' public/blog/$FILENAME.html

# Modify content/blog/$FILENAME.html
# and insert contents from index template before and after
sed -i '/<!-- content -->/ {r '"public/blog/${FILENAME}_temp.html"'
d;};' public/blog/$FILENAME.html

# Add additional class to content box: 'page' and 'post'
sed -i 's|box content|box content page post|' public/blog/$FILENAME.html

# Wrap the post's subtitle (h4 right after h1) into the h1 as a doc-subtitle span
# so the title/subtitle pair is one semantic unit instead of two sibling headings
perl -i -0pe 's|<h1>(.*?)</h1>\s*<h4>(.*?)</h4>|<h1>$1 <span role="doc-subtitle" class="subtitle">$2</span></h1>|' public/blog/$FILENAME.html

# Make every heading clickable: derive a slug id from the heading text and
# wrap the visible text in a self-link so visitors can grab a permalink to
# any section. Slug rule: lowercase, non-alphanumeric runs collapse to "_",
# trimmed. The h1's optional subtitle span is preserved verbatim and stays
# outside the link (only the title text is linked).
perl -i -0pe '
sub slug {
    local $_ = lc shift;
    s/&amp;/and/g;
    s/&[a-z]+;//g;
    s/[^a-z0-9]+/_/g;
    s/^_+|_+$//g;
    $_
}
s|<h1>([^<]+?)((?: <span role="doc-subtitle" class="subtitle">[^<]*</span>)?)</h1>|
    my $sl = slug($1);
    qq{<h1 id="$sl"><a class="heading-anchor" href="#$sl">$1</a>$2</h1>}
|se;
s|<(h[2-6])>([^<]+)</\1>|
    my $sl = slug($2);
    qq{<$1 id="$sl"><a class="heading-anchor" href="#$sl">$2</a></$1>}
|seg;
' public/blog/$FILENAME.html

# Resolve the ODT download placeholder to an actual link to the source ODT
sed -i 's|<!-- odtDownload -->|<p class="odt-source"><a href="'"$FILENAME"'.odt" download>Download this post as ODT</a></p>|' public/blog/$FILENAME.html

# Append project to blog list
echo $FILENAME >> content/blog/list-ids

# Append it to the list of names
echo $TITLE >> content/blog/list-names

# Remove temporary file
rm public/blog/"${FILENAME}_temp".html

# Add social media menu
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/blog/$FILENAME.html

# Add main menu
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/blog/$FILENAME.html

# Set dir level to the main menu's href (one level up)
sed -i 's|href="this.|href="../|' public/blog/$FILENAME.html

# Set page title
sed -i 's|<!-- currentPage -->|Blog: '"$TITLE"'|' public/blog/$FILENAME.html

# Add SEO bits
sed -i '/<!-- SEOTemplate -->/ {r '"SEOTemplate"'
d;};' public/blog/$FILENAME.html
# Add SEO bits: set URLs
sed -i 's|this.html|blog/'"$FILENAME"'.html|' public/blog/$FILENAME.html
# Add SEO bits: set title
sed -i 's|this.title|'"$TITLE"'|' public/blog/$FILENAME.html
# Add SEO bits: set image
sed -i 's|this.image|images/avatar.jpeg|' public/blog/$FILENAME.html
# Add SEO bits: set description
sed -i 's|this.description|'"$TITLE"' ⋅ Blog article from Pedro Pinto Silva|' public/blog/$FILENAME.html
# Add SEO bits: set og type
sed -i 's|this.type|article|' public/blog/$FILENAME.html
# Add SEO published time
PUBDATE=$(echo ${FILENAME} | cut -d '_' -f1)
sed -i 's|<!-- published_time -->|<meta property="article:published_time" content="'"$PUBDATE"'" />|' public/blog/$FILENAME.html


echo "🗣️ $(tail -n 1 content/blog/list-names)"
echo '  ⮡ public/blog/'$FILENAME'.html'
