#!/usr/bin/awk -f
{
    gsub(/\"|\;|\=|\-|\{|\}|\,/,"")
    gsub(" ","")
    gsub("length16bytes0x"," ")
    if (NF == 0)
      next
    else if (NF == 1)
      printf "%s",$0
    else if (NF >= 2)
      printf "%s %s ",$1,$2
      for (i=31;i>=1;i=i-2) printf "%s%s",substr($2,i,2),(i>1?"":"\n")
}
