xquery version "3.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=json media-type=text/javascript";

let $targetCollection :=  xmldb:create-collection($config:data-root, "/transformed")

let $start := 1869
let $end := 2013
let $codes := for $norm in collection($config:data-root)//tei:TEI return  <code year="{year-from-date(xs:date($norm//tei:publicationStmt/tei:date))}"/>                    
let $yearsWithCodeCount :=    
        <div>{
            for $year in $start to $end return
                concat('[&apos;1/1/',$year,'&apos;, ', count($codes[@year eq xs:string($year)]) ,']', if($year = $end) then() else (', '))            
        }</div>
let $jsonResult := concat('[', $yearsWithCodeCount/text(), ']')            
return     
    xmldb:store($targetCollection, "linechart.json", $jsonResult, "text/json")
    