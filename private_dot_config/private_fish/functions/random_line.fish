function random_line
  if type -f gshuf 1>/dev/null 2>/dev/null
    gshuf -n 1 -
  else if echo a | sort -R 1>/dev/null 2>/dev/null
    sort -R - | tail -n 1
  else
    cat - | awk 'BEGIN { srand() } { print rand() "\t" $0 }' \
       | sort -n | cut -f2- | tail -n 1
  end
end
