<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--  -->

  <xsl:output method="html" encoding="utf-8"/>

  <!-- intervals -->
  
  <xsl:variable name="int_p0" select="1"/> <!-- first record position -->
  
  <xsl:variable name="int_p1" select="0"/> <!-- last record position -->

  <xsl:variable name="int_t0" select="//fit[1]/descendant::record[position() = $int_p0]/timestamp/@sec"/> <!-- start second -->

  <xsl:variable name="int_tmax" select="$int_t0 + 4 * 3600"/> <!-- max seconds -->
  
  <xsl:variable name="int_t1"> <!-- stop second -->
    <xsl:choose>
      <xsl:when test="//fit[1]/descendant::record[position() = last()]/timestamp/@sec &lt; $int_t0">
	<!-- new day -->
        <xsl:value-of select="$int_tmax"/>
      </xsl:when>
      <xsl:when test="$int_p1 &gt; 0 and //fit[1]/descendant::record[position() = $int_p1]/timestamp/@sec &lt; $int_tmax">
        <xsl:value-of select="//fit[1]/descendant::record[position() = $int_p1]/timestamp/@sec"/>
      </xsl:when>
      <xsl:when test="//fit[1]/descendant::record[position() = last()]/timestamp/@sec &lt; $int_tmax">
        <xsl:value-of select="//fit[1]/descendant::record[position() = last()]/timestamp/@sec"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$int_tmax"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="int_timer"> <!-- timer seconds -->
    <xsl:choose>
      <xsl:when test="//fit[1]/session/total_timer_time">
        <xsl:value-of select="//fit[1]/session/total_timer_time"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- heart rate ranges -->

  <xsl:variable name="int_hr_1"> <!-- upper threshold for a break -->
    <xsl:choose>
      <xsl:when test="//fit[1]/hist[@param='heart_rate_breaks']/@hr_0">
        <xsl:value-of select="//fit[1]/hist[@param='heart_rate_breaks']/@hr_0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="125"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="int_hr_2"> <!-- end threshold for an interval -->
    <xsl:choose>
      <xsl:when test="//fit[1]/hist[@param='heart_rate_intervals']/@hr_2">
        <xsl:value-of select="//fit[1]/hist[@param='heart_rate_intervals']/@hr_2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="150"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="int_hr_3">
    <xsl:choose>
      <xsl:when test="//fit[1]/hist[@param='heart_rate']/c[position() = last()]/@v">
        <xsl:value-of select="number(//fit[1]/hist[@param='heart_rate']/c[position() = last()]/@v)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="200"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="int_hr_4"> <!-- start threshold for an interval -->
    <xsl:choose>
      <xsl:when test="//fit[1]/hist[@param='heart_rate_intervals']/@hr_1">
        <xsl:value-of select="//fit[1]/hist[@param='heart_rate_intervals']/@hr_1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="170"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- speed levels -->

  <xsl:variable name="int_v_1" select="25"/>

  <xsl:variable name="int_v_2" select="50"/>

  <xsl:variable name="int_v_3">
    <xsl:choose>
      <xsl:when test="//fit[1]/hist[@param='speed']/c[position() = last()]/@v">
        <xsl:value-of select="number(//fit[1]/hist[@param='speed']/c[position() = last()]/@v)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="70"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- altitudes -->
  
  <xsl:variable name="int_alt_0">
    <xsl:for-each select="//altitude">
      <xsl:sort select="." data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
	<xsl:value-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="int_alt_1">
    <xsl:for-each select="//altitude">
      <xsl:sort select="." data-type="number" order="descending"/>
      <xsl:if test="position() = last()">
	<xsl:value-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  
  <xsl:variable name="int_height" select="900"/> <!-- diagram height -->

  <xsl:decimal-format name="f1" grouping-separator="," decimal-separator="."/>
  
  <xsl:decimal-format name="s1" grouping-separator="," decimal-separator="."/>
  
  <xsl:decimal-format name="t1" grouping-separator="," />
  
  <xsl:template match="/">
    <xsl:element name="html">
      <xsl:call-template name="CREATESTYLE"/>
      <xsl:element name="body">
        <xsl:apply-templates/>
	<xsl:call-template name="CREATESCRIPT"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fit">
    <xsl:element name="h1">
      <xsl:value-of select="@src"/>
    </xsl:element>

    <xsl:comment>
      <xsl:value-of select="concat('Timer: ',$int_timer,' s = ')"/>
      <xsl:call-template name="ISOTIME">
	<xsl:with-param name="s" select="$int_timer"/>
      </xsl:call-template>
      <xsl:value-of select="concat('','&#10;')"/>
      <xsl:value-of select="concat('Range of records: [',$int_p0,' : ',$int_p1,']','&#10;')"/>
      <xsl:value-of select="concat('Resulting time interval [s]: [',$int_t0,' : ',$int_t1,']',' ≌ ')"/>
      <xsl:call-template name="ISOTIME">
	<xsl:with-param name="s" select="$int_t0"/>
      </xsl:call-template>
      <xsl:value-of select="concat(' .. ','')"/>
      <xsl:call-template name="ISOTIME">
	<xsl:with-param name="s" select="$int_t1"/>
      </xsl:call-template>
      <xsl:value-of select="concat('','&#10;')"/>
      <xsl:value-of select="concat('Heart rate values [bpm]: ',$int_hr_1,', ',$int_hr_2,', ',$int_hr_3,', ',$int_hr_4,'&#10;')"/>
      <xsl:value-of select="concat('Speed values [km/h]: ',$int_v_1,', ',$int_v_2,', ',$int_v_3,'&#10;')"/>
    </xsl:comment>
    
    <xsl:element name="h2">
      <xsl:element name="a">
	<xsl:text>Meta Data &amp; Heart Rate Histogram</xsl:text>
      </xsl:element>
    </xsl:element>

    <xsl:element name="div">
      <xsl:attribute name="style">align:top;</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="style">display:inline-block</xsl:attribute>
	<xsl:call-template name="META_TABLE"/>
      </xsl:element>
      
      <xsl:if test="hist[@param='heart_rate']">
	<xsl:element name="div">
	  <xsl:attribute name="style">display:inline-block</xsl:attribute>
	  <xsl:call-template name="HR_HISTOGRAM"/>
	</xsl:element>
      </xsl:if>
    </xsl:element>
    
    <xsl:if test="hist[@param='speed']">
      <xsl:element name="h2">
	<xsl:element name="a">
	  <xsl:attribute name="onclick">javascript:switchDisplay("v_histogram")</xsl:attribute>
	  <xsl:text>Speed Histogram</xsl:text>
	</xsl:element>
      </xsl:element>
      <xsl:call-template name="SPEED_HISTOGRAM"/>
    </xsl:if>
    
    <xsl:if test="hist[@param='heart_rate_intervals']">
      <xsl:element name="h2">
	<xsl:element name="a">
	  <xsl:attribute name="onclick">javascript:switchDisplay("intervals")</xsl:attribute>
	  <xsl:text>Intervals</xsl:text>
	</xsl:element>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="id">intervals</xsl:attribute>
	<xsl:attribute name="style">display:none</xsl:attribute>
	<xsl:call-template name="INTERVAL_TABLE"/>
	<!-- 
	<xsl:call-template name="HR_INTERVALS"/>
	<xsl:call-template name="HR_BREAKS"/>
	-->
      </xsl:element>
    </xsl:if>
    
    <xsl:if test="count(record) &gt; 10">
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
    </xsl:if>
    
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
	  <xsl:for-each select="*[not(contains(name(),'enhanced'))]">
	    <xsl:sort select="@unit" order="descending"/>
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
		<xsl:choose>
		  <xsl:when test="contains(name(),'heart')">
		    <xsl:value-of select="format-number(.,'###','f1')"/> <!--  -->
		  </xsl:when>
		  <xsl:when test="contains(name(),'speed')">
		    <xsl:value-of select="."/>
		  </xsl:when>
		  <xsl:when test="contains(name(),'time') and @sec">
		    <xsl:value-of select="."/>
		  </xsl:when>
		  <xsl:when test="contains(name(),'time') and @unit = 's'">
		    <xsl:value-of select="concat(.,' ≌ ')"/>
		    <xsl:call-template name="ISOTIME">
		      <xsl:with-param name="s" select="."/>
		    </xsl:call-template>
		  </xsl:when>
		  <xsl:when test="contains(name(),'distance')">
		    <xsl:value-of select="format-number(.,'###,###','s1')"/> <!--  -->
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="."/>
		  </xsl:otherwise>
		</xsl:choose>
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
	      <xsl:for-each select="start_time|total_elapsed_time|total_distance|avg_heart_rate|avg_speed|max_speed|max_heart_rate">
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
	    <xsl:for-each select="start_time|total_elapsed_time|total_distance|avg_heart_rate|avg_speed|max_speed|max_heart_rate">
	      <xsl:sort select="name()"/>
	      <xsl:element name="td">
		<xsl:choose>
		  <xsl:when test="name() = 'total_elapsed_time'">
		    <xsl:call-template name="ISOTIME">
		      <xsl:with-param name="s" select="."/>
		    </xsl:call-template>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="."/> <!-- format-number(.,'#.##','f1') -->
		  </xsl:otherwise>
		</xsl:choose>
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
	  <xsl:element name="th"># record</xsl:element>
	  <xsl:element name="th">time</xsl:element>
	  <xsl:element name="th">time [s]</xsl:element>
	  <xsl:element name="th">distance [km]</xsl:element>
	  <xsl:element name="th">heart_rate [bpm]</xsl:element>
	  <xsl:element name="th">speed [km/h]</xsl:element>
	  <xsl:element name="th">altitude [m]</xsl:element>
	  <xsl:element name="th">Δ altitude [m]</xsl:element>
	</xsl:element>
      </xsl:element>
      <xsl:element name="tbody">
	<xsl:for-each select="record">
	  <xsl:variable name="int_t" select="timestamp/@sec - $int_t0"/>
	  <xsl:variable name="int_h" select="altitude - preceding-sibling::record[1]/altitude"/>
	  <xsl:element name="tr">
	    <xsl:element name="td">
              <xsl:value-of select="position()"/>
	    </xsl:element>
	    <xsl:element name="td">
	      <xsl:call-template name="ISOTIME">
		<xsl:with-param name="s" select="$int_t"/>
	      </xsl:call-template>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="$int_t"/>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="distance"/>
	    </xsl:element>
	    <xsl:element name="td">
	      <xsl:choose>
		<xsl:when test="heart_rate &gt; $int_hr_2">
		  <xsl:attribute name="bgcolor">#ffcccc</xsl:attribute>
		</xsl:when>
		<xsl:when test="heart_rate &gt; $int_hr_1">
		  <xsl:attribute name="bgcolor">#ccffcc</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
		  <!-- default color -->
		</xsl:otherwise>
	      </xsl:choose>
              <xsl:value-of select="heart_rate"/>
	    </xsl:element>
	    <xsl:element name="td">
	      <xsl:choose>
		<xsl:when test="speed &gt; $int_v_2">
		  <xsl:attribute name="bgcolor">#ffcccc</xsl:attribute>
		</xsl:when>
		<xsl:when test="speed &gt; $int_v_1">
		  <xsl:attribute name="bgcolor">#ccffcc</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
		  <!-- default color -->
		</xsl:otherwise>
	      </xsl:choose>
              <xsl:value-of select="speed"/>
	    </xsl:element>
	    <xsl:element name="td">
              <xsl:value-of select="format-number(altitude,'##.0','f1')"/>
	    </xsl:element>
	    <xsl:element name="td">
	      <xsl:choose>
		<xsl:when test="$int_h &gt; 0.1">
		  <xsl:attribute name="bgcolor">#ffcccc</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
		  <!-- default color -->
		</xsl:otherwise>
	      </xsl:choose>
              <xsl:value-of select="format-number($int_h,'##0.0','f1')"/>
	    </xsl:element>
	  </xsl:element>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="RECORD_DIAGRAM">

    <xsl:variable name="int_width" select="$int_t1 - $int_t0 + 100"/>
    
    <xsl:element name="svg" xmlns="http://www.w3.org/2000/svg">
      <xsl:attribute name="version">1.1</xsl:attribute>
      <xsl:attribute name="baseProfile">full</xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$int_width"/></xsl:attribute>
      <xsl:attribute name="id">diagram</xsl:attribute>

      <xsl:element name="title">
	<xsl:value-of select="concat('Diagram: ', $int_t0, 's .. ', $int_t1,'s')"/>
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
	<xsl:attribute name="stroke">#ff0000</xsl:attribute>
	<xsl:attribute name="stroke-width">.5</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - ($int_hr_4)"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - ($int_hr_4)"/></xsl:attribute>
	<xsl:element name="title">
	  <xsl:value-of select="concat('Red zone: ', $int_hr_4, ' .. ', $int_hr_4)"/>
	</xsl:element>
      </xsl:element>

      <xsl:element name="line">
	<xsl:attribute name="stroke">#ccccff</xsl:attribute>
	<xsl:attribute name="stroke-width">.5</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - ($int_v_1 * 2)"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - ($int_v_1 * 2)"/></xsl:attribute>
      </xsl:element>

      <xsl:element name="line">
	<xsl:attribute name="stroke">#ccccff</xsl:attribute>
	<xsl:attribute name="stroke-width">.5</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - ($int_v_2 * 2)"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - ($int_v_2 * 2)"/></xsl:attribute>
      </xsl:element>

      <xsl:for-each select="intervals/interval">
	<xsl:element name="rect">
	  <xsl:attribute name="fill-opacity">0.7</xsl:attribute>
	  <xsl:attribute name="fill">#ffffcc</xsl:attribute>
	  <xsl:attribute name="x"><xsl:value-of select="@t_0 - $int_t0"/></xsl:attribute>
	  <xsl:attribute name="y"><xsl:value-of select="$int_height - $int_alt_0"/></xsl:attribute>
	  <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
	  <xsl:attribute name="width"><xsl:value-of select="@t_1 - @t_0"/></xsl:attribute>
	  <xsl:element name="title">
	    <xsl:value-of select="concat('Interval: ', position(),': max. ',@hr_max,' bpm, ', format-number(@s_1 - @s_0,'##0.00','s1'),' km, ',@v,' km/h, ')"/>
	    <xsl:call-template name="ISOTIME">
	      <xsl:with-param name="s" select="@t_1 - @t_0"/>
	    </xsl:call-template>
	  </xsl:element>
	</xsl:element>
      </xsl:for-each>

      <xsl:element name="line">
	<xsl:attribute name="stroke">#00ff00</xsl:attribute>
	<xsl:attribute name="stroke-width">1</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - $int_alt_0"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - $int_alt_0"/></xsl:attribute>
	<xsl:element name="title">
	  <xsl:value-of select="$int_alt_0"/>
	</xsl:element>
      </xsl:element>

      <xsl:element name="line">
	<xsl:attribute name="stroke">#00ff00</xsl:attribute>
	<xsl:attribute name="stroke-width">1</xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="0"/></xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="$int_height - $int_alt_1"/></xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="$int_height - $int_alt_1"/></xsl:attribute>
	<xsl:element name="title">
	  <xsl:value-of select="$int_alt_1"/>
	</xsl:element>
      </xsl:element>

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

      <xsl:for-each select="record[timestamp/@sec &gt; $int_t0 and timestamp/@sec &lt; $int_t1]">
	<xsl:variable name="int_x" select="timestamp/@sec - $int_t0"/>
	
	<xsl:for-each select="speed">
	  <xsl:variable name="int_y" select="$int_height - format-number(. * 2,'#,')"/>
	
	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ccccff</xsl:attribute>
	    <xsl:attribute name="stroke-width">1</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="$int_height"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_y"/></xsl:attribute>
	    <xsl:if test="number(.) &gt; $int_v_1">
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
	    <xsl:attribute name="r"><xsl:value-of select="1.0"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:call-template name="ISOTIME">
		<xsl:with-param name="s" select="$int_x"/>
	      </xsl:call-template>
	      <xsl:value-of select="concat(': ',.)"/>
	    </xsl:element>
	  </xsl:element>
	</xsl:for-each>
	
	<xsl:for-each select="altitude">
	  <xsl:variable name="int_y" select="$int_height - format-number(.,'#,')"/>
	
	  <xsl:element name="circle">
	    <xsl:attribute name="stroke">#00ff00</xsl:attribute>
	    <xsl:attribute name="cx"><xsl:value-of select="$int_x"/></xsl:attribute>
	    <xsl:attribute name="cy"><xsl:value-of select="$int_y"/></xsl:attribute>
	    <xsl:attribute name="r"><xsl:value-of select="1.0"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="."/>
	    </xsl:element>
	  </xsl:element>
	</xsl:for-each>
	
      </xsl:for-each>

      <xsl:for-each select="lap[timestamp/@sec &gt; $int_t0 and timestamp/@sec &lt; $int_t1]">
	<xsl:variable name="int_x" select="timestamp/@sec - $int_t0"/>
	
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
	      <xsl:attribute name="x"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="dy"><xsl:value-of select="12"/></xsl:attribute>
              <xsl:value-of select="concat(name(),':', .,' [', @unit,']')"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:element>

      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="INTERVAL_TABLE">
    <xsl:for-each select="intervals[@id='intervals']">
      <xsl:element name="table">
	<xsl:attribute name="name">
	  <xsl:value-of select="@id"/>
	</xsl:attribute>
	<xsl:element name="thead">
	  <xsl:element name="tr">
	    <xsl:element name="th">#</xsl:element>
	    <xsl:element name="th">time</xsl:element>
	    <xsl:element name="th">max_heart_rate [bpm]</xsl:element>
	    <xsl:element name="th">interval_distance [km]</xsl:element>
	    <xsl:element name="th">avg_speed [km/h]</xsl:element>
	  </xsl:element>
	</xsl:element>
	<xsl:element name="tbody">
	  <xsl:for-each select="interval">
	    <xsl:element name="tr">
	      <xsl:element name="td">
		<xsl:value-of select="position()"/>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="@t_1 - @t_0"/>
		</xsl:call-template>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="@hr_max"/>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="format-number(@s_1 - @s_0,'##0.00','s1')"/>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="format-number(@v,'##0.0','s1')"/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:for-each>
	    <xsl:element name="tr">
	      <xsl:element name="th">
	      </xsl:element>
	      <xsl:element name="th">
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="@d_t"/>
		</xsl:call-template>
	      </xsl:element>
	      <xsl:element name="th">
	      </xsl:element>
	      <xsl:element name="th">
		<xsl:value-of select="format-number(@d_s,'##0.00','s1')"/>
	      </xsl:element>
	      <xsl:element name="th">
	      </xsl:element>
	    </xsl:element>
	</xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="HR_INTERVALS">
    <xsl:for-each select="hist[@param='heart_rate_intervals']">
      <xsl:element name="table">
	<xsl:attribute name="name">
	  <xsl:value-of select="@param"/>
	</xsl:attribute>
	<xsl:element name="thead">
	  <xsl:element name="tr">
	    <xsl:element name="th">
	      <xsl:value-of select="concat('interval (↗',@hr_1,' ↘',@hr_2,')')"/>
	    </xsl:element>
	    <xsl:element name="th">count</xsl:element>
	  </xsl:element>
	</xsl:element>
	<xsl:element name="tbody">
	  <xsl:for-each select="c[. &gt; 0]">
	    <xsl:element name="tr">
	      <xsl:element name="td">
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="@v"/>
		</xsl:call-template>
		<xsl:value-of select="' ... '"/>
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="following-sibling::c[1]/@v"/>
		</xsl:call-template>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:for-each>
	  <xsl:element name="tr">
	    <xsl:element name="th">
	      <xsl:value-of select="concat('',' ∑ ')"/>
	      <xsl:call-template name="ISOTIME">
		<xsl:with-param name="s" select="@sum"/>
	      </xsl:call-template>
	    </xsl:element>
	    <xsl:element name="th">
	      <xsl:value-of select="@count"/>
	    </xsl:element>
	  </xsl:element>
	</xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="HR_BREAKS">
    <xsl:for-each select="hist[@param='heart_rate_breaks']">
      <xsl:element name="table">
	<xsl:attribute name="name">
	  <xsl:value-of select="@param"/>
	</xsl:attribute>
	<xsl:element name="thead">
	  <xsl:element name="tr">
	    <xsl:element name="th">
	      <xsl:value-of select="concat('(active) breaks (↘',@hr_0,')')"/>
	    </xsl:element>
	    <xsl:element name="th">count</xsl:element>
	  </xsl:element>
	</xsl:element>
	<xsl:element name="tbody">
	  <xsl:for-each select="c[. &gt; 0]">
	    <xsl:element name="tr">
	      <xsl:element name="td">
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="@v"/>
		</xsl:call-template>
		<xsl:value-of select="' ... '"/>
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="following-sibling::c[1]/@v"/>
		</xsl:call-template>
	      </xsl:element>
	      <xsl:element name="td">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:for-each>
	  <xsl:element name="tr">
	    <xsl:element name="th">
	      <xsl:value-of select="concat('',' ∑ ')"/>
	      <xsl:call-template name="ISOTIME">
		<xsl:with-param name="s" select="@sum"/>
	      </xsl:call-template>
	    </xsl:element>
	    <xsl:element name="th">
	      <xsl:value-of select="@count"/>
	    </xsl:element>
	  </xsl:element>
	</xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="HR_HISTOGRAM">

    <xsl:variable name="int_scale" select="3.0"/>
    <xsl:variable name="int_width" select="200"/>
    <xsl:variable name="int_height" select="100"/>
    
    <xsl:element name="svg" xmlns="http://www.w3.org/2000/svg">
      <xsl:attribute name="version">1.1</xsl:attribute>
      <xsl:attribute name="baseProfile">full</xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$int_height * $int_scale"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$int_width * $int_scale"/></xsl:attribute>
      <xsl:attribute name="id">hr_histogram</xsl:attribute>

      <xsl:element name="g">
	<xsl:attribute name="transform">
	  <xsl:value-of select="concat('scale(',$int_scale,')')"/>
	</xsl:attribute>

	<xsl:for-each select="hist[@param='heart_rate']">
	  
	  <xsl:variable name="int_hr_min" select="number(c[1]/@v)"/>
	  
	  <xsl:variable name="int_hr_scale" select="$int_width div ($int_hr_3 - $int_hr_min)"/>
	  
	  <xsl:variable name="int_bar_width" select="c[2]/@v - c[1]/@v"/>
	  
	  <xsl:element name="rect">
	    <xsl:attribute name="fill">#ccffcc</xsl:attribute>
	    <xsl:attribute name="x"><xsl:value-of select="($int_hr_1 - $int_hr_min) * $int_hr_scale"/></xsl:attribute>
	    <xsl:attribute name="y"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
	    <xsl:attribute name="width"><xsl:value-of select="($int_hr_2 - $int_hr_1) * $int_hr_scale"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="concat('Endurance zone: ', $int_hr_1, ' .. ', $int_hr_2)"/>
	    </xsl:element>
	  </xsl:element>
	  
	  <xsl:element name="rect">
	    <xsl:attribute name="fill">#ffcccc</xsl:attribute>
	    <xsl:attribute name="x"><xsl:value-of select="($int_hr_2 - $int_hr_min) * $int_hr_scale"/></xsl:attribute>
	    <xsl:attribute name="y"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="height"><xsl:value-of select="$int_height"/></xsl:attribute>
	    <xsl:attribute name="width"><xsl:value-of select="($int_hr_3 - $int_hr_2) * $int_hr_scale"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="concat('Red zone: ', $int_hr_2, ' .. ', $int_hr_3)"/>
	    </xsl:element>
	  </xsl:element>

	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.25</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="$int_hr_min"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="concat('HR Zone: ', number(@v), ' ', number(.) * 100,'%')"/>
	    </xsl:element>
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

	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.5</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="(number(@median) - $int_hr_min) * $int_hr_scale"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="(number(@median) - $int_hr_min) * $int_hr_scale"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="concat('HR median.: ',number(@median))"/>
	    </xsl:element>
	  </xsl:element>

	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.5</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="(number(@max) - $int_hr_min) * $int_hr_scale"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="(number(@max) - $int_hr_min) * $int_hr_scale"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat('HR max.: ',number(@max))"/>
	      </xsl:element>
	  </xsl:element>

	  <xsl:for-each select="child::c">
	    <xsl:variable name="int_x" select="(number(@v) - $int_hr_min) * $int_hr_scale"/>
	    <xsl:variable name="int_y" select="number(.) * 100"/>
	    
	    <xsl:if test="@n &gt; 0">
	      <xsl:element name="rect">
		<xsl:attribute name="fill">#ff8888</xsl:attribute>
		<xsl:attribute name="x"><xsl:value-of select="$int_x"/></xsl:attribute>
		<xsl:attribute name="y"><xsl:value-of select="$int_height - $int_y"/></xsl:attribute>
		<xsl:attribute name="height"><xsl:value-of select="$int_y"/></xsl:attribute>
		<xsl:attribute name="width"><xsl:value-of select="$int_bar_width * $int_hr_scale"/></xsl:attribute>
		<xsl:element name="title">
		  <xsl:value-of select="concat('HR = ', number(@v), ' bpm: ', format-number(number(.) * 100.0,'###','f1'),'%  ≌ ')"/>
		  <xsl:call-template name="ISOTIME">
		    <xsl:with-param name="s" select="number(@n)"/>
		  </xsl:call-template>
		</xsl:element>
	      </xsl:element>
	    </xsl:if>

	    <xsl:element name="line">
	      <xsl:attribute name="stroke">rgb(128,128,128)</xsl:attribute>
	      <xsl:attribute name="stroke-width">.25</xsl:attribute>
	      <xsl:attribute name="x1"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	      <xsl:attribute name="x2"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	    </xsl:element>

	    <xsl:element name="circle">
	      <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	      <xsl:attribute name="stroke-width">1</xsl:attribute>
	      <xsl:attribute name="cx"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="cy"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	      <xsl:attribute name="r"><xsl:value-of select=".5"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat('HR ≥ ',number(@v),' bpm: ',format-number(@sum * 100.0,'###','f1'),'%  ≌ ')"/>
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="@sum * $int_timer"/>
		</xsl:call-template>
	      </xsl:element>
	    </xsl:element>

	  </xsl:for-each>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="SPEED_HISTOGRAM">

    <xsl:variable name="int_scale" select="3.0"/>
    <xsl:variable name="int_width" select="300"/>
    <xsl:variable name="int_height" select="100"/>
    
    <xsl:element name="svg" xmlns="http://www.w3.org/2000/svg">
      <xsl:attribute name="version">1.1</xsl:attribute>
      <xsl:attribute name="baseProfile">full</xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$int_height * $int_scale"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$int_width * $int_scale"/></xsl:attribute>
      <xsl:attribute name="id">v_histogram</xsl:attribute>

      <xsl:element name="g">
	<xsl:attribute name="transform">
	  <xsl:value-of select="concat('scale(',$int_scale,')')"/>
	</xsl:attribute>

	<xsl:for-each select="hist[@param='speed']">
	  
	  <xsl:variable name="int_v_min" select="number(c[1]/@v)"/>
	  
	  <xsl:variable name="int_v_scale" select="$int_width div ($int_v_3 - $int_v_min)"/>
	  
	  <xsl:variable name="int_bar_width" select="c[2]/@v - c[1]/@v"/>
	  
	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.25</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="$int_v_min"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="$int_width"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="concat('v ', number(@v), ' km/h: ', number(.),'%')"/>
	    </xsl:element>
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

	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.5</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="(number(@median) - $int_v_min) * $int_v_scale"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="(number(@median) - $int_v_min) * $int_v_scale"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	    <xsl:element name="title">
	      <xsl:value-of select="concat('v median. km/h: ',format-number(number(@median),'##.#','f1'))"/>
	    </xsl:element>
	  </xsl:element>

	  <xsl:element name="line">
	    <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	    <xsl:attribute name="stroke-width">.5</xsl:attribute>
	    <xsl:attribute name="x1"><xsl:value-of select="(number(@max) - $int_v_min) * $int_v_scale"/></xsl:attribute>
	    <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	    <xsl:attribute name="x2"><xsl:value-of select="(number(@max) - $int_v_min) * $int_v_scale"/></xsl:attribute>
	    <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat('v max. km/h: ',format-number(number(@max),'##.#','f1'))"/>
	      </xsl:element>
	  </xsl:element>

	  <xsl:for-each select="child::c">
	    <xsl:variable name="int_x" select="(number(@v) - $int_v_min) * $int_v_scale"/>
	    <xsl:variable name="int_y" select="number(.) * 100"/>
	    
	    <xsl:if test="@n &gt; 0">
	      <xsl:element name="rect">
		<xsl:attribute name="fill">#aaaaaa</xsl:attribute>
		<xsl:attribute name="x"><xsl:value-of select="$int_x"/></xsl:attribute>
		<xsl:attribute name="y"><xsl:value-of select="$int_height - $int_y"/></xsl:attribute>
		<xsl:attribute name="height"><xsl:value-of select="$int_y"/></xsl:attribute>
		<xsl:attribute name="width"><xsl:value-of select="$int_bar_width * $int_v_scale"/></xsl:attribute>
		<xsl:element name="title">
		  <xsl:value-of select="concat('v = ', number(@v), ' km/h: ', format-number(number(.) * 100.0,'###','f1'),'%  ≌ ')"/>
		  <xsl:call-template name="ISOTIME">
		    <xsl:with-param name="s" select="number(@n)"/>
		  </xsl:call-template>
		</xsl:element>
	      </xsl:element>
	    </xsl:if>

	    <xsl:element name="line">
	      <xsl:attribute name="stroke">rgb(128,128,128)</xsl:attribute>
	      <xsl:attribute name="stroke-width">
		<xsl:choose>
		  <xsl:when test="@v mod 10 = 0">
		    <xsl:text>.75</xsl:text>
		  </xsl:when>
		  <xsl:when test="@v mod 5 = 0">
		    <xsl:text>.5</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>.25</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
 	      </xsl:attribute>
	      <xsl:attribute name="x1"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="y1"><xsl:value-of select="0"/></xsl:attribute>
	      <xsl:attribute name="x2"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="y2"><xsl:value-of select="$int_height"/></xsl:attribute>
	    </xsl:element>

	    <xsl:element name="circle">
	      <xsl:attribute name="stroke">#ff0000</xsl:attribute>
	      <xsl:attribute name="stroke-width">1</xsl:attribute>
	      <xsl:attribute name="cx"><xsl:value-of select="$int_x"/></xsl:attribute>
	      <xsl:attribute name="cy"><xsl:value-of select="$int_height - (@sum * 100)"/></xsl:attribute>
	      <xsl:attribute name="r"><xsl:value-of select=".5"/></xsl:attribute>
	      <xsl:element name="title">
		<xsl:value-of select="concat('v ≥ ',number(@v),' km/h: ',format-number(@sum * 100.0,'###','f1'),'%  ≌ ')"/>
		<xsl:call-template name="ISOTIME">
		  <xsl:with-param name="s" select="@sum * $int_timer"/>
		</xsl:call-template>
	      </xsl:element>
	    </xsl:element>

	  </xsl:for-each>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="ISOTIME">
    <xsl:param name="s" select="0"/>
    <xsl:choose>
      <xsl:when test="$s &lt; 60">
	<xsl:value-of select="concat(format-number($s,'0','t1'),' s')"/>
      </xsl:when>
      <xsl:when test="$s &lt; 3600">
	<xsl:value-of select="concat(format-number(floor($s div 60.0),'0','t1'),':',format-number($s mod 60,'00','t1'),' min')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat(format-number(floor($s div 3600.0),'0','t1'),':',format-number(floor(($s mod 3600) div 60.0),'00','t1'),':',format-number($s mod 60,'00','t1'),' h')"/>
      </xsl:otherwise>
    </xsl:choose>
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
  border-collapse: collapse;
  empty-cells:show;
}

table.unlined {
  background-color:#ffffff;
}

tr {
  text-align:right;
  vertical-align:top;
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

/* header cells */
th {
  border: 1px solid grey;
  padding: .2em .5em;
  background-color:#d9d9d9;
  color:#000000;
  font-weight:bold;
}

/* data cells */
td {
  border: 1px solid grey;
  margin: 8px;
  padding: .2em .5em;
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

svg {
  font-family: Arial; font-size: 8pt;
  display:none;
}

#v_histogram, #hr_histogram {
  display:block;
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

</xsl:stylesheet>
