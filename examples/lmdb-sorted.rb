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

puts "\n\nIterating"
db.each do |k,v|
  p unpack_val(v)
end

print "\n\nSearching"
db.each do |k,v|
  print "."
  if val_equals_tuple(v, [1, 2, 5])
    print "found!"
    break
  end
end
puts

print "\n\nFast lookup"
t = [1, 2, 5]
th = make_val_hash(t) # optimization
key = make_key(t)
db.cursor do |c|
  k, v = c.set_range(key)
  while k == key
    print "."
    if val_equals_tuple(v, t, th)
      print "found!"
      break
    end
    k, v = c.next
  end
  puts
end
