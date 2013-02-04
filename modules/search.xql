xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";

import module namespace app="http://exist-db.org/apps/gesetze/templates" at "app.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: 
let $data := request:get-data()
let $startdate := xs:date(if($data) then ($data//startdate) else ('1700-01-01'))
let $enddate := xs:date(if($data) then ($data//enddate) else (current-date()))
let $showAscending :=if($data and $data//sortAscending = 'true') then (true()) else (false())
let $term :=    if($data and string-length($data//term) gt 0) then ($data//term/text()) else ('')
let $orderBy := if($data and string-length($data//orderBy) gt 0) then ($data//orderBy/text()) else ('')
let $norms := collection("/apps/gesetze/data/")/dokumente/norm[xs:date(metadaten/ausfertigung-datum) ge $startdate][xs:date(metadaten/ausfertigung-datum) le $enddate]:)

 
 
 declare %private function local:result-table($term,$start as xs:integer, $end as xs:integer) {
    let $hits := collection($config:data-root)//tei:div[ft:query(., $term)][not(tei:div)]
    let $searchResults := for $hit in $hits
                            group by $docId := $hit/ancestor::tei:TEI/@xml:id
                            order by $hit/ancestor::tei:TEI//tei:date
                                return
                                    <code id="{$docId}" 
                                          year="{year-from-date(xs:date($hit/ancestor::tei:TEI//tei:date/text()))}" 
                                          title="{$hit/ancestor::tei:TEI//tei:title[@type]/text()}" 
                                          desc="{$hit/ancestor::tei:TEI//tei:title[not(@type)]/text()}">{$hit}</code>                              
    let $formatedResult := for $code at $index in $searchResults                                
                                return 
                                    if(xs:integer($code/@year) ge $start and xs:integer($code/@year) le $end)
                                    then (
                                        <tr class="col-{$index mod 2}">                                
                                            <td><a href="toc.html?id={data($code/@id)}" target="_blank">{data($code/@title)}</a></td>
                                            <td>{data($code/@desc)}</td>
                                            <td>{data($code/@year)}</td>        
                                            <td>
                                                {
                                                    for $paragraph in $code//tei:div[tei:head]
                                                        let $type :=    if(starts-with($paragraph/tei:head/text(),'§'))
                                                                        then ('paragraph')
                                                                        else (
                                                                            if(starts-with($paragraph/tei:head/text(),'Anlage'))
                                                                            then ('attachment')
                                                                            else (
                                                                                if(starts-with($paragraph/tei:head/text(),'Art'))
                                                                                then ('article')
                                                                                else ('other')
                                                                            )
                                                                        )
                                                        return
                                                            <a class="{$type}" href="norm.html?docId={data($code/@id)}&amp;id={data($paragraph/@xml:id)}" target="_blank">{$paragraph/tei:head/text()}</a>
                                                }
                                            </td>
                                        </tr>
                                        )else ()
      return 
        <div>
            <div>Found term '{$term}' at {count($formatedResult)} locations in {count($formatedResult//a[@class='paragraph'])} codes</div>
            <table class="results">
                <tr>
                    <td><b>Code</b></td>
                    <td><b>Description</b></td>
                    <td><b>Date</b></td>
                    <td><b>Paragraph(s)</b></td>
                </tr>
                <tbody>
                    {$formatedResult}
                </tbody>
            </table>
        </div>
 };
 
 
 let $term := request:get-parameter('term', 'Bier')
 let $start := request:get-parameter('startyear', '1868')
 let $end := request:get-parameter('endyear', '2013')

return 
    local:result-table($term,$start, $end)



