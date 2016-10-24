<?xml version="1.0">
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="javaclient"></xsl:param>
  <xsl:template match="/configuration">
    /**
     * @module
     * This module defines the settings that need to be configured for a new
     * environment.
     * The clientId and clientSecret are provided when you create
     * a new security profile in Login with Amazon.
     *
     * You will also need to specify
     * the redirect url under allowed settings as the return url that LWA
     * will call back to with the authorization code.  The authresponse endpoint
     * is setup in app.js, and should not be changed.
     *
     * lwaRedirectHost and lwaApiHost are setup for login with Amazon, and you should
     * not need to modify those elements.
     */
    var config = {
        clientId: "<xsl:valueof select="credentials/application/clientId"/>",
        clientSecret: "<xsl:valueof select="credentials/application/clientSecret"/>",
        redirectUrl: 'https://localhost:3000/authresponse',
        lwaRedirectHost: "amazon.com",
        lwaApiHost: "api.amazon.com",
        validateCertChain: true,
        sslKey: "<xsl:valueof select="$javaclient"/>/certs/server/node.key",
        sslCert: "<xsl:valueof select="$javaclient"/>/certs/server/node.crt",
        sslCaCert: "<xsl:valueof select="$javaclient"/>/certs/ca/ca.crt",
        products: {
            "<xsl:valueof select="credentials/application/productId"/>": ["<xsl:valueof select="device/serialNumber"/>"],
        },
    };

    module.exports = config;
  <xsl:template>
</xsl:stylesheet>
