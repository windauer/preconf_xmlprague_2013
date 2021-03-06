xquery version "3.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $local:XSL_PREPROCESS := doc($config:app-root || "/resources/xsl/inline.xsl");
declare variable $local:XSL_PREPROCESS2 := doc($config:app-root || "/resources/xsl/content.xsl");
declare variable $local:XSL_TEI := doc($config:app-root || "/resources/xsl/tei.xsl");
declare variable $local:OUTPUT_COL := xmldb:create-collection($config:data-root, "/tei");


declare %private function local:transform-codes() {
    for $doc in collection(concat($config:data-root,'/codes'))/dokumente
        let $name := util:document-name($doc)
        let $processed := transform:transform($doc, $local:XSL_PREPROCESS, ())
        (:let $processed := transform:transform($processed, $local:XSL_PREPROCESS2, ()):)
        let $tei := transform:transform($processed, $local:XSL_TEI, ())
        return
            xmldb:store($local:OUTPUT_COL, $name, $tei, "text/xml")
};

declare function local:create-toc-of-codes($filename, $targetCollection) {
    let $codes := collection(concat($config:data-root,'/tei'))//tei:TEI
    let $result-toc := <codes>
                            {
                            for $code in $codes
                                return
                                    <code id="{$code/@xml:id}"                                             
                                            title="{$code/tei:teiHeader//tei:title[exists(@type)]/text()}" 
                                            date="{data($code/tei:teiHeader//tei:publicationStmt/tei:date)}">
                                                {$code/tei:teiHeader//tei:title[not(exists(@type))]/text()}                                                
                                    </code>
                            }
                        </codes>

    return
        xmldb:store($targetCollection, $filename, $result-toc, "text/xml")

};

declare function local:create-timeline-xml($filename, $targetCollection) {
    let $codes := collection(concat($config:data-root,'/tei'))//tei:TEI
    let $codesAsEvents := <data>
                            {
                            for $code in $codes
                                return
                                    <event  id="{$code/@xml:id}" 
                                            title="{$code/tei:teiHeader//tei:title[exists(@type)]/text()}"
                                            link="../../toc.html?id={$code/@xml:id}"
                                            start="{data($code/tei:teiHeader//tei:publicationStmt/tei:date/text())}">
                                                {$code/tei:teiHeader//tei:title[not(exists(@type))]/text()}          
                                    </event>
                            }
                        </data>

    return
        xmldb:store($targetCollection, $filename, $codesAsEvents, "text/xml")

};



declare %private function local:create-codes-by-year($filename, $targetCollection) {
    let $codes :=
                        for $norm in collection($config:data-root)//tei:TEI
                            order by $norm/tei:teiHeader//tei:publicationStmt/tei:date ascending
                            return
                                <code   year="{year-from-date(xs:date($norm/tei:teiHeader//tei:publicationStmt/tei:date))}"
                                        date="{xs:string($norm/tei:teiHeader//tei:publicationStmt/tei:date)}"
                                        title="{$norm/tei:teiHeader//tei:title[exists(@type)]/text()}"
                                        id="{$norm/@xml:id}">{$norm/tei:teiHeader//tei:title[not(exists(@type))]/text()}</code>

    let $distinctYears := distinct-values(for $value in $codes return $value/@year)
    let $codesSortedByYear := 
                        <data>
                            {
                            for $distinctYear in $distinctYears
                                return
                                    element { 'codes' } {
                                        attribute year { $distinctYear },
                                        let $codesInYear := $codes[@year = $distinctYear]
                                        return
                                            (attribute count {count($codesInYear)}, $codesInYear)
                
                                    }
                            }
                        </data>
    return
            xmldb:store($targetCollection, $filename, $codesSortedByYear, "text/xml")


};

(: 
let $short := collection($config:data-root)//tei:TEI[@xml:id='BJNR005380942']/tei:teiHeader//tei:title[exists(@type)]/text()
let $long :=  collection($config:data-root)//tei:TEI[@xml:id='BJNR005380942']/tei:teiHeader//tei:title[not(exists(@type))]/text()
return 
    <div>
            <short>{for $t in $short return concat('-text: ',$t)}</short>
            <long>{for $t in $long return concat('-text: ',$t)}</long>
    </div>
 :)

let $collection :=  xmldb:create-collection($config:data-root, "/transformed")

let $codes-toc      := local:create-toc-of-codes("codes-toc.xml" , $collection) 
let $codes-by-year := local:create-codes-by-year("codes-by-year.xml" , $collection) 
let $codes-timeline-xml := local:create-timeline-xml("timeline.xml" , $collection) 

let $transformed-codes := local:transform-codes() 

return 
    ($codes-toc, $codes-by-year, $transformed-codes, $codes-timeline-xml)
