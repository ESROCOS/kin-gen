FUNCTIONAL TESTS


This test runs the entire toolchain for a set of queries for the UR5 robot and compiles the resulting generated C code.

TEST EXECUTION:
1. Execute generate.sh bash script.
2. Inspect the results in compiled/ directory.
3. Run tests generated for each solver query.
NOTE: IK tests are self-contained, i.e. they generate random input-output pairs and test the IK solver on it.
      FK tests are NOT, i.e. require as a parameter a file with datasets to compare the output with.
      Currently, only one example dataset file is provided: the fk-dataset intended for fk1.
      Trying it on another fk solver will obviously result in errors.
