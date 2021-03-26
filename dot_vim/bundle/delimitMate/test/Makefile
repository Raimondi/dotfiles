#all: build/runVimTests build/VimTAP
#	build/runVimTests/bin/runVimTests.sh -0 .
all:
	expect -d main.exp

build/runVimTests:
	git clone https://github.com/inkarkat/runVimTests $@

# Use VimTAP as directory name, as used with runVimTestsSetup.vim.
build/VimTAP:
	git clone https://github.com/inkarkat/vimtap $@
