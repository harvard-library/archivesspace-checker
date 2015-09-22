<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  <ns uri="urn:isbn:1-931666-22-9" prefix="ead"/>

  <phase id="automated">
    <active pattern="descgrp-automated" />
  </phase>
  <phase id="manual">
    <active pattern="descgrp-manual" />
    <active pattern="extent-nonnumeric-manual" />
  </phase>

  <pattern id="extent-nonnumeric-manual">
    <rule context="//extent">
      <!-- 'extent' elements -->
      <assert test="matches(., '^[0123456789]')" diagnostics="enm-1">'extent' element content should not start with non-numeric character.</assert>
    </rule>
  </pattern>

  <pattern id="descgrp-automated">
    <rule context="//descgrp[@type and @type != 'add']/head">
      <!-- 'head' elements inside 'descgrp' elements -->
      <assert test="not(.)">'head' element should be dropped from descgrp</assert>
    </rule>

    <rule context="//descgrp[@type and @type != 'add']/address|
                   //descgrp[@type and @type != 'add']/blockquote|
                   //descgrp[@type and @type != 'add']/chronlist|
                   //descgrp[@type and @type != 'add']/list|
                   //descgrp[@type and @type != 'add']/p">
      <!-- 'descgrp' sub-elements of kinds valid in 'note' -->
      <assert test="not(.)" diagnostics="da-2">'descgrp' is deprecated, and must be removed. 'address', 'blockquote', 'chronlist', 'list', and 'p' children of 'descgrp' must be reparented into a new 'note' in the 'descgrp's parent element</assert>
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
      <!-- 'descgrp' sub-elements of kinds valid outside of 'note' -->
      <assert test="not(.)" diagnostics="da-3">'descgrp' is deprecated, and must be removed. Element children of various types must be reparented into 'descgrp's parent element</assert>
    </rule>
  </pattern>

  <pattern id="descgrp-manual">
    <rule context="//descgrp[@type]">
      <!-- 'descgrp' elements with type 'add' -->
      <assert test="not(@type='add')" diagnostics="dm-1">'descgrp' is deprecated, and must be removed. 'descgrp' element with type 'add' requires manual review and intervention.</assert>
    </rule>
  </pattern>

  <pattern id="did-lacking-unitdate-or-unittitle">
    <rule context="//did">
      <!-- 'did' elements -->
      <assert test="count(./unitdate|./unittitle) > 0" diagnostics="dluoum-1">
        'did' elements should contain a unitdate and/or a unittitle.
      </assert>
    </rule>
  </pattern>
  <diagnostics>
    <diagnostic id="enm-1">Ref-number: 18
Content: Value is "<value-of select="." />"</diagnostic>
<diagnostic id="dm-1">Ref-number: 11</diagnostic>
<diagnostic id="da-2">Ref-number: 11
Content: '<value-of select="local-name(.)" />' element can be moved out of 'descgrp' element into a new 'note' element in surrounding '<value-of select="local-name(./../..)" />'</diagnostic>
<diagnostic id="da-3">Ref-number: 11
Content: '<value-of select="local-name(.)" />' element can be moved out of 'descgrp element into surrounding '<value-of select="local-name(./../..)" />'</diagnostic>
<diagnostic id="dluoum-1">
Ref-number: X
Content: Content goeth here
</diagnostic>
  </diagnostics>

</schema>
