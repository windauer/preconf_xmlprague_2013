<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bf="http://www.betterform.de/xsl/fn" xmlns:uuid="java:java.util.UUID" version="3.0" exclude-result-prefixes="bf uuid">
    <xsl:output indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    
    
    <!-- 
       @TODO: Footnotes 
    -->
    <xsl:template match="/">
        <xsl:variable name="rootNorm" select="//norm[1]"/>
        <norm uuid="{uuid:randomUUID()}" level="0">
            <!-- COPPY CURRENT NORM -->
            <xsl:apply-templates select="$rootNorm" mode="copyNormData"/>
            
            <!-- "STEP DEEPER" -->
            <xsl:apply-templates/>
        </norm>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=3]">
        <xsl:variable name="level1Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level1Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level1Title" select="normalize-space(.//gliederungstitel)"/>
        
        <!-- <level1 gliederungskennzahl="{$level1Key}" gliederungsbez="{$level1Identifier}" gliederungstitel="{$level1Title}" doknr="{@doknr}" uuid="{uuid:randomUUID()}"> -->
        <norm uuid="{uuid:randomUUID()}" level="1">
            <!-- COPPY CURRENT NORM -->
            <xsl:apply-templates select="." mode="copyNormData"/>
            
            <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
            <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                <xsl:with-param name="gliederungskennzahl" select="$level1Key"/>
            </xsl:apply-templates>                        
            
            <!-- "STEP DEEPER" -->
            <xsl:apply-templates select="following-sibling::*" mode="level2">
                <xsl:with-param name="level1Key" select="$level1Key"/>
            </xsl:apply-templates>
        </norm>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=6]" mode="level2">
        <xsl:param name="level1Key"/>
        <xsl:variable name="level2Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level2Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level2Title" select="normalize-space(.//gliederungstitel)"/>
        <xsl:choose>
            <xsl:when test="starts-with($level2Key, $level1Key)">
                <norm uuid="{uuid:randomUUID()}" level="2">
                    <!-- COPPY CURRENT NORM -->
                    <xsl:apply-templates select="." mode="copyNormData"/>
                    
                    <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level2Key"/>
                    </xsl:apply-templates>                        
                    
                    <!-- "STEP DEEPER" -->
                    <xsl:apply-templates select="following-sibling::*" mode="level3">
                        <xsl:with-param name="level2Key" select="$level2Key"/>
                    </xsl:apply-templates>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=9]" mode="level3">
        <xsl:param name="level2Key"/>
        <xsl:variable name="level3Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level3Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level3Title" select="normalize-space(.//gliederungstitel)"/>
        <xsl:choose>
            <xsl:when test="starts-with($level3Key, $level2Key)">
                <norm uuid="{uuid:randomUUID()}" level="3">
                    <!-- COPPY CURRENT NORM -->
                    <xsl:apply-templates select="." mode="copyNormData"/>
                    
                    <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level3Key"/>
                    </xsl:apply-templates>                        
                    
                    <!-- "STEP DEEPER" -->
                    <xsl:apply-templates select="following-sibling::*" mode="level4">
                        <xsl:with-param name="level3Key" select="$level3Key"/>
                    </xsl:apply-templates>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=12]" mode="level4">
        <xsl:param name="level3Key"/>
        <xsl:variable name="level4Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level4Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level4Title" select="normalize-space(.//gliederungstitel)"/>
        <xsl:choose>
            <xsl:when test="starts-with($level4Key, $level3Key)">
                <norm uuid="{uuid:randomUUID()}" level="4">
                    <!-- COPPY CURRENT NORM -->
                    <xsl:apply-templates select="." mode="copyNormData"/>
                    
                    <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level4Key"/>
                    </xsl:apply-templates>                        
                   
                    <!-- "STEP DEEPER" -->
                    <xsl:apply-templates select="following-sibling::*" mode="level5">
                        <xsl:with-param name="level4Key" select="$level4Key"/>
                    </xsl:apply-templates>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=15]" mode="level5">
        <xsl:param name="level4Key"/>
        <xsl:variable name="level5Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level5Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level5Title" select="normalize-space(.//gliederungstitel)"/>
        <xsl:choose>
            <xsl:when test="starts-with($level5Key, $level4Key)">
                <norm uuid="{uuid:randomUUID()}" level="5">
                    <!-- COPPY CURRENT NORM -->
                    <xsl:apply-templates select="." mode="copyNormData"/>

                    <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level5Key"/>
                    </xsl:apply-templates>                        
                    
                    <!-- "STEP DEEPER" -->
                    <xsl:apply-templates select="following-sibling::*" mode="level6">
                        <xsl:with-param name="level5Key" select="$level5Key"/>
                    </xsl:apply-templates>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=18]" mode="level6">
        <xsl:param name="level5Key"/>
        <xsl:variable name="level6Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level6Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level6Title" select="normalize-space(.//gliederungstitel)"/>
        <xsl:choose>
            <xsl:when test="starts-with($level6Key, $level5Key)">
                <norm uuid="{uuid:randomUUID()}" level="6">
                    <!-- COPPY CURRENT NORM -->
                    <xsl:apply-templates select="." mode="copyNormData"/>
                    
                    <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level6Key"/>
                    </xsl:apply-templates>                        

                    <!-- "STEP DEEPER" -->
                    <xsl:apply-templates select="following-sibling::*" mode="level7">
                        <xsl:with-param name="level6Key" select="$level6Key"/>
                    </xsl:apply-templates>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=21]" mode="level7">
        <xsl:param name="level6Key"/>
        <xsl:variable name="level7Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level7Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level7Title" select="normalize-space(.//gliederungstitel)"/>
        <xsl:choose>
            <xsl:when test="starts-with($level7Key, $level6Key)">
                <norm uuid="{uuid:randomUUID()}" level="7">
                    <!-- COPPY CURRENT NORM -->
                    <xsl:apply-templates select="." mode="copyNormData"/>
                    
                    <!-- COPPY CHILD NORMS BELONGING TO CURRENT NORM -->
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level7Key"/>
                    </xsl:apply-templates>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- COPY DIRECT CHILD NORMS OF THE CALLING NORM" -->
    <xsl:template match="norm" mode="paragraphs">
        <xsl:param name="gliederungskennzahl"/>
        <xsl:variable name="prevGliederung" select="preceding-sibling::norm[exists(.//gliederungskennzahl)][1]"/>
        <xsl:choose>
            <xsl:when test="$prevGliederung//gliederungskennzahl = $gliederungskennzahl and not(exists(.//gliederungskennzahl))">
                <norm uuid="{uuid:randomUUID()}">
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*"/>
                </norm>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- COPY THE NORM DATA OF HIERARCHICAL NORMS -->
    <xsl:template match="norm" mode="copyNormData">
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="*"/>
    </xsl:template>
    <xsl:template match="text()" mode="#all" priority="10">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="*|@*|text()|comment()" mode="#all">
        <xsl:apply-templates select="@* | *"/>
    </xsl:template>
</xsl:stylesheet>