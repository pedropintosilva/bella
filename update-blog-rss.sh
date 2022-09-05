#! /bin/bash

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

FILENAME="$1"
rssfile="blog.xml"

generate_rss_entrie () {
    echo -e "----------------------------\n${PURPLE}generate_rss_entrie\n"
    # You will want to change these variables to your needs.
    website="https://pintosilva.com"

    # In order to cleanly use sed on a multi-line file, we have to use `tr` to
    # convert newlines to a set character, then run sed, then reconvert the
    # character. Unfortunately, due to a current issue in GNU's tr, characters of
    # more than one byte are not functioning properly. It would be more ideal to
    # use a rarer character (some random Tamil character, for example), but ^ is
    # one byte.
    replchar='^'
    # So if you have a page with ^ in it, you'll have to change this to another
    # single byte character that isn't in the page like ~ or something.

    link="$website/blog/$1"
    title="$(sed -n 's/<h1>\(.*\)<\/h1>/\1/ip' "$1")"
    echo -e "\nTitle: $title"

    # Check and see if this page has already been added to the RSS feed.
    if grep -q "<guid.*>$link</guid>" "$rssfile"; then
        # Do this if it has been adding and we are updating it.

        # If updating a file, we append the time/date to the GUID, as all GUIDs
        # must be unique to validate an RSS feed. Even feed readers that follow
        # GUIDs will still be lead to the same page with this.
        guid="$link#$(date '+%y%m%d%H%M%S')"
        title="$title (Updated)"
        echo "Explain the nature of the update:"
        read -r content
        [ -z "$content" ] && content="New updates to $link"
    else
        # Do this if it is a new page.
        echo -e "\nNew page"
        guid=$link
        # Get the page body content, excluding the nav and footer.
        content="$(tr '\n' $replchar < "$1" | sed "
        s/.*<body>//
        s/<footer>.*<\/footer>//
        s/<nav>.*<\/nav>//
        s/<\/body>.*//
        " | tr -s $replchar '\n')"
    fi

    rssdate="$(LC_TIME=en_US date '+%a, %d %b %Y %H:%M:%S %z')"

    # Eh, I'm a brainlet and I'm not sure how to elegantly add in the content to
    # the RSS feed without first writing it out to a file. This is because if we
    # tried run, say, a sed substitute command, we'd have to escape with \
    # basically every other character. If you know how to do it without creating a
    # temporary file, tell me. I do the same in lb, actually.
    temp="$(mktemp)";
    trap 'rm -f "$temp"' 0 1 2 3 15	# Delete temp file after script termination.
    echo "
    <item>
    <title>$title</title>
    <guid>$guid</guid>
    <link>$link</link>
    <pubDate>$rssdate</pubDate>
    <description><![CDATA[$content
    ]]></description>
    </item>
    " > "$temp"

    sed -i "/<!-- LB -->/r $temp" "$rssfile"
}

echo -e "${RED}"
[ -z "$FILENAME" ] && read -p "Missing filenam.html. Updating all entries? (y,n)" -n 1 UPDATEALL
echo    # Move to a new line
if [[ ! $UPDATEALL =~ ^[Yy]$ ]]
then
    exit 1
fi

echo -e '\n'${BLUE}'Creating rss feed entries:
\n----------------------------'
find ./public/blog/ -maxdepth 1 -type f -iname "*converted.html" | cut -d '/' -f4 |
while read line; do
  echo $line
  generate_rss_entrie $line
done
echo -e '\n'${BLUE}'Copied XML to public folder:'
cp -p ${rssfile} public/${rssfile}
echo -e "----------------------------\n${NC}"
