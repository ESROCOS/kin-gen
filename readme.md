This is the source code repository of the Kin-Gen tool(chain), a kinematics code
generator developed by KU Leuven in the context of the ESROCOS project.

# Description
Kin-Gen generates code (C++, Python, Julia) for forward and inverse kinematics
solvers for articulated robots.

Given a robot model and a user request, the "ILK Generator" generates a model of
the requested kinematics solver, independent of programming language or
computational hardware ("ILK" stands for Intermediate Language for Kinematics).
Afterwards, this model can be compiled by the "ILK Compiler" into actual 
code (C++, Python, Julia) that can be used on the target platform.

Please also refer to the readme files of the two main components of the tool,
`ilk-generator/readme.md` and `ilk-compiler/readme.md`. These files contain
building and usage instructions.

The scripts in this folder, `ilk-generator.sh` and `ilk-compiler.sh`, are
provided for convenience. Please set the following environment variables for
their correct execution:

```
export KIN_GEN_ROOT=<full absolute path to this folder>
export PATH=$PATH:$KIN_GEN_ROOT
```

# License

Copyright © 2019-2020, KU Leuven Robotics Group

Released under the BSD 2-clause license. See the `LICENSE` file for additional
information.