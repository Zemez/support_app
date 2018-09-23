class Lookup
  # attr_accessor :tree
  TreeStruct = Struct.new(:path, :dirs, :files)

  def initialize(path)
    @tree = dir_look(path)
  end

  def look(pattern, print_files = true)
    # puts "Всего файлов '#{pattern}': #{looking(@tree, pattern)}"
    # pattern = Regexp.new(pattern)
    looking(@tree, pattern, print_files)
  end

  private

  def looking(tree, pattern, print_files, prefix = '', last = false)
    count = 0
    tag = last ? '└─ ' : '├─ '
    dir_name = prefix.empty? ? "#{tree.path}" : File.basename(tree.path) #tree.path.sub(/^.+\/(.??)/, '\1')
    puts prefix.empty? ? "#{dir_name}/" : "#{prefix}#{tag}#{dir_name}/"
    pre = prefix + (prefix.empty? ? ' ' : (last ? '   ' : '│  '))
    if File.readable?(tree.path)
      tree.dirs.each do |dir|
        last = dir == tree.dirs.last && (tree.files.empty? || !print_files)
        count += looking(dir, pattern, print_files, pre, last)
      end
      tree.files.each do |file|
        last = file == tree.files.last 
        tag = last ? '└─ ' : '├─ '
        if print_files
          puts "#{pre}#{tag}#{file}" + ((File.fnmatch(pattern, file) && count += 1) ? " + (#{count})" : '')
        else
          count += 1 if pattern =~ file
        end
      end
      count.tap do |c|
        mod = c % 10
        cuter = c > 10 && c < 20 || mod == 0 || mod >= 5 ? 'файлов' : (mod == 1 ? 'файл' : 'файла') 
        puts "#{pre}Всего [#{dir_name}]: #{c} #{cuter}"
      end
    else
      puts "#{pre} *** нет доступа! ***"
      0 # access denied
    end
  end

  def dir_look(path)
    dirs = []
    files = []
    Dir.foreach(path) do |file|
      target = "#{path}/#{file}"
      dirs << dir_look(target) if File.directory?(target) && File.readable?(target) && !file.match(/^\.+$/)
      files << file if File.file?(target)
    end
    TreeStruct.new(path, dirs.sort_by(&:path), files.sort)
  end
end
