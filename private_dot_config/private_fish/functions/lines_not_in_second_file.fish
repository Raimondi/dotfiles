# Defined in /var/folders/d7/9x3nzt_n74z9rw52prcwxq0r0000gn/T//fish.RD7iqf/lines_not_in_second_file.fish @ line 2
function lines_not_in_second_file --argument file1 file2
    gawk 'FNR==NR{
    hash[$0]=1; next
}
{
   if (hash[$0]) {} else {print}
}' $file2 $file1
end
