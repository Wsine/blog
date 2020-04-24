#!/bin/bash

echo $added_files
IFS=',' read -r -a changes <<< "$added_files"
for change_file in ${changes[@]}; do
  echo "Handling $change_file"
  imgs=$(grep -oh -E "(https?:\/\/.*\.(?:png|jpg|svg|gif|JPEG|PNG|JPG))" "$change_file")
  for img in ${imgs[@]}; do
    echo "Processing $img"
    ext=${img##*.}
    wget -O /tmp/image.$ext $img

    file="/tmp/image.$ext"
    md5=$(md5sum "$file" | cut -d' ' -f1)
    length=$(stat -c%s "$file")
    mime=$(file -b --mime-type "$file")

    keyname="image/$md5.${file##*.}"
    bucketname="wsine"
    string2sign="PUT\n$md5\n$mime\n\n/$bucketname/$keyname"
    publickey="xqcTFHYj7H7/I5OSrPRJLFhImFHyKZu4u2gfq64VwBCMP/5/JCWExQ=="

    signature=$(echo -en "$string2sign" | openssl sha1 -hmac "$ucloud_private_key" | cut -d' ' -f2 | xxd -r -p | base64)
    authorization="UCloud $publickey:$signature"
    url="http://$bucketname.cn-gd.ufileos.com/$keyname"

    # curl -v -X PUT --http1.1 "$url" \
    #   --data "@$file" \
    #   -H "Authorization: $authorization" \
    #   -H "Content-Length: $length" \
    #   -H "Content-Type: $mime" \
    #   -H "Content-MD5: $md5"

    sed -i "s|$img|$url|g" "$change_file"
    echo "Replacing img to $url"
  done
done

