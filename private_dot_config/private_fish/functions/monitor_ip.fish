function monitor_ip -a ip
    begin
        echo 'date	time'
        while true
            ping -n -i 10 $ip 2>/dev/null \
               | sed -En -e "/$ip:/{s/.*time=(.*) ms/"(date '+%H-%M-%S')"	\\1/;p;}"
            #sleep 10
        end
    end # | $HOME/Source/golang/bin/termeter
end

