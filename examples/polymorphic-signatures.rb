# Combined indexing of tuples with different signatures.

require 'tuplex'

TPX = Tuplex.new

a1 = TPX.make_key ["a", 1]
b2 = TPX.make_key [2, "b"]

p a1
p b2
p( a1 < b2 )

def TPX.sig_key t
  if t.kind_of? Array and t.size == 2 and (t[0].kind_of? Numeric or t[1].kind_of? Numeric)
    "qwertyui" # choose some 8 byte key
  end
end

a1 = TPX.make_key ["a", 1]
b2 = TPX.make_key [2, "b"]

p a1
p b2
p( a1 < b2 )
