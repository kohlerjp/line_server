#!/usr/bin/env bash

# This script attempts to install erlang and elixir for Mac OSX
# using the asdf version manager. Details on installing Elixir can
# be found at https://elixir-lang.org/install.html
# Please let me know if you have any problems with this


git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.5.1

echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile # .bashrc for linux
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile

source ~/.bash_profile

# install erlang 21.1
asdf plugin-add erlang
asdf install erlang 21.1
asdf global erlang 21.1

# install elixir 1.5.1
asdf plugin-add elixir
asdf install elixir 1.5.1
asdf global elixir 1.5.1


# Alternative build bath for Homebrew
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # install homebrew
# brew update
# brew install elixir
# mix local.hex


