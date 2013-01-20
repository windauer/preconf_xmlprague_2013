xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";

declare option exist:serialize "method=xhtml media-type=application/xhtml+html";


declare %private function local:printNumberedList($norms){  
    for $norm at $index in $norms         
        return 
            <tr>
                <td>{$index}</td> 
                <td>{$norm//jurabk}</td>
                <td>{$norm//metadaten/ausfertigung-datum}</td>    
                <td>{$norm//metadaten/langue}</td>    
            </tr>            
};   

   
declare %private function local:sort($norms, $orderBy, $showAscending) { 
    let $orderedParams :=
            if($showAscending)
            then (        
                for $norm in $norms                     
                    order by $norm/metadaten/ausfertigung-datum ascending
                    return $norm
            )else (
                for $norm in $norms
                    order by $norm/metadaten/ausfertigung-datum descending
                    return $norm            
            )                    
    return 
        local:printNumberedList($orderedParams)
};

declare %private function local:searchTerm($norms, $term, $orderBy, $showAscending) {
    let $result :=  $norms[.//*/ft:query(. , $term)]                                     
    return 
        local:sort($result, $orderBy, $showAscending)
};


declare function local:main($norms, $term as xs:string, $orderBy as xs:string, $showAscending as xs:boolean)  as element() {
    <tbody>
    {
        if($term eq '')
        then(
             local:sort($norms, $orderBy, $showAscending)
        )else (                   
            local:searchTerm($norms, $term, $orderBy, $showAscending)            
        )
        
    }
    </tbody>
};


let $data := request:get-data()
let $startdate := xs:date(if($data) then ($data//startdate) else ('1700-01-01'))
let $enddate := xs:date(if($data) then ($data//enddate) else (current-date()))
let $showAscending :=if($data and $data//sortAscending = 'true') then (true()) else (false())
let $term :=    if($data and string-length($data//term) gt 0) then ($data//term/text()) else ('')
let $orderBy := if($data and string-length($data//orderBy) gt 0) then ($data//orderBy/text()) else ('') 

(: Get all law book within the given start and enddate :)
let $norms := collection("/apps/gesetze/data/")/dokumente/norm[xs:date(metadaten/ausfertigung-datum) ge $startdate][xs:date(metadaten/ausfertigung-datum) le $enddate]

return
    <div>
        <h2>Search Result</h2>
        <table id="masterdataFiles" border="0">
            <thead>
                <tr>
                    <td>Nr</td>
                    <td>Titel</td>
                    <td>Datum</td>
                    <td>About</td>
                
                </tr>
            </thead>            
             { local:main($norms, $term, $orderBy, $showAscending) }            
        </table>                
    </div>
 

