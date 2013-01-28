xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace templates="http://exist-db.org/xquery/templates" ;

(: sort norms by date and return norm elem. with reference to full norm :)
declare function local:sort-norms-by-date() {
       let $normWithYear := 
                        for $norm in collection($config:data-root)//tei:TEI
                            order by $norm/tei:teiHeader//tei:publicationStmt/tei:date
                            return 
                                <norm date="{$norm/tei:teiHeader//tei:publicationStmt/tei:date}" id="{$norm/@xml:id}"/>
        return $normWithYear
                
};

(: count of norms per year :)
declare function local:get-norms-by-year() { 
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
 
local:get-norms-by-year()
    

    