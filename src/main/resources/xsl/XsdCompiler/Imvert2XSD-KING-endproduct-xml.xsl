<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $ 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310" 
    xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
    xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
    xmlns:stuf="http://www.egem.nl/StUF/StUF0301" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" 
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2XSD-KING-enrich-excel.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-create-endproduct-rough-structure.xsl"/>
    <xsl:import href="Imvert2XSD-KING-create-endproduct-structure.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="stylesheet">Imvert2XSD-KING-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $</xsl:variable>  
    
<!-- ROME: Heel vreemd maar de volgende twee (uitbecommentarieerde) variabelen zijn toch anders dan de daarop volgende 2 variabelen (waarbij de functie
           'buildParametersAndStuurgegevens' wel werkt. -->
    <?x xsl:variable name="config-schemarules" select="imf:get-config-schemarules()"/>
    <xsl:variable name="config-tagged-values" select="imf:get-config-tagged-values()"/ x?>
    
    <xsl:variable name="config-schemarules">
        <xsl:sequence select="imf:get-config-schemarules()"/>
    </xsl:variable> 
    <xsl:variable name="config-tagged-values">
        <xsl:sequence select="imf:get-config-tagged-values()"/>
    </xsl:variable> 
    
    <!-- set the processing parameters of the stylesheets. -->
    <xsl:variable name="debug" select="'no'"/>
    
    <!-- Within the next variable the configurations defined within the Base-configuration spreadsheet are placed in a processed XML format.
         With this configuration the attributes to be used on each location within the XML schemas are determined. -->
    <xsl:variable name="enriched-endproduct-base-config-excel">
        <result>
            <xsl:if test="$endproduct-base-config-excel = ''">
                <xsl:message select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The variable $endproduct-base-config-excel is empty so the Excel with the base configuration can not be found.')"/>								
            </xsl:if>
             <xsl:choose> 
                <xsl:when test="ends-with(lower-case($endproduct-base-config-excel),'.xlsx')">
                    <!-- excel based on OO-XML -->
                    <xsl:for-each select="$content-doc/files/file/ss:worksheet">
                        <xsl:variable name="worksheet">
                            <xsl:apply-templates select="." mode="resolve-strings"/>
                        </xsl:variable>
                        <!-- OO-XML is an XML format. Preproces that format if needed. -->
                        <xsl:sequence select="$worksheet"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="ends-with(lower-case($endproduct-base-config-excel),'.xls')">
                    <!-- excel 97-2003 --> 
                    <xsl:variable name="xml-path" select="imf:serializeExcel($endproduct-base-config-excel,concat($workfolder-path,'/excel.xml'),$excel-97-dtd-path)"/>
                    <xsl:variable name="xml-doc" select="imf:document(imf:file-to-url($xml-path))"/>
                    <!-- excel 97-2003 is'nt an XML format. Using the above variables the format is translated to XML.
                         The XML format then is processed to be able to use it. -->
                    <xsl:apply-templates select="$xml-doc/workbook"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('WARNING','No or not a known endproduct base configuration excel file: [1] ', ($endproduct-base-config-excel))"/>
                </xsl:otherwise>
            </xsl:choose>
        </result>
    </xsl:variable>
    
   <xsl:variable name="berichtNaam" select="/imvert:packages/imvert:application"/>
	
    
    <!-- Within these variables all messages defined within the BSM of the koppelvlak are placed transformed to the imvertor endproduct format.-->
    <xsl:variable name="imvert-endproduct">
       <ep:message-set>
            <xsl:sequence select="imf:create-output-element('ep:date', substring-before(/imvert:packages/imvert:generated,'T'))"/>
            <xsl:sequence select="imf:create-output-element('ep:name', /imvert:packages/imvert:project)"/>
           <xsl:sequence select="imf:create-output-element('ep:namespace', /imvert:packages/imvert:base-namespace)"/>
           <!-- Hiervoor moet de tagged-value short-alias toegevoegd worden aan de tvset. -->
           <xsl:variable name="prefix">
               <xsl:choose>
                   <xsl:when test="/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']">
                       <xsl:value-of select="/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']/imvert:value"/>
                   </xsl:when>
                   <xsl:otherwise>TODO</xsl:otherwise>
               </xsl:choose>
           </xsl:variable>
           <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $prefix)"/>
           <xsl:sequence select="imf:create-output-element('ep:patch-number', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
            
           <xsl:variable name="packages" select="/imvert:packages"/>
           
           <xsl:variable name="rough-messages">
               <ep:rough-messages>
                   <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-rough-message-structure"/>
               </ep:rough-messages>
           </xsl:variable>
           <xsl:sequence select="$rough-messages"/>
           
           <xsl:variable name="messages">
               <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-message-structure"/>
           </xsl:variable>
           <xsl:sequence select="$messages"/>
           
           <!-- The following for-each takes care of creating global construct elements for each ep:constructRef present within the 'messages' variable. -->
           <xsl:for-each select="$rough-messages//ep:construct[not(ep:type-id = preceding-sibling::ep:construct/ep:type-id)]">
               <xsl:variable name="berichtCode" select="ancestor::ep:rough-message/ep:code"/>
               <xsl:variable name="context">
                   <xsl:choose>
                       <xsl:when test="@context=''">
                           <xsl:value-of select="'-'"/>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:value-of select="@context"/>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:variable>
               <xsl:variable name="id" select="ep:id"/>
               <xsl:variable name="type-id" select="ep:type-id"/>
               <xsl:variable name="typeCode">
                   <xsl:choose>
                       <xsl:when test="@typeCode1"><xsl:value-of select="@typeCode1"/></xsl:when>
                       <xsl:when test="@typeCode2"><xsl:value-of select="@typeCode2"/></xsl:when>
                       <xsl:when test="@typeCode3"><xsl:value-of select="@typeCode3"/></xsl:when>
                   </xsl:choose>
               </xsl:variable>
               <xsl:variable name="package-id" select="$packages/imvert:package[.//imvert:*[$id=imvert:id]]/imvert:id"/>
               <xsl:variable name="historyApplies">
                   <xsl:choose>
                       <xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">yes-Materieel</xsl:when>
                       <xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">yes</xsl:when>
                       <xsl:otherwise>no</xsl:otherwise>
                   </xsl:choose>
               </xsl:variable>
               <xsl:if test="imf:boolean($debug)">
                   <xsl:message select="concat('globalComplexType: ',$id)"/>
               </xsl:if>
               
               
               <!-- LET OP! We moeten bij het bepalen van de globale complexTypes niet alleen kijken of ze hergebruikt worden over de berichten 
                    maar ook of ze over die beruichten heen wel hetzelfde moeten blijven. Het ene bericht heeft een hele ander type complexType nodig dan het andere. -->
               
               
               
               <xsl:comment select="concat(name($packages//imvert:*[imvert:id = $type-id]),': ',$type-id)"/>
               <xsl:choose>
                   <xsl:when test="@type='groupType' and $packages//imvert:class[imvert:id = $type-id]">
                       <xsl:variable name="type-id" select="$packages//imvert:class[imvert:id = $type-id]/imvert:id"/>
                       <ep:construct type="groupType">
                           <?x xsl:sequence
                               select="imf:create-output-element('ep:name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'package-name'),'-',$berichtCode))" / x?>
                           <xsl:sequence
                               select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-',$berichtCode))" />
                           <ep:seq>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'attributes'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type"
                                       select="'associationsGroepCompositie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                           </ep:seq> 
                       </ep:construct>                       
                   </xsl:when>
                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]">
                       <ep:construct>
                            <xsl:sequence
                               select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-',$berichtCode))" />
                           <ep:seq>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'attributes'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type"
                                       select="'associationsGroepCompositie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer 
					of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar 
					ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. Onderstaande 
					elementen 'StUF:tijdvakGeldigheid' en 'StUF:tijdstipRegistratie' mogen trouwens 
					alleen voorkomen als voor een van de attributen van het huidige object historie 
					is gedefinieerd of als er om gevraagd wordt. De vraag is echter of daarbij 
					alleen gekeken moet worden naar de attributen waarvan de elementen op hetzelfde 
					niveau als onderstaande elementen worden gegenereerd of dat deze elementen 
					ook al gegenereerd moeten worden als er ergens dieper onder het huidige niveau 
					een element voorkomt waarbij op het gerelateerde attribuut historie is gedefinieerd. 
					Dit geldt voor alle locaties waar onderstaande elementen worden gedefinieerd. -->
                               <ep:construct>
                                   <ep:name>StUF:tijdvakGeldigheid</ep:name>
                                   <ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
                                   <ep:max-occurs>1</ep:max-occurs>
                                   <ep:min-occurs>0</ep:min-occurs>
                                   <ep:position>150</ep:position>
                               </ep:construct>
                               <ep:construct>
                                   <ep:name>StUF:tijdstipRegistratie</ep:name>
                                   <ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
                                   <ep:max-occurs>1</ep:max-occurs>
                                   <ep:min-occurs>0</ep:min-occurs>
                                   <ep:position>151</ep:position>
                               </ep:construct>
                               <ep:construct>
                                   <ep:name>StUF:extraElementen</ep:name>
                                   <ep:tech-name>StUF:extraElementen</ep:tech-name>
                                   <ep:max-occurs>1</ep:max-occurs>
                                   <ep:min-occurs>0</ep:min-occurs>
                                   <ep:position>152</ep:position>
                               </ep:construct>
                               <xsl:if test="imf:boolean($debug)">	
                                   <xsl:message select="concat('$historyApplies ',$historyApplies)" />
                               </xsl:if>
                               <xsl:if test="($historyApplies='yes-Materieel' or $historyApplies='yes') and //imvert:class[imvert:id = $type-id and 
                                           .//imvert:tagged-value[imvert:name='IndicatieMateriLeHistorie' and contains(imvert:value,'Ja')]]">
                                   <ep:construct orderingDesired="no" >
                                       <ep:name>historieMaterieel</ep:name>
                                       <ep:tech-name>historieMaterieel</ep:tech-name>
                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                       <ep:min-occurs>0</ep:min-occurs>
                                       <ep:position>153</ep:position>
                                       <ep:seq>
                                           <!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
								and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
								be placed directly within the current 'ep:seq'. -->
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                       </ep:seq>
                                   </ep:construct>
                               </xsl:if>
                               <xsl:if
                                   test="$historyApplies='yes' and //imvert:class[imvert:id = $type-id and 
                                   .//imvert:tagged-value[imvert:name='IndicatieFormeleHistorie' and contains(imvert:value,'Ja')]]">
                                   <ep:construct orderingDesired="no" >
                                       <ep:name>historieFormeel</ep:name>
                                       <ep:tech-name>historieFormeel</ep:tech-name>
                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                       <ep:min-occurs>0</ep:min-occurs>
                                       <ep:position>154</ep:position>
                                       <ep:seq>
                                           <!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
								and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
								be placed directly within the current 'ep:seq'. -->
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                       </ep:seq>
                                   </ep:construct>
                               </xsl:if>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:variable name="mnemonic" select="$packages//imvert:class[imvert:id = $type-id]/imvert:alias" />
                               <!-- The function imf:createAttributes is used to determine the XML attributes 
                					neccessary for this context. It has the following parameters: - typecode 
                					- berichttype - context - datumType The first 3 parameters relate to columns 
                					with the same name within an Excel spreadsheet used to configure a.o. XML 
                					attributes usage. The last parameter is used to determine the need for the 
                					XML-attribute 'StUF:indOnvolledigeDatum'. -->
                               <xsl:if test="imf:boolean($debug)">	
                                   <xsl:comment select="concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
                               </xsl:if>
                               <xsl:comment select="concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
                               <xsl:variable name="attributes"
                                   select="imf:createAttributes($typeCode, substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no','no')" />
                               <xsl:sequence select="$attributes" />
                           </ep:seq> 
                       </ep:construct>
                   </xsl:when>
                    <!-- Volgende when was voorheen niet noodzakelijk omdat alle id's verwezen naar een class. Op de eoa manier verwijzen sommige id's nu naar associations.
                         Zo mogelijk corrigeren. -->
                   <?x xsl:when test="@type='groupType' and $packages//imvert:association[imvert:id = $id]">
                       <xsl:variable name="type-id" select="$packages//imvert:association[imvert:id = $id]/imvert:type-id"/>
                       <ep:construct type="groupType">
                           <xsl:sequence
                               select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-',$berichtCode))" />
                           <ep:seq>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'attributes'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type"
                                       select="'associationsGroepCompositie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                           </ep:seq> 
                       </ep:construct>
                       
                   </xsl:when>
                   <xsl:when test="$packages//imvert:association[imvert:id = $id]">
                       <ep:construct>
                           <xsl:sequence
                               select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-',$berichtCode))" />
                           <ep:seq>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'attributes'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type"
                                       select="'associationsGroepCompositie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer 
					of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar 
					ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. Onderstaande 
					elementen 'StUF:tijdvakGeldigheid' en 'StUF:tijdstipRegistratie' mogen trouwens 
					alleen voorkomen als voor een van de attributen van het huidige object historie 
					is gedefinieerd of als er om gevraagd wordt. De vraag is echter of daarbij 
					alleen gekeken moet worden naar de attributen waarvan de elementen op hetzelfde 
					niveau als onderstaande elementen worden gegenereerd of dat deze elementen 
					ook al gegenereerd moeten worden als er ergens dieper onder het huidige niveau 
					een element voorkomt waarbij op het gerelateerde attribuut historie is gedefinieerd. 
					Dit geldt voor alle locaties waar onderstaande elementen worden gedefinieerd. -->
                               <ep:construct>
                                   <ep:name>StUF:tijdvakGeldigheid</ep:name>
                                   <ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
                                   <ep:max-occurs>1</ep:max-occurs>
                                   <ep:min-occurs>0</ep:min-occurs>
                                   <ep:position>150</ep:position>
                               </ep:construct>
                               <ep:construct>
                                   <ep:name>StUF:tijdstipRegistratie</ep:name>
                                   <ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
                                   <ep:max-occurs>1</ep:max-occurs>
                                   <ep:min-occurs>0</ep:min-occurs>
                                   <ep:position>151</ep:position>
                               </ep:construct>
                               <ep:construct>
                                   <ep:name>StUF:extraElementen</ep:name>
                                   <ep:tech-name>StUF:extraElementen</ep:tech-name>
                                   <ep:max-occurs>1</ep:max-occurs>
                                   <ep:min-occurs>0</ep:min-occurs>
                                   <ep:position>152</ep:position>
                               </ep:construct>
                               <xsl:if test="imf:boolean($debug)">	
                                   <xsl:message select="concat('$historyApplies ',$historyApplies)" />
                               </xsl:if>
                               <xsl:if test="($historyApplies='yes-Materieel' or $historyApplies='yes') and //imvert:class[imvert:id = $type-id and 
                                   .//imvert:tagged-value[imvert:name='IndicatieMateriLeHistorie' and contains(imvert:value,'Ja')]]">
                                   <ep:construct orderingDesired="no" >
                                       <ep:name>historieMaterieel</ep:name>
                                       <ep:tech-name>historieMaterieel</ep:tech-name>
                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                       <ep:min-occurs>0</ep:min-occurs>
                                       <ep:position>153</ep:position>
                                       <ep:seq>
                                           <!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
								and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
								be placed directly within the current 'ep:seq'. -->
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                       </ep:seq>
                                   </ep:construct>
                               </xsl:if>
                               <xsl:if
                                   test="$historyApplies='yes' and //imvert:class[imvert:id = $type-id and 
                                   .//imvert:tagged-value[imvert:name='IndicatieFormeleHistorie' and contains(imvert:value,'Ja')]]">
                                   <ep:construct orderingDesired="no" >
                                       <ep:name>historieFormeel</ep:name>
                                       <ep:tech-name>historieFormeel</ep:tech-name>
                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                       <ep:min-occurs>0</ep:min-occurs>
                                       <ep:position>154</ep:position>
                                       <ep:seq>
                                           <!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
								and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
								be placed directly within the current 'ep:seq'. -->
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                           <xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="package-id" select="$package-id"/>
                                               <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                               <!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
                                               <xsl:with-param name="id-trail" select="''" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="$historyApplies" />
                                           </xsl:apply-templates>
                                       </ep:seq>
                                   </ep:construct>
                               </xsl:if>
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="package-id" select="$packages//imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]/imvert:id"/>
                                   <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                   <!-- ROME: Het is de vraag of deze parameter en het checken op id 
        									nog wel noodzakelijk is. -->
                                   <xsl:with-param name="id-trail" select="''" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <xsl:variable name="mnemonic">
                                   <xsl:choose>
                                       <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias != ''">
                                           <xsl:value-of select="$packages//imvert:class[imvert:id = $type-id]/imvert:alias"/>
                                       </xsl:when>
                                       <xsl:otherwise/>
                                   </xsl:choose>                                 
                               </xsl:variable>
                               <!-- The function imf:createAttributes is used to determine the XML attributes 
                					neccessary for this context. It has the following parameters: - typecode 
                					- berichttype - context - datumType The first 3 parameters relate to columns 
                					with the same name within an Excel spreadsheet used to configure a.o. XML 
                					attributes usage. The last parameter is used to determine the need for the 
                					XML-attribute 'StUF:indOnvolledigeDatum'. -->
                               <xsl:if test="imf:boolean($debug)">	
                                   <xsl:comment select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
                               </xsl:if>
                               <xsl:variable name="attributes"
                                   select="imf:createAttributes('toplevel', substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no','no')" />
                               <xsl:sequence select="$attributes" />
                           </ep:seq> 
                       </ep:construct>
                   </xsl:when x?>
               </xsl:choose>
            </xsl:for-each>
       </ep:message-set>
     </xsl:variable>
    
    <xsl:template match="/">
        <!-- This template is used to place the content of the variable '$imvert-endproduct' within the ep file. -->
        <?x xsl:result-document href="file:/c:/temp/imvert-schema-rules.xml">
            <xsl:sequence select="$config-schemarules"/>
        </xsl:result-document x?> 
        <?x xsl:result-document href="file:/c:/temp/imvert-tagged-values.xml">
            <xsl:sequence select="$config-tagged-values"/>
        </xsl:result-document x?> 
        <?x xsl:result-document href="file:/c:/temp/imvert-endproduct.xml">
            <xsl:sequence select="$enriched-endproduct-base-config-excel"/>
            
            <!-- xsl:sequence select="$imvert-endproduct/*"/ -->
        </xsl:result-document x?> 
        
        <xsl:sequence select="$imvert-endproduct/*"/>
    </xsl:template>
    
    <!-- supress the suppressXsltNamespaceCheck message -->
    <xsl:template match="/imvert:dummy"/>
    
</xsl:stylesheet>
