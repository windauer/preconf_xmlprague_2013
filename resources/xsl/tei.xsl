<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:output indent="yes"/>
    <xsl:template match="code">
        <TEI>
            <xsl:apply-templates select="metadaten"/>
            <text>
                <front>
                    <xsl:apply-templates select="textdaten"/>
                </front>
                <body>
                    <xsl:apply-templates select="level1|level2|level3|level4"/>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <xsl:template match="metadaten">
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
    <xsl:template match="level1|level2|level3|level4">
        <div>
            <head>
                <xsl:value-of select="@gliederungsbez"/>
            </head>
            <head type="subtitle">
                <xsl:value-of select="@gliederungstitel"/>
            </head>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="norm">
        <div>
            <head type="short">
                <xsl:value-of select="@enbez"/>
            </head>
            <xsl:apply-templates/>
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
                <xsl:when test="list|text">
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