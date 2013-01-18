<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bf="http://www.betterform.de/xsl/fn" 
    version="3.0">
    <xsl:output indent="yes" encoding="UTF-8" />


    <!-- "
       @TODO: Footnotes 
    -->
    <xsl:template match="/">
        <xsl:variable name="rootNorm" select="//norm[1]"></xsl:variable>
        <code jurabk="{$rootNorm//jurabk}" ausfertigung-datum="{$rootNorm//ausfertigung-datum}">    
            <xsl:copy-of select="$rootNorm/metadaten"/>
            <xsl:apply-templates select="$rootNorm//textdaten" mode="text"/>
            <xsl:apply-templates/>
        </code>        
    </xsl:template>
    
    
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=3]">
        <xsl:variable name="level1Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level1Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level1Title" select="normalize-space(.//gliederungstitel)"/>
        
        <level1 gliederungskennzahl="{$level1Key}" gliederungsbez="{$level1Identifier}" gliederungstitel="{$level1Title}" doknr="{@doknr}">
            <xsl:apply-templates select=".//Content" mode="text"/>
            
            <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                <xsl:with-param name="gliederungskennzahl" select="$level1Key"/>
            </xsl:apply-templates>                        
            
            <xsl:apply-templates select="following-sibling::*"  mode="level2">
                <xsl:with-param name="level1Key" select="$level1Key"/>                
            </xsl:apply-templates>
        </level1>
    </xsl:template>
    
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=6]" mode="level2">
        <xsl:param name="level1Key" />
        
        <xsl:variable name="level2Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level2Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level2Title" select="normalize-space(.//gliederungstitel)"/>        
        <xsl:choose>
            <xsl:when test="starts-with($level2Key, $level1Key)">
                <level2 gliederungskennzahl="{$level2Key}" gliederungsbez="{$level2Identifier}" gliederungstitel="{$level2Title}" doknr="{@doknr}">
                    <xsl:apply-templates select=".//Content" mode="text"/>
                    
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level2Key"/>
                    </xsl:apply-templates>                        
                    
                    <xsl:apply-templates select="following-sibling::*" mode="level3">
                        <xsl:with-param name="level2Key" select="$level2Key"/>
                    </xsl:apply-templates>
                </level2>
                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=9]" mode="level3">
        <xsl:param name="level2Key" />
        
        <xsl:variable name="level3Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level3Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level3Title" select="normalize-space(.//gliederungstitel)"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($level3Key, $level2Key)">
                <level3 gliederungskennzahl="{$level3Key}" gliederungsbez="{$level3Identifier}" gliederungstitel="{$level3Title}" doknr="{@doknr}">
                    <xsl:apply-templates select=".//Content" mode="text"/>
                    
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level3Key"/>
                    </xsl:apply-templates>                        
                    
                    <xsl:apply-templates select="following-sibling::*" mode="level4">
                        <xsl:with-param name="level3Key" select="$level3Key"/>
                    </xsl:apply-templates>
                </level3>
                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=12]" mode="level4">
        <xsl:param name="level3Key" />
        
        <xsl:variable name="level4Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level4Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level4Title" select="normalize-space(.//gliederungstitel)"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($level4Key, $level3Key)">
                <level4 gliederungskennzahl="{$level4Key}" gliederungsbez="{$level4Identifier}" gliederungstitel="{$level4Title}" doknr="{@doknr}">
                    <xsl:apply-templates select=".//Content" mode="text"/>
                    
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level4Key"/>
                    </xsl:apply-templates>                        
                   
                    <xsl:apply-templates select="following-sibling::*" mode="level5">
                        <xsl:with-param name="level4Key" select="$level4Key"/>
                    </xsl:apply-templates>
                </level4>                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=15]" mode="level5">
        <xsl:param name="level4Key" />
        
        <xsl:variable name="level5Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level5Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level5Title" select="normalize-space(.//gliederungstitel)"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($level5Key, $level4Key)">
                <level5 gliederungskennzahl="{$level5Key}" gliederungsbez="{$level5Identifier}" gliederungstitel="{$level5Title}" doknr="{@doknr}">
                    <xsl:apply-templates select=".//Content" mode="text"/>
                    
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level5Key"/>
                    </xsl:apply-templates>                        
                    
                    <xsl:apply-templates select="following-sibling::*" mode="level6">
                        <xsl:with-param name="level5Key" select="$level5Key"/>
                    </xsl:apply-templates>
                </level5>                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="norm[string-length(.//gliederungskennzahl)=18]" mode="level6">
        <xsl:param name="level5Key" />
        
        <xsl:variable name="level6Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level6Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level6Title" select="normalize-space(.//gliederungstitel)"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($level6Key, $level5Key)">
                <level6 gliederungskennzahl="{$level6Key}" gliederungsbez="{$level6Identifier}" gliederungstitel="{$level6Title}" doknr="{@doknr}">
                    <xsl:apply-templates select=".//Content" mode="text"/>
                    
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level6Key"/>
                    </xsl:apply-templates>                        

                    <xsl:apply-templates select="following-sibling::*" mode="level7">
                        <xsl:with-param name="level6Key" select="$level6Key"/>
                    </xsl:apply-templates>
                </level6>                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>

    <xsl:template match="norm[string-length(.//gliederungskennzahl)=21]" mode="level7">
        <xsl:param name="level6Key" />
        
        <xsl:variable name="level7Key" select=".//gliederungskennzahl"/>
        <xsl:variable name="level7Identifier" select=".//gliederungsbez"/>
        <xsl:variable name="level7Title" select="normalize-space(.//gliederungstitel)"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($level7Key, $level6Key)">
                <level7 gliederungskennzahl="{$level7Key}" gliederungsbez="{$level7Identifier}" gliederungstitel="{$level7Title}" doknr="{@doknr}">
                    <xsl:apply-templates select=".//Content" mode="text"/>
                    
                    <xsl:apply-templates select="following-sibling::*" mode="paragraphs">
                        <xsl:with-param name="gliederungskennzahl" select="$level7Key"/>
                    </xsl:apply-templates>                        
                </level7>                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="norm" mode="paragraphs" >        
        <xsl:param name="gliederungskennzahl"/>        
        <xsl:variable name="prevGliederung" select="preceding-sibling::norm[exists(.//gliederungskennzahl)][1]"/>
        
        <xsl:choose>
            <xsl:when test="$prevGliederung//gliederungskennzahl = $gliederungskennzahl and not(exists(.//gliederungskennzahl))">
                <norm doknr="{@doknr}" enbez="{./metadaten/enbez}" jurabk="{./metadaten/jurabk}">
                    <title><xsl:value-of select="./metadaten/titel"></xsl:value-of></title>
                    <xsl:apply-templates select=".//Content" mode="text"/>    
                </norm>
                                                                   
            </xsl:when>
        </xsl:choose>                
    </xsl:template>
    

    <xsl:template match="textdaten" mode="text" >        
        <textdaten>
            <xsl:apply-templates mode="text"/>
        </textdaten>        
    </xsl:template>

    <xsl:template match="text" mode="text" >        
        <text>
            <xsl:apply-templates mode="text"/>
        </text>        
    </xsl:template>

    <xsl:template match="fussnoten" mode="text" >        
        <fussnoten>
            <xsl:apply-templates mode="text"/>
        </fussnoten>        
    </xsl:template>
    

    <xsl:template match="Content|BR" mode="text" >        
            <xsl:apply-templates mode="text"/>          
    </xsl:template>
    
    <xsl:template match="noindex" mode="text">
        <text>
            <xsl:for-each select="text()" >
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:for-each>
        </text>
        <xsl:apply-templates select="*" mode="text"/>
    </xsl:template>
   
        
    
    <xsl:template match="P" mode="text"> 
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()" mode="text"/>
        </xsl:copy>
    </xsl:template>
    
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
    
    
    
    <xsl:template match="DL" mode="text"> 
        <list>        
            <xsl:apply-templates select="*|@*" mode="text"/>
        </list>        
    </xsl:template>
    
    <xsl:template match="DT" mode="text"> 
        <item id="{normalize-space(.)}">    
            <xsl:apply-templates select="./following-sibling::*[1]/LA" mode="text"/>
        </item>
        
    </xsl:template>    

    <xsl:template match="LA" mode="text">         
        <xsl:apply-templates select="*|text()|comment()" mode="text"/>
    </xsl:template>
    
    <xsl:template match="pre" mode="text">
        <xsl:copy-of select="normalize-space(text()[1])"/>
        <list>
            <xsl:for-each select="BR">
                <item><xsl:value-of select="normalize-space(following-sibling::text()[1])"/></item>
            </xsl:for-each>
        </list>
       
    </xsl:template>

    

    <xsl:template match="text()" mode="text" priority="10">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    
    <xsl:template match="*|@*|text()|comment()" mode="#all">
        <xsl:apply-templates select="@* | *"/>                  
    </xsl:template>
    
</xsl:stylesheet>