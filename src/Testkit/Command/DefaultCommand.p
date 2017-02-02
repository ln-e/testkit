# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 31.01.17
# Time: 20:32
# To change this template use File | Settings | File Templates.

@CLASS
Testkit/Command/DefaultCommand

@OPTIONS
locals

@BASE
Ln-e/Console/CommandInterface

@auto[]
###

#-----------------------------------------------------------------------------
#:result string
#-----------------------------------------------------------------------------
@configure[]
    $self.name[default]
    $self.description[execute all test command]
    ^self.addOption[debug;d;;Enabling debug output]
###


#-----------------------------------------------------------------------------
#Abstract method for command execution
#
#:param input type Ln-e/Console/Input/InputInterface
#:param output type Ln-e/Console/Output/OutputInterface
#-----------------------------------------------------------------------------
@execute[input;output]


#    $testkit[^file::load[text;/testkit.json]]
    ^self.runTests[$testkit]
###


@runTests[config]
    ^use[/vault/classpath.p]
    ^dstop[$MAIN:_autouseOrigin]
    $self.testClasses[^self.findTests[/tests]]
    ^dstop[$self.testClasses]
###

@executeTests[][result]
    ^self.testClasses.foreach[className;object]{
        $methods[^reflection:methods[$className]]
        ^methods.foreach[methodName;value]{
            ^if(^methodName.left(4) eq test){
                ^object.$methodName[]
            }
        }
    }
###

@findTests[dir][result;locals]
    $result[^hash::create[]]
    $list[^file:list[$dir]]
    ^list.menu{
        ^if($list.dir){
            ^result.add[^self.findTests[$dir/$list.name]]
        }(^list.name.match[Test.p^$][in]>0){
            $className[^list.name.mid(0;^list.name.length[] - 2)]
#            ^dstop[^dir.replace[tests;src]/^list.name.replace[Test.p;.p]]
#            ^use[^dir.replace[tests;src]/^list.name.replace[Test.p;.p]]
            ^use[$dir/$list.name]
            $result.$className[^reflection:create[$className;create]]
        }
    }
###
