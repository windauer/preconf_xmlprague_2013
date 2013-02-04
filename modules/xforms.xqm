xquery version "3.0";

(:~
 : 
 :)
module namespace xforms="http://betterform.de/xquery/xforms";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
:)

declare %private function xforms:label($node as node(),$model as node()*) {    
    let $label := if(exists($node/@label)) 
                  then (data($node/@label)) 
                  else ($model//label[@for=$node/@id]/text())
    return  
        if(string-length($label) gt 0)
        then (
            element xf:label {                 
                $label
            }        
        )
        else ()
};

declare %private function xforms:hint($node as node()*,$model as node()*) {
    if(exists($node/@placeholder))
    then (                                     
        let $hint := data($node/@placeholder)
        return 
            element xf:hint {                
                $hint
            }    
    )
    else ()                                            

};

(: 
 : XForms Input
 :  
:)
declare %private function xforms:input($node as node(),$model as node()*) {
    element xf:input {
        for $attr in $node/@*[not(local-name(.)='data-ref' or local-name(.)='placeholder')] return $attr,
        attribute { 'ref' } { xs:string($node/@data-ref) }, 
        xforms:label($node,$model),
        xforms:hint($node,$model)
    }
};
(: 
 : XForms Trigger
 :  
:)
declare %private function xforms:trigger($node as node(),$model as node()*) {
    element xf:trigger { 
        element xf:label { 
            $node/text()            
        },        
        element xf:send {
            attribute {'submission'} { data($node/@data-submission) }
        }
    }
};

(: 
 : XForms Output
 :  
:)
declare %private function xforms:output($node as node(),$model as node()*) {
    element xf:output { 
        for $attr in $node/@*[not(local-name(.)='data-ref')] return $attr,
        if(not(exists($node/@ref)) and exists($node/@data-ref)) 
        then ( attribute { 'ref' } { xs:string($node/@data-ref) })
        else (),
        xforms:label($node,$model)       
    }
};

(: 
 : XForms Select1
 :  
:)
declare %private function xforms:select1($node as node(),$model as node()*) {
    (: <select1 data-ref="startyear" label="Code / Year" data-itemset="instance('i-years')/codes" data-label="@year" data-value="@year"/> :)
    if(exists($node/@data-ref))
    then (        
        element xf:select1 {
            attribute { 'ref' } { data($node/@data-ref) },        
            for $attr in $node/@* return $attr,                            
            xforms:label($node,$model),
            let $optionType := if(exists($node/@data-itemset))
                               then ('itemset')
                               else if(exists($node/option))
                                    then 'options'
                                    else ()
            return 
                switch($optionType)
                    case 'itemset' return 
                        element xf:itemset {
                            attribute { 'nodeset' } { data($node/@data-itemset) },
                            element xf:label { 
                                attribute { 'ref' } { if(exists($node/@data-label)) then (data($node/@data-label)) else ('.') }
                            },                            
                            element xf:value {                 
                                attribute { 'ref' } { if(exists($node/@data-value)) then (data($node/@data-value)) else ('.') }
                            }                            
                        }
                    case 'options' return 
                        element xf:choices {
                            for $option in $node//option
                                return 
                                    element xf:item {
                                        element xf:label { $option/text() },
                                        element xf:value { data($option/@id) }                                    
                                    }                        
                        }
                    default return $node/*
        }
    )
    else ( 
        $node
    )
};
(: 
 : XForms Group
 :  
:)
declare %private function xforms:group($node as node(),$model as node()*) {
    element xf:group {        
        for $attr in $node/@* return $attr,                            
        if(exists($node/@data-xf-label))
        then (
            element xf:label { data($node/@data-xf-label)}
        )
        else (),
        for $child in $node/node() return xforms:process-ui($child,$model)
    }
};




(: TRANSFORM HTML5 UI TO XFORMS USER INTERFACE MARKUP  :)
declare  function xforms:process-ui($nodes as node()*,$model as node()*) {    
    for $node in $nodes
        return
            if($node instance of element())
            then (
                let $nodename := local-name($node)
                let $type := if($nodename eq 'form' and exists($node/@data-target))
                             then ('group')
                             else (
                                 if(($nodename eq 'span' or  $nodename  eq 'div') and exists($node/@data-ref))
                                 then ('output')
                                 else ($nodename)
                             )
                return
                    switch($type)
                        case 'input'    return xforms:input($node, $model)
                        case 'button'   return xforms:trigger($node, $model)
                        case 'group'    return xforms:group($node, $model)
                        case 'select1'  return xforms:select1($node,$model)
                        case 'output'   return xforms:output($node,$model)
                        default return                     
                            element {name($node)} {
                                for $attr in $node/@* return $attr,
                                for $child in $node/node() return xforms:process-ui($child,$model)
                            }
            )
            else (
                $node
            )
          
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
        if(exists($node/@model))
        then (
        let $xfUI := xforms:process-ui($node,$node)        
        return
            (templates:process($xfUI/node(), $model))        
        )
        else (
            let $expanded := xforms:transform($node)
            return
                templates:process($expanded/node(), $model)
        )
    )
};


declare function xforms:transform($node as node()) {
    let $xfModel := xforms:process-model($node)
    let $xfUI := xforms:process-ui($node,$node)
    
    return 
        ($xfModel,$xfUI)
        
    
};
