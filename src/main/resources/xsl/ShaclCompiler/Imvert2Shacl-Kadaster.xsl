<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ekf="http://EliotKimber/functions"

    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="stylesheet-code">SHACL</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:value-of select="imf:ttl(('# Generated by ', imf:get-config-string('run','version')))"/>
        <xsl:value-of select="imf:ttl(('# Generated at ', imf:get-config-string('run','start')))"/>
        <xsl:value-of select="imf:ttl(())"/>
        
        <!-- 
            read the configured info 
        -->
        <xsl:apply-templates select="$configuration-shaclrules-file//vocabulary" mode="preamble"/>
      
        <xsl:value-of select="imf:ttl(())"/>
        <!-- 
            process the imvertor info 
        -->
        <xsl:apply-templates select="/imvert:packages/imvert:package" mode="mode-object"/>
        
    </xsl:template>
   
    <xsl:template match="vocabulary" mode="preamble">
        <xsl:value-of select="imf:ttl(('@prefix ',prefix,': &lt;', URI ,'&gt;.'))"/>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="mode-object">
        <xsl:apply-templates select="imvert:class" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')]" mode="mode-object">
            <xsl:variable name="this" select="."/>
        
        <xsl:value-of select="imf:ttl-construct($this)"/>
        <xsl:value-of select="imf:ttl(('data:',$this/imvert:name,' rdf:type kkg:Objecttype;'))"/>
        <xsl:value-of select="imf:ttl((' kkg:naam ',imf:ttl-value($this/imvert:name,'1q'),';'))"/>
        <xsl:sequence select="imf:ttl-get-all-tvs($this)"/>
        
        <!-- loop door alle attributen en associaties heen, en plaats een property (predicate object)-->
        <xsl:apply-templates select="$this/imvert:attributes/imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attribute')]" mode="mode-object"/>
        <xsl:apply-templates select="$this/imvert:attributes/imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attributegroup')]" mode="mode-object"/>
        <xsl:apply-templates select="$this/imvert:associations/imvert:association[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relation-role')]" mode="mode-object"/>
       
        <xsl:value-of select="imf:ttl('.')"/>
        
        <!-- loop door alle attributen en associaties heen, en maak daarvoor een subject -->
        <xsl:apply-templates select="$this/imvert:attributes/imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attribute')]" mode="mode-subject"/>
        <xsl:apply-templates select="$this/imvert:attributes/imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attributegroup')]" mode="mode-subject"/>
        <xsl:apply-templates select="$this/imvert:associations/imvert:association[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relation-role')]" mode="mode-subject"/>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attribute')]" mode="mode-object">
        <xsl:variable name="this" select="."/>
        <xsl:value-of select="imf:ttl((' kkg:bezitAttribuutsoort data:',$this/imvert:name, ';'))"/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attribute')]" mode="mode-subject">
        <xsl:variable name="this" select="."/>
        
        <xsl:value-of select="imf:ttl-construct($this)"/>
        <xsl:value-of select="imf:ttl(('data:',$this/imvert:name,' rdf:type kkg:Attribuutsoort;'))"/>
        <xsl:value-of select="imf:ttl((' kkg:naam ',imf:ttl-value($this/imvert:name,'1q'),';'))"/>
        
        <xsl:variable name="defining-class" select="imf:ttl-get-defining-class($this)"/>
        <xsl:value-of select="if (exists($defining-class)) then imf:ttl((' kkg:heeftDatatype data:',$defining-class/imvert:name,';')) else ()"/>

        <xsl:sequence select="imf:ttl-get-all-tvs($this)"/>
        
        <xsl:value-of select="imf:ttl('.')"/>
        
    </xsl:template>
    
        
    <xsl:template match="node()" mode="#all">
        <!-- skip -->        
    </xsl:template>
    
    <xsl:function name="imf:ttl" as="xs:string">
        <xsl:param name="parts" as="item()*"/>
        <xsl:value-of select="string-join(($parts,'&#10;'),'')"/>
    </xsl:function>
    
    <xsl:function name="imf:ttl-construct" as="xs:string">
        <xsl:param name="this" as="item()*"/>
        <xsl:value-of select="imf:ttl(('# Construct: ',imf:get-display-name($this), ' (', string-join($this/imvert:stereotype,', '),')'))"/>
    </xsl:function>
    
    <xsl:variable name="str3quot">'''</xsl:variable>
    <xsl:variable name="str1quot">"</xsl:variable>
    
    <!-- return (name, type) sequence -->
    <xsl:function name="imf:ttl-map" as="element(map)?">
        <xsl:param name="id"/>
        <xsl:sequence select="$configuration-shaclrules-file//node-mapping/map[@id=$id]"/>
    </xsl:function>
    
    <xsl:function name="imf:ttl-value">
        <xsl:param name="string"/>
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = '3q'">
                <xsl:value-of select="concat($str3quot,$string,$str3quot)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($str1quot,$string,$str1quot)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Haal alle tagged values op in TTL statement formaat.
        Dit zijn alle relevante tv's, dus ook die waarvan de waarde is afgeleid.
    -->
    <xsl:function name="imf:ttl-get-all-tvs">
        <xsl:param name="this"/>
        <!-- loop door alle tagged values heen -->
        <xsl:for-each select="imf:get-config-applicable-tagged-value-ids($this)">
            <xsl:variable name="tv" select="imf:get-most-relevant-compiled-taggedvalue-element($this,concat('##',.))"/>
            <xsl:variable name="map" select="imf:ttl-map($tv/@id)"/>
            <xsl:if test="exists($tv) and exists($map)">
                <xsl:value-of select="imf:ttl((' ', $map, ' ', imf:ttl-value($tv/@value,$map/@type),';'))"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
        return for passed attribute or assoc the class when this is defined in terms of classes 
    -->
    <xsl:function name="imf:ttl-get-defining-class" as="element()?">
        <xsl:param name="this"/>
        <xsl:variable name="type-id" select="$this/imvert:type-id"/>
        <xsl:if test="exists($type-id)">
            <xsl:sequence select="$document-classes[imvert:id = $type-id]"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>