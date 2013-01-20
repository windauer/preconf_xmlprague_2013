<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:output indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="norm">
        <norm uuid="{@uuid}">
            <xsl:attribute name="level">
                <xsl:choose>
                    <xsl:when test="not(exists(@level))">
                        <xsl:value-of select="number(../@level) + 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@level"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="exists(metadaten/enbez)">
                <xsl:attribute name="paragraph" select="normalize-space(metadaten/enbez)"/>
            </xsl:if>
            <xsl:if test="exists(metadaten/titel)">
                <xsl:attribute name="title" select="normalize-space(metadaten/titel)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </norm>
    </xsl:template>
    <xsl:template match="*|@*|text()">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>