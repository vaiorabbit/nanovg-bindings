#!/bin/sh
pushd .
cd ..
gem build nanovg-bindings.gemspec
gem build nanovg-bindings.gemspec --platform arm64-darwin
gem build nanovg-bindings.gemspec --platform x86_64-darwin
gem build nanovg-bindings.gemspec --platform aarch64-linux
gem build nanovg-bindings.gemspec --platform x86_64-linux
gem build nanovg-bindings.gemspec --platform x64-mingw
popd
