<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <TEI>
            <xsl:attribute name="xml:id" select="norm/@doknr"/>
            <xsl:apply-templates select="norm/metadaten" mode="header"/>
            <text>
                <front>
                    <xsl:apply-templates select="norm/textdaten"/>
                </front>
                <body>
                    <xsl:apply-templates select="norm/norm"/>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <xsl:template match="metadaten" mode="header">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>
                        <xsl:value-of select="langue"/>
                    </title>
                    <title type="short">
                        <xsl:value-of select="(jurabk|amtabk)[1]"/>
                    </title>
                </titleStmt>
                <publicationStmt>
                    <date>
                        <xsl:value-of select="ausfertigung-datum"/>
                    </date>
                </publicationStmt>
            </fileDesc>
        </teiHeader>
    </xsl:template>
    <xsl:template match="textdaten">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="norm[norm]">
        <div>
            <head>
                <xsl:value-of select="metadaten/gliederungseinheit/gliederungsbez"/>
            </head>
            <head type="subtitle">
                <xsl:value-of select="metadaten/gliederungseinheit/gliederungstitel"/>
            </head>
            <xsl:apply-templates select="norm"/>
        </div>
    </xsl:template>
    <xsl:template match="norm">
        <div>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <head>
                <xsl:value-of select="metadaten/enbez"/>
            </head>
            <xsl:apply-templates select="textdaten"/>
        </div>
    </xsl:template>
    <xsl:template match="title">
        <head>
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    <xsl:template match="P">
        <xsl:if test=".//text()">
            <xsl:choose>
                <xsl:when test="OL|UL|DL|text">
                    <xsl:for-each select="node()">
                        <xsl:choose>
                            <xsl:when test=". instance of text()">
                                <p>
                                    <xsl:value-of select="."/>
                                </p>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="OL">
        <list type="ordered">
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="UL">
        <list>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="DL">
        <list type="gloss">
            <xsl:apply-templates select="DT|DD"/>
        </list>
    </xsl:template>
    <xsl:template match="DT">
        <label>
            <xsl:apply-templates/>
        </label>
    </xsl:template>
    <xsl:template match="LI|DD">
        <item>
            <xsl:apply-templates/>
        </item>
    </xsl:template>
    <xsl:template match="list">
        <list>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="item">
        <item>
            <xsl:if test="@id">
                <xsl:attribute name="n" select="@id"/>
            </xsl:if>
            <xsl:apply-templates/>
        </item>
    </xsl:template>
</xsl:stylesheet>