# This should make my life easier.
# Everthing depends on perl.
# vim: set nowrap:

# The name of the plugin is the same of the containing dir.
plugin_name        = $(shell basename "$$PWD")
# Location of help file, many things depend on this.
help_file          = doc/vo_readme.txt
help_files         = $(wildcard doc/*.txt)
# All other files.
rc_file            = vimoutliner/$(plugin_name)rc
ftplugins          = $(wildcard ftplugin/vo_*.vim)
color_themes       = $(wildcard colors/vo_*.vim)
ftdetect           = $(wildcard ftdetect/vo_*.vim)
plugins            = $(wildcard vimoutliner/plugin/vo_*)
syntax             = $(wildcard syntax/vo_*.vim)
#non_vim_scripts    = $(wildcard vimoutliner/scripts/*)
non_vim_scripts    = $(shell find vimoutliner/scripts -type f \! -path ./.git\* \! -path ./view\* \! -name .\* \! -name \*.orig \! -iname \*.zip \! -iname \*.gz \! -iname \*.vba \! -name tags \! -name \*.tag | tr  " ")
other_files        = $(wildcard README) $(wildcard README.detailed) $(wildcard CHANGELOG) $(wildcard 	INSTALL) $(wildcard install.sh) $(wildcard LICENSE)
# Group all files.
all_files          = $(rc_file) $(help_files) $(ftplugins) $(color_themes) $(ftdetect) $(plugins) $(syntax) $(non_vim_scripts) $(other_files)
# Let's get them ready to be used by Vim's append().
all_quoted         = $(shell for i in $(all_files); do var="$$var\"$$i\", ";done;echo $${var%, })

temp= $(shell mktemp -td)

# Get version from the documentation.
current_version    = $(shell perl -ne 'if (/^The VimOutliner\s*/) {s/.*VimOutliner\s*([.0-9]+).*$$/\1/;print;exit}' $(help_file))
# Set the file name + version to be used in release files.
name_plus_version  = $(plugin_name)-$(current_version)
release_files      = $(name_plus_version).vba $(name_plus_version).zip $(name_plus_version).tgz
# Where is Vim.
vim_exec           = vim
# Temp file that will prevent the version target to be run if not needed.
version_file       = version.txt
# Command to open URLs.
open_url = open

# vim.org values.
#----------------
# The version comments.
VO_comment_file    = comments.txt
# Script's vim.org ID.
VO_scriptID        = 3515
# Script URL.
VO_scriptURL       = http://www.vim.org/scripts/script.php?script_id=$(VO_scriptID)
# Vim's minimum version where the script will run.
VO_min_vim_version = $(shell perl -ne 'if (/^\*$(plugin_name).txt\*\s+For Vim version/) {s/^.*For Vim version (\d+\.\S+)\s.*$$/\1/;print;exit}' $(help_file))
# Cookies file.
VO_cookie_jar      = cookies.txt

# github.com values.
#-------------------
# Get github's username from the git repo.
GH_username        = $(strip $(shell git config --global github.user))
# Now the downloads page URL.
GH_project_URL     = https://github.com/$(shell git remote show origin | perl -ne 'if (/github/) {s%^.*github\.com:(.*)\.git.*$$%$$1/downloads%;print;exit;}')
GH_temp_file       = github

# Phony targets.
.PHONY: clean all vimball zip targzip release echo version deploy_vimorg deploy_github
all: vimball zip targzip
all_files: $(all_files)
deploy_github: $(GH_temp_file)
deploy_vimorg: $(VO_cookie_jar)
release: $(plugin_name).vba $(plugin_name).zip $(plugin_name).tgz
version: $(version_file)
targzip: $(plugin_name).tgz
vimball: $(plugin_name).vba
zip: $(plugin_name).zip
clean:
	@echo clean
	rm -f *.vba **/*.orig *.~* .VimballRecord *.zip *.tgz $(version_file) $(VO_comment_file) $(PASSWDFILE) $(VO_cookie_jar) $(GH_temp_file)

# all files target
$(all_files):

# Undo version.
undo:
	@for i in **/*.orig; do mv -f "$$i" "$${i%.*}"; echo mv -f "$$i" "$${i%.*}"; done

# Real targets.
# Update version everywhere.
$(version_file): $(all_files)
	@echo Version: $(current_version); \
	perl -i.orig -pne 'if (/^"#\s*version/) {s/(\d+\.\S+)/$(current_version)/}' $(ftplugins) $(syntax) $(autoload_script); \
	perl -i.orig -pne 'if (/^v\d+\.\S+$$/) {s/(v\d+\.\S+)/v$(current_version)/}' $(help_file); \
	echo Date: `date '+%G %B %d'`; \
	perl -i.orig -MPOSIX -pne 'if (/^\s+$(current_version)\s+\d+-\d+-\d+\s+\*/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(help_file); \
	perl -i.orig -MPOSIX -pne 'if (/^\*$(plugin_name)\.txt\*.*/) {$$now_string = strftime "%G %B %d", localtime; s/(\d{4} [a-zA-Z]+ \d{2})/$$now_string/}' $(help_file); \
	echo $(current_version) > $(version_file)

