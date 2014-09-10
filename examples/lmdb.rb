require 'tuplex'
require 'lmdb'
require 'tmpdir'

TPX = Tuplex.new

dir = Dir.mktmpdir
env = LMDB.new dir
db = env.database("tuples", create: true, dupsort: true)

t = {a: 1, b: 2}
db[TPX.make_key(t)] = TPX.make_val(t)

p db.map {|k,v| [k, TPX.unpack_val(v)]}
