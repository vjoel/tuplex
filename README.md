Tuplex
==

Constructs index keys for tuples.

What is it for?
---

1. Assign keys to tuples (immutable value types) that do not have unique ids (primary keys). This can be used to store a tuplespace in a key-value store.

2. Keys for similar tuples should be similar, to keep them close in storage, reducing cache misses and page faults.

3. The key construction preserves ordering in such a way that the index can be used as an approximate secondary index for multidimensional range queries.

What does it do?
---

Tuplex gives you a function that turns a tuple into a string that can be used as a key in a key-value store. The key is non-unique, so you'll need to use the value to disambiguate (see examples).

For tuples of a given _signature_ (same array sizes, map keys, type of each value, etc.), the function is _monotonic_ on each value. For example:

    ["foo", 1, 2]
    ["foo", 1, 3]

These two tuples have the same signature: three elements of types string, number, and number, respectively.

The index keys for these tuples are as follows:

    >> Tuplex.make_key(["foo", 1, 2])
    => "\x97\xB0kL\xA0\xC9\x00\xD1\x00hwn"
    >> Tuplex.make_key(["foo", 1, 3])
    => "\x97\xB0kL\xA0\xC9\x00\xD1\x00hwn\x00\b"
    >> Tuplex.make_key(["foo", 1, 2]) < Tuplex.make_key(["foo", 1, 3])
    => true

So, the ordering `2<3` is preserved in the key strings (lexically ordered).

This is also true when varying any number of terms, whether string or number:

    >> Tuplex.make_key(["foo", 1, 2]) < Tuplex.make_key(["foozap", 7, 3])
    => true

And it's true for arbitrary nesting:

    >> Tuplex.make_key(["foo", {a: 1, b: [2]}]) < Tuplex.make_key(["foozap", {a: 7, b: [3]}])
    => true

However, for tuples of different signatures, the ordering depends only on the signature and not on term values:

    >> Tuplex.make_key(["a", 0]) < Tuplex.make_key([0, "a"])
    => true
    >> Tuplex.make_key(["z", 1000]) < Tuplex.make_key([0, "a"])
    => true

In other words, all tuples of signature (String, Number) are contiguous in the index, and that contiguous group is separate from tuples of signature (Number, String).

Contact
=======

Joel VanderWerf, vjoel@users.sourceforge.net, [@JoelVanderWerf](https://twitter.com/JoelVanderWerf).

License and Copyright
========

Copyright (c) 2014, Joel VanderWerf

License for this project is BSD. See the COPYING file for the standard BSD license. The supporting gems developed for this project are similarly licensed.
