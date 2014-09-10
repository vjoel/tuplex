require 'minitest/autorun'
require 'tuplex'

class TestNesting < Minitest::Test
  TPX = Tuplex.new

  def test_nest
    assert_equal(
      "\x00\x00\x00\x00\x00\x00" + TPX.sum_key('a'),
      TPX.sum_key([[['a']]]))
  end
end
