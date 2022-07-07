# infer_types cython=True
cimport cython
from ext.model.vec2 cimport Vec2, read_vec2, write_vec2
from ext.stream_wrapper cimport StreamWrapper

@cython.freelist(50)
@cython.no_gc
cdef class Sound:
    """Sound heard by one of your units"""

    cdef public int type_index
    cdef public int unit_id
    cdef public Vec2 position

    def __cinit__(self, int type_index, int unit_id, Vec2 position):
        self.type_index = type_index
        """Sound type index (starting with 0)"""
        self.unit_id = unit_id
        """Id of unit that heard this sound"""
        self.position = position
        """Position where sound was heard (different from sound source position)"""

    @staticmethod
    @cython.nonecheck(False)
    def read_from(StreamWrapper stream) -> "Sound":
        """Read Sound from input stream
        """
        type_index = stream.read_int()
        unit_id = stream.read_int()
        position = read_vec2(stream)
        return Sound.__new__(Sound, type_index, unit_id, position)
    
    @cython.nonecheck(False)
    cpdef write_to(self, StreamWrapper stream):
        """Write Sound to output stream
        """
        stream.write_int(self.type_index)
        stream.write_int(self.unit_id)
        write_vec2(self.position, stream)
    
    def __repr__(self):
        return "Sound(" + \
            repr(self.type_index) + \
            ", " + \
            repr(self.unit_id) + \
            ", " + \
            repr(self.position) + \
            ")"