#!/usr/bin/bash

configuration=$1
if xmllint --noout $configuration --schema configuration.xsd then
  echo 'Invalid configuration file provided'
  exit 1
fi

# Installation relative variables.
os=rpi
user=$(id -un)
group=$(id -gn)
origin=$(pwd)
xslt=$origin/xslt
client=$origin/client
wakeword=$origin/wakeword
companion=$origin/companion/service
kittai=$wakeword/kitt_ai
sensory=$wakeword/sensory
external=$wakeword/ext

mkdir $kittai
mkdir $sensory
mkdir $external

# Start header section.
startheader() {
  echo ""
  echo ""
  echo "==============================================="
  echo "***********************************************"
}

# End header section.
endheader() {
  echo "***********************************************"
  echo "==============================================="
  echo ""
  echo ""
}

# Echoes given $1 subheader.
subheader() {
  echo "=========== $1 ==========="
}

# Deletes given $1 file if exists.
delete() {
  if [ -f $1 ]; then
    rm $1
  fi
}

startHeader
echo " Making sure we are installing to the right OS"
endHeader

subheader "Installing Oracle Java8"
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
cd $client
chmod +x install-java8.sh
bash ./install-java8.sh

startheader
echo " *** STARTING INSTALLATION ***"
echo "  ** this may take a while **"
endheader

subheader "Installing required tools and libraries through aptitude"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git libasound2-dev libatlas-base-dev vlc vlc-nox \
vlc-data nodejs npm build-essential maven openssl cmake libfontconfig xalan
sudo sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
sudo sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo ldconfig

subheader "Configuring ALSA devices"
delete /home/$user/.asoundrc
printf "pcm.!default {\n  type asym\n   playback.pcm {\n     type plug\n     slave.pcm \"hw:0,0\"\n   }\n   capture.pcm {\n     type plug\n     slave.pcm \"hw:1,0\"\n   }\n}" >> /home/$user/.asoundrc

subheader "Installing and configuring Java client"
cd $client
xalan -in $configuration -out ssl.cnf -xsl $xslt/ssl_configuration.xsl
xalan -in $configuration -out generate.sh -xsl $xslt/client_certificate_generator.xsl
xalan -in $configuration -out configuration.json -xsl $xslt/client_configuration.xsl -param javaclient $client
chmod +x generate.sh
bash ./generate.sh
mvn validate && mvn install

subheader "Installing companion service"
cd $companion
xalan -in $configuration -out configuration.js -xsl $xslt/companion_configuration.xsl -param javaclient $client
generate template_config_js config.js
npm install

subheader "Installing Sensory engine"
cd $sensory && git clone https://github.com/Sensory/alexa-rpi.git

subheader "Installing Kitt-AI engine"
cd $kittai
git clone https://github.com/Kitt-AI/snowboy.git
cd snowboy/examples/C++
bash ./install_portaudio.sh
sudo ldconfig
make -j4
sudo ldconfig

subheader "Preparing and compiling wake word agent"
mkdir $external/include
mkdir $external/lib
mkdir $external/resources
cp $kittai/snowboy/include/snowboy-detect.h $external/include/snowboy-detect.h
cp $kittai/snowboy/examples/C++/portaudio/install/include/portaudio.h $external/include/portaudio.h
cp $kittai/snowboy/examples/C++/portaudio/install/include/pa_ringbuffer.h $external/include/pa_ringbuffer.h
cp $kittai/snowboy/examples/C++/portaudio/install/include/pa_util.h $external/include/pa_util.h
cp $kittai/snowboy/lib/$OS/libsnowboy-detect.a $external/lib/libsnowboy-detect.a
cp $kittai/snowboy/examples/C++/portaudio/install/lib/libportaudio.a $external/lib/libportaudio.a
cp $kittai/snowboy/resources/common.res $external/resources/common.res
cp $kittai/snowboy/resources/alexa.umdl $external/resources/alexa.umdl
$sensory/alexa-rpi/bin/sdk-license file $sensory/alexa-rpi/config/license-key.txt $sensory/alexa-rpi/lib/libsnsr.a $sensory/alexa-rpi/models/spot-alexa-rpi-20500.snsr $sensory/alexa-rpi/models/spot-alexa-rpi-21000.snsr $sensory/alexa-rpi/models/spot-alexa-rpi-31000.snsr
cp $sensory/alexa-rpi/include/snsr.h $external/include/snsr.h
cp $sensory/alexa-rpi/lib/libsnsr.a $external/lib/libsnsr.a
cp $sensory/alexa-rpi/models/spot-alexa-rpi-31000.snsr $external/resources/spot-alexa-rpi.snsr
mkdir $wakeword/tst/ext
cp -R $external/* $wakeword/tst/ext
cd $wakeword/src && cmake . && make -j4
cd $wakeword/tst && cmake . && make -j4
chown -R $user:$group $origin
chown -R $user:$group /home/$user/.asoundrc

subheader "Installing PhantomJS for autologin"
curl -o /tmp/phantomjs -sSL https://github.com/fg2it/phantomjs-on-raspberry/releases/download/v2.1.1-wheezy-jessie/phantomjs
sudo mv /tmp/phantomjs /usr/local/bin/phantomjs
sudo chmod a+x /usr/local/bin/phantomjs

subheader "Installing Edgar dependencies"
sudo pip install flask

startheader
echo '========= Finished =========='
endheader
