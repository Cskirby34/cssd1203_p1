#! /usr/bin/env bash

if [ "$#" -gt 1 ]; then
  exit 1
fi

if [ "$#" -eq 0 ]; then
    dir="."
else
    dir="$1"
fi

if [ ! -d "$dir" ]; then
    printf '%s is not a directory.\n' "$dir" >&2
    exit 1
fi

if [ ! -r "$dir" ] || [ ! -x "$dir" ]; then
    printf '%s is not readable or executable.\n' "$dir" >&2
    exit 1
fi

find "$dir" -type f \
    \( -iname '*.jpg' -o \
       -iname '*.jpeg' -o \
       -iname '*.png' -o \
       -iname '*.tif' -o \
       -iname '*.tiff' -o \
       -iname '*.bmp' -o \
       -iname '*.gif' \) \
    ! -path '*/.thumbs/*' |
while IFS= read -r image
do

    image_dir=$(dirname "$image")

    filename=$(basename "$image")

    mkdir -p "$image_dir/.thumbs"
    mkdir -p "$image_dir/.metadata"

    identify -verbose "$image" > "$image_dir/.metadata/$filename.txt"

    dimensions=$(identify -format '%w %h\n' "${image}[0]" 2>/dev/null </dev/null | head -n 1)
    read -r width height <<< "$dimensions"
    case "$width" in ''|*[!0-9]*) continue ;; esac

    if [ "$width" -gt 512 ] || [ "$height" -gt 512 ]; then
        max_size=512
    elif [ "$width" -gt 256 ] || [ "$height" -gt 256 ]; then
        max_size=256
    elif [ "$width" -gt 128 ] || [ "$height" -gt 128 ]; then
        max_size=128
    else
        max_size=0
    fi

    base="${filename%.*}"
    extension="${filename##*.}"

    if [ "$max_size" -ge 128 ]; then
        convert "$image" -resize "128x128>" \
            "$image_dir/.thumbs/${base}-128.${extension}"
    fi

    if [ "$max_size" -ge 256 ]; then
        convert "$image" -resize "256x256>" \
            "$image_dir/.thumbs/${base}-256.${extension}"
    fi

    if [ "$max_size" -ge 512 ]; then
        convert "$image" -resize "512x512>" \
            "$image_dir/.thumbs/${base}-512.${extension}"
    fi

    printf '%s\n' "$image"

done
