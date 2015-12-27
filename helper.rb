class Helper

  def cleanup_dst
    path = File.join(Dir.pwd, 'dst')
    FileUtils.rm_rf(path)
    FileUtils.mkdir('dst')
  end

  # prepare vars to be used in erb files
  def prepare_variables(erb_vars)
    return OpenStruct.new(erb_vars).instance_eval { binding }
  end

  def concat_commands(global_cmds, commands)
    return global_cmds + ' && ' + commands.join(' && ')
  end

  # params: f is the path at yml file
  def read_file(f, erb_vars)
    path = File.join(Dir.pwd, f)
    file = File.new(path, 'r')
    variables = prepare_variables( erb_vars )
    file_content = path.end_with?('.erb') ? ERB.new( file.read ).result( variables ) : file.read
    file.close
    file_content
  end

  # params: f is the path at yml file (needed to get the name of the file)
  def write_file(f, content)
    file_name = f.slice(f.rindex('/') + 1, f.length).chomp('.erb')
    path = File.join(Dir.pwd, 'dst', ".#{file_name}")
    file = File.new(path, "a+")
    file.write(content)
    file.close
    return file
  end

  # in every package the .files keys is passed here as file_paths
  # each one has path, sym (the path is the current path)
  # and the sym is the symbolic link location
  def setup_and_dst_files(files_paths, erb_vars)
    files_paths.each_key do |k|
      f = files_paths[k]
      file = write_file(f['path'], read_file(f['path'], erb_vars))
      # TODO: separate method
      sym_ln = File.expand_path(f['sym'])
      FileUtils.mkdir_p sym_ln unless File.exists? sym_ln
      sym_ln = File.join(sym_ln, File.basename(file.path))
      FileUtils.ln_sf File.absolute_path(file), sym_ln
    end
  end

  # write every key in the package that start with .
  # .xyz to .xyz file with sym link location always equal to
  # dotfiles_loc
  def write_hash(files_hash, paths)
    # { .zshrc: {....}, .xyz: {.....}}
    files_hash.each_key do |file_name|
      path = File.join(Dir.pwd, 'dst', file_name)
      # TODO: separate method
      unless File.exist? path
        unexpanded_path = paths.has_key?(file_name) ? paths[filename] : paths['default']
        expanded_sym_path = File.expand_path(unexpanded_path)
        sym_ln = File.join(expanded_sym_path, file_name)
        FileUtils.mkdir_p expanded_sym_path
        FileUtils.ln_sf path, sym_ln
      end
      f = File.new(path, 'a+')
      f.write files_hash[file_name]
      f.close
    end
  end

  # install a package by routing the data in the yml correctly
  # where .files are templated, copied and symlinked to dst
  def install_package(package, global_cmds, execute)
    files, erb_vars, commands = {}, {}, []
    ret = {}
    package.each_key do |k|
      case k
        when '.files'
          files = package[k]
        when 'erb_vars'
          erb_vars = package[k]
        when 'commands'
          commands = package[k]
        else
          ret[k] = (ret[k] || '') + package[k].join("\n") + "\n"
      end
    end
    # run the commands
    %x[#{concat_commands(global_cmds, commands)}] unless (commands.empty? || !execute)
    # read and write the files with the erb_vars array
    setup_and_dst_files(files, erb_vars)
    return ret
  end

  def prompt_user(all_options)
    puts "Select the numbers that you which to install or enter all to install everything (may take a while)"
    all_options.each.with_index do |package, i|
      puts "#{i+1}. Install/Configure #{package}"
    end
    puts 'Answer format: 1,9 OR 1,3-6,8-10 OR all'
    answer = gets
    parse_answer answer.chomp("\n"), all_options.length
  end

  # use scmpuff format 1,3,4-7 => 1,3,4,5,6,7
  def parse_answer(ans, max_options)
    return (1..max_options+1).to_a if ans.downcase == 'all'
    selected_options = ans.split(',')
    selected_options.each.with_index do |o, i|
      unless o.index('-').nil?
        o = o.split('-')
        selected_options << (o.first..o.last).to_a
        selected_options.slice!(i)
      end
    end
    selected_options.flatten!
    selected_options.reject { |o| (o.to_i > max_options || o.to_i < 0) }
  end

  def install_extras(extra)
    abs_path = File.join(Dir.pwd, extra['file'])
    f = File.new abs_path, 'r'
    extra_packages = f.read.split("\n")
    extra_packages.each do |line|
      next if line.start_with? "#"
      cmd = extra['command'] + ' ' + line
      %x[#{cmd}]
    end
  end

  def merge_hashes_with_concatenation(h1, h2)
    ret = h1
    h2.each_key do |k|
      ret[k] = h1[k].nil? ? h2[k] : h1[k] + "\n" + h2[k]
    end
    return ret
  end

end
