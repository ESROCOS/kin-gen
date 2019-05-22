# Code generation tests

This test runs the entire toolchain for a set of queries for the UR5 robot and
compiles the generated C++ code.

## Execution

1. Run the `generate.sh` shell script.

2. Inspect the results in `compiled/` directory.

3. Run the generated tests for each solver.
   NOTE: IK tests are self-contained, i.e. they generate random input-output
   pairs and test the IK solver on it. FK tests are NOT, i.e. they require a
   file with datasets against which compare the output. Currently, only one
   example dataset file is provided: the fk-dataset intended for fk1.
   Trying it on another fk solver will obviously result in errors.
