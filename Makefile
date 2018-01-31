PLUG=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

all:
	mkdir -p autoload
	mkdir -p bundle
	touch ~/.vim/config/vimrc.user
	curl -kfLo ~/.vim/autoload/plug.vim --create-dirs $(PLUG)
	vim +PlugInstall +qall

update:
	git stash
	git pull
	git clean -fdx -eswap -eundo -eautoload -ebundle -eplugged -espell
	rm -rf swap/* undo/* autoload/* bundle/* plugged/* spell/*
	vim +PlugInstall +qall

.PHONY: update
