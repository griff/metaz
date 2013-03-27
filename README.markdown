# Introduction

MetaZ is an mp4 meta-data editor for OS X.  
It started its life when another great meta-data editor MetaX stopped getting
updated, some of the web-services it used changed in ways that broke
functionality and it had some really anoying (to us at least) little missing
things like no proper window resizing. This lead to us starting MetaZ as a
reimplementation of MetaX with a few ideas of our own sprinkled in there.


# Bugs / Feature request

For bugs and feature requests you can use our [issue tracker at github](https://github.com/griff/metaz/issues)

# Extras

We have created some extra resources and small plugins that were deemed to
small or silly to be included with the main program.

The classic moo from MetaX is finally available via a small MetaZ plugin you
can download from [here](https://github.com/downloads/griff/metaz/Moo.zip).
To install it simply unpack the zip file and drop the unpacked script onto the
MetaZ dock icon.

If you use [Script Debugger](http://www.latenightsw.com/) from Late Night
Software you are in luck because we have created a Script Debugger template
for MetaZ plugins which illustrate the different types of events plugins can
respond to. To get the template [click here](https://github.com/downloads/griff/metaz/MetaZ%20Plugin.sdtemplate.zip)

# Building

There are some files missing in the git repository that you will need if you
are going to build your own version of MetaZ.

`Plugins/Amazon/Access.h`  
This file contains Amazon AWS access credentials.  
Copy `Plugins/Amazon/Access_template.h` and insert your own credentials.

`App/resources/CowHead.png`  
`App/resources/faded_cow*.png`  
`App/resources/presets.png`  
These files are mostly just taken from MetaX but since I don't have the rights
to use them they are not included in the repository.  
I have though made a tar with these files and uploaded it to github:
[missing.tar.gz](http://github.com/downloads/griff/metaz/missing.tar.gz)
