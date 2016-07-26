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
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.kadaster.nl/schemas/imvertor/application/v20141001"
    
    version="2.0">

    <!--
        This stylesheet processes the context document by calling the generated comparision stylesheet 
        and implementing the report template to return a neat overview of all differences 
        to be listed later in table format in the /doc section.
    -->
   
    <xsl:import href="Imvert2compare-common.xsl"/>
    
    <!-- this import file is generated by the xml-to-diff.xsl meta-stylesheet -->
   
    <xsl:import href="http://www.imvertor.org/imvertor/1.0/xslt/compare/compare-generated.xsl"/><!-- resolved by catalog! -->
    
    <xsl:output indent="no"/>
    
    <xsl:variable name="ctrl-url" select="concat('file:/', replace($ctrl-filepath,'\\','/'))"/>
    <xsl:variable name="test-url" select="concat('file:/', replace($test-filepath,'\\','/'))"/>
    
    <xsl:variable name="ctrl-doc" select="document($ctrl-url)"/>
    <xsl:variable name="test-doc" select="document($test-url)"/>

    <xsl:variable name="diffs">
        <xsl:apply-templates select="$ctrl-doc/*" mode="compare"/> <!-- returns a sequence of diff elements -->
    </xsl:variable>
    
    <xsl:template match="/">
        <imvert:report>
            <imvert:ctrl>
                <xsl:value-of select="$ctrl-url"/>
            </imvert:ctrl>           
            <imvert:test>
                <xsl:value-of select="$test-url"/>
            </imvert:test>           
            <xsl:for-each-group select="$diffs/imvert:diff" group-by="@ctrl-id">
                <imvert:diffs ctrl-id="{@ctrl-id}">
                    <xsl:for-each select="current-group()">
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </imvert:diffs>
            </xsl:for-each-group>
            <xsl:variable name="diffs">
                <xsl:apply-templates select="$test-doc/*" mode="compare"/> <!-- returns a sequence of diff elements -->
            </xsl:variable>
            <xsl:for-each-group select="$diffs/imvert:diff" group-by="@test-id">
                <imvert:diffs test-id="{@test-id}">
                    <xsl:for-each select="current-group()">
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </imvert:diffs>
            </xsl:for-each-group>
        </imvert:report>
    </xsl:template>
    
    <!-- 
        This is the default reporting on the differences found
        Any specific context should implement its own variant 
    -->
    <xsl:template name="report">
        <xsl:param name="ctrl" as="item()?"/>
        <xsl:param name="test" as="item()?"/>
        <xsl:param name="diff" as="document-node()"/>
        
        <xsl:variable name="desc-raw" select="$diff/diff/@desc"/>
        <xsl:variable name="base" select="ancestor-or-self::*[parent::*:root-of-compare]"/>
        <xsl:variable name="type" select="ancestor-or-self::*[parent::* = $base]"/>
        <xsl:variable name="compos" select="$base/*:compos"/>
        
        <xsl:variable name="desc">
            <xsl:choose>
                <xsl:when test="$desc-raw = 'sequence of child nodes'">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'number of child nodes'">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'presence of child node' and exists($ctrl) and $ctrl = '#text'">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'text value' and not(normalize-space($ctrl)) and not(normalize-space($test))">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'presence of child node' and exists($ctrl) and not(normalize-space($ctrl))">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'presence of child node' and exists($ctrl)">
                    <xsl:value-of select="'removed'"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'presence of child node' and exists($test)">
                    <xsl:value-of select="'added'"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'presence of child nodes to be' and exists($test)"> <!-- TODO check this, is this correct? -->
                    <xsl:value-of select="'added'"/>
                </xsl:when>
                <xsl:when test="$desc-raw = 'text value'">
                    <xsl:value-of select="'value'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="concat('Unknown or unexpected compare state: ', $desc-raw)"/>
                    <xsl:value-of select="$desc-raw"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$desc = ''">
                <!-- skip -->
            </xsl:when>
            <xsl:when test="$desc = 'added' and not(normalize-space($test))">
                <!-- skip -->
            </xsl:when>
            <xsl:otherwise>
                <imvert:diff ctrl-id="{$diff/diff/ctrl/@path}" test-id="{$diff/diff/test/@path}"> <!---->
                    <imvert:compos>
                        <xsl:value-of select="$compos"/>
                    </imvert:compos>    
                    <imvert:base>
                        <xsl:value-of select="local-name($base)"/>
                    </imvert:base>    
                    <imvert:type>
                        <xsl:value-of select="local-name($type)"/>
                    </imvert:type>    
                    <!-- 4 columns -->
                    <imvert:ctrl>
                        <xsl:sequence select="if (exists($ctrl)) then (if ($ctrl instance of text()) then string($ctrl) else '*') else '(empty)'"/>
                    </imvert:ctrl>
                    <imvert:test>
                        <xsl:sequence select="if (exists($test)) then (if ($test instance of text()) then string($test) else '*') else '(empty)'"/>
                    </imvert:test>
                    <imvert:change>
                       <xsl:value-of select="$desc"/>
                    </imvert:change>
                    <imvert:level>user</imvert:level>
                </imvert:diff>
            </xsl:otherwise>
        </xsl:choose>
              
    </xsl:template>
    
    <xsl:function name="imf:decode-base-name" as="xs:string*">
        <xsl:param name="encoded-name"/>
        <xsl:sequence select="subsequence(tokenize($encoded-name,'\.'),2)"/>
    </xsl:function>
</xsl:stylesheet>