# End-to-end test for qdb docker images

This test suite uses https://www.cypress.io/ to run end-to-end integration and regression tests
against a qdb-dashboard instance backed by qdb-preloaded.

As such, it inderectly also tests:
 * qdbd
 * the REST API
 * the Go API
 * the C API
 * railgun

The tests cannot be considered exhaustive as they only cover a happy path, having the goal of
catching the most blatant breaking modifications.

## Running the tests headlessly

Dependency: docker

```
./run_test.sh latest   # or another docker tag
```

## Running the tests interactively

Dependency: docker, cypress (install via npm: `npm install -g cypress`)

```
./interactive_test.sh latest   # or another docker tag
```

The cypress launcher will start and reload test specs automatically, rerunning the tests as necessary.
The dashboard will be available at port 40080.