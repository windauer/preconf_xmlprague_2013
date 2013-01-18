xquery version "3.0";

module namespace app="http://exist-db.org/apps/gesetze/templates";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

import module namespace templates="http://exist-db.org/xquery/templates" ;

declare %templates:wrap function app:list-all($node as node(), $model as map(*)) {
    map {
        "documents" := 
            for $doc in collection($config:data-root)/dokumente
            order by $doc/norm[1]/metadaten/jurabk[1]
            return
                $doc
    }
};

declare %templates:wrap function app:abbrev($node as node(), $model as map(*)) {
    $model("document")/norm[1]/metadaten/jurabk/text()
};

declare %templates:wrap function app:title($node as node(), $model as map(*)) {
    <a href="toc.html?doknr={$model('document')/@doknr}">
    {$model("document")/norm[1]/metadaten/langue/text()}
    </a>
};

declare %templates:wrap function app:date($node as node(), $model as map(*)) {
    $model("document")/norm[1]/metadaten/ausfertigung-datum/text()
};

declare function app:load($node as node(), $model as map(*), $doknr as xs:string) {
    map {
        "document" := collection($config:data-root)/dokumente[@doknr = $doknr]
    }
};

declare %templates:wrap function app:contents($node as node(), $model as map(*)) {
    for $norm in subsequence($model("document")/norm, 2)
    let $meta := $norm/metadaten
    let $enbz := $meta/enbez
    let $gliederungseinheit := $meta/gliederungseinheit
    return
        if ($gliederungseinheit) then
            <li>
                <h2>{$gliederungseinheit/gliederungsbez/text()}: {$gliederungseinheit/gliederungstitel/text()}</h2>
            </li>
        else if ($enbz) then
            <li>
                <a href="norm.html?doknr={$norm/@doknr}">
                { $enbz/text(), " ", $meta/titel/text() }
                </a>
            </li>
        else
            ()
};

declare %templates:wrap function app:load-norm($node as node(), $model as map(*), $doknr as xs:string) {
    let $log := util:log("INFO", "DokNr: " || $doknr)
    let $norm := collection($config:data-root)//norm[@doknr = $doknr]
    let $log := util:log("INFO", "NORM: " || $norm)
    return
    map {
        "norm" := $norm,
        "document" := $norm/ancestor::dokumente
    }
};

declare %templates:wrap function app:norm-title($node as node(), $model as map(*)) {
    $model("norm")//metadaten/enbez || " " || $model("norm")//metadaten/titel
};

declare function app:norm-content($node as node(), $model as map(*)) {
    app:process($model("norm")/textdaten/text/*)
};

declare function app:process($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(P) return
                <p>{for $child in $node/node() return app:process($child)}</p>
            case element(UL) return
                <ul>{app:process($node/*)}</ul>
            case element(OL) return
                <ol>{app:process($node/*)}</ol>
            case element(LI) return
                <li>{app:process($node/node())}</li>
            case element(DL) return
                <dl>{app:process($node/*)}</dl>
            case element(DD) return
                <dd>{app:process($node/*)}</dd>
            case element(DT) return
                <dt>{app:process($node/*)}</dt>
            case element() return
                for $child in $node/node() return app:process($child)
            default return
                $node
};

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};