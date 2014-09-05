require 'tuplex'
require 'lmdb'
require 'tmpdir'

include Tuplex

dir = Dir.mktmpdir
env = LMDB.new dir
db = env.database("tuples", create: true)

t = {a: 1, b: 2}
db[make_key(t)] = make_val(t)

p db.map {|k,v| [k, unpack_val(v)]}
