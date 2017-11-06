require 'yaml'
require 'erb'
require 'ostruct'
require 'fileutils'
require './helper'

module OS
  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.linux?
   (/linux/ =~ RUBY_PLATFORM) != nil
  end
end

conf_path = OS.mac? ? 'install_mac.yml' : 'install_linux.yml'

h = Helper.new
conf = YAML.load_file(conf_path)

# export some variables that will be prepended to every command running
# useful as nvm_path, ruby_path,...
global_cmds = conf['main']['commands'].join(' && ')
execute = conf['main']['options']['execute']
extras = conf['main']['extras']
installs = conf['installs']
all_options = conf['installs'].keys + extras.keys
main_exports = conf['main']['commands'].select { |cmd| cmd.start_with?('export ') }

selected_installs = h.prompt_user(all_options)

# clean up the dst directory
h.cleanup_dst if selected_installs.min.to_i < conf['installs'].keys.length

# this will contains the aggregation of all the keys that start with . except .files
dotfiles_hash = {}

# The main loop
# loop over the main keys => packages
# in every package get the list of keys (.files, commands,...) and use it
installs.each_key.with_index do |package, i|
  next unless selected_installs.include? (i+1).to_s
  puts "Now Installing #{package}"
  puts "=========================="
  dotfiles_hash = h.merge_hashes_with_concatenation dotfiles_hash, h.install_package(installs[package], global_cmds, execute)
  puts "Done"
end

# write the dotfiles_hash to their corresponding files
# .export to .export file .xyz to .xyz file
dotfiles_hash['.exports'] = main_exports.join("\n") + "\n" + (dotfiles_hash['.exports'] || '')
h.write_hash(dotfiles_hash, conf['main']['paths'])

extras.each_key.with_index do |k, i|
  counter = i + conf['installs'].keys.length + 1 # shift the index by packages number in the yml file
  next unless selected_installs.include? (counter).to_s
  puts "Now Installing #{k}"
  puts "=========================="
  puts extras[k]
  h.install_extras extras[k]
  puts "Done"
end
puts "Finished dotfiles installation"

# # IF INSTALLING vim using brew (latest version)
# # sudo mv /usr/bin/vim /usr/bin/oldvim
# # ln -s /usr/local/bin/vim /usr/bin/vim
# # also if using brew on multiple users
# # sudo chgrp -R brew {/usr/local,/Library/Caches/Homebrew} && sudo chmod -R g+w {/usr/local,/Library/Caches/Homebrew} && brew doctor
