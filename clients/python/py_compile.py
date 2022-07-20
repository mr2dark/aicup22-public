import os
import subprocess
import sys

print("*" * 3, "Starting the cleanup of the flawed Cython output", "*" * 3, flush=True)

curdir = os.getcwd()
cython_exts = ('.so', '.c', '.html')
for root, dirs, files in os.walk(curdir):
    for file in files:
        if file.lower().endswith(cython_exts):
            fullname = os.path.join(root, file)
            os.remove(fullname)
            print("Deleted", fullname)

print("*" * 3, "Finished the cleanup of the flawed Cython output", "*" * 3, flush=True)

subprocess.run(
    [
        "python",
        "setup.py",
        "build_ext",
        "--inplace",
    ],
)

solution_dir = os.path.abspath(os.getenv("SOLUTION_CODE_PATH", os.getcwd())).rstrip(os.path.sep)
sys.path.remove(solution_dir)

import py_compile
py_compile.main()
