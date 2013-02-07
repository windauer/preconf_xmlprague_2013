xquery version "3.0";

module namespace app="http://exist-db.org/apps/gesetze/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace xforms="http://betterform.de/xquery/xforms" at "xforms.xqm";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace kwic="http://exist-db.org/xquery/kwic"
    at "resource:org/exist/xquery/lib/kwic.xql";

declare %templates:wrap function app:list-all($node as node(), $model as map(*)) {
    map {
        "documents" := 
            for $doc in collection($config:data-root)/tei:TEI
            order by $doc/tei:teiHeader//tei:titleStmt/tei:title[@type = "short"]
            return
                $doc
    }
};

declare %templates:wrap function app:abbrev($node as node(), $model as map(*)) {
    $model("document")/tei:teiHeader//tei:titleStmt/tei:title[@type = "short"]/string()
};

declare %templates:wrap function app:title($node as node(), $model as map(*)) {
    <a href="toc.html?id={$model('document')/@xml:id}">
    {$model("document")/tei:teiHeader//tei:titleStmt/tei:title[not(@type)]/text()}
    </a>
};

declare %templates:wrap function app:date($node as node(), $model as map(*)) {
    $model("document")/tei:teiHeader//tei:publicationStmt/tei:date/text()
};

declare function app:load($node as node(), $model as map(*), $id as xs:string) {
    map {
        "document" := collection($config:data-root)/tei:TEI[@xml:id = $id]
    }
};

declare %templates:wrap function app:contents($node as node(), $model as map(*)) {
    for $div in $model("document")//tei:div
    let $level := count($div/ancestor::tei:div) + 2
    return
        <li>
        {
            if ($div/tei:div) then
                element { "h" || $level } {
                    $div/tei:head[not(@type)]/text(), ": ", $div/tei:head[@type = "subtitle"]/text()
                }
            else
                <a href="norm.html?docId={$model('document')/@xml:id}&amp;id={$div/@xml:id}">{$div/tei:head/text()}</a>
        }
        </li>
};

declare %templates:wrap function app:load-norm($node as node(), $model as map(*), $docId as xs:string, $id as xs:string,
    $query as xs:string?) {
    let $doc := collection($config:data-root)//id($docId)
    let $norm := 
        if ($query) then
            $doc/id($id)[ft:query(., $query)]
        else
            $doc/id($id)
    return
    map {
        "norm" := $norm,
        "document" := $doc
    }
};

declare %templates:wrap function app:random-norm($node as node(), $model as map(*)) {
    
    let $teiData := collection($config:data-root)//tei:TEI[@xml:id]
    let $teiCount := count($teiData)
    let $random := ceiling(util:random() * $teiCount) cast as xs:integer
    
    let $doc := collection($config:data-root)//tei:TEI[@xml:id][$random]
    
    let $randomPara := ceiling(util:random() * count($doc//tei:div[@xml:id])) cast as xs:integer
    let $norm := $doc//tei:div[$randomPara]
    return
    map {
        "norm" := $norm,
        "document" := $doc
    }
};

declare function app:norm-content($node as node(), $model as map(*)) {
    app:process(util:expand($model("norm")/*))
};

declare %private function app:process($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(tei:head) return
                <h2>{app:process($node/node())}</h2>
            case element(tei:p) return
                <p>{app:process($node/node())}</p>
            case element(tei:list) return
                switch ($node/@type)
                    case "ordered" return
                        <ol>{app:process($node/node())}</ol>
                    case "gloss" return
                        <dl>{app:process($node/node())}</dl>
                    default return
                        <ul>{app:process($node/node())}</ul>
            case element(tei:item) return
                if ($node/parent::tei:list[@type = "gloss"]) then
                    <dd>{app:process($node/node())}</dd>
                else
                    <li>
                    {
                        app:process($node/node())
                    }
                    </li>
            case element(tei:label) return
                <dt>{app:process($node/node())}</dt>
            case element(exist:match) return
                <mark>{$node/node()}</mark>
            case element() return
                for $child in $node/node() return app:process($child)
            default return
                $node
};

declare %templates:wrap function app:hierarchy($node as node(), $model as map(*)) {
    <li>
        <a href="toc.html?id={$model('document')/@xml:id}">
        {$model("document")/tei:teiHeader//tei:titleStmt/tei:title[not(@type)]/text()}
        </a>
    </li>,
    for $div in $model("norm")/ancestor::tei:div[tei:head]
    return
        <li>{$div/tei:head[not(@type)]/text(), ": ", $div/tei:head[@type = "subtitle"]/text()}</li>
};

declare function app:next-page($node as node(), $model as map(*)) {
    let $following := $model("norm")/following::tei:div[not(tei:div)][1]
    return
        if ($following) then
            <a href="norm.html?docId={$model('document')/@xml:id}&amp;id={$following/@xml:id}">
            { $node/node() }
            </a>
        else
            ()
};

declare function app:previous-page($node as node(), $model as map(*)) {
    let $preceding := $model("norm")/preceding::tei:div[not(tei:div)][1]
    return
        if ($preceding) then
            <a href="norm.html?docId={$model('document')/@xml:id}&amp;id={$preceding/@xml:id}">
            { $node/node() }
            </a>
        else
            ()
};

declare 
    %templates:wrap
function app:search($node as node(), $model as map(*), $query as xs:string?, $cached as item()*) {
    if ($query or $cached) then
        let $result := 
            if ($query) then
                collection($config:data-root)//tei:div[ft:query(., $query)][not(tei:div)]
            else
                $cached
        return (
            map {
                "result" := $result,
                "query" := $query
            },
            session:set-attribute("cached", $result)
        )
    else
        ()
};


declare function app:hit-count($node as node(), $model as map(*)) {
    count($model("result"))
};

declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("max", 20)
function app:search-result($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    let $toDisplay := subsequence($model("result"), $start, $max)
    for $result in $toDisplay
    group by $docId := $result/ancestor::tei:TEI/@xml:id
    return
        templates:process($node/node(), map:new(($model, map { "group" := $result, "doc-id" := $docId })))
};

declare
    %templates:wrap 
function app:result-title($node as node(), $model as map(*)) {
    $model("group")/ancestor::tei:TEI/tei:teiHeader//tei:titleStmt/tei:title[not(@type)]/text()
};

declare function app:result-kwic($node as node(), $model as map(*)) {
    for $item in $model("group")
    let $config :=
        <config width="40" table="yes" link="norm.html?docId={$model('doc-id')}&amp;id={$item/@xml:id}&amp;query={$model('query')}"/>
    let $expanded := kwic:expand($item)
    return
        (: Only display the first match if there are multiple matches within a paragraph :)
        kwic:get-summary($expanded, head($expanded//exist:match), $config)
};

declare 
    %templates:default("start", 1)
    %templates:default("max", 20)
function app:pagination-next($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    let $total := count($model("result"))
    return
        if ($start + $max < $total) then
            element { node-name($node) } {
                $node/@* except $node/@href,
                attribute href { "?start=" || $start + $max },
                $node/node()
            }
        else
            ()
};

declare 
    %templates:default("start", 1)
    %templates:default("max", 20)
function app:pagination-previous($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    let $total := count($model("result"))
    return
        if ($start > 1) then
            element { node-name($node) } {
                $node/@* except $node/@href,
                attribute href { "?start=" || $start - $max },
                $node/node()
            }
        else
            ()
};

declare %templates:wrap function app:playground($node as node(), $model as map(*)) {
    let $htmlTemplate := collection($config:app-root)/*[@id='search5']
    let $xformsMarkup := xforms:transform($htmlTemplate)
    (:$htmlTemplate:)
    return
        $xformsMarkup
};

declare %private function app:order-by($order, $tei as node()*) {
    switch($order)
        case 'title' return $tei//tei:title[@type]/text()
        case 'desc' return  $tei//tei:title[not(@type)]/text()
        case 'year' return  $tei//tei:date
        default return  $tei//@xml:id
};

declare 
    %templates:wrap
    %templates:default("query", 'EMPTY')
    %templates:default("startyear", 1869)
    %templates:default("endyear", 2012)    
function app:xf-search($node as node(), $model as map(*), $query as xs:string?, $cached as item()*, $startyear as xs:integer, $endyear as xs:integer) {    
    if (($query or $cached) and $query ne 'EMPTY') then
        let $result := 
            if ($query) then
                let $hits := collection($config:data-root)//tei:div[ft:query(., $query)][not(tei:div)]                
                for $hit in $hits                    
                    group by $docId := $hit/ancestor::tei:TEI/@xml:id                      
                    return 
                        let $year := xs:integer(year-from-date(xs:date($hit/ancestor::tei:TEI/tei:teiHeader//tei:date/text())))
                        return 
                            if($year ge $startyear and $year le $endyear) then $hit else ()
            else
                $cached
        let $stored := session:set-attribute("cached", $result)
        return
            map {
                "result" := $result,
                "query" := $query
            }
    else
        ()
};


declare 
    %templates:wrap
function app:xf-simple-search($node as node(), $model as map(*), $query as xs:string?, $cached as item()*, $startyear as xs:integer, $endyear as xs:integer) {
    if ($query or $cached) then
        let $result := 
            if ($query) then
                
                let $hits := collection($config:data-root)//tei:div[ft:query(., $query)][not(tei:div)]                
                for $hit in $hits                    
                    group by $docId := $hit/ancestor::tei:TEI/@xml:id                      
                    return 
                        let $year := xs:integer(year-from-date(xs:date($hit/ancestor::tei:TEI/tei:teiHeader//tei:date/text())))
                        return 
                            if($year ge $startyear and $year le $endyear) then $hit else ()
                
            else
                $cached
        let $stored := session:set-attribute("cached", $result)
        return
            map {
                "result" := $result,
                "query" := $query
            }
    else
        ()
};





declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("max", 20)
    %templates:default("startyear", 1869)
    %templates:default("endyear", 2012)
    %templates:default("order", "year")
function app:xf-search-result($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer, $order as xs:string, $startyear as xs:integer, $endyear as xs:integer) {
    let $sortedResults := for $doc in $model("result")/ancestor::tei:TEI
                            group by $docId := $doc/@xml:id
                            order by app:order-by($order, $doc) ascending        
                            return 
                                $doc
                            
    let $filteredResults := subsequence($sortedResults, $start, $max)                            
    for $result at $index in $filteredResults
        return 
            templates:process($node/node(), map:new(($model, map {"group" := $result, "index" := ($start + $index -1)})))                      
};

declare
    %templates:wrap
 function app:xf-hit-count($node as node(), $model as map(*), $query as xs:string, $start as xs:integer, $max as xs:integer) {    
    (: let $resultCount := count($model("result")) :)
    let $resultCount := count(distinct-values($model("result")/ancestor::tei:TEI/tei:teiHeader//tei:titleStmt/tei:title[@type]/text()))
    let $showNext := if($resultCount gt  ($start + $max -1)) then($start + $max -1) else ($start + $resultCount -1) 
    return         
        if ($resultCount > 1)
        then 
            <div class="alert alert-info">Found term '{$query}' in {$resultCount} Books of Law and {count($model("result"))} paragraphs. Displaying results from {$start} to {$showNext}</div>                               
        else <div class="alert">No results found for term '{$query}'</div>
};


declare
    %templates:wrap 
function app:xf-result-number($node as node(), $model as map(*)) {   
    $model("index")
};


declare
    %templates:wrap 
function app:xf-result-title($node as node(), $model as map(*)) {
    let $title := $model("group")/tei:teiHeader//tei:titleStmt/tei:title[@type]/text()
    let $id := $model("group")/@xml:id
    return 
        <a href="toc.html?id={$id}" target="_blank">{$title}</a>
};

declare
    %templates:wrap 
function app:xf-result-desc($node as node(), $model as map(*)) {
    let $desc := $model("group")/tei:teiHeader//tei:titleStmt/tei:title[not(@type)]/text()
    let $id := $model("group")/@xml:id
    return 
        <a href="toc.html?id={$id}" target="_blank">{$desc}</a>    
};

declare
    %templates:wrap 
function app:xf-result-year($node as node(), $model as map(*)) {
    year-from-date(xs:date($model("group")/tei:teiHeader//tei:date/text()))       
};

declare
    %templates:wrap 
function app:xf-result-paragraphs($node as node(), $model as map(*)) {
    let $docId :=$model("group")/@xml:id
    for $paragraph in $model("result")[./ancestor::tei:TEI[@xml:id eq $docId]] 
        let $type :=    if(starts-with($paragraph/tei:head/text(),'¤'))
                        then ('paragraph')
                        else (
                            if(starts-with($paragraph/tei:head/text(),'Anlage'))
                            then ('attachment')
                            else (
                                if(starts-with($paragraph/tei:head/text(),'Art'))
                                then ('article')
                                else ('other')
                            )
                        )
        return
            <a class="{$type}" href="norm.html?docId={data($docId)}&amp;id={data($paragraph/@xml:id)}" target="_blank">{$paragraph/tei:head/text()}</a>
};

declare 
    %templates:default("start", 1)
    %templates:default("max", 20)
function app:pagination-next-trigger($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    let $resultCount := count(distinct-values($model("result")/ancestor::tei:TEI/tei:teiHeader//tei:titleStmt/tei:title[@type]/text()))
    return 
        if ($start + $max < $resultCount) 
        then(
            app:create-nav-trigger($node,($start + $max))
        )
        else()
};


declare 
    %templates:default("start", 1)
    %templates:default("max", 20)
function app:pagination-previous-trigger($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    if ($start > 1) then
        app:create-nav-trigger($node,($start - $max))
    else ()
};

declare %private function app:create-nav-trigger($node as node(), $startindex) {
    let $triggerOpts := map {   
                        "label" := data($node/@label),
                        "appearance" := 'minimal',
                        "actions" := 
                            map  {
                                '1' := map { 'name' := 'xf:setvalue', 'ref' := 'start', 'value' := $startindex},
                                '2' := map { 'name' := 'xf:send', 'submission' := data($node/@data-send)}                            
                            }
                        }
    return                     
        xforms:create-trigger($triggerOpts)
};


