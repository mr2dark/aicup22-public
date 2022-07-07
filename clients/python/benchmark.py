import importlib
import io
import os
import sys
import tempfile
import timeit
from typing import Type, Protocol

from pympler import asizeof
import model

import stream_wrapper
import ext.model
import ext.model.player
import ext.stream_wrapper
import ext.simpleio
from references import *

# REFERENCE_BUILDING = model.Building(building_type=model.BuildingType.FARM, health=100, work_done=42,
#                                 last_tick_tasks_done=420)
# TRANS_READ_FILENAME = "game.trans"


class TransObject(Protocol):
    @staticmethod
    def read_from(stream) -> "TransObject":
        ...

    def write_to(self, stream):
        ...


def benchmark_trans_object_type_read(
        trans_object_type: Type[TransObject],
        stream,
        sw_type,
        number: int = 1000,
):
    wrapper = sw_type(stream)
    result = timeit.timeit(
        "trans_object_type.read_from(wrapper)",
        globals={
            "trans_object_type": trans_object_type,
            "wrapper": wrapper,
        },
        number=number,
    )
    print(result)


def assert_equal(b1, b2):
    # assert b1.building_type == b2.building_type
    # assert b1.health == b2.health
    # assert b1.work_done == b2.work_done
    # assert b1.last_tick_tasks_done == b2.last_tick_tasks_done
    # assert b1 == b2
    pass


def type_name(typ):
    return ".".join([typ.__module__, typ.__qualname__])


def benchmark_reads(
        trans_object_type: Type[TransObject],
        sw_type,
        number: int = 1000,
        trans_filename: str = None,
):
    print("Benchmarking reading for", type_name(trans_object_type), "with", type_name(sw_type), "...")

    with open(trans_filename, "rb") as fileobj:
        sw = sw_type(fileobj)
        trans_object = trans_object_type.read_from(sw)

    assert_equal(trans_object, REFERENCE)
    print("Object size (w/o nested)", sys.getsizeof(trans_object))
    print("Object size (with nested)", asizeof.asizeof(trans_object))
    print("Repr:", repr(trans_object))
    print("Str:", str(trans_object))

    print("Checking io.FileIO")
    with open(trans_filename, "rb") as fileobj:
        benchmark_trans_object_type_read(trans_object_type, stream=fileobj, sw_type=sw_type, number=number)

    with open(trans_filename, "rb") as fileobj:
        object_bytes = fileobj.read()

    print("Checking io.BytesIO")
    mem_stream = io.BytesIO(object_bytes)
    benchmark_trans_object_type_read(trans_object_type, stream=mem_stream, sw_type=sw_type, number=number)

    # print("Checking SimpleBytesIO")
    # mem_stream = ext.simpleio.SimpleBytesIO(object_bytes)
    # benchmark_trans_object_type_read(model.Building, stream=mem_stream, sw_type=sw_type, number=number)


def dump_trans_object(trans_object: TransObject, filename: str, number: int = 1):
    with open(filename, "wb") as fileobj:
        trans_object.write_to(stream_wrapper.StreamWrapper(fileobj))

    if number > 1:
        with open(filename, "rb") as fileobj:
            object_bytes = fileobj.read()
        object_bytes *= number
        with open(filename, "wb") as fileobj:
            fileobj.write(object_bytes)


def load_trans_object(trans_object_type: Type[TransObject], filename: str, number: int = 1) -> TransObject:
    with open(filename, "rb") as fileobj:
        return trans_object_type.read_from(stream_wrapper.StreamWrapper(fileobj))


def benchmark_trans_object_type_write(
        trans_object: TransObject,
        stream,
        sw_type,
        number: int = 1000,
):
    wrapper = sw_type(stream)
    result = timeit.timeit(
        "trans_object.write_to(wrapper)",
        globals={
            "trans_object": trans_object,
            "wrapper": wrapper,
        },
        number=number,
    )
    print(result)


