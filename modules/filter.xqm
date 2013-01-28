xquery version "3.0";

(:~
 :
 :)
module namespace filter="http://exist-db.org/xquery/apps/filter";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: count of norms per year :)
declare function filter:get-years-with-norms() {
    let $dates := collection($config:data-root)//tei:TEI/tei:teiHeader//tei:publicationStmt/tei:date
    let $distinctValues := distinct-values(
                                for $value in $dates return year-from-date(xs:date($value)))
                                    return
                                        <years>
                                            {
                                                for $distinctValue in $distinctValues
                                                   return
                                                        <year>{$distinctValue}</year>
                                            }
                                        </years>
};