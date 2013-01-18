xquery version "3.0";

declare namespace g2tei="http://exist-db.org/apps/gesetze/g2tei";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function g2tei:transform($doc as element(dokumente)) {
    let $meta := $doc/norm[1]/metadaten
    let $title := $meta/langue
    let $short := $meta/jurabk
    return
        <tei:TEI>
            <tei:teiHeader>
                <tei:fileDesc>
                    <tei:titleStmt>
                        <tei:title>{$title/text()}</tei:title>
                        <tei:title type="short">{$short/text()}</tei:title>
                    </tei:titleStmt>
                </tei:fileDesc>
            </tei:teiHeader>
            <tei:text xml:id="{$doc/@doknr}">
                <tei:body>
                {
                    for $norm in subsequence($doc/norm, 2)
                    let $enbez := $norm/metadaten/enbez
                    where empty($enbez) or $enbez != "Inhaltsübersicht"
                    return
                        g2tei:process-norm($norm)
                }
                </tei:body>
            </tei:text>
        </tei:TEI>
};

declare function g2tei:process-norm($norm as element(norm)) {
    let $meta := $norm/metadaten
    let $enbz := $meta/enbez
    let $gliederungseinheit := $meta/gliederungseinheit
    return
        if ($gliederungseinheit) then
            <tei:head>{$gliederungseinheit/gliederungsbez/text()}: {$gliederungseinheit/gliederungstitel/text()}</tei:head>
        else if ($enbz) then
            <tei:div>
                <tei:head>{ $enbz/text(), " ", $meta/titel/text() }</tei:head>
                { g2tei:process-content($norm/textdaten/text) }
            </tei:div>
        else
            <tei:div>
                { g2tei:process-content($norm/textdaten/text) }
            </tei:div>
};

declare function g2tei:process-content($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(P) return
                <tei:p>{for $child in $node/node() return g2tei:process-content($child)}</tei:p>
            case element(UL) return
                <tei:list>{g2tei:process-content($node/*)}</tei:list>
            case element(OL) return
                <tei:list type="ordered">{g2tei:process-content($node/*)}</tei:list>
            case element(LI) return
                <tei:item>{g2tei:process-content($node/node())}</tei:item>
            case element(DL) return
                <dl>{g2tei:process-content($node/*)}</dl>
            case element(DD) return
                <dd>{g2tei:process-content($node/*)}</dd>
            case element(DT) return
                <dt>{g2tei:process-content($node/*)}</dt>
            case element() return
                for $child in $node/node() return g2tei:process-content($child)
            default return
                $node
};

g2tei:transform(doc("/db/apps/gesetze/data/BJNR001950896.xml")/dokumente)