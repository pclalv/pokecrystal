# See [crystal-key-item-randomizer](https://github.com/pclalv/crystal-key-item-randomizer).

The `randomizer-labels` branch builds the same ROM as the `master`
branch but contains additional labels/exported symbols that have been
useful in the development of the randomizer. 

The `randomizer-changes` branch is based off of `randomizer-labels`
but has some code modified (such that all byte values corresponding to
unmodified code _always line up_ - we cannot be shifting bytes
around). The modifications pertain to changes particular to the
randomizer, such as allowing early Kanto transit.

Both branches are built and diffed in order to determine the address
ranges that we need to target, the original values appearing inthose
address ranges and the values that should be inserted by the
randomizer.

In general, this technique is useful in developing the randomizer.
