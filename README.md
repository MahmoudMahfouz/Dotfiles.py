# Dotfiles.py
Having a good dotfiles is a must for every Developer. It can save us days and even weeks of reconfiguring our machine in case of OS crash
or even migrating to a new machine.

Dotfiles.py is the simplest yet a very configurable dotfiles which is very helpful because no one developer machine is like the other
and we all need our own modifications and customizations. Customizing your dotfiles using the Dotfiles.py is super easy you just have 1 file for your configurations (install.yml). It is inspired by YAML configuration of Ansible (easy and efficient).

## How to use it:
1. Clone the repo
2. `pip3 install -r requirements.txt`
3. run `python3 install.py -e -c`
4. Done !

## How to configure it:
The main part of the dotfiles is the `install.yml` file which will have all your configurations that you need.

## Example structure of the `install.yml`:

```
# This part is for some common commands, variables and extras e.g: gems, npms, etc.
main:
  # Use it as global variables they are prepended with every install command section
  commands:
  - export dotfiles_path=$HOME/.dotfiles
  - export vim_path=$dotfiles_path/.vim
  - if [[ -f "$HOME/.asdf/asdf.sh" ]]; then . $HOME/.asdf/asdf.sh; fi

  # This section hold list of extras to be installed
  # The key names are gonna be a list of options to select from when you run the py script ex: Gem(s)
  # each section has `file` to have the list of packages and the `command` will be prepended to it
  extras:
    Brew package(s):
      command: brew install
      file: extras/brewfile
    Cask program(s):
      command: brew cask install
      file: extras/caskfile
    Defaults settings (Mac OSX):
      command: defaults write
      file: extras/defaultsfile
    Gem(s):
      command: gem install --no-ri --no-rdoc
      file: extras/gemfile
    npm(s):
      command: npm i -g
      file: extras/npmfile
    pip(s):
      command: pip3 install
      file: extras/pipfile
  paths:
    default: ~/.dotfiles
    .zshrc: ~/

# The key names are gonna be a list of options to select from when you run the py script ex: else or git
# subkeys:
# .files => Will create a sym link pointing to the file in the `path` key, and will be in the `sym` location
#           the files also could be mako templates and gets the variables from key `template_vars`
# .<zshrc|exports|path> => will be all combined together in a single file = .<NAME> in the
#                          path specified by `main.paths.zshrc` for `.zshrc` else in `main.paths.default`
# commands => is an array of commands to be executed.
installs:
  else:
    .files:
      editor:
        path: general/.editorconfig
        sym: ~/
      tmux-conf:
        path: general/.tmux.conf
        sym: ~/
    .zshrc:
    - . $HOME/.asdf/asdf.sh
    - . $HOME/.asdf/completions/asdf.bash
    commands:
    - xcode-select --install
      # - sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
      # - ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    - git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
    - curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/darwin/amd64/aws-iam-authenticator
    - chmod +x ./aws-iam-authenticator
    - mkdir -p $HOME/bin
    - mv ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH

  git:
    .files:
      gitconfig:
        path: git/.gitconfig.mako
        sym: ~/
      gitignore:
        path: git/.gitignore
        sym: ~/
    template_vars:
      name: Mahmoud Mahfouz
      email: anyone@anywhere.com
      editor: vim

  asdf-golang:
    commands:
    - asdf plugin-add golang
    - asdf install golang 1.10.2 && asdf global golang 1.10.2
  asdf-ruby:
    commands:
    - asdf plugin-add ruby
    - asdf install ruby 2.4.1 && asdf global ruby 2.4.1
  asdf-nodejs:
    commands:
    - asdf plugin-add nodejs
    - bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
    - export NODEJS_CHECK_SIGNATURES=no && asdf install nodejs 7.6.0 && asdf global nodejs 7.6.0
  asdf-python:
    commands:
    - asdf plugin-add python
    - env PYTHON_CONFIGURE_OPTS="--enable-framework" asdf install python 3.7.2 && asdf install python 2.7.15 && asdf global python 3.7.2

  terminal:
    .files:
      aliases:
        path: terminal/.aliases
        sym: ~/.dotfiles
      functions:
        path: terminal/.functions
        sym: ~/.dotfiles
      profile:
        path: terminal/.profile
        sym: ~/.dotfiles
      prompt:
        path: terminal/.prompt
        sym: ~/.dotfiles
    .exports:
    - export ANDROID_HOME=/usr/local/Cellar/android-sdk/24.3.3/
    - export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    - export PATH=/usr/local/sbin:/usr/local/bin:$PATH
    - export PATH=$rbenv_path/shims:$rbenv_path/bin:$PATH
    - export PATH=/opt/chefdk/bin:$PATH
    - export PATH=$HOME/bin:$PATH

  tmuxinator:
    .files:
      coder.yml:
        path: tmuxinator/coder.yml
        sym: ~/.tmuxinator/
      landscape.yml:
        path: tmuxinator/landscape.yml
        sym: ~/.tmuxinator/
      portrait.yml:
        path: tmuxinator/portrait.yml
        sym: ~/.tmuxinator/
  vim:
    .files: # will use template_vars from the current object
      vimrc:
        path: vim/.vimrc.mako
        sym: ~/
      vim-settings:
        path: vim/.vim-settings.mako
        sym: ~/.dotfiles
    .exports:
    - export vim_path=$vim_path
    - export EDITOR=vim
    commands:
    - if [[ -e $vim_path/bundle ]]; then rm -rf $vim_path/bundle; fi
    - git clone https://github.com/gmarik/Vundle.vim.git $vim_path/bundle/Vundle.vim
    - vim -E -u NONE -S ~/.vimrc +PluginInstall +qall > /dev/null
    - cd $vim_path/bundle/YouCompleteMe/ && ./install.py --clang-completer
    template_vars:
      vim_path: $dotfiles_path/.vim
      dotfiles_path: $dotfiles_path

  zsh:
    .files:
      zshrc:
        path: zsh/.zshrc
        sym: ~/
    .exports:
    - export ZSH=$dotfiles_path'/zsh'
    - export ZSH_THEME="pygmalion"
    - export powerline="$HOME/.local/lib/python2.7/site-packages/powerline"
    - export LC_ALL=en_US.UTF-8
    - export LANG=en_US.UTF-8
    - export TERM=screen-256color
    commands:
    - export ZSH=$dotfiles_path'/zsh'; if [[ -e $ZSH ]]; then rm -rf $ZSH; fi; curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
    - cd $ZSH/themes
    - git clone https://github.com/KuoE0/oh-my-zsh-solarized-powerline-theme.git solarized-powerline
    - cd solarized-powerline
    - ln -s $PWD/solarized-powerline.zsh-theme $ZSH/themes
    - cd $ZSH/ && git clone https://github.com/tarjoilija/zgen.git
```
## known limitation:
1. can't make partial updates on a dotfile
