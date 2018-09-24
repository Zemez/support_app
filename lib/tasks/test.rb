require_relative 'lookup'

# a = Lookup.new('../..')
path = ARGV[0] ? ARGV[0] : '.'
pattern = ARGV[1] ? ARGV[1] : '*.rb'

tree = Lookup.new(path)

tree.look(pattern, true, false)
# tree.look(/.+\.rb$/)
# tree.look('*.rb')
