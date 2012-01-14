function freq
{
  cat ~/.*h_h*|cut -d" " -f1|ruby -e'h=Hash.new 0;h[$_]+=1 while gets;h.each{|k,v|puts"#{v} "+k}'|sort -rn|head
}

# This function prints out lines in the given files that
# contain non-ascii characters
function is_not_ascii
{
  if [ "$#" == "0" ]; then
    echo "Usage: $0 file1 file2 ..."
    exit 1
  fi
  while (( "$#" )); do
    echo "$1:"
    perl -nwe 'print if /[^[:ascii:]]/' "$1"
    shift
  done
}

