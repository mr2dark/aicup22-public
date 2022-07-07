from cpython cimport array
import array

cdef class StreamWrapper:
    cdef bint is_big_endian_machine
    cdef array.array bool_buffer
    cdef array.array int_buffer
    cdef array.array long_buffer
    cdef array.array float_buffer
    cdef array.array double_buffer
    cdef array.array string_buffer
    cdef object stream

    cpdef flush(self)
    cpdef close(self)
    # Reading primitives
    cpdef bint read_bool(self)
    cpdef int read_int(self)
    cpdef long read_long(self)
    cpdef float read_float(self)
    cpdef double read_double(self)
    cpdef str read_string(self)
    # Writing primitives
    cpdef void write_bool(self, bint value)
    cpdef void write_int(self, int value)
    cpdef void write_long(self, long value)
    cpdef void write_float(self, float value)
    cpdef void write_double(self, double value)
    cpdef void write_string(self, str value)
