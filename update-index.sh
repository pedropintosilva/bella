#! /bin/bash

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "\n${RED}Removing generated old files\n* rm -r public/\n* > content/projects/list-ids\n* > content/projects/list-names"
# Remove anything old and empty lists
rm -r public/
> content/projects/list-ids
> content/projects/list-names

echo -e "\n${GREEN}Creating directory tree...\n* public\n* public/style\n* public/projects\n* public/images${NC}"
mkdir public
mkdir public/style
mkdir public/projects
mkdir public/images

# Call generate-page.sh
#  How many top pages?
echo 'Total pages found: '
find ./content/ -maxdepth 1 -name  \*.odt | wc -l
find ./content/ -maxdepth 1 -name  \*.odt | cut -d '/' -f3  | cut -d '.' -f1 | while read line; do
	echo 'Creating Page '$line
	./generate-page.sh $line
done

# Copy Homepage
cp -p content/index.html public/index.html
cp -p static/main.css public/style/main.css

# Temp file
touch content/temp

# Create array with projectslist
mapfile -t LIST < content/projects/list-ids
mapfile -t NAMES < content/projects/list-names

# Update Homepage
ITER=0
for i in "${LIST[@]}"
do
	echo ${ITER}
	echo '<div class="box box'${ITER}' box--card" style="background-image: url(projects/images/'${i}'-cover.png">' >> content/temp
	echo '  <a href="projects/'${i}'.html">' >> content/temp
	echo '    <h2>'${LIST[${ITER}]}'</h2>' >> content/temp
	echo '  </a>' >> content/temp
	echo '</div>' >> content/temp
	ITER=$(expr $ITER + 1)
done

# Append project cards to index
sed -i '/<!-- projectCard -->/ {r '"content/temp"'
d;};' public/index.html

# Adjust paths
sed -i 's|../static/main.css| style/main.css|' public/index.html

# remove temporary file
rm content/temp
