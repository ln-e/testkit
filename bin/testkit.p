#!cgi/parser3.cgi

@auto[][locals]
    ^use[../vault/classpath.p]
###


#------------------------------------------------------------------------------
#Do tests initialization
#------------------------------------------------------------------------------
@main[][result]
    $app[^Testkit/Application::create[]]
    $result[$result^app.run[]]
#--- end of main
