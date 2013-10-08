# Introduction

MetaZ is an mp4 meta-data editor for OS X.  
It started its life when another great meta-data editor MetaX stopped getting
updated, some of the web-services it used changed in ways that broke
functionality and it had some really anoying (to us at least) little missing
things like no proper window resizing. This lead to us starting MetaZ as a
reimplementation of MetaX with a few ideas of our own sprinkled in there.

[issues]: https://github.com/griff/metaz/issues
[flow]: http://scottchacon.com/2011/08/31/github-flow.html

# Bugs / Feature request

For bugs and feature requests you can use our [issue tracker at github](issues)

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

# Helping out

## Building

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

### Building with Xcode 5

It seems possible to build the project with Xcode 5 while still compiling with
the 10.5 SDK. What you need to do is manually install the SDK from the Xcode 3.2.6 DMG.

```bash
# Download and mount the Xcode 3.2.6 DMG from Apple

open /Volumes/Xcode\ and\ iOS\ SDK/Packages/MacOSX10.5.pkg
# Install the SDK and choose a location like your user home 
# You should now have the directory MacOSX10.5.sdk in ~/SDKs

# Make a link from the Xcode 5 install location to the installed SDK
cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
sudo ln -s ~/SDKs/MacOSX10.5.sdk MacOSX10.5.sdk
```

## Contribution steps

We follow [GitHub flow][flow], as a workflow. Basically:

- Create a feature branch in your fork
- Make your change with documentation as appropriate
- Please run and test a release build before submitting a pull request!
- Submit a pull request from your branch
- Someone with commit access will review the code and merge it. This applies even if you also have commit access.

## Becoming a committer

Going forward we will follow [rubinius'
lead](http://www.programblings.com/2008/04/15/rubinius-for-the-layman-part-2-how-rubinius-is-friendly/)
and once you have one pull request accepted into MetaZ, we will add you to a
team that has push+pull access. Basically you will get a big green merge
button on other people's pull requests, and you will be able to commit those
pull requests to the griff/metaz master branch.

This _also_ means that you _could_ push your commits directly to
griff/metaz without going through a pull request. We ask that you not do
this, however, so that any code on master has been reviewed. This does not apply
to branches other than master; if there is long-term collaboration happening,
create a feature branch and feel free to push directly to that (but have 
commits reviewed before merging that branch into master).

We reserve the right to take away this permission, but in general we trust you
to give it to you.
