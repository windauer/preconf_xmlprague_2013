xquery version "3.0";

module namespace app="http://exist-db.org/apps/gesetze/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

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
            case element(exist:match) return
                <mark>{$node/node()}</mark>
            case element() return
                for $child in $node/node() return app:process($child)
            default return
                $node
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
function app:search($node as node(), $model as map(*), $query as xs:string?) {
    if ($query) then
        let $result := collection($config:data-root)//tei:div[ft:query(., $query)][not(tei:div)]
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
function app:search-result($node as node(), $model as map(*)) {
    for $result in $model("result")
    group by $docId := $result/ancestor::tei:TEI/@xml:id
    return (
        <tr>
            <td colspan="3" class="title">
            {$result/ancestor::tei:TEI/tei:teiHeader//tei:titleStmt/tei:title[not(@type)]/text()}
            </td>
        </tr>,
        for $item in $result
        let $config :=
            <config width="40" table="yes" link="norm.html?docId={$docId}&amp;id={$item/@xml:id}&amp;query={$model('query')}"/>
        return
            kwic:summarize($item, $config, ())
    )
};