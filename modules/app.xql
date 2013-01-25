xquery version "3.0";

module namespace app="http://exist-db.org/apps/gesetze/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

import module namespace templates="http://exist-db.org/xquery/templates" ;

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

declare %templates:wrap function app:load-norm($node as node(), $model as map(*), $docId as xs:string, $id as xs:string) {
    let $doc := collection($config:data-root)//id($docId)
    let $norm := $doc/id($id)
    let $log := util:log("DEBUG", "Norm: " || $norm)
    return
    map {
        "norm" := $norm,
        "document" := $doc
    }
};

declare function app:norm-content($node as node(), $model as map(*)) {
    app:process($model("norm")/*)
};

declare %private function app:process($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(tei:head) return
                <h2>{app:process($node/node())}</h2>
            case element(tei:p) return
                <p>{app:process($node/node())}</p>
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


