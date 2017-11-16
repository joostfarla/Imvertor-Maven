<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:import href="imvert-common-prettyprint.xsl"/>
    
    <xsl:variable name="xml-indented" as="element()">
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="yes"/>
        </output:serialization-parameters>
    </xsl:variable>
  
    <xsl:variable name="xml-not-indented" as="element()">
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="no"/>
        </output:serialization-parameters>
    </xsl:variable>
    
    <xsl:function name="imf:debug-document">
        <xsl:param name="sequence" as="item()*"/>
        <xsl:param name="filename" as="xs:string"/>
        <xsl:param name="prettyprint" as="xs:boolean"/>
        <xsl:param name="prettyprint-with-mixed-content" as="xs:boolean"/>
        
        <xsl:variable name="path" select="concat('c:/temp/', $filename)"/>
        
        <xsl:variable name="sequence-with-wrapper">
            <DEBUG-DOCUMENT>
                <xsl:sequence select="$sequence"/>
            </DEBUG-DOCUMENT>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$debugging">
                <xsl:sequence select="imf:msg('DEBUG','Writing [1] debug document to [2]',((if ($prettyprint) then 'pretty printed' else 'straight printed'), $path))"/>
                <xsl:variable name="doc">
                    <xsl:choose>
                        <xsl:when test="$prettyprint">
                            <xsl:sequence select="imf:pretty-print($sequence-with-wrapper,$prettyprint-with-mixed-content)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$sequence-with-wrapper"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:sequence select="imf:expath-write($path,$doc,if ($prettyprint) then $xml-indented else $xml-not-indented)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>