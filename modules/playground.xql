xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace templates="http://exist-db.org/xquery/templates" ;


(: returns all norms between the given start and end date :)
declare function local:norms-between-dates($start as xs:date, $end as xs:date) {
    let $filteredNorms := collection($config:data-root)//tei:TEI[xs:date(tei:teiHeader//tei:publicationStmt/tei:date) ge $start and xs:date(tei:teiHeader//tei:publicationStmt/tei:date) le $end]
    
    for $norm in $filteredNorms
        order by $norm/tei:teiHeader//tei:publicationStmt/tei:date
        return 
            <norm title="{$norm/tei:teiHeader//tei:title[@type='short']}" date="{$norm/tei:teiHeader//tei:publicationStmt/tei:date}" id="{$norm/@xml:id}">
                {$norm/tei:teiHeader//tei:title[not(@type='small')]}
            </norm>
};


(:  returns all norms between the given start and end date :)
declare function local:norms-between-years($start as xs:integer, $end as xs:integer) {
    
    let $filteredNorms := collection($config:data-root)//tei:TEI[xs:integer(substring(tei:teiHeader//tei:publicationStmt/tei:date,1,4)) ge $start and xs:integer(substring(tei:teiHeader//tei:publicationStmt/tei:date,1,4)) le $end]
    
    for $norm in $filteredNorms
        order by $norm/tei:teiHeader//tei:publicationStmt/tei:date
        return 
            <norm title="{$norm/tei:teiHeader//tei:title[@type='short']}" date="{$norm/tei:teiHeader//tei:publicationStmt/tei:date}" id="{$norm/@xml:id}">
                {$norm/tei:teiHeader//tei:title[not(@type='small')]}
            </norm>
};

(: sort norms by date and return norm elem. with reference to full norm :)
declare function local:sort-norms-by-date() {
       let $normWithYear := 
                        for $norm in collection($config:data-root)//tei:TEI
                            order by $norm/tei:teiHeader//tei:publicationStmt/tei:date
                            return 
                                <norm date="{$norm/tei:teiHeader//tei:publicationStmt/tei:date}" id="{$norm/@xml:id}"/>
        return $normWithYear
                
};

(: returns the latest german law book :)
declare function local:get-latest-norm($seq) {
        let $maxDate := if (every $value in $seq satisfies ($value/@date castable as xs:date))
                then max(for $value in $seq return xs:date($value/@date))
                else max(for $value in $seq return xs:string($value/@date))
        let $maxNormId := $seq[@date=$maxDate][1]/@id
        let $maxNorm := collection($config:data-root)//tei:TEI[@xml:id = $maxNormId]
        return 
            <latest   id="{$maxNorm/@xml:id}" 
                        title="{xs:string($maxNorm/tei:teiHeader//tei:title[@type='short'])}" 
                        date="{$maxNorm/tei:teiHeader//tei:publicationStmt/tei:date}">
                {xs:string($maxNorm//tei:teiHeader//tei:title[1])}                
            </latest>
};

(: returns the earlist german law book :)
declare %private function local:get-earliest-norm($seq) {
        let $minDate := if (every $value in $seq satisfies ($value/@date castable as xs:date))
                then min(for $value in $seq return xs:date($value/@date))
                else min(for $value in $seq return xs:string($value/@date))
        let $minNormId := $seq[@date=$minDate][1]/@id
        let $minNorm := collection($config:data-root)//tei:TEI[@xml:id = $minNormId]
        
        return 
            <earliest   id="{$minNorm/@xml:id}" 
                        title="{xs:string($minNorm/tei:teiHeader//tei:title[@type='short'])}" 
                        date="{$minNorm/tei:teiHeader//tei:publicationStmt/tei:date}">
                {xs:string($minNorm//tei:teiHeader//tei:title[1])}                
            </earliest>
};

(: return the earliest and latest norms :)
declare function local:get-earliest-and-latest-norm($seq) {
    (local:get-latest-norm($seq),local:get-earliest-norm($seq))
                
};

(: count of norms per year :)
declare function local:get-norms-by-year($seq) {
    let $distinctValues := distinct-values(for $value in $seq return substring($value/@date,1,4))
    let $teiData := collection($config:data-root)//tei:TEI
    for $distinctValue in $distinctValues
        return <norms year="{$distinctValue}" count="{count($seq[substring(@date,1,4) = $distinctValue])}">
                    {
                        for $norm in $seq[substring(@date,1,4) = $distinctValue]
                            return 
                                <norm id="{$norm/@id}" title="{$teiData[@xml:id=$norm/@id]/tei:teiHeader//tei:title[@type='short']/text()}" date="{data($teiData[@xml:id=$norm/@id]/tei:teiHeader//tei:publicationStmt/tei:date)}" />
                    }
                </norms>
  
};

let $startDate := xs:date('2000-01-01')
let $endDate := xs:date('2000-12-31')
let $normsBetweenDates := local:norms-between-dates($startDate, $endDate)

let $startYear := xs:integer(2000)
let $endYear := xs:integer(2000)
let $normsBetweenYears := local:norms-between-years($startYear, $endYear)

let $normsByYear := local:sort-norms-by-date()

let $normsPerYear := local:get-norms-by-year($normsByYear)
let $earliestLatestNorm := local:get-earliest-and-latest-norm($normsByYear)



return 
    <result>
        <normsBetweenDates>{$normsBetweenDates}</normsBetweenDates>
        <normsBetweenYears>{$normsBetweenDates}</normsBetweenYears>
        <latestEarliestNorm>{$earliestLatestNorm}</latestEarliestNorm>
        <normsPerYear>{$normsPerYear}</normsPerYear>
    </result>

    