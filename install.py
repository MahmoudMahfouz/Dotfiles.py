#!/usr/bin/env python
import argparse
import errno
import logging
import os
import platform
import shutil
import subprocess
import yaml
# import pdb

from mako.template import Template


cwd = os.getcwd()

logging.getLogger().setLevel(logging.INFO)


class Helper:

    def create_sym_link(self, src_path, dst_path):
        try:
            dirname = os.path.dirname(dst_path)
            if not os.path.exists(dirname):
                os.makedirs(dirname)
            if os.path.exists(dst_path):
                os.remove(dst_path)
            if dst_path.endswith('.mako'):
                dst_path = dst_path.replace('.mako', '')

            os.symlink(src_path, dst_path)
            logging.debug("Created link from: %s to: %s", src_path, dst_path)
        except OSError as exc:  # Python >2.5
            if exc.errno == errno.EEXIST:
                logging.warning("Already exists %s", str(exc))
                os.remove(dst_path)
                os.symlink(src_path, dst_path)
            else:
                raise

    def flatten_array(self, arr):
        ret = []
        for item in arr:
            if type(item) is list or type(item) is range:
                for elem in item:
                    ret.append(int(elem))
            else:
                ret.append(int(item))
        return ret

    def merge_and_concat_hashes(self, h1, h2):
        ret = h1
        for k in h2.keys():
            if h1.get(k):
                ret[k] = h1[k] + '\n' + h2[k]
            else:
                ret[k] = h2[k]
        logging.debug("Hash1 %s, Hash2 %s, Merged hashes %s",
                      str(h1), str(h2), str(ret))
        return ret

    def cleanup_dst(self):
        path = os.path.join(cwd, 'dst')
        shutil.rmtree(path)
        os.mkdir('dst')

    def expand_path(self, path):
        return os.path.abspath(os.path.expanduser(path))

    def concat_commands(self, global_cmds, commands):
        return global_cmds + ' && ' + ' && '.join(commands)

    def prompt_user(self, all_options):
        print("Select the numbers that you which to install")
        for i, package in enumerate(all_options):
            print("{0}. Install/Configure {1}".format(str(i+1), package))

        answer = input('Answer format: 1,9 OR 1,3-6,8-10 OR all')
        return self.parse_answer(answer, len(all_options))

    # use scmpuff format 1,3,4-7 => 1,3,4,5,6,7
    def parse_answer(self, ans, max_options):
        if ans.lower() == 'all':
            return range(1, max_options+1, 1)

        selected_options = ans.split(',')
        for i, value in enumerate(selected_options):
            if '-' in value:
                st, end = value.split('-')
                selected_options[i] = range(int(st),
                                            int(end) + 1)

        # Flatten the array
        flattened_arr = self.flatten_array(selected_options)
        ret = [ops for ops in flattened_arr
               if ops <= max_options and ops > 0]
        logging.debug("Answer array %s", str(ret))
        return ret

    # params: f is the path at yml file
    def parse_template(self, f, template_vars):
        path = os.path.join(cwd, f)
        f = open(path, "r")
        content = f.read()
        logging.debug('Reading file with vars %s', str(template_vars))
        if path.endswith('.mako'):
            template = Template(content)
            content = template.render(**template_vars)
        f.close()
        # logging.trace("File content: %s", content)
        return content

    # params: f is the path at yml file (needed to get the name of the file)
    def write_file_to_dst(self, path, content):
        file_name = os.path.basename(path).replace('.mako', '')

        path = os.path.join(cwd, 'dst', file_name)
        file = open(path, "w")
        file.write(content)
        file.close()
        return path

    # in every package the .files keys is passed here as file_paths
    # each one has path, sym (the path is the current path)
    # and the sym is the symbolic link location
    def setup_and_dst_files(self, files_paths, template_vars):
        for k, f in files_paths.items():
            content = self.parse_template(f['path'], template_vars)
            src_path = self.write_file_to_dst(f['path'], content)
            dst_path = os.path.join(self.expand_path(f['sym']),
                                    os.path.basename(f['path']))
            logging.debug("Src is %s, dst is %s and f[k] %s",
                          src_path, dst_path, f)
            self.create_sym_link(src_path, dst_path)

    # write every key in the package that start with .
    # .xyz to .xyz file with sym link location always equal to
    # dotfiles_loc
    def write_hash_to_file(self, files_hash, paths):
        # { .zshrc: {....}, .xyz: {.....}}
        for k, v in files_hash.items():
            src_path = os.path.join(cwd, 'dst', k)
            f = open(src_path, 'a')
            f.write(v)
            f.close()

            dst_dir = self.expand_path(paths.get(k, paths['default']))
            dst_path = os.path.join(dst_dir, k)
            self.create_sym_link(src_path, dst_path)

    def build_hash_of_custom_keys(self, package):
        ret = {}
        for k in package.keys():
            if k != '.files' and k != 'template_vars' and k != 'commands':
                ret[k] = (ret.get(k) or '') + '\n'.join(package[k]) + "\n"

        return ret

    # install a package by routing the data in the yml correctly
    # where .files are templated, copied and symlinked to dst
    def install_package(self, package):
        files, template_vars, commands = {}, {}, []
        for k in package.keys():
            if k == '.files':
                files = package[k]
            elif k == 'template_vars':
                template_vars = package[k]
            elif k == 'commands':
                commands = package[k]

        logging.debug("files are %s", str(files))
        logging.debug("Template_vars are %s", str(template_vars))
        logging.debug("Commands are %s", str(commands))

        # read and write the files with the template_vars array
        self.setup_and_dst_files(files, template_vars)

        return commands

    def run_commands(self, commands, global_cmds, args):
        # run the commands
        if commands and args.execute:
            if getattr(args, 'continue'):
                commands = ["({0} || True)".format(c)
                            for c in commands]
            cmd = self.concat_commands(global_cmds, commands)
            logging.debug('Running command %s', cmd)
            self.execute(cmd)

    def execute(self, cmd):
        try:
            subprocess.check_output(cmd,
                                    shell=True,
                                    stdin=subprocess.PIPE)
        except Exception as e:
            logging.error("Running cmd %s failed %s", cmd, str(e))

    def install_extras(self, extra, args):
        abs_path = os.path.join(cwd, extra['file'])
        f = open(abs_path, 'r')
        extra_packages = f.readlines()
        if args.execute:
            for pkg in extra_packages:
                if pkg and not pkg.startswith('#'):
                    cmd = extra['command'] + ' ' + pkg.rstrip()
                    if getattr(args, 'continue'):
                        cmd = ["({0} || True)".format(cmd)]

                    self.execute(cmd)


