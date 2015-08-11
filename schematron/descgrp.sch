<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  <ns uri="urn:isbn:1-931666-22-9" prefix="ead"/>

  <phase id="automated">
    <active pattern="descgrp-automated" />
  </phase>
  <phase id="manual">
    <active pattern="descgrp-manual" />
  </phase>

  <pattern id="descgrp-automated">
    <rule context="//descgrp[@type and @type != 'add']/head">
      <assert test="not(.)">'head' element should be dropped from descgrp</assert>
    </rule>

    <rule context="//descgrp[@type and @type != 'add']/address|
                   //descgrp[@type and @type != 'add']/blockquote|
                   //descgrp[@type and @type != 'add']/chronlist|
                   //descgrp[@type and @type != 'add']/list|
                   //descgrp[@type and @type != 'add']/p">
      <assert test="not(.)">'descgrp' is deprecated, and must be removed. '<value-of select="local-name(.)" />' element can be moved out of 'descgrp' element into a new 'note' element in surrounding '<value-of select="local-name(./../..)" />'</assert>
    </rule>
    <rule context="//descgrp[@type and @type != 'add']/accessrestrict|
                   //descgrp[@type and @type != 'add']/accruals|
                   //descgrp[@type and @type != 'add']/acquinfo|
                   //descgrp[@type and @type != 'add']/altformavail|
                   //descgrp[@type and @type != 'add']/appraisal|
                   //descgrp[@type and @type != 'add']/custodhist|
                   //descgrp[@type and @type != 'add']/note|
                   //descgrp[@type and @type != 'add']/prefercite|
                   //descgrp[@type and @type != 'add']/processinfo|
                   //descgrp[@type and @type != 'add']/userestrict|
                   //descgrp[@type and @type != 'add']/accessrestrict|
                   //descgrp[@type and @type != 'add']/accruals|
                   //descgrp[@type and @type != 'add']/acquinfo|
                   //descgrp[@type and @type != 'add']/altformavail|
                   //descgrp[@type and @type != 'add']/appraisal|
                   //descgrp[@type and @type != 'add']/custodhist|
                   //descgrp[@type and @type != 'add']/note|
                   //descgrp[@type and @type != 'add']/prefercite|
                   //descgrp[@type and @type != 'add']/processinfo|
                   //descgrp[@type and @type != 'add']/userestrict">
      <assert test="not(.)">'descgrp' is deprecated, and must be removed. '<value-of select="local-name(.)" />' element can be moved out of 'descgrp element into surrounding '<value-of select="local-name(./../..)" />'</assert>
    </rule>
  </pattern>
  <pattern id="descgrp-manual">
    <rule context="//descgrp[@type]">
      <assert test="not(@type='add')">'descgrp' is deprecated, and must be removed. 'descgrp' element with type 'add' requires manual review and intervention.</assert>
    </rule>
  </pattern>

</schema>
