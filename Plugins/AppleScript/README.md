# MetaZ AppleScript plugins

This folder contains plugins for MetaZ written in AppleScript.

They are stored both as `.applescript` text documents and as compiled `.scpt`
scripts and `.scptd` script bundles because some of them only compile on macOS
Mojave or older and some only compile on macOS Catalina. They also need to be
precompiled because they are included in `MetaZ.app` and to compile the
script pluginss you need an already compiled version of `MetaZ.app`.

To compile the `.applescript` files call the `compile-applescripts.sh` script in
the source root folder. That script will find all applescripts and compile the
ones that can be compiled on the version of macOS that the machine running the
script is on.

```
cd ../..
./compile-applescripts.sh
```
