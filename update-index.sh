#! /bin/bash

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Remove anything old and empty lists
[ -d public ] && echo -e "\n${RED}Removing generated old files\n* rm -r public/\n* > content/projects/list-ids\n* > content/projects/list-names" && cd public/ && rm -r `ls | grep -v ".git"` && cd ..
> content/projects/list-ids
> content/projects/list-names
> content/blog/list-ids
> content/blog/list-names


echo -e "\n${GREEN}Creating directory tree...\n* public\n* public/style\n* public/projects\n* public/images${NC}"
rm -rf public
mkdir public
mkdir public/style
mkdir public/projects
mkdir public/images

# Call generate-page.sh
#  How many top pages?
TOTALPAGES=$(find ./content/ -maxdepth 1 -name  \*.odt | wc -l)
echo -e '\n'${BLUE}'Creating Pages ('${TOTALPAGES}'):\n----------------------------'
find ./content/ -maxdepth 1 -name  \*.odt | cut -d '/' -f3  | cut -d '.' -f1 |
while read line; do
  ./generate-page.sh $line
done
echo -e '----------------------------\n'
# Call generate.sh
#  How many Projects?
TOTALPROJECTS=$(find ./content/projects/ -maxdepth 1 -name  \*.odt | wc -l)
echo -e ''${PURPLE}'Creating Projects ('${TOTALPROJECTS}'):\n----------------------------'
find ./content/projects/ -maxdepth 1 -name \*.odt -printf "%T+ %p\n" | sort -r | cut -d '/' -f4  | cut -d '.' -f1 |
while read line; do
  ./generate.sh $line
done
echo -e '----------------------------\n'
# Call generate-post.sh
#  How many Posts?
TOTALPOSTS=$(find ./content/blog/ -maxdepth 1 -name  \*.odt | wc -l)
echo -e ''${BLUE}'Creating Blog Posts ('${TOTALPOSTS}'):\n----------------------------'
# Posts odt files are already named with dates as prefix. Example: 2019-11-18_hello-world.odt
find ./content/blog/ -maxdepth 1 -name \*.odt | cut -d '/' -f4  | cut -d '.' -f1  | sort -r |
while read line; do
  ./generate-post.sh $line
done
echo -e '----------------------------\n'${NC}''

