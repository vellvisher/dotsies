all: init emaxcode silver_searcher global yasnippet

silver_searcher:
	which ag || brew install ag || apt-get install silversearcher-a

init:
	mkdir -p ~/.emacs.d
	python ../installer/copy_into.py init.el ~/.emacs.d/init.el "my-emacs" ";;"
	mkdir -p ~/.emacs.d/downloads/exec-path-from-shell
	curl https://raw.githubusercontent.com/purcell/exec-path-from-shell/master/exec-path-from-shell.el -o ~/.emacs.d/downloads/exec-path-from-shell/exec-path-from-shell.el || echo "No internet connection... skipping exec-path-from-shell.el install."
	mkdir -p ~/.emacs.d/downloads/company-async-files
	curl https://raw.githubusercontent.com/CeleritasCelery/company-async-files/master/company-async-files.el -o ~/.emacs.d/downloads/company-async-files/company-async-files.el || echo "No internet connection... skipping company-async-files.el install."
	mkdir -p ~/local/bin/
	cp emacssocket ~/local/bin/
	make -C ar
	make -C external
	make -C features

pylint:
	cp -i python/pylintrc ~/.pylintrc

global:
	cp -i global/.globalrc ~/

yasnippet:
	mkdir -p ~/.emacs.d/yasnippets
	cp -rf yasnippets/* ~/.emacs.d/yasnippets

yasxcode:
	mkdir -p ~/.emacs.d/yasnippets
	cd yasnippets/personal && python ../generate-xcode-yasnippets.py

emaxcode:
	curl https://raw.githubusercontent.com/ShingoFukuyama/emaXcode/master/emaXcode.el -o /tmp/emaXcode.el
	mkdir -p ~/.emacs.d/downloads/emaXcode
	mv /tmp/emaXcode.el ~/.emacs.d/downloads/emaXcode

ox-rss:
	curl http://orgmode.org/cgit.cgi/org-mode.git/plain/contrib/lisp/ox-rss.el -o /tmp/ox-rss.el
	mkdir -p ~/.emacs.d/downloads/ox-rss
	mv /tmp/ox-rss.el ~/.emacs.d/downloads/ox-rss

local_path := ~/local
ifeq ($(shell uname), Darwin)
  local_path := ~/homebrew
endif
rtags:
	rm -rf ~/.emacs.d/downloads/rtags
	git clone https://github.com/Andersbakken/rtags.git ~/.emacs.d/downloads/rtags
	cd ~/.emacs.d/downloads/rtags && git submodule init && git submodule update
	cd ~/.emacs.d/downloads/rtags && cmake . && make

rtags_setup:
	ln -s ~/.emacs.d/downloads/rtags/bin/gcc-rtags-wrapper.sh $(local_path)/bin/gcc
	ln -s ~/.emacs.d/downloads/rtags/bin/gcc-rtags-wrapper.sh $(local_path)/bin/c++
	ln -s ~/.emacs.d/downloads/rtags/bin/gcc-rtags-wrapper.sh $(local_path)/bin/cc
	ln -s ~/.emacs.d/downloads/rtags/bin/gcc-rtags-wrapper.sh $(local_path)/bin/g++

rtags_reset:
	rm -f $(local_path)/bin/gcc
	rm -f $(local_path)/bin/c++
	rm -f $(local_path)/bin/cc
	rm -f $(local_path)/bin/g++

ycmd_install:
	rm -rf ~/.emacs.d/downloads/ycmd
	git clone https://github.com/Valloric/ycmd.git ~/.emacs.d/downloads/ycmd
	cd ~/.emacs.d/downloads/ycmd && git submodule update --init --recursive
	cd ~/.emacs.d/downloads/ycmd && ./build.sh --clang-completer
