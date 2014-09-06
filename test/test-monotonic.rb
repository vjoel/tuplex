require 'minitest/autorun'
require 'tuplex'

class TestMonotonic < Minitest::Test
  include Tuplex

  def make_key_pairs vals, frame = proc {|x| [x]}
    vals.sort.map { |x|
      t = frame[x]
      [t, make_key(t)]
    }
  end

  def assert_monotonic pairs
    pairs.each_cons(2) {|(t1,s1),(t2,s2)|
      assert_operator(s1, :<, s2, "comparing #{t1.inspect} < #{t2.inspect}")
    }
  end

  FRAMES = [
    proc {|x| [x]},
    proc {|x| {a: "foo", b: 123.456, c: [1, 2, x, 3, 4], d: 1.23}}
  ]

  def test_numerics
    ints = [-2**62, -123456, -10, -1, 0, 1, 2, 11, 99999, 2**62]
    floats = [
      -1.0/0, -1.23e300, -4.56e10, -7.89e-200,
      1.23e-200, 4.56e10, 7.89e300, 1.0/0]

    FRAMES.each do |frame|
      assert_monotonic(make_key_pairs(ints+floats, frame))
    end

    assert_equal(make_key(0), make_key(0.0))
  end

  def test_strings
    strs = ["", "a", "aa", "ab", "b", "bb"]

    FRAMES.each do |frame|
      assert_monotonic(make_key_pairs(strs, frame))
    end

    assert_equal(make_key(""), make_key("\0"))
  end

  def test_overflow
    # Too slow, with new hashing code.
    # t = ["\xFF"] * 0x10101
    # make_key(t)
    # t << "\xFF"
    # assert_raises(RuntimeError) {
    #   make_key(t)
    # }
  end
end
