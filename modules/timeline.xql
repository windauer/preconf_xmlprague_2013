xquery version "3.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $targetCollection :=  xmldb:create-collection($config:data-root, "/transformed")
let $codesAsEvents := 
    <data>{
        for $code in collection(concat($config:data-root,'/tei'))//tei:TEI return
            <event  id="{$code/@xml:id}" 
                    title="{$code/tei:teiHeader//tei:title[exists(@type)]/text()}"
                    link="../../toc.html?id={$code/@xml:id}"
                    start="{data($code/tei:teiHeader//tei:publicationStmt/tei:date/text())}">
                {$code/tei:teiHeader//tei:title[not(exists(@type))]/text()}          
            </event>                                    
    }</data>
return
        xmldb:store($targetCollection, "timeline.xml", $codesAsEvents, "text/xml")