# This just hard links the help file to README.
#README: $(help_file)
#	@echo README
#	#ln -f $(help_file) README

# Create VimBall archive.
$(plugin_name).vba: $(all_files)
	@echo Creating "$(plugin_name).vba"; \
	rm -f $(plugin_name).vba; \
	$(vim_exec) -N -u NONE -c 'ru! plugin/vimballPlugin.vim' -c ':call append("0", [ $(all_quoted) ])' -c '$$d' -c ":%MkVimball $(plugin_name)  ." -c':q!'
	ln -f $(plugin_name).vba $(name_plus_version).vba
	@echo "'$(plugin_name).vba' content:"
	@perl -ne "if (/^.*\\[\\[\\[1/) {s/^(.*?)\\s*\\[\\[\\[1/	\$$1/; print;}" $(plugin_name).vba

# Create zip archive.
$(plugin_name).zip: $(all_files)
	@echo Creating "$(plugin_name).zip"
	@rm -f *.zip
	@zip -r $(plugin_name).zip $(all_files)
	@-zip $(plugin_name).zip -d \*.sw\? 1>/dev/null
	@-zip $(plugin_name).zip -d \*.un\? 1>/dev/null
	@-zip $(plugin_name).zip -d \*.orig 1>/dev/null
	@-zip $(plugin_name).zip -d \*tags 1>/dev/null
	ln -f $(plugin_name).zip $(name_plus_version).zip
	#@unzip -l $(plugin_name).zip

# Tar+gzip VimBall archive.
$(plugin_name).tgz: $(all_files)
	@echo Creating "$(plugin_name).tgz"
	tar -cvzf $(plugin_name).tgz $(all_files)
	ln -f $(plugin_name).tgz $(name_plus_version).tgz

# Update vimorg's version comments.
$(VO_comment_file): $(help_file)
	$(vim_exec) -c 'set tw=9999' -c 'read $(help_file)' -c 'write $(VO_comment_file)' -c '1,/\* Current Release.*\n\s*/d' -c '/^|-\+|$$/,$$d' -c '%s/^\s*//' -c 'normal! gggqG' -c "silent! %s/'/\\'/g"

# Upload new version to vim.org.
# Depends on cURL.
$(VO_cookie_jar): $(VO_comment_file) zip
	@touch $(VO_cookie_jar)
	@echo logging in to vim.org...; read -sp "Enter username for vim.org: " userName; read -sp "Enter pasword for user '$(USER)': " pass; curl -b $(VO_cookie_jar) --cookie-jar $(VO_cookie_jar) --user-agent Mozilla/4.0 -e 'http://www.vim.org/login.php' -d "authenticate=true" -d "referrer=" -d "userName=$$userName" -d "password=$$pass" 'http://www.vim.org/login.php' > /dev/null
	@echo Uploading...; curl --referer '$(VO_scriptURL)' --cookie $(VO_cookie_jar) --user-agent Mozilla/4.0 -F 'MAX_FILE_SIZE=10485760' -F 'vim_version=$(VO_min_vim_version)' -F 'script_version=$(current_version)' -F 'script_file=@$(name_plus_version).zip' -F 'version_comment=$(shell cat $(VO_comment_file))' -F 'script_id=$(VO_scriptID)' -F 'add_script=upload' 'http://www.vim.org/scripts/add_script_version.php?script_id=$(VO_scriptID)' >/dev/null
	@printf 'Opening $(VO_scriptURL)...'; sleep 2; $(open_url) '$(VO_scriptURL)';printf " done.\n"

# Upload new version to GitHub downloads page.
# Depends on https://github.com/github/upload
$(GH_temp_file): release
	@read -p "Upload '$(name_plus_version).zip' to GitHub: (y/N) " yn; \
	if [ "$$yn" == "y" ]; \
	then for file in $(release_files); \
	do printf "Uploading \"$$file\" to GitHub..."; \
	github-upload $$file &>/dev/null || printf ""; \
	printf " done.\n" ; \
	done; \
	echo Opening '$(GH_project_URL)'; \
	$(open_url) $(GH_project_URL); \
	touch $(GH_temp_file); \
	fi

# Test stuff here.
echo:
	@echo $(all_files)
