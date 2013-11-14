git submodule init
git submodule update
cp Plugins/Amazon/Access_template.h Plugins/Amazon/Access.h
curl -L http://github.com/downloads/griff/metaz/missing.tar.gz | tar zxv