require 'tuplex'
require 'lmdb'
require 'tmpdir'

include Tuplex

dir = Dir.mktmpdir
env = LMDB.new dir
db = @db = env.database("tuples", create: true, dupsort: true)

def store t
  @db[make_key(t)] = make_val(t)
end

(1..10).to_a.shuffle.each do |i|
  store [1, 2, i]       # same signature for each i
  store a: "foo", b: i  # same signature for each i, but different from above
  store i => nil        # different signature for each i
end

puts "\n\nIterating..."
db.each do |k,v|
  p unpack_val(v)
end

puts "\n\nSearching..."
db.each do |k,v|
  if val_equals_tuple(v, [1, 2, 5])
    puts "found!"
  end
end
