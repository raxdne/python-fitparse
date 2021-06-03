<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--  -->

  <xsl:output method="html" encoding="utf-8"/>

  <!-- diagram height -->
  <xsl:variable name="int_height" select="900"/>

  <!-- heart rate ranges -->
  <xsl:variable name="int_hr_1" select="125"/>
  <xsl:variable name="int_hr_2" select="150"/>
  <xsl:variable name="int_hr_3" select="190"/>

  <!-- speed levels -->
  <xsl:variable name="int_speed_1" select="25"/>
  <xsl:variable name="int_speed_2" select="50"/>

  <xsl:decimal-format name="f1" grouping-separator="." decimal-separator=","/>
  
  <xsl:template match="/">
    <xsl:element name="html">
      <xsl:call-template name="CREATESTYLE"/>
      <xsl:element name="body">
        <xsl:apply-templates/>
	<xsl:call-template name="CREATESCRIPT"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="pie|file|dir">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="fit">
    <xsl:element name="h1">
      <xsl:value-of select="@src"/>
    </xsl:element>

    <xsl:element name="h2">
      <xsl:element name="a">
	<xsl:text>Meta &amp; Heart Rate Diagram</xsl:text>
      </xsl:element>
    </xsl:element>

    <xsl:element name="div">
      <xsl:attribute name="style">align:top;</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="style">display:inline-block</xsl:attribute>
	<xsl:call-template name="META_TABLE"/>
      </xsl:element>
      
      <xsl:element name="div">
	<xsl:attribute name="style">display:inline-block</xsl:attribute>
	<xsl:call-template name="HR_DIAGRAM"/>
      </xsl:element>
    </xsl:element>
    
    <xsl:element name="h2">
      <xsl:element name="a">
	<xsl:attribute name="onclick">javascript:switchDisplay("lap_table")</xsl:attribute>
	<xsl:text>Lap Table</xsl:text>
      </xsl:element>
    </xsl:element>
    <xsl:call-template name="LAP_TABLE"/>

    <xsl:element name="h2">
      <xsl:element name="a">
	<xsl:attribute name="onclick">javascript:switchDisplay("diagram")</xsl:attribute>
	<xsl:text>Diagram</xsl:text>
      </xsl:element>
    </xsl:element>
    <xsl:call-template name="RECORD_DIAGRAM"/>

    <xsl:element name="h2">
      <xsl:element name="a">
	<xsl:attribute name="onclick">javascript:switchDisplay("record_table")</xsl:attribute>
	<xsl:text>Records</xsl:text>
      </xsl:element>
    </xsl:element>
    <xsl:call-template name="RECORD_TABLE"/>
    <!--
    -->
  </xsl:template>

  <xsl:template name="META_TABLE">

    <xsl:for-each select="session">
      <xsl:element name="table">
	<xsl:attribute name="id">meta_table</xsl:attribute>
	<xsl:element name="thead">
	  <xsl:element name="tr">
	    <xsl:element name="th">parameter</xsl:element>
	    <xsl:element name="th">value</xsl:element>
	    <xsl:element name="th">unit</xsl:element>
	  </xsl:element>
	</xsl:element>
	<xsl:element name="tbody">
	  <xsl:for-each select="*">
	    <xsl:element name="tr">
	      <xsl:choose>
		<xsl:when test="contains(name(),'heart')">
		  <xsl:attribute name="class">heart</xsl:attribute>
		</xsl:when>
		<xsl:when test="contains(name(),'speed')">
		  <xsl:attribute name="class">speed</xsl:attribute>
		</xsl:when>
		<xsl:when test="contains(name(),'time')">
		  <xsl:attribute name="class">time</xsl:attribute>
		</xsl:when>
		<xsl:when test="contains(name(),'distance')">
		  <xsl:attribute name="class">altitude</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
		</xsl:otherwise>
	      </xsl:choose>
	      <xsl:element name="td">
		<xsl:value-of select="name()"/>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="."/> <!-- format-number(.,'#,##','f1') -->
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="@unit"/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="LAP_TABLE">

    <xsl:element name="table">
      <xsl:attribute name="id">lap_table</xsl:attribute>
      <xsl:attribute name="style">display:none</xsl:attribute>
      <xsl:element name="tbody">
	<xsl:for-each select="lap">
	  <xsl:if test="position()=1">
	    <xsl:element name="tr">
	      <xsl:element name="th">lap</xsl:element>
	      <xsl:for-each select="start_time|avg_heart_rate|avg_speed|max_speed|max_heart_rate|total_distance">
		<xsl:sort select="name()"/>
		<xsl:element name="th">
		  <xsl:value-of select="concat(name(),' [', @unit,']')"/>
		</xsl:element>
	      </xsl:for-each>
	    </xsl:element>
	  </xsl:if>
	  <xsl:element name="tr">
	    <xsl:element name="td">
              <xsl:value-of select="position()"/>
	    </xsl:element>
	    <xsl:for-each select="start_time|avg_heart_rate|avg_speed|max_speed|max_heart_rate|total_distance">
	      <xsl:sort select="name()"/>
	      <xsl:element name="td">
		<xsl:value-of select="."/> <!-- format-number(.,'#,##','f1') -->
	      </xsl:element>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="RECORD_TABLE">

    <xsl:element name="table">
      <xsl:attribute name="id">record_table</xsl:attribute>
      <xsl:attribute name="style">display:none</xsl:attribute>
      <xsl:element name="thead">
	<xsl:element name="tr">
	  <xsl:element name="th">record</xsl:element>
	  <xsl:element name="th">time</xsl:element>
	  <xsl:element name="th">distance</xsl:element>
	  <xsl:element name="th">heart_rate</xsl:element>
	  <xsl:element name="th">speed</xsl:element>
	</xsl:element>
      </xsl:element>
      <xsl:element name="tbody">
	<xsl:for-each select="record">
	  <xsl:element name="tr">
	    <xsl:element name="td">
              <xsl:value-of select="position()"/>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="number(timestamp/@sec) - number(../record[1]/timestamp/@sec)"/>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="distance"/>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="heart_rate"/>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="speed"/>
	    </xsl:element>
	  </xsl:element>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="RECORD_DIAGRAM">

    <xsl:variable name="int_width" select="record[position() = last()]/timestamp/@sec - record[1]/timestamp/@sec + 200"/>
    
    <xsl:element name="svg" xmlns="http://www.w3.org/2000/svg">
      <xsl:attribute name="version">1.1</xsl:attribute>
      <xsl:attribute name="baseProfile">full</xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$int_width"/></xsl:attribute>
      <xsl:attribute name="id">diagram</xsl:attribute>
      <xsl:attribute name="style">display:none</xsl:attribute>

      <xsl:element name="style">
	<xsl:attribute name="type">text/css</xsl:attribute>
	<xsl:text>svg { font-family: Arial; font-size: 8pt;}</xsl:text>
      </xsl:element>

      <xsl:element name="rect">
	<xsl:attribute name="fill">#ffcccc</xsl:attribute>
	<xsl:attribute name="x"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y"><xsl:value-of select="$int_height - $int_hr_3"/></xsl:attribute>
	<xsl:attribute name="height"><xsl:value-of select="$int_hr_3 - $int_hr_2"/></xsl:attribute>
	<xsl:attribute name="width"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:element name="title">
	  <xsl:value-of select="concat('Red zone: ', $int_hr_2, ' .. ', $int_hr_3)"/>
	</xsl:element>
      </xsl:element>

      <xsl:element name="rect">
	<xsl:attribute name="fill">#ccffcc</xsl:attribute>
	<xsl:attribute name="x"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y"><xsl:value-of select="$int_height - $int_hr_2"/></xsl:attribute>
	<xsl:attribute name="height"><xsl:value-of select="$int_hr_2 - $int_hr_1"/></xsl:attribute>
	<xsl:attribute name="width"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:element name="title">
	  <xsl:value-of select="concat('Endurance zone: ', $int_hr_1, ' .. ', $int_hr_2)"/>
	</xsl:element>
      </xsl:element>

      <xsl:element name="line">
	<xsl:attribute name="stroke">#ccccff</xsl:attribute>
	<xsl:attribute name="stroke-width">.5</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - ($int_speed_1 * 2)"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - ($int_speed_1 * 2)"/></xsl:attribute>
      </xsl:element>

      <xsl:element name="line">
	<xsl:attribute name="stroke">#ccccff</xsl:attribute>
	<xsl:attribute name="stroke-width">.5</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - ($int_speed_2 * 2)"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - ($int_speed_2 * 2)"/></xsl:attribute>
      </xsl:element>

      <xsl:for-each select="//altitude">
	<xsl:sort select="."/>
	<xsl:variable name="int_alt" select="."/>
	<xsl:choose>
	  <xsl:when test="position() = 1">
	    <xsl:element name="line">
	      <xsl:attribute name="stroke">#00ff00</xsl:attribute>
	      <xsl:attribute name="stroke-width">1</xsl:attribute>
	      <xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	      <xsl:attribute name="y1"><xsl:value-of select="$int_height - $int_alt"/></xsl:attribute>
	      <xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	      <xsl:attribute name="y2"><xsl:value-of select="$int_height - $int_alt"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:when>
	  <xsl:when test="position() = last()">
	    <xsl:element name="line">
	      <xsl:attribute name="stroke">#00ff00</xsl:attribute>
	      <xsl:attribute name="stroke-width">1</xsl:attribute>
	      <xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	      <xsl:attribute name="y1"><xsl:value-of select="$int_height - $int_alt"/></xsl:attribute>
	      <xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	      <xsl:attribute name="y2"><xsl:value-of select="$int_height - $int_alt"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
      
      <xsl:element name="line">
	<xsl:attribute name="stroke">black</xsl:attribute>
	<xsl:attribute name="stroke-width">1</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="0"/></xsl:attribute>
      </xsl:element>

      <xsl:element name="line">
	<xsl:attribute name="stroke">black</xsl:attribute>
	<xsl:attribute name="stroke-width">1</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
      </xsl:element>

      <xsl:for-each select="record">
	<xsl:variable name="int_x" select="number(timestamp/@sec) - number(../record[1]/timestamp/@sec)"/>
	
	<xsl:for-each select="speed">
	  <xsl:variable name="int_y" select="$int_height - format-number(. * 2,'#,')"/>
	
	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ccccff</xsl:attribute>
	    <xsl:attribute name="stroke-width">1</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="$int_height"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_y"/></xsl:attribute>
	    <xsl:if test="number(.) &gt; $int_speed_1">
	      <xsl:element name="title">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:if>
	  </xsl:element>
	</xsl:for-each>

	<xsl:for-each select="heart_rate">
	  <xsl:variable name="int_y" select="$int_height - format-number(.,'#,')"/>
	
	  <xsl:element name="circle">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="cx"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="cy"><xsl:value-of select="$int_y"/></xsl:attribute>
	    <xsl:attribute name="r"><xsl:value-of select=".5"/></xsl:attribute>
	    <xsl:if test="number(.) &gt; $int_hr_2">
	      <xsl:element name="title">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:if>
	  </xsl:element>
	</xsl:for-each>
	
	<xsl:for-each select="altitude">
	  <xsl:variable name="int_y" select="$int_height - format-number(.,'#,')"/>
	
	  <xsl:element name="circle">
	    <xsl:attribute name="stroke">#00ff00</xsl:attribute>
	    <xsl:attribute name="cx"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="cy"><xsl:value-of select="$int_y"/></xsl:attribute>
	    <xsl:attribute name="r"><xsl:value-of select=".5"/></xsl:attribute>
	  </xsl:element>
	</xsl:for-each>
	
      </xsl:for-each>

      <xsl:for-each select="lap">
	<xsl:variable name="int_x" select="number(timestamp/@sec) - number(../record[1]/timestamp/@sec)"/>
	
	<xsl:element name="line">
	  <xsl:attribute name="stroke">black</xsl:attribute>
	  <xsl:attribute name="stroke-width">.5</xsl:attribute>
	  <xsl:attribute name="x1"><xsl:value-of select="$int_x"/></xsl:attribute>
	  <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="x2"><xsl:value-of select="$int_x"/></xsl:attribute>
	  <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="text">
	  <xsl:attribute name="x"><xsl:value-of select="$int_x"/></xsl:attribute>
	  <xsl:attribute name="y"><xsl:value-of select="10"/></xsl:attribute>
	  <xsl:element name="tspan">
	    <xsl:attribute name="x"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="dy"><xsl:value-of select="12"/></xsl:attribute>
            <xsl:value-of select="concat(name(),' ', position(),' ',position() * total_distance)"/>
	  </xsl:element>
	  <xsl:for-each select="start_time|avg_heart_rate|avg_speed|max_speed|max_heart_rate|total_distance|event_type|lap_trigger">
	    <xsl:sort select="name()"/>
	    <xsl:element name="tspan">
	      <xsl:attribute name="x"><xsl:value-of select="$int_x + 5"/></xsl:attribute>
	      <xsl:attribute name="dy"><xsl:value-of select="12"/></xsl:attribute>
              <xsl:value-of select="concat(name(),':', .,' [', @unit,']')"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:element>

      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="HR_DIAGRAM">

    <xsl:variable name="int_scale" select="3"/>
    <xsl:variable name="int_width" select="200"/>
    <xsl:variable name="int_height" select="100"/>
    
    <xsl:element name="svg" xmlns="http://www.w3.org/2000/svg">
      <xsl:attribute name="version">1.1</xsl:attribute>
      <xsl:attribute name="baseProfile">full</xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$int_scale * $int_height"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$int_scale * $int_width"/></xsl:attribute>
      <xsl:attribute name="id">hr_diagram</xsl:attribute>

      <xsl:element name="style">
	<xsl:attribute name="type">text/css</xsl:attribute>
	<xsl:text>svg { font-family: Arial; font-size: 8pt;}</xsl:text>
      </xsl:element>

      <xsl:element name="g">
	<xsl:attribute name="transform">
	  <xsl:value-of select="concat('scale(',$int_scale,')')"/>
	</xsl:attribute>

	<xsl:element name="rect">
	  <xsl:attribute name="fill">#ccffcc</xsl:attribute>
	  <xsl:attribute name="x"><xsl:value-of select="$int_hr_1"/></xsl:attribute>
	  <xsl:attribute name="y"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
	  <xsl:attribute name="width"><xsl:value-of select="$int_hr_2 - $int_hr_1"/></xsl:attribute>
	  <xsl:element name="title">
	    <xsl:value-of select="concat('Endurance zone: ', $int_hr_1, ' .. ', $int_hr_2)"/>
	  </xsl:element>
	</xsl:element>
	
	<xsl:element name="rect">
	  <xsl:attribute name="fill">#ffcccc</xsl:attribute>
	  <xsl:attribute name="x"><xsl:value-of select="$int_hr_2"/></xsl:attribute>
	  <xsl:attribute name="y"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
	  <xsl:attribute name="width"><xsl:value-of select="$int_hr_3 - $int_hr_2"/></xsl:attribute>
	  <xsl:element name="title">
	    <xsl:value-of select="concat('Red zone: ', $int_hr_2, ' .. ', $int_hr_3)"/>
	  </xsl:element>
	</xsl:element>

	<xsl:element name="line">
	  <xsl:attribute name="stroke">black</xsl:attribute>
	  <xsl:attribute name="stroke-width">.5</xsl:attribute>
	  <xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="y1"><xsl:value-of select="$int_height"/></xsl:attribute>
	  <xsl:attribute name="x2"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="y2"><xsl:value-of select="0"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="line">
	  <xsl:attribute name="stroke">black</xsl:attribute>
	  <xsl:attribute name="stroke-width">.25</xsl:attribute>
	  <xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="y1"><xsl:value-of select="$int_height * 0.5"/></xsl:attribute>
	  <xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	  <xsl:attribute name="y2"><xsl:value-of select="$int_height * 0.5"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="line">
	  <xsl:attribute name="stroke">black</xsl:attribute>
	  <xsl:attribute name="stroke-width">.5</xsl:attribute>
	  <xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	  <xsl:attribute name="y1"><xsl:value-of select="$int_height"/></xsl:attribute>
	  <xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	  <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	</xsl:element>

	<!--
	<xsl:element name="ellipse">
	  <xsl:attribute name="stroke">#ffaaaa</xsl:attribute>
	    <xsl:attribute name="fill">transparent</xsl:attribute>
	  <xsl:attribute name="cx"><xsl:value-of select="$int_hr_2"/></xsl:attribute>
	  <xsl:attribute name="cy"><xsl:value-of select="$int_height * (1.0 - 0.66)"/></xsl:attribute>
	  <xsl:attribute name="rx"><xsl:value-of select="5"/></xsl:attribute>
	  <xsl:attribute name="ry"><xsl:value-of select="15"/></xsl:attribute>
	</xsl:element>
	-->
	
	<xsl:for-each select="hist[@param='heart_rate']">
	  
	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.5</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="number(@median)"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="number(@median)"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat('HR median.: ',number(@median))"/>
	      </xsl:element>
	  </xsl:element>

	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.5</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="number(@max)"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="number(@max)"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat('HR max.: ',number(@max))"/>
	      </xsl:element>
	  </xsl:element>

	  <xsl:for-each select="child::c">
	    <xsl:variable name="int_x" select="number(@v) * 10"/>
	    <xsl:variable name="int_y" select="number(.) * 100"/>
	    
	    <xsl:element name="line">
	      <xsl:attribute name="stroke">rgb(128,128,128)</xsl:attribute>
	      <xsl:attribute name="stroke-width">.25</xsl:attribute>
	      <xsl:attribute name="x1"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	      <xsl:attribute name="x2"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	    </xsl:element>

	    <xsl:if test="number(.) &gt; 0.01">
	      <xsl:element name="rect">
		<xsl:attribute name="fill">#ff8888</xsl:attribute>
		<xsl:attribute name="x"><xsl:value-of select="$int_x - 4"/></xsl:attribute>
		<xsl:attribute name="y"><xsl:value-of select="$int_height - $int_y"/></xsl:attribute>
		<xsl:attribute name="height"><xsl:value-of select="$int_y"/></xsl:attribute>
		<xsl:attribute name="width"><xsl:value-of select="8"/></xsl:attribute>
		<xsl:element name="title">
		  <xsl:value-of select="concat('HR Zone: ', number(@v) * 10, ' ', number(.) * 100,'%')"/>
		</xsl:element>
	      </xsl:element>
	    </xsl:if>

	    <xsl:if test="number(@v) * 10 = $int_hr_2">
	      <xsl:element name="line">
		<xsl:attribute name="stroke">#ff0000</xsl:attribute>
		<xsl:attribute name="stroke-width">.25</xsl:attribute>
		<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
		<xsl:attribute name="y1"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
		<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
		<xsl:attribute name="y2"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	      </xsl:element>
	    </xsl:if>

	    <xsl:element name="circle">
	      <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	      <xsl:attribute name="stroke-width">1</xsl:attribute>
	      <xsl:attribute name="cx"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="cy"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	      <xsl:attribute name="r"><xsl:value-of select=".5"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat(@sum * 100,'% &lt; ',number(@v) * 10 + 5)"/>
	      </xsl:element>
	    </xsl:element>

	  </xsl:for-each>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="VRULE_DIAGRAM">
    <xsl:param name="d" select="0"/>

    <xsl:element name="line">
      <xsl:attribute name="stroke">rgb(128,128,128)</xsl:attribute>
      <xsl:attribute name="stroke-width">.25</xsl:attribute>
      <xsl:attribute name="x1"><xsl:value-of select="$d * 10.0"/></xsl:attribute>
      <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
      <xsl:attribute name="x2"><xsl:value-of select="$d * 10.0"/></xsl:attribute>
      <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
    </xsl:element>

    <xsl:choose>
      <xsl:when test="$d &lt; 22">
	<xsl:call-template name="VRULE_DIAGRAM">
	  <xsl:with-param name="d" select="$d + 1"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="CREATESTYLE">
    <xsl:element name="style">

