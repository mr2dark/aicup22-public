# cython: infer_types=True
cimport cython
from ext.stream_wrapper cimport StreamWrapper

@cython.freelist(10000)
@cython.no_gc
cdef class Vec2:
    """2 dimensional vector."""

    def __cinit__(self, double x, double y):
        self.x = x
        """`x` coordinate of the vector"""
        self.y = y
        """`y` coordinate of the vector"""

    def __repr__(self):
        return "Vec2(" + \
            repr(self.x) + \
            ", " + \
            repr(self.y) + \
            ")"


@cython.nonecheck(False)
cdef void write_vec2(Vec2 vec2, StreamWrapper stream):
    """Write Vec2 to output stream
    """
    stream.write_double(vec2.x)
    stream.write_double(vec2.y)


@cython.nonecheck(False)
cdef Vec2 read_vec2(StreamWrapper stream):
    """Read Vec2 from input stream
    """
    x = stream.read_double()
    y = stream.read_double()
    return Vec2.__new__(Vec2, x, y)
