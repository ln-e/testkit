# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 31.01.17
# Time: 20:16
# To change this template use File | Settings | File Templates.

@CLASS
Testkit/Application

@OPTIONS
locals

@BASE
Ln-e/Console/Application

@auto[]
###

@create[]
  ^BASE:create[]
#  $a[^Testkit/TestCase::create[]]
###


#------------------------------------------------------------------------------
#:param input type Ln-e/Console/Input/InputInterface
#:param output type Ln-e/Console/Output/OutputInterface
#------------------------------------------------------------------------------
@preExecute[input;output][result]
    ^output.writeln[^self.info[]]
###


#------------------------------------------------------------------------------
#Prints information for each call
#------------------------------------------------------------------------------
@info[][result]
    $result[Testkit 0.0.1 by Igor Bodnar. Tool for test parser3 projects.]
###


#------------------------------------------------------------------------------
#Configures list of available commands
#------------------------------------------------------------------------------
@configureCommands[][result]
    $files[^file:list[../src/Testkit/Command/;\s*Command.p]]
    ^files.menu{
        ^self.registerCommand[^reflection:create[Testkit/Command/^files.name.replace[.p;];create]]
    }
###
