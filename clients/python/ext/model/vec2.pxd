# cython: infer_types=True
from ext.stream_wrapper cimport StreamWrapper

cdef class Vec2:
    """2 dimensional vector."""

    cdef public double x
    cdef public double y


cdef void write_vec2(Vec2 vec2, StreamWrapper stream)
cdef Vec2 read_vec2(StreamWrapper stream)
