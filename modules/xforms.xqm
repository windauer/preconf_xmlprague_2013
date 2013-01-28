xquery version "3.0";

(:~
 : 
 :)
module namespace xforms="http://betterform.de/xquery/xforms";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
:)

declare function xforms:process-ui-label($node as node()*,$model as node()*) {
    let $label := $model//label[@for=$node/@id]
    return 
        <xf:label>{$label/text()}</xf:label>
    
};

declare function xforms:process-ui-hint($node as node()*,$model as node()*) {
    let $hint := data($node/@placeholder)
    return 
        <xf:hint>{$hint}</xf:hint>
};

(: TRANSFORM HTML5 UI TO XFORMS USER INTERFACE MARKUP  :)
declare function xforms:process-ui($nodes as node()*,$model as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(input) return
                <xf:input ref="{$node/@data-ref}">
                    { 
                        xforms:process-ui-label($node,$model),
                        if(exists($node/@placeholder))
                        then (                            
                            xforms:process-ui-hint($node,$model) 
                        )
                        else ()
                    }                        
                </xf:input>
            case element(button) return 
                <xf:trigger>
                    <xf:label>{$node/text()}</xf:label>                        
                    <xf:send submission="s-{data($node/@data-submission)}"/>
                </xf:trigger>
            case element(label) return ()
            case element(form) return                 
                switch(data($node/@data-xf-type))
                    case 'group' return (
                        element xf:group {
                            attribute { 'appearance' } { 'full' },
                            for $attr in $node/@* return $attr,
                            if(exists($node/@data-xf-label))
                            then (
                                element xf:label { data($node/@data-xf-label)},
                                for $child in $node/node() return xforms:process-ui($child,$model),
                                <xf:trigger>
                                    <xf:label>Send</xf:label>
                                    <xf:send submission="s-submit"/>
                                </xf:trigger>
                                )
                            else (
                                for $child in $node/node() return xforms:process-ui($child,$model),
                                <xf:trigger>
                                    <xf:label>Send</xf:label>
                                    <xf:send submission="s-submit"/>
                                </xf:trigger>
                            )                            
                        }

                    )
                    default return 
                      element {local-name($node)} {                                                    
                            for $attr in $node/@* return $attr,
                            for $child in $node/node() return xforms:process-ui($child,$model)
                        }
            case element() return
                element {local-name($node)} {
                    for $attr in $node/@* return $attr,
                    for $child in $node/node() return xforms:process-ui($child,$model)
                }
            default return
                $node
};

(: TRANSFORM HTML5 UI TO XFORMS MODEL MARKUP  :)
declare function xforms:process-model($model as node()*) {
        <div style="display:none;">
            <xf:model>
                <xf:instance xmlns="" id="i-default">
                    <data>
                        {
                            for $node in $model//*[exists(@data-ref)]
                                return 
                                    element { data($node/@data-ref) } {data($node/@value)}
                        
                        }
                    </data>
                </xf:instance>
                
                <!--xf:instance xmlns="" id="i-years" src="modules/test.xql" /-->
                <xf:bind nodeset="instance('i-default')">
                        {
                          for $node in $model//*[exists(@data-ref) and exists(@type)]                                                      
                            return 
                                switch($node/@type)                                        
                                    case 'checkbox' return 
                                            <xf:bind nodeset="{data($node/@data-ref)}" type="boolean"/>
                                    default return
                                            <xf:bind nodeset="{data($node/@data-ref)}" type="{data($node/@type)}"/>       
                        }
                </xf:bind>,

                <xf:submission id="s-submit" 
                    method="post" 
                    replace="embedHTML" 
                    targetid="searchResultMount" 
                    resource="modules/search.xql" 
                    validate="false">                                
                    <xf:action ev:event="xforms-submit-error">
                        <xf:message>Submission 'submit' failed</xf:message>
                    </xf:action>
                </xf:submission>              
            </xf:model>
        </div>

};

declare %templates:wrap function xforms:expand($node as node(), $model as map(*)) {
    if(exists($node/@modelref))
    then (
        let $xfModel := doc(concat($config:app-root, "/", data($node/@modelref)))
        let $xfUI := xforms:process-ui($node,$node)        
        return
            (templates:process(($xfModel/node(), $xfUI/node()), $model))
    )
    else (
        let $expanded := xforms:transform($node)
        return
            templates:process($expanded/node(), $model)    
    )
};


declare function xforms:transform($node as node()) {
    let $xfModel := xforms:process-model($node)
    let $xfUI := xforms:process-ui($node,$node)
    
    return 
        ($xfModel,$xfUI)
        
    
};
