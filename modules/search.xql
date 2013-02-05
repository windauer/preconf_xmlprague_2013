xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";

import module namespace app="http://exist-db.org/apps/gesetze/templates" at "app.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xf="http://www.w3.org/2002/xforms";

declare option exist:serialize "method=html5 media-type=text/html";

(: 
let $data := request:get-data()
let $startdate := xs:date(if($data) then ($data//startdate) else ('1700-01-01'))
let $enddate := xs:date(if($data) then ($data//enddate) else (current-date()))
let $showAscending :=if($data and $data//sortAscending = 'true') then (true()) else (false())
let $term :=    if($data and string-length($data//term) gt 0) then ($data//term/text()) else ('')
let $orderBy := if($data and string-length($data//orderBy) gt 0) then ($data//orderBy/text()) else ('')
let $norms := collection("/apps/gesetze/data/")/dokumente/norm[xs:date(metadaten/ausfertigung-datum) ge $startdate][xs:date(metadaten/ausfertigung-datum) le $enddate]:)

 declare %private function local:order-by($order, $tei as node()*) {
    switch($order)
        case 'title' return $tei//tei:title[@type]/text()
        case 'desc' return  $tei//tei:title[not(@type)]/text()
        case 'year' return  $tei//tei:date
        default return  $tei//@xml:id
 };
 
 
 declare %private function local:result-table($term,$startyear as xs:integer, $endyear as xs:integer, $order as xs:string, $start as xs:integer, $max as xs:integer) {
    let $hits := collection($config:data-root)//tei:div[ft:query(., $term)][not(tei:div)]
    let $searchResults := for $hit in $hits
                            group by $docId := $hit/ancestor::tei:TEI/@xml:id
                                order by local:order-by($order, $hit/ancestor::tei:TEI)  
                                return
                                    <code id="{$docId}" 
                                          year="{year-from-date(xs:date($hit/ancestor::tei:TEI//tei:date/text()))}" 
                                          title="{$hit/ancestor::tei:TEI//tei:title[@type]/text()}" 
                                          desc="{$hit/ancestor::tei:TEI//tei:title[not(@type)]/text()}">{$hit}</code>                              
    let $formatedResult := for $code at $index in $searchResults                                
                                return 
                                    if(xs:integer($code/@year) ge $startyear and xs:integer($code/@year) le $endyear)
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
        let $toDisplay := subsequence($formatedResult, $start, $start + $max - 1)
        let $resultCount := count($formatedResult)
        let $showNext := if($resultCount gt  ($start + $max -1)) then($start + $max -1) else ($start + $resultCount -1)
        return 
        <div>           
            {
                
                if ($resultCount > 1)
                then <div class="alert alert-info">Found term '{$term}' at {$resultCount} locations in {count($formatedResult//a[@class='paragraph'])} codes. Displaying results from {$start} to {$showNext}</div>                               
                else <div class="alert">No results found for term '{$term}'</div>
            }

            <nav class="top">
                <ul>
                    <li class="next">
                        <xf:trigger appearance="minimal">
                            <xf:label>Next</xf:label>
                            <xf:setvalue ref="instance()/start" value="{$start} + {$max}"/>                            
                        </xf:trigger>

                    </li>
                    <li class="previous">   
                        <xf:trigger appearance="minimal">
                            <xf:label>Previous</xf:label>
                            <xf:setvalue ref="instance()/start" value="{$max}-{$start}"/>
                        </xf:trigger>
                    </li>
                </ul>
            </nav>
            <table class="results table table-striped">
                <thead>
                    <tr>
                        <td><b>Code</b></td>
                        <td><b>Description</b></td>
                        <td><b>Date</b></td>
                        <td><b>Paragraph(s)</b></td>
                    </tr>
                </thead>
                <tbody>
                    {$toDisplay}
                </tbody>
            </table>
        </div>
 };
 
 declare %private function local:render-result($result,$start as xs:integer ,$max as xs:integer){
    <div/> 
    
 };
 
 
 let $term := request:get-parameter('query', 'Bier')
 let $startyear := request:get-parameter('startyear', '1869')
 let $endyear := request:get-parameter('endyear', '2012')
 let $order := request:get-parameter('order', 'year')
 let $code := request:get-parameter('code', '')
 let $start := request:get-parameter('start', '1')
 let $max := request:get-parameter('max', '20')
 
return 
    local:result-table($term,$startyear, $endyear, $order, $start, $max)



