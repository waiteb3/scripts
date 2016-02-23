### Bash
```bash
ln -s $HOME/shared/bash/aliases .bash_aliases
```

### VIM
```bash
ln -s $HOME/shared/.vimrc .vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall
```

### GPG
```bash
gpg -o backups.tar -d backups.tar.gpg 
tar xf backups.tar
mv <file> backups/
tar cf backups.tar backups
gpg -c backups.tar
rm -rf backups/ backups.tar
```
