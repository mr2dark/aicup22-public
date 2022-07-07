# cython: infer_types=True
cimport cython
from ext.stream_wrapper cimport StreamWrapper

@cython.freelist(120)
@cython.no_gc
cdef class Player:
    """Game's participant (team of units)"""

    cdef public int id
    cdef public int kills
    cdef public double damage
    cdef public int place
    cdef public double score

    def __cinit__(self, int id, int kills, double damage, int place, double score):
        self.id = id
        """Unique id"""
        self.kills = kills
        """Number of kills"""
        self.damage = damage
        """Total damage dealt to enemies"""
        self.place = place
        """Survival place (number of survivor teams currently/at the moment of death)"""
        self.score = score
        """Team score"""

    @staticmethod
    @cython.nonecheck(False)
    def read_from(StreamWrapper stream) -> "Player":
        """Read Player from input stream
        """
        id = stream.read_int()
        kills = stream.read_int()
        damage = stream.read_double()
        place = stream.read_int()
        score = stream.read_double()
        return Player.__new__(Player, id, kills, damage, place, score)
    
    @cython.nonecheck(False)
    cpdef write_to(self, StreamWrapper stream):
        """Write Player to output stream
        """
        stream.write_int(self.id)
        stream.write_int(self.kills)
        stream.write_double(self.damage)
        stream.write_int(self.place)
        stream.write_double(self.score)
    
    def __repr__(self):
        return "Player(" + \
            repr(self.id) + \
            ", " + \
            repr(self.kills) + \
            ", " + \
            repr(self.damage) + \
            ", " + \
            repr(self.place) + \
            ", " + \
            repr(self.score) + \
            ")"