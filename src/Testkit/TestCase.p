# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 02.02.17
# Time: 16:27
# To change this template use File | Settings | File Templates.

@CLASS
Testkit/TestCase

@OPTIONS
locals

@auto[]
###

#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
    $self.successAsserts(0)
    $self.failedAsserts[^hash::create[]]
###


#------------------------------------------------------------------------------
# Throw an exception if value is not true
#
#:param value type string
#:param expected type string
#:param message type string
#------------------------------------------------------------------------------
@_assert[value;message]
    ^if(!$value){
        ^throw[AssertFailedException;;$message]
    }{
        ^self.successAsserts.inc[]
    }
###


#------------------------------------------------------------------------------
# $value should be equal to $expected
#
#:param value type string
#:param expected type string
#:param message type string
#------------------------------------------------------------------------------
@assertString[value;expected;message]
    ^self._assert($value ne $expected)[$message]
###


#------------------------------------------------------------------------------
# $value should be true boolean
#
#:param value type boolean
#:param message type string
#------------------------------------------------------------------------------
@assertTrue[value;message]
    ^self._assert($value)[$message]
###


#------------------------------------------------------------------------------
# $value should be false boolean
#
#:param value type boolean
#:param message type string
#------------------------------------------------------------------------------
@assertFalse[value;message]
    ^self._assert(!$value)[$message]
###