# Copy additional files
cp -p content/cardListTemplate public/selected-works.html
cp -p content/cardListTemplate public/blog.html
# Copy Homepage
cp -p content/aboutPageTemplate public/index.html
# Copy styles and fonts
cp -p static/main.css public/style/main.css
cp -p static/fonts.css public/style/fonts.css
cp -p static/*.ttf public/style/

# Temp file
touch content/temp

# Create array with projectslist
mapfile -t LIST < content/projects/list-ids
mapfile -t NAMES < content/projects/list-names
mapfile -t GRIDSPANS < content/projects/list-grid-spans

echo 'Updating homepage with latest project cards...'
# Update Homepage
ITER=0
for i in "${LIST[@]}"
do
# Use to store it in a variable isntead: `read -r -d '' VAR <<- EOM`
# Add '-' to '<<'  to ignore tabs like so: `cat >> content/temp <<- EOM`
# but then you must use tabs, not spaces, for indentation in your code
cat >> content/temp << EOM
						<div id="prjct-${LIST[${ITER}]}"class="box box${ITER} box--card" style="background-image: url(projects/images/${i}-cover.png); ${GRIDSPANS[${ITER}]}">
							<a class="mobile d-flex" href="projects/${i}.html#content">
								<h2>${NAMES[${ITER}]}</h2>
							</a>
							<a class="mobile-hidden" href="projects/${i}.html">
								<h2>${NAMES[${ITER}]}</h2>
							</a>
						</div>
EOM
	ITER=$(expr $ITER + 1)
done

# Append project cards to selected-works.html page
sed -i '/<!-- projectCard -->/ {r '"content/temp"'
d;};' public/selected-works.html

# Temp file
touch content/blogtemp

# Create array with projectslist
mapfile -t BLOGLIST < content/blog/list-ids
mapfile -t BLOGNAMES < content/blog/list-names
mapfile -t BLOGHEADLINERS < content/blog/list-headliners

echo 'Updating blog with latest posts cards...'
# Update Blog
ITERPOST=0
for post in "${BLOGLIST[@]}"
do
POSTDATE=$(echo ${post} | cut -d '_' -f1)
cat >> content/blogtemp << EOM
						<div id="post-${BLOGLIST[${ITERPOST}]}" class="box box${ITERPOST} box--card post" style="background-image: url(blog/images/${post}-cover.png">
							<a class="mobile d-flex" href="blog/${post}.html#content">
								<span>${POSTDATE}</span>
								<h2>${BLOGNAMES[${ITERPOST}]}</h2>
								<p>${BLOGHEADLINERS[$ITERPOST]}</p>
							</a>
							<a class="mobile-hidden" href="blog/${post}.html">
								<span>${POSTDATE}</span>
								<h2>${BLOGNAMES[${ITERPOST}]}</h2>
								<p>${BLOGHEADLINERS[$ITERPOST]}</p>
							</a>
						</div>
EOM
	ITERPOST=$(expr $ITERPOST + 1)
done

# Append posts cards to blog.html page
sed -i '/<!-- projectCard -->/ {r '"content/blogtemp"'
d;};' public/blog.html

# Adjust paths
sed -i 's|../static/main.css| style/main.css|' public/blog.html
sed -i 's|../static/fonts.css| style/fonts.css|' public/blog.html
sed -i 's|../static/main.css| style/main.css|' public/selected-works.html
sed -i 's|../static/fonts.css| style/fonts.css|' public/selected-works.html
sed -i 's|../static/main.css| style/main.css|' public/index.html
sed -i 's|../static/fonts.css| style/fonts.css|' public/index.html
echo 'Adjusting file paths...'

# Add social media menu
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/blog.html
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/selected-works.html
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/index.html

# Add main menu
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/blog.html
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/selected-works.html
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/index.html

# Set dir level to the main menu's href (already in the correct level)
sed -i 's|href="this.|href="|' public/blog.html
# Set dir level to the main menu's href (already in the correct level)
sed -i 's|href="this.|href="|' public/selected-works.html
# Set dir level to the main menu's href (already in the correct level)
sed -i 's|href="this.|href="|' public/index.html

# Set page title
sed -i 's|<!-- currentPage -->|blog|' public/blog.html
sed -i 's|<!-- currentPage -->|Selected Works|' public/selected-works.html
sed -i 's|<!-- currentPage -->|About|' public/index.html

# Add SEO bits for blog page ---------------------------
sed -i '/<!-- SEOTemplate -->/ {r '"SEOTemplate"'
d;};' public/blog.html
# Add SEO bits: set URLs
sed -i 's|this.html|blog.html|' public/blog.html
# Add SEO bits: set title
sed -i 's|this.title|Blog ⋅ Pedro Pinto Silva|' public/blog.html
# Add SEO bits: set image
sed -i 's|this.image|images/avatar.jpeg|' public/blog.html
# Add SEO bits: set description
sed -i 's|this.description|Blog ⋅ Pedro Pinto Silva|' public/blog.html
# Add SEO bits: set og type
sed -i 's|this.type|website|' public/blog.html
# Add SEO bits for selected works page -------------------
sed -i '/<!-- SEOTemplate -->/ {r '"SEOTemplate"'
d;};' public/selected-works.html
# Add SEO bits: set URLs
sed -i 's|this.html|selected-works.html|' public/selected-works.html
# Add SEO bits: set title
sed -i 's|this.title|Selected works ⋅ Pedro Pinto Silva|' public/selected-works.html
# Add SEO bits: set image
sed -i 's|this.image|images/avatar.jpeg|' public/selected-works.html
# Add SEO bits: set description
sed -i 's|this.description|Selected works ⋅ Pedro Pinto Silva|' public/selected-works.html
# Add SEO bits: set og type
sed -i 's|this.type|website|' public/selected-works.html
# Add SEO bits for homepage -------------------------------
sed -i '/<!-- SEOTemplate -->/ {r '"SEOTemplate"'
d;};' public/index.html
# Add SEO bits: set URLs
sed -i 's|this.html|index.html|' public/index.html
# Add SEO bits: set title
sed -i 's|this.title|About ⋅ Pedro Pinto Silva|' public/index.html
# Add SEO bits: set image
sed -i 's|this.image|images/avatar.jpeg|' public/index.html
# Add SEO bits: set description
sed -i 's|this.description|About ⋅ Pedro Pinto Silva|' public/index.html
# Add SEO bits: set og type
sed -i 's|this.type|website|' public/index.html

# Set current menu item
sed -i 's|data-filename="blog"|class="selected"|' public/blog.html
# Set current menu item
sed -i 's|data-filename="selected-works"|class="selected"|' public/selected-works.html
# Set current menu item
sed -i 's|data-filename="about"|class="selected"|' public/index.html

# Add RSS feed links everywhere
find . -type f \( -not -name "*_converted.html" -and -name '*.html' \) |
while read htmlfilename; do
sed -i '/<!-- rssFeedTemplate -->/ {r '"rssFeedTemplate"'
d;};' $htmlfilename
done

# remove temporary file
rm content/temp
rm content/blogtemp
echo -e 'Removing temp files...\n\nWebsite generated:\n  ⮡ 📂 ./public'
