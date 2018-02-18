ToPoint(var, returnZero := false)
{
	if(var == "" && returnZero)
	{
		Return 0
	}
    StringReplace, outputVar, var, `,, ., All
    Return outputVar
}

ToComma(var)
{
	global

    var := Round(insulinUnitStep * var) / insulinUnitStep ; Set precision step - 1/2 or 1/4 etc
    var := RemoveZero(var) ; Remove trailing zeros
    
    StringReplace, outputVar, var, ., `,, All
    Return outputVar
}


RemoveZero(var)
{
    IfNotInString var, .
        Return var
    
    Loop
    {
        StringRight, zeroTest, var, 1
        
        if (zeroTest == "0" || zeroTest == ".")
        {
            StringTrimRight, var, var, 1
        }
        else
        {
            Return var
        }
    }
}