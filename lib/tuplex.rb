require 'msgpack'

module Tuplex
  module_function

  # +t+ can be a tuple or a value in a tuple (that is, an entry in
  # an array or a value at some key in a hash).
  def signature t
    case t
      when nil, true, false; 0
      when Numeric; 1
      when String, Symbol; 2
      when Array
        t.map {|v| signature(v)}
      when Hash
        t.each_with_object({}) {|(k,v), h| h[k] = signature(v)}
      else raise ArgumentError, "cannot compute signature for #{t.inspect}"
    end
  end

  SIG_KEY_SIZE = 8
  def sig_key t
    [signature(t).hash].pack("q")
  end

  def str_sum acc, s
    a = acc.unpack("C*")
    b = s.unpack("C*")
    if a.size < b.size
      a,b = b,a
    end
    cv = 0
    s = []
    a.zip(b).reverse_each do |av,bv|
      bv ||= 0
      cv,r = (av + bv + cv).divmod 256
      s << r
    end
    if cv != 0
      raise "overflow"
    end
    s.reverse.pack("C*")
  end

  # https://en.wikipedia.org/wiki/Double-precision_floating-point_format
  # "%064b" % [-1.0].pack("G").unpack("Q>")
  # [0b1011111111110000000000000000000000000000000000000000000000000000].pack("Q>").unpack("G")

  def expo(x) ([x].pack("G")[0..1].unpack("S>")[0] & 0b0111111111110000) >> 4; end
  def mant(x) [x].pack("G").unpack("Q>")[0] & 0x000FFFFFFFFFFFFF; end

  def float_to_key x
    if x >= 0
      bits = [x].pack("G").unpack("Q>")[0] | 0x8000000000000000
      # [1, expo(x), mant(x)].pack("CS>Q>") # sparse version
    else
      expo_bits = ((-expo(x)) & 0x7FF) << 52
      mant_bits = (-mant(x)) & 0x0FFFFFFFFFFFFF
      bits = expo_bits | mant_bits
      # [0, -expo(x), -mant(x)].pack("CS>Q>")
    end
    [bits].pack("Q>")
  end
  # def fk(x); "%064b" % float_to_key(x).unpack("Q>"); end

  MAX_SUM_KEY_SIZE = 500
  def sum_key t, acc = "\0\0"
    case t
    when nil;   str_sum(acc, "\0\0")
    when false; str_sum(acc, "\0\1")
    when true;  str_sum(acc, "\0\2")
    when Numeric; str_sum(acc, "\0" + float_to_key(t.to_f))
    when String; str_sum(acc, "\0" + t) # truncate here
    when Symbol; str_sum(acc, "\0" + t.to_s) # and here
    when Array; t.inject(acc) {|s,v| sum_key(v,s)}
    when Hash; t.inject(acc) {|s,(k,v)| sum_key(v,s)}
    else raise ArgumentError, "bad type: #{t.inspect}"
    end
  end

  MAX_KEY_SIZE = SIG_KEY_SIZE + MAX_SUM_KEY_SIZE
  # note: MDB_MAXKEYSIZE is 511

  def make_key t
    (sig_key(t) + sum_key(t))[0..MAX_KEY_SIZE].sub(/\0+\z/, "")
  end

  def make_val t
    make_val_hash(t) + MessagePack.pack(t)
  end

  def make_val_hash t
    [t.hash].pack("Q>")
  end

  def unpack_val s
    MessagePack.unpack(s[8..-1])
  end

  def val_equals_tuple s, t, th = make_val_hash(t)
    s[0..7] == th && unpack_val(s) == t
  end
end
