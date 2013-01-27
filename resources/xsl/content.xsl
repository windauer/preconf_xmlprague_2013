<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:output indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <xsl:apply-templates select="norm"/>
    </xsl:template>
    <xsl:template match="norm">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="metadaten|textdaten" mode="text"/>
            <xsl:apply-templates select="norm"/>
        </xsl:copy>
    </xsl:template>
               
    <!-- LIST -->
    <xsl:template match="DL" mode="text" priority="5">
        <list>
            <xsl:apply-templates mode="text"/>
        </list>
    </xsl:template>
    
    <!-- BRING DT / DD / LA in shape -->
    <xsl:template match="DT" mode="text" priority="5">
        <item id="{normalize-space(.)}">
            <xsl:apply-templates select="./following-sibling::DD[1]/LA" mode="text"/>
        </item>
    </xsl:template>    
    
    <!-- IGNORE -->
    <xsl:template match="DD" mode="text" priority="5"/>
    <xsl:template match="Content" mode="text" priority="5">
        <xsl:apply-templates mode="text"/>
    </xsl:template>
    <xsl:template match="LA" mode="text" priority="5">
        <xsl:apply-templates mode="text"/>
    </xsl:template>
    <xsl:template match="*" mode="text">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|comment()" mode="text"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*" mode="#all">
        <xsl:copy>
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()" mode="#all">
        <xsl:choose>
            <xsl:when test="exists(./preceding-sibling::BR) and not(exists(./following-sibling::BR))">
                <line>
                    <xsl:copy-of select="normalize-space(.)"/>
                </line>
            </xsl:when>
            <xsl:when test="exists(not(./preceding-sibling::BR)) and exists(./following-sibling::BR)">
                <line>
                    <xsl:copy-of select="normalize-space(.)"/>
                </line>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="normalize-space(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="BR" mode="text"/>
    <!-- 
        
        
        
   <xsl:template match="FnR" mode="text">         
        <xsl:variable name="key" select="normalize-space(@ID)"/>
        <footnote sd="sd">
            <xsl:apply-templates select="//Footnote[@ID=$key]" mode="text"/>
        </footnote>
    </xsl:template>
    
    <xsl:template match="Footnote" mode="text">
        <header><xsl:value-of select="B"/></header>
        <xsl:for-each select="BR">
            <xsl:variable name="desc" select="following-sibling::text()[1]"/>
            <xsl:if test="exists($desc)">
                <desc><xsl:apply-templates select="$desc" mode="text"/></desc>    
            </xsl:if>
            <xsl:variable name="next" select="following-sibling::*[1]"/>
            <xsl:if test="exists($next)">
                <item><xsl:apply-templates select="$next" mode="text"/></item>
            </xsl:if>            
        </xsl:for-each>
        
    </xsl:template>
    
            
    <xsl:template match="pre" mode="text">
        <xsl:copy-of select="normalize-space(text()[1])"/>
        <list>
            <xsl:for-each select="BR">
                <item><xsl:value-of select="normalize-space(following-sibling::text()[1])"/></item>
            </xsl:for-each>
        </list>
        
    </xsl:template>
    -->
</xsl:stylesheet>