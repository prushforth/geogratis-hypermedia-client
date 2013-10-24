<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:as="http://atomserver.org/namespaces/1.0/" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" xmlns:app="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom" exclude-result-prefixes="xs xsl os as georss gml app atom" version="2.0">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="nl">
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>
    <xsl:variable name="base" select="base-uri(/atom:feed/app:collection)"/>
    <xsl:template match="/">
        <xsl:apply-templates select="atom:feed"/>
    </xsl:template>
    
    <xsl:template match="atom:feed">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
        <html>
            <head>
                <!--<base href="{resolve-uri(app:collection/@href, base-uri())}"/>-->
                <script type="text/javascript" src="js/lib/uritemplate.js"></script>
                <script type="text/javascript" src="js/lib/jquery-1.10.2.min.js"></script>
            </head>
            <body>
                <div id="id"/>
                <script type="text/javascript">
                    <xsl:text>function collect_inputs() {
                    "use strict"; </xsl:text>
                    return UriTemplate.parse('<xsl:value-of select="app:collection/atom:link[@rel='api']/@tref"/>').expand({<xsl:apply-templates select="app:collection/atom:link[@rel='api']/*" mode="generate-script"/>});}
                    
                </script>
                
                <script type="text/javascript">
                    <xsl:text>function resolve(url) {
                    "use strict";</xsl:text>
                    var base_url = "<xsl:value-of select="$base"/>";
                    var doc = document
                    , old_base = doc.getElementsByTagName('base')[0]
                    , old_href = old_base &amp;&amp; old_base.href
                    , doc_head = doc.head || doc.getElementsByTagName('head')[0]
                    , our_base = old_base || doc_head.appendChild(doc.createElement('base'))
                    , resolver = doc.createElement('a')
                    , resolved_url;
                    our_base.href = base_url;
                    resolver.href = url;
                    resolved_url  = resolver.href; // browser magic at work here
                    
                    if (old_base) old_base.href = old_href;
                    else doc_head.removeChild(our_base);
                    return resolved_url;
                    }
                </script>
                <script type="text/javascript">
                    <xsl:text>function get(url) {
                    "use strict";</xsl:text>
                    var div;
                    var xmlhttp = new XMLHttpRequest();
                    xmlhttp.onreadystatechange=function() {
                    if (xmlhttp.readyState==4 &amp;&amp; xmlhttp.status==200) {
                    document.getElementById("results").innerHTML=xmlhttp.responseText;
                    }
                    }                   
                    xmlhttp.open("GET",resolve(url),true);
                    xmlhttp.send();
                    
                    }
                </script>
                <xsl:apply-templates select="app:collection/atom:link[@rel='api']" mode="generate-ui"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="atom:link[@rel='api']" mode="generate-ui">
        <form id="theform" target="_blank" method="get">
            <xsl:apply-templates select="*[local-name()!='mediaType']" mode="generate-ui"/>
            <input type="button" value="Submit" onclick="get(collect_inputs())" /><br/>
        </form>
        <div id="results"></div>
    </xsl:template>
    <xsl:template match="*[child::atom:value|child::atom:pattern]" mode="generate-ui">
        <xsl:if test="not(@tref)">
            <label for="{local-name()}"><xsl:value-of select="local-name()"/></label>
            <input id="{local-name()}" type="text" name="{local-name()}"/><xsl:value-of select="$nl"/><br/>
        </xsl:if>
        <xsl:apply-templates select="*" mode="generate-ui"/>
    </xsl:template>
    <xsl:template match="atom:alt" mode="generate-ui">
        <input type="hidden" id="alt" value="phtml"></input>
    </xsl:template>
    <xsl:template match="atom:bbox" mode="generate-ui">
        <xsl:for-each select="tokenize(child::*[1]/@format,',')">
            <label for="{concat('bbox-',.)}"><xsl:value-of select="."/></label>
            <input id="{concat('bbox-',.)}" type="text" name="{concat('bbox-',.)}"/>
        </xsl:for-each>
        <xsl:value-of select="$nl"/><br/>
    </xsl:template>
    <xsl:template mode="generate-ui" match="atom:categoryQuery">
        <!-- not sure how to deal with category queries at this time... -->
        <input type="hidden" id="{local-name()}"/>
    </xsl:template>
    <xsl:template match="*" mode="generate-ui">
        <xsl:apply-templates select="*" mode="generate-ui"/>
    </xsl:template>
    <xsl:template match="*" mode="generate-script">
        <xsl:choose>
            <xsl:when test="@tref">
                <xsl:value-of select="concat(local-name(),': ')"/>UriTemplate.parse('<xsl:value-of select="@tref"/>').expand({<xsl:apply-templates select="*[local-name() != 'link']" mode="generate-script"/>})
            </xsl:when>
            <xsl:when test="child::atom:pattern|child::atom:value">
                <xsl:value-of select="concat(local-name(),': ','$(','''','#',local-name(),'''',').val()')"/>
            </xsl:when>
            <xsl:when test="child::atom:values">
                <xsl:value-of select="concat(local-name(),': [', string-join(for $dir in tokenize(@format,',') return concat( '$(','''','#','bbox-',$dir,'''',').val()'),','),']')"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
    <xsl:template match="atom:updatedMin|atom:publishedMin" mode="generate-ui">
        <label for="{local-name()}"><xsl:value-of select="local-name()"/></label>
        <input id="{local-name()}" type="date" name="{local-name()}"/><xsl:value-of select="$nl"/>
    </xsl:template>
    <xsl:template match="atom:updatedMax|atom:publishedMax|atom:editedMin" mode="generate-ui">
        <label for="{local-name()}"><xsl:value-of select="local-name()"/></label>
        <input id="{local-name()}" type="date" name="{local-name()}"/><xsl:value-of select="$nl"/><br/>
    </xsl:template>
    <xsl:template match="atom:link[@rel='suggestions']" mode="generate-ui"/>
    <xsl:template match="atom:categoryQuery" mode="generate-script"/>
    <xsl:template match="atom:mediaType" mode="generate-script"/>
    <xsl:template match="*|@*|text()"/>
</xsl:stylesheet>