body,table {
  background-color:#ffffff;
  font-family: Arial,sans-serif;
  /* font-family:Courier; */
  font-size:12px;
}

/* settings for tables
 */

table {
  margin-left:0px;
  border-collapse: collapse;
  empty-cells:show;
}

table.unlined {
  background-color:#ffffff;
}

tr {
}
tr.heart {
  background-color:#ffcccc;
}
tr.speed {
  background-color:#ccccff;
}
tr.time {
  background-color:#cccccc;
}
tr.altitude {
  background-color:#00ff00;
}

/* data cells */
td {
  border: 1px solid grey;
  vertical-align:top;
}
.empty {
  margin-bottom:0px;
}

/* header cells */
th {
  border: 1px solid grey;
  margin-bottom:0px;
  text-align:left;
  background-color:#d9d9d9;
  color:#000000;
  font-weight:bold;
}

/* lists */
ul, ol {
 margin: 0px 0px 0px 0px;
 padding: 0px 0px 0px 3em;
}

ul {
  list-style-type:square;
}

li {
  /* 
 margin: 5px 5px 20px 20px;
     margin-top
     margin-bottom
     margin-left
     margin-right
  */
  margin-left:0px;
  /* text-indent:0.1cm; */
}

/* misc tags

*/
p {
  /* 
 margin: 5px 5px 20px 20px;
     margin-top
     margin-bottom
     margin-left
     margin-right
  */
  /* text-indent:0.1cm; */
 margin: 3px 2px 3px 1px;
}

pre {
  background-color: #f8f8f8;
  border: 1px solid #cccccc;
  font-size: 13px;
  line-height: 19px;
  overflow: auto;
  padding: 6px 10px;
  border-radius: 3px;
}

   </xsl:element>
</xsl:template>

<xsl:template name="CREATESCRIPT">
  <xsl:element name="script">
    <xsl:attribute name="type">text/javascript</xsl:attribute>
    <xsl:text>
//
//
//
function switchDisplay(strId) {

  var node = document.getElementById(strId);

  if (node == undefined || node == null) {
    console.log( 'node: ' + node);
  } else if (node.style.display == "block" || node.style.display == undefined) {
    node.style.display = "none";
  } else {
    node.style.display = "block";
  }

  return
}
    </xsl:text>
  </xsl:element>
</xsl:template>

<xsl:template match="*"/>
  
</xsl:stylesheet>
