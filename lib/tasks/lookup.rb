class Lookup
  attr_accessor :nums, :pattern, :count_lines, :print_files
  TreeStruct = Struct.new(:path, :dirs, :files)

  def initialize(path)
    @pattern = ''
    @nums = { files: 0, lines: 0 }
    @print_files = false
    @count_lines = false
    @tree = dir_look(path)
  end

  def look(pattern, count_lines = false, print_files = true)
    # pattern = Regexp.new(pattern)
    @pattern = pattern
    @count_lines = count_lines
    @print_files = print_files
    @num_files = looking(@tree)
  end

  private

  def looking(tree, prefix = '', last = false)
    count = { files: 0, lines: 0 } # счетчики файлов и строк
    tag = last ? '└─ ' : '├─ '
    dir_name = prefix.empty? ? "#{tree.path}" : File.basename(tree.path) #tree.path.sub(/^.+\/(.??)/, '\1')
    puts prefix.empty? ? "#{dir_name}/" : "#{prefix}#{tag}#{dir_name}/"
    pre = prefix + (prefix.empty? ? ' ' : (last ? '   ' : '│  '))
    if File.readable?(tree.path)
      tree.dirs.each do |dir|
        last = dir == tree.dirs.last && (tree.files.empty? || !@print_files)
        tmp = looking(dir, pre, last)
        count[:files] += tmp[:files]
        count[:lines] += tmp[:lines] if @count_lines
      end
      tree.files.each do |file|
        last = file == tree.files.last 
        tag = last ? '└─ ' : '├─ '
        opt_str = ''
        if File.fnmatch(@pattern, file)
          count[:files] += 1
          opt_str += " * (#{count[:files]})" if @print_files
          if @count_lines
            line_count = 0
            # puts "#{tree.path}/#{file}"
            File.open("#{tree.path}/#{file}").each { |line| line_count += 1 }
            opt_str += " [+#{line_count}]" if @print_files
            count[:lines] += line_count
          end
        end
        puts ("#{pre}#{tag}#{file}" + opt_str) if @print_files
      end
      count[:files].tap do |c|
        # cute нверно лучше вынести в отдельный метод, но пусть пока так
        mod = c % 10
        cute_files = c > 10 && c < 20 || mod == 0 || mod >= 5 ? 'файлов' : (mod == 1 ? 'файл' : 'файла')
        opt_str = ''
        if count_lines # && tree == @tree
          mod = count[:lines] % 10
          cute_lines = c > 10 && c < 20 || mod == 0 || mod >= 5 ? 'строк' : (mod == 1 ? 'строка' : 'строки')
          opt_str = ", #{count[:lines]} #{cute_lines}" if count[:files] > 0
        end
        puts "#{pre}Всего [#{dir_name}]: #{c} ruby #{cute_files}" + opt_str 
      end
    else
      puts "#{pre} *** нет доступа! ***"
    end
    count
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
