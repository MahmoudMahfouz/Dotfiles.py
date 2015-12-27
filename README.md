# Dotfiles.rb
=============
Having a good dotfiles is a must for every Developer. It can save us days and even weeks of reconfiguring our machine in case of OS crash
or even migrating to a new machine.

Dotfiles.rb is the simplest yet a very configurable dotfiles which is very helpful because no one developer machine is like the other
and we all need our own modifications and customizations. Customizing your dotfiles using the Dotfiles.rb is super easy you just have 1 file for your configurations (install.yml). It is inspired by YAML configuration of Ansible (easy and efficient).

## How to use it:
=================
1. Clone the repo
2. run `ruby install.rb`
3. Done !

## How to configure it:
=======================
The main part of the dotfiles is the `install.yml` file which will have all your configurations that you need.

##The structure of the `install.yml`
=====================================
```
main:
  # an array of commands to be prepended to every commands array in every package in the installs key useful for global exports
  commands:
  options:
    # whether or not to execute shell commands
    # useful when you want to change something in a rc file or a configuration and you just want to update the files (and it is very fast)
    execute: true
  extras:
    [name]:
      command: # prefix every line with this option and execute
      path: # relative path to the extras file
  paths:
    default: # the location to save the dotfiles sym links
    [anything]: #location

installs:
  # what every name you need to identify and group your packages ex: Node.js:
  # also note that this name will be used in the prompt in the start of the install.rb
  [name]:
    .files:
      # all files will be concatenated together to the ./dst directory
      # ex: if you have 2 packages and each one has
      [whatever]:
        path: # the path of the current file relative install.rb
        sym: # the final location of the symbolic link whether ~/ OR ~/my_new_dotfiles OR ~/anything
      [whatever.erb]:
        # the main difference is this is a template file that will use the erb_vars to generate the file
        # the path of the current file relative install.rb
        path: folder/file.erb
        sym: # the final location of the symbolic link whether ~/ OR ~/my_new_dotfiles OR ~/anything

    # similar to commands but themain difference is that it is persisted to .exports file
    .exports:
    - export ...
    - export ...
    erb_vars:
      [git_name]: Mahmoud Mahfouz

    # will create a file having all the lines from all the [anything] tags in all the packages
    [anything]:
    - # source file1
    - # source file2

    commands:
    # array of commands that will be appended to the main > commands and then executed
    - export v=1.0
    - echo $v

```

