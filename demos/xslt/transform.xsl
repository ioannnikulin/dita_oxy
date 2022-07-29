<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:template match = "div[@outputclass='tabs']">
        <div>
            <xsl:attribute name = "class" select = "concat('tabs ', ./@class)"/>
        <xsl:apply-templates mode="tabs"/>
        </div>
    </xsl:template>
    
    <xsl:template match = "ul" mode = "tabs">
        <ul>
        <xsl:for-each select = "li">
            <li>
            <xsl:apply-templates mode="tab_head"/>
            </li>
        </xsl:for-each>
        </ul>
    </xsl:template>
    
    <xsl:template match = "div" mode = "tab_head">
    <xsl:element name = "a">
        <xsl:attribute name = "href" select = "./@outputclass"/>
        <xsl:apply-templates/>
    </xsl:element>
    </xsl:template>
    
    <xsl:template match = "div" mode = "tabs">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy><xsl:apply-templates/></xsl:copy>
    </xsl:template>
</xsl:stylesheet>