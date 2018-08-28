This folder contains some tests for the kinematics code generator developed by
KUL in the context of the ESROCOS project.

The tests typically involve the execution of one or more components of the
tool(chain), namely the ilk-generator and the ilk-compiler, to verify the
expected functionality.

The final output of the tool(chain) is typically C++ code, which in turn can be
itself the subject of testing! Thus, bare in mind the chance of confusion when
talking about "tests" or "unit tests".


# Prerequisites

Build the ilk-generator, following the instructions in its `readme` file.

Set up the environment for the ilk-compiler, again refer to its `readme` file;
do not forget to run:

```
eval `luarocks path`
```

to fix the LUA path.

In addition, please set the following environment variables for the correct
execution of the tests:

```
export KIN_GEN_ROOT=<this folder>/..
export PATH=$PATH:$KIN_GEN_ROOT
```

