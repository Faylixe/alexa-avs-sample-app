/** 
 * Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Amazon Software License (the "License"). You may not use this file 
 * except in compliance with the License. A copy of the License is located at
 *
 *   http://aws.amazon.com/asl/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, 
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied. See the License for the 
 * specific language governing permissions and limitations under the License.
 */
package com.amazon.alexa.avs;

import com.amazon.alexa.avs.auth.AccessTokenListener;
import com.amazon.alexa.avs.auth.AuthSetup;
import com.amazon.alexa.avs.auth.companionservice.RegCodeDisplayHandler;
import com.amazon.alexa.avs.config.DeviceConfig;
import com.amazon.alexa.avs.config.DeviceConfig.CompanionServiceInformation;
import com.amazon.alexa.avs.config.DeviceConfigUtils;
import com.amazon.alexa.avs.http.AVSClientFactory;
import com.amazon.alexa.avs.wakeword.WakeWordDetectedHandler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.amazon.alexa.avs.wakeword.WakeWordIPCFactory;

/**
 * 
 * @author fv
 */
public final class AVSApp implements ExpectSpeechListener, RecordingRMSListener,
        RegCodeDisplayHandler, AccessTokenListener, ExpectStopCaptureListener,
        WakeWordDetectedHandler, Runnable {

    /** Enumeration of state this client go through. **/
    private enum ClientState {
        START, STOP, PROCESSING;
    }

	/** Class logger. **/
    private static final Logger log = LoggerFactory.getLogger(AVSApp.class);

    /** AVS controller instance. **/
    private final AVSController controller;

    /** Configuration provided by user for this device. **/
    private final DeviceConfig deviceConfig;

    /** **/
    private AuthSetup authSetup;
    
    /** Client state. **/
    private ClientState state;

    /**
     * Default constructor.
     * 
     * @param config Configuration provide by the user.
     * @throws Exception
     */
    private AVSApp(final DeviceConfig config) throws Exception {
        this.deviceConfig = config;
        controller = new AVSController(
        		this,
                new AVSAudioPlayerFactory(),
                new AlertManagerFactory(),
                new AVSClientFactory(deviceConfig),
                DialogRequestIdAuthority.getInstance(),
                config.getWakeWordAgentEnabled(),
                new WakeWordIPCFactory(),
                this);
        authSetup = new AuthSetup(config, this);
        authSetup.addAccessTokenListener(this);
        authSetup.addAccessTokenListener(controller);
    }

    /** {@inheritDoc} **/
    @Override
    public void run() {
        authSetup.startProvisioningThread();
        controller.initializeStopCaptureHandler(this);
        controller.startHandlingDirectives();
    }
    
    private void onWakeWordDetected2() {
    	controller.onUserActivity();
    	final RecordingRMSListener rmsListener = this;
        if (state == ClientState.START) { // if in idle mode
            state = ClientState.STOP;
            final RequestListener requestListener = new RequestListener() {
                @Override
                public void onRequestSuccess() {
                    finishProcessing();
                }
                @Override
                public void onRequestError(Throwable e) {
                    log.error("An error occured creating speech request", e);
                    onWakeWordDetected2();
                    finishProcessing();
                }
            };
            controller.startRecording(rmsListener, requestListener);
        }
        else { // else we must already be in listening
            state = ClientState.PROCESSING;
            controller.stopRecording(); // stop the recording so the request can complete
        }
    }

    /**
     * 
     */
    public void finishProcessing() {
    	state = ClientState.START;
        controller.processingFinished();
    }

    /** {@inheritDoc} **/
    @Override
    public void rmsChanged(int rms) { // AudioRMSListener callback
        // OLD : visualizer.setValue(rms); // update the visualizer
    }

    /** {@inheritDoc} **/
    @Override
    public void onExpectSpeechDirective() {
        final Thread thread = new Thread() {
            @Override
            public void run() {
                while (state != ClientState.START || controller.isSpeaking()) {
                    try {
                        Thread.sleep(500);
                    }
                    catch (final Exception e) {
                    }
                }
                onWakeWordDetected2();
            }
        };
        thread.start();
    }

    /** {@inheritDoc} **/
    @Override
    public void onStopCaptureDirective() {
        if (state == ClientState.STOP) {
            onWakeWordDetected2();
        }
    }
    
    /** {@inheritDoc} **/
    @Override
    public void displayRegCode(final String registrationCode) {
    	final CompanionServiceInformation information = deviceConfig.getCompanionServiceInfo();
    	final StringBuilder builder = new StringBuilder();
    	builder
    		.append(information.getServiceUrl())
    		.append("/provision/")
    		.append(registrationCode);
    	final String url = builder.toString();
    	System.out.println("Registration URL : " + url);
    	// TODO : Send post request to http://localhost:6969/registration/url
    }

    /** {@inheritDoc} **/
    @Override
    public synchronized void onAccessTokenReceived(final String accessToken) {
    	controller.onUserActivity();
        authSetup.onAccessTokenReceived(accessToken);
    }

    /** {@inheritDoc} **/
    @Override
    public synchronized void onWakeWordDetected() {
        if (state == ClientState.START) { // if in idle mode
            log.info("Wake Word was detected");
            onWakeWordDetected2();
        }
    }

    /**
     * Client entry point.
     * 
     * @param args Command line parameters.
     * @throws Exception If any error occurs while executing client.
     */
    public static void main(final String[] args) throws Exception {
    	final DeviceConfig configuration = getDeviceConfiguration(args);
    	final AVSApp application = new AVSApp(configuration);
    	application.run();
    	
    }
    
    /**
     * 
     * @param args
     * @return
     */
    private static DeviceConfig getDeviceConfiguration(final String [] args) {
    	if (args.length == 0) {
    		return DeviceConfigUtils.readConfigFile();
    	}
    	return DeviceConfigUtils.readConfigFile(args[0]);
    }
    
}
