#!/usr/bin/python

import os
import subprocess

from os.path import join

from flask import Flask, request

# Default application port.
DEFAULT_PORT = 6969

# Application
application = Flask(__name__)

def createProcess(command, workingDirectory):
    """ Creates a return a process instance.

    :param command: Command to run into created process.
    :param workingDirectory: Directory to run command in (relative to the current)
    """
    cwd = join(os.getcwd(), workingDirectory)
    return subprocess.Popen(command.split(), cwd=cwd)

class Alexa(object):
    """ Alexa services instance manager. """

    def startCompanionService(self):
        """ Starts and saves companion service process. """
        self.companionProcess = createProcess('npm start', 'companion/service')

    def startClient(self):
        """ Starts and saves java client process. """
        self.clientProcess = createProcess('mvn exec:exec', 'client')

    def startWakewordAgent(self):
        """ Starts and saves wake word agent process. """
        self.wakewordAgentProcess = createProcess('./wakeWordAgent -e kitt_ai', 'wakeword/src')

alexa = Alexa()

# TODO : Implements UI based method for edgar managment.

@application.route('/registration/success', methods=['GET'])
def authentificationSuccess():
    """ Endpoint for successfull authentification, start wakeword agent. """
    alexa.startWakewordAgent()
    return 'OK', 200

if __name__ == '__main__':
    # TODO : Argparse for port.
    alexa.startCompanionService()
    alexa.startClient()
    application.run(host='0.0.0.0', port=DEFAULT_PORT)
