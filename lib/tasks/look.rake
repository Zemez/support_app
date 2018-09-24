require_relative 'lookup'

namespace :look do

	desc 'Поиск и подсчет ruby файлов, в качестве аргумента можно передать начальный путь'
	task :rbfiles, [:path] => [:environment]  do |_t, arg|
	  path = arg[:path] ? arg[:path] : '.'
	  tree = Lookup.new(path.to_s)
	  tree.look('*.rb')
	end

	desc 'Поиск ruby файлов и подсчет кол-ва строк в них, в качестве аргумента можно передать начальный путь'
	task :rblines, [:path] => [:environment]  do |_t, arg|
	  path = arg[:path] ? arg[:path] : '.'
	  tree = Lookup.new(path.to_s)
	  tree.look('*.rb', true)
	end

end
