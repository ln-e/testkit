# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 19.04.16
# Time: 9:09
# To change this template use File | Settings | File Templates.

@CLASS
ConsoleTable

@OPTIONS
locals
static

@auto[]
###


@static:formatTable[table;prefix][result;columnLength]

    ^if(!($table is table)){
        ^throw[table;ConsoleTable.p;Table isn't instance of table]
    }

    $columnLength[^hash::create[]]

    ^table.fields.foreach[name;value]{
        $columnLength.$name(^name.length[] + 3)
    }

    ^table.foreach[pos;row]{
        $fields[$table.fields]
        ^fields.foreach[name;value]{
            ^if(!def $columnLength.$name || ^value.length[] + 3 > $columnLength.$name){
                $columnLength.$name(^value.length[] + 3)
            }
        }
    }
    $seperator[^ConsoleTable:drawSeparator[$columnLength]]
    $fields[$table.fields]

    $result[^if(^table.columns[]){${prefix}$seperator
${prefix}^ConsoleTable:drawHeader[$fields;$columnLength]
}${prefix}$seperator
^table.menu{${prefix}^ConsoleTable:drawLine[$table.fields;$columnLength]}[^taint[^#0A]]
${prefix}$seperator]

###

@static:drawHeader[fields;columnLength][result]
    $result[|^fields.foreach[name;value]{^ConsoleTable:padRight[$name; ;$columnLength.$name]}[|]|]
###

@static:drawLine[fields;columnLength][result]
    $result[|^fields.foreach[name;value]{^ConsoleTable:padRight[$value; ;$columnLength.$name]}[|]|]
###

@static:drawSeparator[hash][result]
    $result[+^hash.foreach[name;length]{^for[i](1;$length){-}}[+]+]
###


@static:padRight[string;symbol;length][result]
    $length($length - 1)

    ^if(^string.length[] >= $length){
        $result[ $string]
    }{
        $pad[]
        ^for[i](1;$length-^string.length[]){
            $pad[${pad}$symbol]
        }
        $result[ ${string}$pad]
    }
###