def benchmark_writes(
        trans_object: TransObject,
        sw_type,
        number: int = 1000,
):
    trans_object_type = type(trans_object)
    print("Benchmarking writing for", type_name(trans_object_type), "with", type_name(sw_type), "...")
    print("Object size (w/o nested)", sys.getsizeof(trans_object))
    print("Object size (with nested)", asizeof.asizeof(trans_object))
    print("Repr:", repr(trans_object))
    print("Str:", str(trans_object))

    fileobj = tempfile.NamedTemporaryFile(delete=False)
    filename = fileobj.name
    trans_object.write_to(sw_type(fileobj))
    fileobj.flush()
    fileobj.close()
    bin_size = os.path.getsize(filename)

    with open(filename, "rb") as fileobj:
        sw = stream_wrapper.StreamWrapper(fileobj)
        trans_obj = REF_TYPE.read_from(sw)
        assert_equal(trans_obj, REFERENCE)


    os.unlink(filename)

    print("Checking io.FileIO")
    with tempfile.TemporaryFile(mode="wb", buffering=(bin_size * number) + io.DEFAULT_BUFFER_SIZE) as fileobj:
        benchmark_trans_object_type_write(trans_object, stream=fileobj, sw_type=sw_type, number=number)

    # print("Checking io.BytesIO")
    # mem_stream = io.BytesIO(object_bytes)
    # benchmark_trans_object_type_read(trans_object_type, stream=mem_stream, sw_type=sw_type, number=number)
    #
    print("Checking SimpleBytesIO")
    mem_stream = ext.simpleio.SimpleBytesIO(b"")
    benchmark_trans_object_type_write(trans_object, stream=mem_stream, sw_type=sw_type, number=number)


ALT_TYPE_MAPPING = {
    "Player": "ext.model.player.Player",
    "Sound": "ext.model.sound.Sound",
    "Vec2": "ext.model.vec2.Vec2",
}


def alt_clone(ob):
    alt_obj_str = str(ob)
    for typ, alt_typ in ALT_TYPE_MAPPING.items():
        alt_obj_str = alt_obj_str.replace(typ, alt_typ)
    alt_object = eval(alt_obj_str)
    return alt_object


if __name__ == "__main__":
    TRANS_READ_FILENAME = "sound.trans"
    number = 1000000
    REFERENCE = REFERENCE_SOUND

    REF_TYPE = type(REFERENCE)
    REF_MODULE = REF_TYPE.__module__
    importlib.import_module(f"ext.{REF_MODULE}")
    alt_type_name = f"ext.{type_name(REF_TYPE)}"
    alt_type = eval(alt_type_name)
    alt_obj = alt_clone(REFERENCE)
    if not os.path.exists(TRANS_READ_FILENAME):
        obj = REFERENCE
        dump_trans_object(obj, TRANS_READ_FILENAME, number=number)
    # if not os.path.exists(TRANS_READ_FILENAME):
    #     if os.path.exists(TRANS_READ_FILENAME):
    #     building = REFERENCE_BUILDING
    #     dump_trans_object(building, TRANS_READ_FILENAME, number=number)

    benchmark_reads(REF_TYPE, sw_type=stream_wrapper.StreamWrapper, number=number, trans_filename=TRANS_READ_FILENAME)
    benchmark_reads(REF_TYPE, sw_type=ext.stream_wrapper.StreamWrapper, number=number, trans_filename=TRANS_READ_FILENAME)
    benchmark_reads(alt_type, sw_type=ext.stream_wrapper.StreamWrapper, number=number, trans_filename=TRANS_READ_FILENAME)

    benchmark_writes(REFERENCE, sw_type=stream_wrapper.StreamWrapper, number=number)
    benchmark_writes(REFERENCE, sw_type=ext.stream_wrapper.StreamWrapper, number=number)
    benchmark_writes(alt_obj, sw_type=ext.stream_wrapper.StreamWrapper, number=number)
    # building_ext = ext.model.Building(REFERENCE_BUILDING.building_type, REFERENCE_BUILDING.health, REFERENCE_BUILDING.work_done, REFERENCE_BUILDING.last_tick_tasks_done)
    # benchmark_writes(building_ext, sw_type=ext.stream_wrapper2.StreamWrapper, number=number)
