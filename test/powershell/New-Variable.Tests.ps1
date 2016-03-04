Describe "New-Variable" {
    $nl = [Environment]::NewLine

    It "Should create a new variable with no parameters" {
	{ New-Variable var1 } | Should Not Throw
    }

    It "Should be able to set variable name using the Name parameter" {
	{ New-Variable -Name var1 } | Should Not Throw
    }

    It "Should be able to assign a value to a variable using the value switch" {
	New-Variable var1 -Value 4

	$var1 | Should Be 4
    }

    It "Should be able to assign a value to a new variable without using the value switch" {
	New-Variable var1 "test"

	$var1 | Should Be "test"
    }

    It "Should assign a description to a new variable using the description switch" {
	New-Variable var1 100 -Description "Test Description"

	(Get-Variable var1).Description | Should Be "Test Description"
    }


    It "Should be able to be called with the nv alias" {
	{ nv var1 }   | Should Not Throw
	{ nv var1 2 } | Should Not Throw
    }

    It "Should not be able to set the name of a new variable to that of an old variable within same scope when the Force switch is missing" {
	New-Variable var1
	(New-Variable var1 -ErrorAction SilentlyContinue) | Should Throw
    }

    It "Should change the value of an already existing variable using the Force switch" {
	New-Variable var1 -Value 1

	$var1 | Should Be 1

	New-Variable var1 -Value 2 -Force

	$var1 | Should Be 2
	$var1 | Should Not Be 1

    }

    It "Should be able to set the value of a variable by piped input" {
	$in = "value"

	$in | New-Variable -Name var1

	$var1 | Should Be $in

    }

    It "Should be able to pipe object properties to output using the PassThru switch" {
	$in = Set-Variable -Name testVar -Value "test" -Description "test description" -PassThru

	$output = $in | Format-List -Property Description | Out-String

	$output | Should Be "${nl}${nl}Description : test description${nl}${nl}${nl}${nl}"
    }

    It "Should be able to set the value using the value switch" {
	New-Variable -Name var1 -Value 2

	$var1 | Should Be 2
    }

    Context "Option tests" {
	BeforeEach {
	    # verify that the test variable doesn't exist
!!$var1 | Should Be $false
}
It "Should be able to use the options switch without error" {
    { New-Variable -Name var1 -Value 2 -Option Unspecified } | Should Not Throw
}

It "Should default to none as the value for options" {
    New-Variable -Name var2 -Value 4 -PassThru| Format-List | Out-String | Should Match "Options     : None"
}

It "Should be able to set ReadOnly option" {
    { New-Variable -Name var1 -Value 2 -Option ReadOnly } | Should Not Throw
}

It "Should not be able to change variable created using the ReadOnly option when the Force switch is not used" {
    New-Variable -Name var1 -Value 1 -Option ReadOnly

    Set-Variable -Name var1 -Value 2 -ErrorAction SilentlyContinue

    $var1 | Should Not Be 2
}

It "Should be able to set a new variable to constant" {
    { New-Variable -Name var1 -Option Constant } | Should Not Throw
}

It "Should not be able to change an existing variable to constant" {
    New-Variable -Name var1 -Value 1 -PassThru

    Set-Variable -Name var1 -Option Constant  -ErrorAction SilentlyContinue

    $var1 | Format-List | Out-String | Should Not Match "Options     : None"

}

It "Should not be able to delete a constant variable" {
    New-Variable -Name var1 -Value 2 -Option Constant

    Remove-Variable -Name var1 -ErrorAction SilentlyContinue

    !!$var1 | Should Be $true

    $var1 | Should Be 2
}

It "Should not be able to change a constant variable" {
    New-Variable -Name var1 -Value 1 -Option Constant

    Set-Variable -Name var1 -Value 2  -ErrorAction SilentlyContinue

    $var1 | Should Not Be 2
}

It "Should be able to create a variable as private without error" {
    { New-Variable -Name var1 -Option Private } | Should Not Throw
}

It "Should be able to see the value of a private variable when within scope" {

    New-Variable -Name var1 -Value 100 -Option Private

    $var1 | Should Be 100

}

It "Should not be able to see the value of a private variable when out of scope" {
    {
	New-Variable -Name var1 -Value 1 -Option Private
    }

    $var1 | Should Be # Nothing, since it's not defined in scope

	}

	It "Should be able to use the AllScope switch without error" {
	    { New-Variable -Name var1 -Option AllScope } | Should Not Throw
	}

	It "Should be able to see variable created using the AllScope switch in a child scope" {
	    New-Variable -Name var1 -Value 1 -Option AllScope
	    function myFunction {
		if ( $var1 -eq 1 ) {
		    $var1 = 2
		}
	    }
	    myFunction

	    $var1 | Should Be 2

	}

    }

    Context "Scope Tests" {
	It "Should be able to create a global scope variable using the global switch" {
	    { New-Variable globalVar -Value 1 -Scope global -Force } | Should Not Throw
	}

	It "Should be able to create a local scope variable using the local switch" {
	    { New-Variable localVar -Value 1 -Scope local -Force } | Should Not Throw
	}

	It "Should be able to create a script scope variable using the script switch" {
	    { New-Variable scriptVar -Value 1 -Scope script -Force } | Should Not Throw
	}
    }
}
