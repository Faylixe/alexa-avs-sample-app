<?xml version="1.0">
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/configuration">
    [req]
    distinguished_name      = req_distinguished_name
    prompt                  = no

    [v3_req]
    subjectAltName          = @alt_names

    [alt_names]
    DNS.1                   = localhost
    IP.1                    = 127.0.0.1
    IP.2                    = 10.0.2.2

    [req_distinguished_name]
    commonName              = $ENV::COMMON_NAME
    countryName             = <xsl:valueof select="profile/country"/>
    stateOrProvinceName     = <xsl:valueof select="profile/state"/>
    localityName            = <xsl:valueof select="profile/city"/>
    organizationName        = <xsl:valueof select="profile/organization"/>
    organizationalUnitName  = <xsl:valueof select="profile/organization"/>
  </xsl:template>
</xsl:stylesheet>
