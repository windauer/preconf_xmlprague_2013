xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace xforms="http://betterform.de/xquery/xforms" at "xforms.xqm";
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
declare function local:get-years-with-norms() {
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


(: count of norms per year :)
declare function local:get-norms-by-year($start, $end) {
    let $codes := collection($config:data-root)//tei:TEI/tei:teiHeader//tei:publicationStmt/tei:date
    (: concat(count($codes[year-from-date(xs:date(.))=$year]),', ') :)
    for $year in $start to $end
        order by $year ascending
        return concat('[&apos;1/1/',$year, '&apos; , ',count($codes[year-from-date(xs:date(.))=$year]),'],')
                       
  
};
<p>
    {local:get-norms-by-year(1869,2012)}
</p>
    

    