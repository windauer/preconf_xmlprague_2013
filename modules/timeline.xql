xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace xforms="http://betterform.de/xquery/xforms" at "xforms.xqm";
import module namespace templates="http://exist-db.org/xquery/templates" ;


(: transforms and return codes of law for simile timeline :)
let $codes := collection($config:data-root)//tei:TEI/tei:teiHeader
return 
    <data>
        {
            for $code in $codes
                order by $code//tei:publicationStmt/tei:date ascending
                return                            
                    <event start="{$code//tei:publicationStmt/tei:date}" title="{$code//tei:title[@type eq 'short']/text()}">{$code//tei:title[1]/text()}</event>
            }            
        </data>
  

    