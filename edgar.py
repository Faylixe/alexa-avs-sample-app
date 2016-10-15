#!/usr/bin/python

from flask import Flask, request

# Default application port.
DEFAULT_PORT = 6969

# Application
application = Flask(__name__)

class Alexa(object):

    def __init__(self):
        """ """
        self.registrationURL = None
        self.token = None
        
@application.route('/registration/url', methods=['GET'])
def getRegistrationURL():
    """ """
    pass

@application.route('/registration/url', methods=['POST'])
def setRegistrationURL():
    """ """
    url = request['url']

@application.route('/register/token')
def registerToken():
    """ """
    token = request.args.get('token')
    pass

if __name__ == '__main__':
    # TODO : Argparse ?
    application.run()
