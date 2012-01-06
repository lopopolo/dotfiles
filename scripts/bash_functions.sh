function freq
{
  cat ~/.*h_h*|cut -d" " -f1|ruby -e'h=Hash.new 0;h[$_]+=1 while gets;h.each{|k,v|puts"#{v} "+k}'|sort -rn|head
}


