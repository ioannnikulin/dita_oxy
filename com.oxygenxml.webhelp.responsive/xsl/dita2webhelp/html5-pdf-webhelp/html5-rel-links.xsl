<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  version="2.0" xmlns:table="http://dita-ot.sourceforge.net/ns/201007/dita-ot/table"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
  xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  exclude-result-prefixes="xs table dita-ot related-links ditamsg relpath"
  >
 
  <xsl:key name="omit-from-unordered-links" match="*[@importance='required' and (not(@role) or @role='sibling' or @role='friend' or @role='cousin')]" use="1" />

  <xsl:param name="args.rellinks.group.mode" select="'single-group'"/>

  <!-- EXM-17960 PATCH FOR DITA-OT 2.0 -->
  <!--main template for setting up all links after the body - applied to the related-links container-->
  <xsl:template match="*[contains(@class, ' topic/related-links ')]" name="topic.related-links" >
    <nav role="navigation">
      <xsl:call-template name="commonattributes"/>
      <xsl:if test="$include.roles = ('child', 'descendant')">
        <xsl:call-template name="ul-child-links"/>
        <!--handle child/descendants outside of linklists in collection-type=unordered or choice-->
        <xsl:call-template name="ol-child-links"/>
        <!--handle child/descendants outside of linklists in collection-type=ordered/sequence-->
      </xsl:if>
      <!-- OXYGEN PATCH START EXM-17960 - omit links generated by DITA-OT. -->
      <!--<xsl:if test="$include.roles = ('next', 'previous', 'parent')">
        <xsl:call-template name="next-prev-parent-links"/>
        <!-\-handle next and previous links-\->
      </xsl:if>-->
      <!-- OXYGEN PATCH END EXM-17960 - omit links generated by DITA-OT. -->
      <!-- Group all unordered links (which have not already been handled by prior sections). Skip duplicate links. -->
      <!-- NOTE: The actual grouping code for related-links:group-unordered-links is common between
             transform types, and is located in ../common/related-links.xsl. Actual code for
             creating group titles and formatting links is located in XSL files specific to each type. -->
      <xsl:variable name="unordered-links" as="element(linklist)*">
        <xsl:apply-templates select="." mode="related-links:group-unordered-links">
          <xsl:with-param name="nodes"
            select="descendant::*[contains(@class, ' topic/link ')]
            [not(related-links:omit-from-unordered-links(.))]
            [generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:apply-templates select="$unordered-links"/>
      <!--linklists - last but not least, create all the linklists and their links, with no sorting or re-ordering-->
      <xsl:apply-templates select="*[contains(@class, ' topic/linklist ')]"/>
    </nav>
  </xsl:template>
  

  
  
  <!-- "/" is not legal in IDs - need to swap it with two underscores -->
  <xsl:template name="parsehref" >
    <xsl:param name="href"/>
    <xsl:choose>
      <xsl:when test="contains($href,'/')">
        <xsl:value-of select="substring-before($href,'/')"/>__<xsl:value-of select="substring-after($href,'/')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
<!-- OXYGEN PATCH END EXM-23770 -->
<xsl:template match="*[@collection-type='sequence']/*[contains(@class, ' topic/link ')][@role='child' or @role='descendant']" priority="3" name="topic.link_orderedchild">
    <xsl:variable name="el-name">
        <xsl:choose>
            <xsl:when test="contains(../@class,' topic/linklist ')">div</xsl:when>
            <xsl:otherwise>li</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$el-name}">
        <xsl:attribute name="class">olchildlink</xsl:attribute>
        <xsl:call-template name="commonattributes">
            <xsl:with-param name="default-output-class" select="'olchildlink'"/>
        </xsl:call-template>
        <!-- Allow for unknown metadata (future-proofing) -->
        <xsl:apply-templates select="*[contains(@class,' topic/data ') or contains(@class,' topic/foreign ')]"/>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="." mode="related-links:ordered.child.prefix"/>
        <xsl:apply-templates select="." mode="add-link-highlight-at-start"/>
        <a>
            <xsl:apply-templates select="." mode="add-linking-attributes"/>
            <xsl:apply-templates select="." mode="add-hoverhelp-to-child-links"/>
            
            <!--use linktext as linktext if it exists, otherwise use href as linktext-->
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/linktext ')]"><xsl:apply-templates select="*[contains(@class, ' topic/linktext ')]"/></xsl:when>
                <xsl:otherwise><!--use href--><xsl:call-template name="href"/></xsl:otherwise>
            </xsl:choose>
        </a>
        <xsl:apply-templates select="." mode="add-link-highlight-at-end"/>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        
        <!--add the description on a new line, unlike an info, to avoid issues with punctuation (adding a period)-->
        <xsl:variable name="topicDesc">
            <xsl:apply-templates select="*[contains(@class, ' topic/desc ')]"/>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($topicDesc)) > 0">
            <div><xsl:value-of select="$topicDesc"/></div>
        </xsl:if>
    </xsl:element>
