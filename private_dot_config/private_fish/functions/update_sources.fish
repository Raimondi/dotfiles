function update_sources
	pushd ~/Documents/Source/
	trap 'popd; exit' SIGINT
	set succesful
	set failed
	for repo in *
		echo "  * $repo"
		cd $repo
		git pull --rebase --autostash --stat
		and set succesful $succesful $repo
		or set failed $failed $repo
		cd ..
	end
	echo '-----------------------------'
	echo 'Successfully updated:'
	set_color green
	for item in $succesful
		echo $item
	end
	set_color normal
	echo '-----------------------------'
	echo 'Failed updating:'
	set_color red
	for item in $failed
		echo $item
	end
	popd
end
