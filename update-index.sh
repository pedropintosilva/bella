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
find ./content/projects/ -maxdepth 1 -name  \*.odt | cut -d '/' -f4  | cut -d '.' -f1 |
while read line; do
  ./generate.sh $line
done
echo -e '----------------------------\n'${NC}''

# Copy Homepage
cp -p public/about.html public/index.html #About is the homepage

# Copy additional files
cp -p content/cardListTemplate public/selected-works.html
# Copy styles and fonts
cp -p static/main.css public/style/main.css
cp -p static/Jost.css public/style/Jost.css
cp -p static/Jost-* public/style/

# Temp file
touch content/temp

# Create array with projectslist
mapfile -t LIST < content/projects/list-ids
mapfile -t NAMES < content/projects/list-names

echo 'Updating homepage with latest project cards...'
# Update Homepage
ITER=0
for i in "${LIST[@]}"
do
# Use to store it in a variable isntead: `read -r -d '' VAR <<- EOM`
# Add '-' to '<<'  to ignore tabs like so: `cat >> content/temp <<- EOM`
# but then you must use tabs, not spaces, for indentation in your code
cat >> content/temp << EOM
						<div class="box box${ITER} box--card" style="background-image: url(projects/images/${i}-cover.png">
							<a href="projects/${i}.html">
								<h2>${LIST[${ITER}]}</h2>
							</a>
						</div>
EOM
	ITER=$(expr $ITER + 1)
done

# Append project cards to selected-works.html page
sed -i '/<!-- projectCard -->/ {r '"content/temp"'
d;};' public/selected-works.html

# Adjust paths
sed -i 's|../static/main.css| style/main.css|' public/selected-works.html
sed -i 's|../static/Jost.css| style/Jost.css|' public/selected-works.html
sed -i 's|../static/main.css| style/main.css|' public/index.html
sed -i 's|../static/Jost.css| style/Jost.css|' public/index.html
echo 'Adjusting file paths...'

# Add social media menu
sed -i '/<!-- menuSocialTemplate -->/ {r '"menus/menuSocialTemplate"'
d;};' public/selected-works.html

# Add main menu
sed -i '/<!-- menuMainTemplate -->/ {r '"menus/menuMainTemplate"'
d;};' public/selected-works.html

# Set dir level to the main menu's href (already in the correct level)
sed -i 's|href="this.|href="|' public/selected-works.html

# Set current menu item
sed -i 's|data-filename="selected-works"|class="selected"|' public/selected-works.html

# remove temporary file
rm content/temp
echo -e 'Removing temp files...\n\nWebsite generated:\n  ⮡ 📂 ./public'
