cimport cython
from cpython cimport array
import array
import sys

cdef class StreamWrapper:
    # cdef object stream

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    def __cinit__(self, stream):
        self.is_big_endian_machine = (sys.byteorder == "big")
        self.bool_buffer = array.array("b", [0])
        self.int_buffer = array.array("i", [0])
        self.long_buffer = array.array("q", [0])
        self.float_buffer = array.array("f", [0])
        self.double_buffer = array.array("d", [0])
        self.string_buffer = array.array("b")
        self.stream = stream

    cpdef flush(self):
        self.stream.flush()

    cpdef close(self):
        self.stream.close()

    # Reading primitives
    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef bint read_bool(self):
        self.stream.readinto(self.bool_buffer)
        return <bint>self.bool_buffer.data.as_chars[0]

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef int read_int(self):
        self.stream.readinto(self.int_buffer)
        if self.is_big_endian_machine:
            self.int_buffer.byteswap()
        return self.int_buffer.data.as_ints[0]

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef long read_long(self):
        self.stream.readinto(self.long_buffer)
        if self.is_big_endian_machine:
            self.long_buffer.byteswap()
        return self.long_buffer.data.as_longs[0]

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef float read_float(self):
        self.stream.readinto(self.float_buffer)
        if self.is_big_endian_machine:
            self.float_buffer.byteswap()
        return self.float_buffer.data.as_floats[0]

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef double read_double(self):
        self.stream.readinto(self.double_buffer)
        if self.is_big_endian_machine:
            self.double_buffer.byteswap()
        return self.double_buffer.data.as_doubles[0]

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef str read_string(self):
        cdef int length = self.read_int()
        array.resize_smart(self.string_buffer, length)
        cdef int bytes_read = self.stream.readinto(self.string_buffer)
        if bytes_read != length:
            raise IOError("Unexpected EOF")
        return self.string_buffer.tobytes().decode("utf-8")

    # Writing primitives

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef void write_bool(self, bint value):
        self.bool_buffer.data.as_chars[0] = value
        self.stream.write(self.bool_buffer)

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef void write_int(self, int value):
        self.int_buffer.data.as_ints[0] = value
        if self.is_big_endian_machine:
            self.int_buffer.byteswap()
        self.stream.write(self.int_buffer)

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef void write_long(self, long value):
        self.long_buffer.data.as_longs[0] = value
        if self.is_big_endian_machine:
            self.long_buffer.byteswap()
        self.stream.write(self.long_buffer)

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef void write_float(self, float value):
        self.float_buffer.data.as_floats[0] = value
        if self.is_big_endian_machine:
            self.float_buffer.byteswap()
        self.stream.write(self.float_buffer)

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef void write_double(self, double value):
        self.double_buffer.data.as_doubles[0] = value
        if self.is_big_endian_machine:
            self.double_buffer.byteswap()
        self.stream.write(self.double_buffer)

    @cython.nonecheck(False)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef void write_string(self, str value):
        data = value.encode("utf-8")
        self.write_int(len(data))
        self.stream.write(data)
