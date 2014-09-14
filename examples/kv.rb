# Tuplex maps tuples into a key-value store. So what if you want
# want to use tuples as key-value pairs?
#
# There are several choices, but an especially good one is to
# represent a k,v pair as {k: v} rather than as [k, v]. The former
# puts k into the non-sorted (hashed) part of the key, leaving the
# sorted part of the key to the value. This is better if you know that
# you don't need range queries over keys. With {k: v} you have same
# key-lookup performance as the underlying kv store (in this case
# lmdb), plus you can do efficient range queries over v.
#
# You can represent multikey items in one of these forms:
#   {k1: {k2: v}}
#   {[k1,k2]: v}
#   {k1: nil, k2: v}

require 'tuplex'
require 'lmdb'
require 'tmpdir'

TPX = Tuplex.new

dir = Dir.mktmpdir
LMDB_ENV = LMDB.new dir
db = LMDB_ENV.database("kvs", create: true)
  # dupsort: true <-- unless you want to merge

def db.insert *tuples
  LMDB_ENV.transaction do
    tuples.each do |t|
      put TPX.make_key(t), TPX.make_val(t)
    end
  end
end

def db.exists? t
  get(TPX.make_key(t)) != nil
end

def db.each
  super do |k, v|
    yield TPX.unpack_val(v)
  end
end

# Note that we must specify a single key value for efficient range searches.
# specialized to String vals
def db.find_in_range key, v_low, v_high
  cursor do |c|
    k_high = TPX.make_key(key => v_high)
    k, v = c.set_range(TPX.make_key(key => v_low))
    while k and k <= k_high # replace with next_range when lmdb gem has it
      h = TPX.unpack_val(v)
      if h.kind_of? Hash and h.keys == [key.to_s] and h[key.to_s].kind_of? String
        return h
      end
      k, v = c.next
    end
  end
  return nil
end

db.insert key1: "hello-key1" # sorts separately from the key2 tuples below
db.insert key2: "hello"
db.insert key2: "z"
db.insert key2: "a"

puts "db in tuplex-sorted order:"
db.each {|t| printf("%20s: %s\n", *t.flatten)}

puts
puts "in key2, between 'hello' and 'z':"
p db.find_in_range :key2, "hello", "z"
puts "in key2, between 'hello-key1' and 'z':"
p db.find_in_range :key2, "hello-key1", "z"

# specialized to Numeric vals
def db.find_all_in_multirange keys, t_low, t_high
  t_low = t_low.inject({}) {|h,(key,value)| h[key.to_s] = value; h}
  t_high = t_high.inject({}) {|h,(key,value)| h[key.to_s] = value; h}
  keys = keys.map {|key| key.to_s}.sort

  cursor do |c|
    k_low  = TPX.make_key(t_low)
    k_high = TPX.make_key(t_high)
    k, v = c.set_range(k_low)
    while k and k <= k_high # replace with next_range when lmdb gem has it
      h = TPX.unpack_val(v)
      if h.kind_of? Hash and h.keys.sort == keys and # This and ...
         h.each {|key, value|
            Numeric === value and     # this may eventually be unneeded.
            t_low[key] <= value and
            t_high[key] >= value
          }
        yield h
      end
      k, v = c.next
    end
  end
  return nil
end

puts
puts "Multikey query"
puts "--------------"

db.insert(
  {a: -123.456, b: 17.2},
  {a: 10, b: 11},
  {a: 20, b: 6},
  {a: 20, b: 21}
)

puts "All tuples of the form {a: Numeric, b: Numeric}:"
db.find_all_in_multirange( [:a, :b], {a: -1.0/0, b: -1.0/0}, {a: 1.0/0, b: 1.0/0} ) do |t|
  p t
end

puts
puts "All of those for which 5 <= a <= 25 and 5 <= b <= 15:"
db.find_all_in_multirange( [:a, :b], {a: 5, b: 5}, {a: 25, b: 15} ) do |t|
  p t
end
