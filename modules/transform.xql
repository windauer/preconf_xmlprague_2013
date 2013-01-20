xquery version "3.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

declare variable $local:XSL_PREPROCESS := doc($config:app-root || "/resources/xsl/toc.xsl");
declare variable $local:XSL_TEI := doc($config:app-root || "/resources/xsl/tei.xsl");

let $docParam := request:get-parameter("doc", "BJNR001950896.xml")
let $doc := doc($config:data-root || "/" || $docParam)
let $processed := transform:transform($doc, $local:XSL_PREPROCESS, ())
let $tei := transform:transform($processed, $local:XSL_TEI, ())
return
    xmldb:store($config:data-root || "/transformed", $docParam, $tei, "text/xml")