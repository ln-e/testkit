@dstop[o][result]
    $result[]
	^if(^Debug:isDeveloper[]){
	    $str[@unhandled_exception[hException^;tStack]^#0A^^Debug:exception[^$hException^;^$tStack]]
        ^process[$MAIN:CLASS]{$str}
        ^if($o is double){ $result[^Debug:stop($o)] }{ $result[^Debug:stop[$o]] }
	}

@dshow[o][result]
	^if(^Debug:isDeveloper[] && (!def $form:mode || $form:mode ne xml)){
		^if($o is double){ ^Debug:show($o) }{ ^Debug:show[$o] }
	}

@dcompact[h][result]
	^Debug:compact[^hash::create[$h]]

@CLASS
Debug

@USE
ConsoleTable.p

@auto[]
	$self.bDeveloper(^env:REMOTE_ADDR.match[^^127\.0\.|^^91\.197\.114|^^91\.197\.113^$|^^58\.96\.54\.98^$|^^10\.0\.|^^^$]))
	$self.tReplacePath[^table::create[nameless]{^if(def $env:DOCUMENT_ROOT){^env:DOCUMENT_ROOT.trim[end;/]	&#8230^;}}]
	$self.sSavePath[/../data/log/debug.html]
	$self.hStatistics[
		$.iCalls(0)
		$.iCompact(0)
		$.hUsage[
			$.hBegin[$status:rusage]
		]
		$.hMemory[
			$.iEnd(0)
			$.iCollected(0)
			$.iBegin($status:memory.used)
		]
		$.fStartTime($status:rusage.tv_sec+$status:rusage.tv_usec/1000000)
	]
	
	$self.sConsole[^self.getInfo[]]

	$self.iTabSize(4)

	$self.iLimit(16384)
	$self.iCall(0)
	$self.iHashId(0)

	$self.iShift(0)
	$self.hShowing[^hash::create[]]

@isDeveloper[][result]
	$result($bDeveloper)

@exception[hException;tStack][result]
$result[]
^if($hException.type eq "debug"){
    $result[${result}^untaint[as-is]{$hException.source}]
}{
    $result[${result}^untaint[html]{$hException.comment}]
    ^if(def $hException.source){
        $result[${result}$hException.source]
        $result[${result}^untaint[html]{$hException.file^($hException.lineno^)}]
    }
    ^if(def $hException.type){$result[${result} exception.type=$hException.type ]}
}
^if($tStack is table){
    $result[${result}^ConsoleTable:formatTable[$tStack]^taint[^#0A]]
#^tStack.menu{^if($hException.type eq debug && ^tStack.line[] < 4 && $tStack.name ne rem){}{|  ^^$tStack.name | ^file:dirname[^if(def $tStack.file){^tStack.file.replace[$self.tReplacePath]}]/<i>^file:basename[$tStack.file] ^[$tStack.lineno^]</i><sup>$tStack.colno</sup>|}}[
#]
}

@extendPostprocess[]
	^if($MAIN:postprocess is junction){
		$MAIN:jOriginalPostprocess[$MAIN:postprocess]
	}
	^process[$MAIN:CLASS]{@postprocess[body][result]
		^^if(^$MAIN:jOriginalPostprocess is junction){
			^$body[^^MAIN:jOriginalPostprocess[^$body]]
		}
		^^if(^$Debug:iCall){
			^$result[^^body.match[(<body[^^^^>]*>)?][i]{^$match.1<div style="display:none" id="_D">^^Debug:getScript^[^]^$Debug:sConsole</div>}]
		}
	}

@getInfo[][result]
$dNow[^date::now[]]
#^rem{ посчитать параметры запроса }
$uriParam[^request:uri.match[^^[^^\?]*\??(.*)?][]{$match.1}]
$uriParam[^uriParam.split[&]]
$uriParamReal(0)
$queryParam[$request:query]
$queryParam[^queryParam.split[&]]
$queryParamCount(^queryParam.count[]-^uriParam.count[])
^if($form:tables is "hash"){^form:tables.foreach[;val]{^uriParamReal.inc(^val.count[])}}
$result[${dNow.hour}:^dNow.minute.format[%.02u]:^dNow.second.format[%.02u]
[^if(def $env:REMOTE_HOST && $env:REMOTE_HOST ne $env:REMOTE_ADDR){REMOTE_ADDR: $env:REMOTE_ADDR REMOTE_HOST: $env:REMOTE_HOST}{$env:REMOTE_ADDR}] ^env:PARSER_VERSION.match[compiled on ][]{}
post/get/query: ^eval($uriParamReal-^queryParam.count[])/^uriParam.count[]/$queryParamCount ^if($cookie:fields){cookie: ^cookie:fields._count[]}
]
###

@compact[hParam][iPrevUsed;result]
^hStatistics.iCalls.inc(1)
^if($hParam.bForce || !$hStatistics.hMemory.iEnd || ($self.iLimit && ($status:memory.used - $hStatistics.hMemory.iEnd) > $self.iLimit)){
	^hStatistics.iCompact.inc(1)
	$iPrevUsed($status:memory.used)
	^memory:compact[]
	^hStatistics.hMemory.iCollected.inc($iPrevUsed - $status:memory.used)
	$hStatistics.hMemory.iEnd($status:memory.used)
}

@showSystemParam[][result]
$self.hStatistics.hMemory.iEnd($status:memory.used)
$self.hStatistics.hUsage.hEnd[$status:rusage]
$usage((^self.hStatistics.hUsage.hEnd.tv_sec.double[] -
				^self.hStatistics.hUsage.hBegin.tv_sec.double[]) +
				(^self.hStatistics.hUsage.hEnd.tv_usec.double[] -
				^self.hStatistics.hUsage.hBegin.tv_usec.double[])/1000000)
$utime($self.hStatistics.hUsage.hEnd.utime - $self.hStatistics.hUsage.hBegin.utime)
$t[^table::create[nameless]{
memory used/collected:	$self.hStatistics.hMemory.iEnd/$self.hStatistics.hMemory.iCollected KB
calls/dcompacts:	$self.hStatistics.iCalls/$self.hStatistics.iCompact
Usage:	^usage.format[%.3f] s
Utime:	^utime.format[%.3f] s
}]
$result[^ConsoleTable:formatTable[$t]]

@show[o][result]
^if(!$self.iCall){^extendPostprocess[]}
$self.iCall(1)
$sConsole[$sConsole
^showSystemParam[]
^if($o is double){^showObject($o)}{^showObject[$o]}
]

@stop[o][result]
^if($o is "double"){ ^self.show($o) }{ ^self.show[$o] }
^sConsole.save[$self.sSavePath]
^throw[debug;$sConsole]

@showObject[o][result;jShow]
^iHashId.inc[]
^if($o is "string" && !def $o){
	$result[^show_void[]]
}{
	$jShow[$[show_$o.CLASS_NAME]]
	^if($jShow is junction){
		$result[${result}^if($o is double){^jShow($o)}{^jShow[$o]}]
	}{
		$result[${result}^show_userclass[$o]]
	}
}

@show_userclass[o][sTabs;i;j;jForeach;hMethods;hFields;sName;h;z;sUID;t]
$sTabs[^for[i](1;$self.iShift){^taint[^#09]}]
$sUID[^reflection:uid[$o]]
$z[^reflection:class[$o]]
$result[^reflection:class_name[$o] (UID: $sUID)^while(def ^reflection:base[$z]){ <= ^reflection:base_name[$z]$z[^reflection:base[$z]]}:]
^if($self.hShowing.$sUID){
	$result[$result -already shown- (recursion?)]
}{
	$hMethods[^reflection:methods[$o.CLASS_NAME]]
	^if($hMethods){
		$jForeach[^reflection:method[$hMethods;foreach]]
		$t[^table::create{name	arguments	file}]
		^jForeach[sName;]{
            $h[^reflection:method_info[$o.CLASS_NAME;$sName]]
		    ^t.append{@$sName	^[^for[j](0;100){^if(def $h.$j){$h.$j}{^break[]}}[^;]^]	^if($h){^file:dirname[^h.file.replace[$self.tReplacePath]]/^file:basename[$h.file]}}
        }
		^t.sort{$t.name}
		$result[${result}^taint[^#0A]$sTabs Methods (^t.count[])^taint[^#0A]]
		$result[${result}^ConsoleTable:formatTable[$t;$sTabs]^taint[^#0A]^taint[^#0A]]
#		^t.menu{$h[^reflection:method_info[$o.CLASS_NAME;$t.name]]^taint[^#0A]^taint[^#09]$sTabs^if($h){^file:dirname[^h.file.replace[$self.tReplacePath]]/^file:basename[$h.file]} ^@$t.name^[^for[j](0;100){^if(def $h.$j){$h.$j}{^break[]}}[^;]^]}^taint[^#0A]
	}
	${self.hShowing.$sUID}(true)
	$hFields[^reflection:fields[$o]]
	^if($hFields){
		$result[$result^show_hash[$hFields]]
	}
	^self.hShowing.delete[$sUID]
}

@show_void[o]
$result[void]

@show_bool[o]
$result[^if($o){true}{false}]

@show_string[o]
$result[^taint[$o]]

@show_int[o]
$result[$o]

@show_double[o]
$result[$o]

@show_date[d]
$result[^^date::create^[^d.sql-string[]^]]

@show_hash[h;b;sort][result;k;v;sTabs;i;j;sUID;s]

$sUID[^reflection:uid[$h]]
^if($self.hShowing.$sUID){
	$result[$result -already shown- (recursion?)]
}{
	$self.hShowing.$sUID(true)
	^self.iShift.inc[]
	$sTabs[^for[i](2;$self.iShift){^taint[^#09]}]
	$j[^reflection:method[$h;foreach]]
	$result[^if($h){
^j[k;v]{$s[^k.match[(.*[^^a-zа-я0-9_\-].*)][i]{^[$match.1^]}]^taint[^#09]$sTabs^switch(true){
^case($v is "double" || $v is "int" || $v is "bool"){^$.$s^(^self.showObject($v)^)}
^case($v is "junction"){^$.$s^{-junction-here-^}}
^case($v is "string" || $v is "date"){^$.$s^[^self.showObject[$v]^]
}
^case[DEFAULT]{^$.$s^[^self.showObject[$v]^]
}}}$sTabs}{^^hash::create^[-empty-hash-here-^]}]
	^self.iShift.dec[]
	^self.hShowing.delete[$sUID]
}

@show_table[t][tCol;tFlipped;bNamless;bF;sTabs;fMarginLeft;i]
	$tCol[^t.columns[]]
	^if(!$tCol){
		$bNamless(true)
		$tFlipped[^t.flip[]]
		$tCol[^table::create{column}]
		^for[i](0;$tFlipped-1){^tCol.append{$i}}
		$t[^tFlipped.flip[]] ^rem{ it helps for named tables without columns }
	}{
		$bNamless(false)
	}
	$sTabs[^for[i](1;$self.iShift+1){^taint[^#09]}]
	$result[^ConsoleTable:formatTable[$t;$sTabs]]

@show_file[f]
$result[FILE (UID: ^reflection:uid[$f]): ^self.show_hash[
	$.name[$f.name]
	$.size[$f.size bytes]
	^if(def $f.mode){
		$.mode[$f.mode]
	}
	^if(def $f.cdate){
		$.cdate[$f.cdate]
	}
	^if(def $f.mdate){
		$.mdate[$f.mdate]
	}
	^if(def $f.adate){
		$.adate[$f.adate]
	}
	^if(def $f.mode && def $f.[content-type]){
		$.content-type[$f.content-type]
	}
	^if(def $f.tables){
		$.tables[$f.tables]
	}
	^if(def $f.cookies){
		$.cookies[$f.cookies]
	}
	^if($f.mode eq "text" || ^f.content-type.left(5) eq "text/"){
		^if(^f.text.length[] <= 100){
			$.text[$f.text]
		}{
			$.[First 100 symbols][^f.text.left(100)]
			$.[Last 100 symbols][^f.text.right(100)]
		}
	}
]]

@show_regex[r]
$result[^^regex::create^[$r.pattern^]^[$r.options^]]

@show_image[i][f]
$result[IMAGE (UID: ^reflection:uid[$i]): ^self.show_hash[
	$.width[$i.width px]
	$.height[$i.height px]
	^if(def $i.src){
		$.html[^i.html[]]]
		^try{
			$f[^file::stat[$i.src]]
			$.size[$f.size bytes]
			$.cdate[$f.cdate]
			$.mdate[$f.mdate]
			$.adate[$f.adate]
		}{
			$exception.handled(true)
		}
	}
	^if(def $i.exif){
		$.exif[$i.exif]
	}
]]

@show_xdoc[x][s;sTabs;fMarginLeft]
	^self.prepareFormat[$x]
	$s[^x.string[ $.omit-xml-declaration[no] $.method[xml] $.indent[yes]]]

	$sTabs[^for[i](1;$self.iShift){^taint[^#09]}]
	$fMarginLeft($self.iShift*5)
	^if($self.iShift > 0){^fMarginLeft.inc(5)}

	$result[^^xdoc::create^{^taint[^s.trim[end]]^}$sTabs]

@show_xnode[x][result]
	$result[^switch($x.nodeType){
		^case($xdoc:ELEMENT_NODE){<span class="node1 value">&lt^;^taint[$x.nodeName]^self.showAttributes[$x]^if(def $x.childNodes){&gt^;^self.showChildren[$x]&lt^;/$x.nodeName&gt^;}{/&gt^;}</span>}
		^case($xdoc:ATTRIBUTE_NODE){<span class="node2 value">^taint[$x.nodeName]="^self.showNodeValue[$x]"</span>}
		^case($xdoc:TEXT_NODE){<span class="node3 value">^self.showNodeValue[$x]</span>}
	}]

@showAttributes[x][result;v]
	$result[^if(def $x.attributes){^x.attributes.foreach[;v]{ ^self.show_xnode[$v]}}]

@showChildren[x][result;v]
	$result[^if(def $x.childNodes){^x.childNodes.foreach[;v]{^self.show_xnode[$v]}}]

@showNodeValue[x]
	$result[$x.nodeValue]

@show_Array[a][result]
	$result[Array(^eval($a)): ^taint[^#10] ^show_hash[^hash::create[$a];;1]]

@showXObject[o]
	$result[<span style="color:red">$o.typeName</span>
		^if($o.getID is junction){<b>^o.getID[]</b>}
		^if($o.getName is junction){<span style="color:blue">(^o.getName[])</span>}
		^if($o.ToString is junction){<span style="color:red">(^o.ToString[])</span>}
		^if($o.current){
			^self.showObject[$o.current]
		}
	]

# clear empty text nodes
@prepareFormat[document][result]
	^self.prepareFormatChild[$document.documentElement;$document.documentElement.childNodes]

@prepareFormatChild[parent;child][i;node;result]
	^for[i](0;$child-1){
		$node[$child.$i]
		^switch($node.nodeType){
			^case($xdoc:TEXT_NODE){
				^if(!def ^node.nodeValue.trim[]){
					$node[^parent.removeChild[$node]]
				}
			}
			^case($xdoc:ELEMENT_NODE){
				^if($node.childNodes){
					^self.prepareFormatChild[$node;$node.childNodes]
				}
			}
		}
	}
