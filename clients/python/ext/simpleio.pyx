# cython: infer_types=True
import cython
from libc.string cimport memcpy
from cpython cimport array
import array
from cpython.object cimport Py_SIZE
from cpython.buffer cimport PyObject_CopyData


ctypedef fused data_type:
    char
    int
    long
    float
    double


cdef class SimpleBytesIO:
    cdef Py_ssize_t pos
    cdef array.array buffer
    cdef char[::1] view
    cdef char fortran

    def __init__(self, buffer: bytes):
        self.pos = 0
        self.buffer = array.array("b", buffer)
        self.view = self.buffer
        self.fortran = <char>b'A'[0]

    def close(self):
        pass

    def flush(self):
        pass

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef read(self, Py_ssize_t size):
        cdef Py_ssize_t _prev_pos = self.pos
        self.pos += size
        return self.view[_prev_pos: self.pos]

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef Py_ssize_t readinto(self, array.array buf):
        cdef Py_ssize_t size = Py_SIZE(buf) * buf.ob_descr.itemsize
        cdef Py_ssize_t _prev_pos = self.pos
        self.pos += size
        # PyObject_CopyData(buf, self.view[_prev_pos: self.pos])
        # PyObject_CopyToObject(buf, <char *>&(self.buffer.data.as_chars[_prev_pos]), size, self.fortran)
        memcpy(buf.data.as_chars, &(self.buffer.data.as_chars[_prev_pos]), size)
        return size

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef write(self, __):
        return 4
