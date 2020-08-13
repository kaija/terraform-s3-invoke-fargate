#!/bin/bash

pushd modules
for d in */ ; do
    pushd $d
    echo "Lint $d module in `pwd`"
    terraform fmt
    popd
done
popd

terragrunt hclfmt

