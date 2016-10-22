# Edgar

Edgar is a coordination application for using Alexa into Raspberry Pi devices. Forked from the original
[AVS sample](https://github.com/alexa/alexa-avs-sample-app).

## Installation

Installation process is the same that the original sample, just run the following command :

```bash
git clone https://github.com/Faylixe/edgar.git
cd edgar
./automated_install.sh
```

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
- Clean installation script to integrate LWA credentials into generated configuration
