#!/bin/sh
pushd .
cd ..
for i in `ls nanovg-bindings-*.gem`; do
    echo gem push $i
done
popd
