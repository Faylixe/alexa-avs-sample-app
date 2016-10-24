# Edgar

Edgar is a coordination application for using Alexa into Raspberry Pi devices. Forked from the original
[AVS sample](https://github.com/alexa/alexa-avs-sample-app).

## Installation

Installation process is the same that the original sample, just run the following command :

```bash
git clone https://github.com/Faylixe/edgar.git
cd edgar
./install.sh /path/to/your/configuration.xml
```

You can directly edit the ``installation_sample.xml`` and add your information. For more information about Amazon account creation, see [original project guide](https://github.com/alexa/alexa-avs-sample-app/wiki/Raspberry-Pi)

## Usage

```bash
python edgar.py
```

This will performs all required step namely :

- Run node.js based companion service.
- Run java client, which will perform auto login to LWA
- Start wake word agent on authentification callback

## Current issues

- Add a web interface for management
