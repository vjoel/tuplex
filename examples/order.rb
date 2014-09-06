require 'tuplex'

def show_sorted(a)
  a.sort_by {|t| Tuplex.make_key(t)}.each {|t| p t}
end

puts "\nIntegers are dominated by strings that differ in their high-order",
     "bytes, so not useful for priority queues:"
show_sorted [
  [1, "z"],
  [2, "b"],
  [3, "c"]
]

puts "\nBox the strings in [] or {}, to reduce their significance:"
show_sorted [
  [1, ["z"]],
  [2, ["b"]],
  [3, ["c"]],
  [1, {x: "z"}],
  [2, {x: "b"}],
  [3, {x: "c"}]
]
