#!/usr/bin/env bash

set -e
set -u
set -o pipefail

USAGE="$0 -a ACCESS_TOKEN -f FOLDER_ID -d DESTINATION

This script clones a folder tree from box. All options
are required.

This script requires an access token and does no refresh
attempts. You can easily get an access token by using
the box-token-generator:

    http://box-token-generator.herokuapp.com/

This script does not respect rate limits and does no error
checking. Use cautiously."

ACCESS_TOKEN=""
FOLDER_ID=""
DESTINATION=""

while getopts "h?a:f:d:" opt; do
    case "$opt" in
    h|\?)
        echo "$USAGE"
        exit 0
        ;;
    a)  ACCESS_TOKEN="$OPTARG"
        ;;
    f)  FOLDER_ID="$OPTARG"
        ;;
    d)  DESTINATION="$OPTARG"
        ;;
    *)  echo "$USAGE"
        exit 1
        ;;
    esac
done

if [ -z "$ACCESS_TOKEN" ] || [ -z "$FOLDER_ID" ] || [ -z "$DESTINATION" ]; then
  echo "$USAGE"
  exit 1
fi

if [ ! -d "$DESTINATION" ]; then
  echo "$DESTINATION is not a directory"
  echo "$USAGE"
  exit 1
fi

# expand tilde in directory
eval DESTINATION="$DESTINATION"

# $1 - folder id
# $2 - item type
function folder_items_by_type
{
  if [ -z "$1" ] || [ -z "$2" ]; then
    return 1
  fi

  echo "$1" | python3 -c "$(cat <<EOF
import sys, json
for e in json.load(sys.stdin)["entries"]:
    if e["type"] == "$2":
        print(e["id"])
EOF
)"
}

# $1 - json
# $2 - field, top-level
function extract_field_from_item
{
  echo "$1" | python3 -c "$(cat <<EOF
import sys, json
print(json.load(sys.stdin)["$2"])
EOF
)"
}

# $1 - indentation depth
# $2 - tabstop
# $3 - string
function indent
{
  {
    printf "%-$(($1*$2))s" " "
    echo "$3"
  } >&2
}

ROOT_FOLDER_NAME=""

# $1 - folder id
# $2 - folder depth
function make_folder
{
  local d="$2"

  folder_json="$(curl --silent "https://api.box.com/2.0/folders/$1?fields=name" -H "Authorization: Bearer $ACCESS_TOKEN")"
  folder_name="$(extract_field_from_item "$folder_json" "name")"

  if [ "$d" -eq "0" ]; then
    ROOT_FOLDER_NAME="$folder_name $(date "+%Y-%m-%d")"
    folder_name="$ROOT_FOLDER_NAME"
  fi

  mkdir "$folder_name"
  pushd "$folder_name" &> /dev/null
  indent "$d" "2" "/$folder_name"

  items_json="$(curl --silent "https://api.box.com/2.0/folders/$1/items" -H "Authorization: Bearer $ACCESS_TOKEN")"

  let d=$d+1
  files="$(folder_items_by_type "$items_json" "file")"
  if [ -n "$files" ]; then
    while read -r file_id; do
      file_json="$(curl --silent "https://api.box.com/2.0/files/$file_id?fields=name" \
        -H "Authorization: Bearer $ACCESS_TOKEN")"
      file_name="$(extract_field_from_item "$file_json" "name")"
      indent "$d" "2" "↳ $file_name"
      curl --silent -L -o "$(extract_field_from_item "$file_json" "name")" \
        "https://api.box.com/2.0/files/$file_id/content" \
        -H "Authorization: Bearer $ACCESS_TOKEN"
    done <<< "$files"
  fi

  subfolders="$(folder_items_by_type "$items_json" "folder")"
  if [ -n "$subfolders" ]; then
    while read -r folder_id; do
      subfolder_json="$(curl --silent "https://api.box.com/2.0/folders/$folder_id?fields=name" \
        -H "Authorization: Bearer $ACCESS_TOKEN")"
      make_folder "$(extract_field_from_item "$subfolder_json" "id")" "$d"
    done <<< "$subfolders"
  fi

  popd &> /dev/null
}

pushd "$DESTINATION" &> /dev/null

make_folder "$FOLDER_ID" "0"

echo "$ROOT_FOLDER_NAME"

