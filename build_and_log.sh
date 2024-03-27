#!/bin/bash

# The first argument is the package name
package=$1

# Run the command and pipe its output. Use a subshell if necessary.
make MELANGE_EXTRA_OPTS="--create-build-log --cache-dir=.melangecache" REPO="./packages" package/$package -j1 2>&1 | tee /tmp/$package.log

# Immediately capture the PIPESTATUS of the make command
exit_code=${PIPESTATUS[0]}

# Act on the exit code
if [ "$exit_code" -ne 0 ]; then
    echo "Error building package $package with exit code $exit_code"
    exit $exit_code
fi