def define_args():
    description = "Install dotfiles"
    parser = argparse.ArgumentParser(description=description)

    parser.add_argument('-e', '--execute', action='store_true',
                        help="Whether to execute commands or not")
    parser.add_argument('-c', '--continue', action='store_true',
                        help="Crash the script on fail or not")
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="Set logger to verbose")

    args = parser.parse_args()
    return args


def get_conf_path():
    current = platform.system()
    if current == 'Darwin':
        return 'install_mac.yml'
    else:
        return 'install_linux.yml'


def main():
    args = define_args()
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    conf_path = get_conf_path()

    h = Helper()
    with open(conf_path, 'r') as stream:
        try:
            conf = yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    # export some variables that will be prepended to every command running
    # useful as nvm_path, ruby_path,...
    global_cmds = ' && '.join(str(cmd) for cmd in conf['main']['commands'])
    extras = conf['main']['extras']
    installs = conf['installs']
    all_options = list(conf['installs'].keys()) + list(extras.keys())
    main_exports = [cmd for cmd in conf['main']['commands']
                    if cmd.startswith('export ')]

    selected_installs = h.prompt_user(all_options)

    # clean up the dst directory
    if min(selected_installs) < len(conf['installs'].keys()):
        h.cleanup_dst

    # this will contains the aggregation of all the keys that
    # start with .except .files
    dotfiles_hash = {}
    dotfiles_hash.setdefault('.exports', '')

    # The main loop
    # loop over the main keys => packages
    # in every package get the list of keys (.files, commands,...) and use it
    for i, package in enumerate(installs.keys()):
        custom_keys = h.build_hash_of_custom_keys(installs[package])
        dotfiles_hash = h.merge_and_concat_hashes(dotfiles_hash,
                                                  custom_keys)
        commands = h.install_package(installs[package])

        if (i+1) in selected_installs:
            logging.debug("Installer %s", package)
            logging.info("Now Installing %s\n===========================",
                         package)
            h.run_commands(commands, global_cmds, args)

            logging.info("Done!")

    # write the dotfiles_hash to their corresponding files
    # .export to .export file .xyz to .xyz file
    dotfiles_hash['.exports'] += '\n' + '\n'.join(str(e) for e in main_exports)
    logging.debug("combined hash %s", str(dotfiles_hash))
    h.write_hash_to_file(dotfiles_hash, conf['main']['paths'])

    for i, k in enumerate(extras.keys()):
        # shift the index by packages number in the yml file
        counter = i + len(conf['installs'].keys()) + 1
        if (counter) in selected_installs:
            logging.info("Now Installing %s\n===========================", k)
            logging.info(extras[k])
            h.install_extras(extras[k], args)
            logging.info("Done!")
    logging.info("Finished dotfiles installation!")


# # IF INSTALLING vim using brew (latest version)
# # sudo mv /usr/bin/vim /usr/bin/oldvim
# # ln -s /usr/local/bin/vim /usr/bin/vim
# # also if using brew on multiple users
# # sudo chgrp -R brew {/usr/local,/Library/Caches/Homebrew}
# # && sudo chmod -R g+w {/usr/local,/Library/Caches/Homebrew} && brew doctor
if __name__ == '__main__':
    main()