</xsl:template>
  
 
  <!-- 
  
    Filter br elements. 
    
    -->  
  
  <!--basicand ordered child processing -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@role = ('child', 'descendant')] | 
                       *[@collection-type = 'sequence']/*[contains(@class, ' topic/link ')][@role = ('child', 'descendant')]" priority="5" name="topic.link_child">
      <xsl:variable name="super">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:apply-templates select="$super" mode="remove.br"/>
    
  </xsl:template>

  <xsl:template match="node() | @*" mode="remove.br">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="br" mode="remove.br"/>

    
  <!-- 
  
    Wrap plain text in markup.
  
   -->  

  <xsl:template match="*[contains(@class, ' topic/linkinfo ')]" name="topic.linkinfo">
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/linklist ')]/*[contains(@class, ' topic/title ')]"
    name="topic.linklist_title">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/linklist ')]/*[contains(@class, ' topic/desc ')] | 
                       *[contains(@class, ' topic/link ')]/*[contains(@class, ' topic/desc')]"
    name="topic.linklist_desc">
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- 
    
    We override the html5 default behavior for related-links to concepts and tasks,
    this avoids the creation of the "Related concepts" and "Related tasks" labels.
    All the related-links are grouped under "Related information" label.
  
  -->
  
  <!-- Concepts have the same group as Topics. -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:get-group"
    name="related-links:group.concept"
    as="xs:string">
    <xsl:choose>
      <xsl:when test="$args.rellinks.group.mode='single-group'">
        <xsl:call-template name="related-links:group."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Priority of concept is the same as no-name group. -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:get-group-priority"
    name="related-links:group-priority.concept"
    as="xs:integer">
    <xsl:choose>
      <xsl:when test="$args.rellinks.group.mode='single-group'">
        <xsl:call-template name="related-links:group-priority."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Wrapper for concepts: "Related information" in a <div>. -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:result-group"
    name="related-links:result.concept" as="element()">
    <xsl:param name="links" as="node()*"/>
    <xsl:choose>
      <xsl:when test="$args.rellinks.group.mode='single-group'">
        <xsl:call-template name="related-links:group-result.">
          <xsl:with-param name="links" select="$links"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match>
          <xsl:with-param name="links" select="$links"/>
        </xsl:next-match>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Tasks have the same group as Topics. -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:get-group"
    name="related-links:group.task"
    as="xs:string">
    <xsl:choose>
      <xsl:when test="$args.rellinks.group.mode='single-group'">
        <xsl:call-template name="related-links:group."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Priority of task is the same as no-name group. -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:get-group-priority"
    name="related-links:group-priority.task"
    as="xs:integer">
    <xsl:choose>
      <xsl:when test="$args.rellinks.group.mode='single-group'">
        <xsl:call-template name="related-links:group-priority."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Wrapper for tasks: "Related information" in a <div>. -->
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:result-group"
    name="related-links:result.task" as="element()">
    <xsl:param name="links" as="node()*"/>
    <xsl:choose>
      <xsl:when test="$args.rellinks.group.mode='single-group'">
        <xsl:call-template name="related-links:group-result.">
          <xsl:with-param name="links" select="$links"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match>
          <xsl:with-param name="links" select="$links"/>
        </xsl:next-match>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
 