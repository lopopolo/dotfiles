#!/usr/bin/env bash

USAGE="$0 -a ACCESS_TOKEN -d DESTINATION

This script clones my secure folder from box. All options
are required.

This script requires an access token and does no refresh
attempts. You can easily get an access token by using
the box-token-generator:

    http://box-token-generator.herokuapp.com/

This script does not respect rate limits and does no error
checking. Use cautiously."

ACCESS_TOKEN=""
DESTINATION=""

while getopts "h?a:d:" opt; do
    case "$opt" in
    h|\?)
        echo "$USAGE"
        exit 0
        ;;
    a)  ACCESS_TOKEN="$OPTARG"
        ;;
    d)  DESTINATION="$OPTARG"
        ;;
    *)  echo "$USAGE"
        exit 1
        ;;
    esac
done

if [ -z "$ACCESS_TOKEN" ] || [ -z "$DESTINATION" ]; then
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

pushd "$DESTINATION" &> /dev/null

box-folder-tree.bash -a "$ACCESS_TOKEN" -f 1733369953 -d .

cat <<EOF > Secure/README.txt
This folder contains the passwords, ssh keys, two factor codes
and other security-related content of Ryan Lopopolo <rjl@hyperbo.la>.

This archive was generated on $(date "+%Y-%m-%d") using the tool
$0.

Passwords can be found in the Keypass folder. The database is a
.kbdx file that can be opened with KeepassX <https://www.keepassx.org/>.

Several accounts require two factor authentication codes. If my phone is
inaccessible, the backup codes in the 2FA folder can be used.
EOF
