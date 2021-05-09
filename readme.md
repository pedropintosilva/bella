# with LO

soffice --headless --convert-to html:HTML --outdir . test-zamad.odt 

# With python to get without css

odf2xhtml --plain test-zamad.odt > test-zamad.html

## To remove anchors from headings

sed -i -e 's/stringname/excludetodelete/' filename.txt 

Example remove "<a id="anchor001"></a>"

sed -i -e 's|<a id="anchor001"></a>||' test-zamad.html
