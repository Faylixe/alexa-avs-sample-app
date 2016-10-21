#!/bin/bash

wget https://github.com/spfaffly/phantomjs-linux-armv6l/archive/master.zip
unzip master.zip
rm master.zip
cd phantomjs-linux-armv6l-master
tar -zxvf *.tar.gz
cp phantomjs-2.0.1-development-linux-armv6l/bin/phantomjs ../
cd ..
rm -Rf phantomjs-linux-armv6l-master
