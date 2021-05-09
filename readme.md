# Structure
* public: folder to use in server 
* content: All content in odt
* static: Images and CSS


# Workflow
## Projects

1. Create a new odt file inside of `content/projects`
2. Write description and add images
3. Generate corresponding html page `./generate.sh [odtfilenameWithoutextension]`
4. Update list of projects and correspondent homepage `./update-index.sh `

# Converting ODT to HTML
## with LO

soffice --headless --convert-to html:HTML --outdir . test-zamad.odt 

## With python to get without css

odf2xhtml --plain test-zamad.odt > test-zamad.html

### To remove anchors from headings

sed -i -e 's/stringname/excludetodelete/' filename.txt 

Example remove "<a id="anchor001"></a>"

sed -i -e 's|<a id="anchor001"></a>||' test-zamad.html
