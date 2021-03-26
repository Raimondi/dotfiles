function cowthink-random
  set -l cow_file (ls -1 /opt/local/share/cowsay/cows | random_line)
  cowthink -f "$cow_file" $argv
end
