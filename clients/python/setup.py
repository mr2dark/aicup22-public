from setuptools import setup
from Cython.Build import cythonize

setup(
    name='Hello world app',
    ext_modules=cythonize(
        [
            "ext/simpleio.pyx",
            "ext/stream_wrapper.pyx",
        ],
        annotate=True,
        compiler_directives={
            'language_level': "3",
        },
    ),
    zip_safe=False,
)