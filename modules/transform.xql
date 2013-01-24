xquery version "3.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

declare variable $local:XSL_PREPROCESS := doc($config:app-root || "/resources/xsl/inline.xsl");
declare variable $local:XSL_PREPROCESS2 := doc($config:app-root || "/resources/xsl/content.xsl");
declare variable $local:XSL_TEI := doc($config:app-root || "/resources/xsl/tei.xsl");
declare variable $local:OUTPUT_COL := xmldb:create-collection($config:data-root, "/tei");

(:let $docParam := request:get-parameter("doc", "BJNR001950896.xml"):)
for $doc in collection($config:data-root)/dokumente
let $name := util:document-name($doc)
let $processed := transform:transform($doc, $local:XSL_PREPROCESS, ())
let $processed := transform:transform($processed, $local:XSL_PREPROCESS2, ())
let $tei := transform:transform($processed, $local:XSL_TEI, ())
return
    xmldb:store($local:OUTPUT_COL, $name, $tei, "text/xml")