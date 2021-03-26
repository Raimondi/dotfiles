function cowsay-random
  set -l cow_file (ls /opt/local/share/cowsay/cows/*.cow ~/Source/cowsay-files/cows/*.cow | random_line)
  eval cowsay -f "$cow_file" $argv
end
