# Introduction [![Build Status](https://travis-ci.org/griff/metaz.svg?branch=develop)](https://travis-ci.org/griff/metaz)

MetaZ is an mp4 meta-data editor for macOS.  
It started its life when another great meta-data editor MetaX stopped getting
updated, some of the web-services it used changed in ways that broke
functionality and it had some really anoying (to us at least) little missing
things like no proper window resizing. This lead to us starting MetaZ as a
reimplementation of MetaX with a few ideas of our own sprinkled in there.

[issues]: https://github.com/griff/metaz/issues
[flow]: http://scottchacon.com/2011/08/31/github-flow.html

# Bugs / Feature request

For bugs and feature requests you can use our [issue tracker at github][issues]

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

To build the project you need to have Xcode and
[Carthage](https://github.com/Carthage/Carthage#quick-start) installed.

Before you can build the project with Xcode you first need to download the
needed submodules:

```
git submodule update --init
```

And then bootstrap the dependencies managed by Carthage:

```
cathage bootstrap
```

After those two steps you should be able to compile the project with Xcode
normally.

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
