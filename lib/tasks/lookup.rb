class Lookup
  attr_accessor :num_files, :num_lines, :pattern, :count_lines, :print_files
  TreeStruct = Struct.new(:path, :dirs, :files)

  def initialize(path)
    @pattern = ''
    @num_files = 0
    @num_lines = 0
    @print_files = false
    @count_strings = false
    @tree = dir_look(path)
  end

  def look(pattern, count_lines = false, print_files = true)
    # puts "Всего файлов '#{pattern}': #{looking(@tree, pattern)}"
    # pattern = Regexp.new(pattern)
    @pattern = pattern
    @count_lines = count_lines
    @print_files = print_files
    @num_files = looking(@tree)
  end

  private

  def looking(tree, prefix = '', last = false)
    file_count = 0  # счетчик файлов
    line_count = 0  # счетчик строк
    tag = last ? '└─ ' : '├─ '
    dir_name = prefix.empty? ? "#{tree.path}" : File.basename(tree.path) #tree.path.sub(/^.+\/(.??)/, '\1')
    puts prefix.empty? ? "#{dir_name}/" : "#{prefix}#{tag}#{dir_name}/"
    pre = prefix + (prefix.empty? ? ' ' : (last ? '   ' : '│  '))
    if File.readable?(tree.path)
      tree.dirs.each do |dir|
        last = dir == tree.dirs.last && (tree.files.empty? || !@print_files)
        file_count += looking(dir, pre, last)
      end
      tree.files.each do |file|
        last = file == tree.files.last 
        tag = last ? '└─ ' : '├─ '
        opt_str = ''
        if File.fnmatch(@pattern, file)
          file_count += 1
          opt_str += " * (#{file_count})" if @print_files
          if @count_lines
            line_count = 0
            # puts "#{tree.path}/#{file}"
            File.open("#{tree.path}/#{file}").each { |line| line_count += 1 }
            opt_str += " [+#{line_count}]" if @print_files
            @num_lines += line_count
          end
        end
        puts ("#{pre}#{tag}#{file}" + opt_str) if @print_files
      end
      file_count.tap do |c|
        # cute тоже нверно лучше вынести в отдельный метод, пусть пока так
        mod = c % 10
        cute_files = c > 10 && c < 20 || mod == 0 || mod >= 5 ? 'файлов' : (mod == 1 ? 'файл' : 'файла')
        opt_str = ''
        if count_lines && tree == @tree
          mod = @num_lines % 10
          cute_lines = c > 10 && c < 20 || mod == 0 || mod >= 5 ? 'строк' : (mod == 1 ? 'строка' : 'строки')
          opt_str = ", #{@num_lines} #{cute_lines}"
        end
        puts "#{pre}Всего [#{dir_name}]: #{c} ruby #{cute_files}" + opt_str 
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
