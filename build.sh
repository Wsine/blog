#!/bin/bash

########### Generate Docsify Sidebar ###########
find . -mindepth 2 -name "*.md" | awk -F'/' 'BEGIN {RS=".md"} {arr[$2]=arr[$2]"\n    - ["$3"](/"$2"/"$3")"} END { num = asorti(arr, indices); for (i=1; i<=num; ++i) if (indices[i]) print "- "indices[i], arr[indices[i]]}' > _sidebar.md

########### Generate RSS xml file ###########
feed="feed.xml"
blog_title="Wsine's Blog"
blog_link="https://wsine.github.io/blog"

urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_+-/]) printf "$c" ;;
      *) printf "$c" | xxd -p -c1 | while read x; do printf "%%%s" "$x"; done ;;
    esac
  done
}

newest_files=$( \
  git ls-files -z '*.md' | \
  xargs -0 -n1 -I{} -- git log -1 --format="%at {}" {} | \
  sort -r | \
  head -n10 | \
  cut -d " " -f2-)

items=""
for file in ${newest_files[@]}; do
  echo $file
  title=$(grep "." $file | head -n1)
  encode=$(urlencode "${file::-3}")
  link="$blog_link/#/$encode"
  html=$(pandoc -f markdown -t html $file)
  date=$(git log -1 --format="%aD" -- $file)
  item="
  <item>
    <title><![CDATA[${title:2}]]></title>
    <link>$link</link>
    <guid isPermaLink=\"false\">$link</guid>
    <description><![CDATA[$html]]></description>
    <pubDate>$date</pubDate>
  </item>
  "
  items="$items $item"
done

rss_content="
<rss xmlns:atom=\"http://www.w3.org/2005/Atom\" version=\"2.0\">
<channel>
  <title>$blog_title</title>
  <atom:link href=\"$blog_link/$feed\" rel=\"self\" type=\"application/rss+xml\" />
  <link>$blog_link</link>
  <description>To be simple, to be powerful.</description>
  $items
</channel>
</rss>
"

echo "$rss_content" > $feed

