Class ZPMModules.EssentialREST.Base Extends %CSP.REST
{
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
	do ##class(%REST.Impl).%SetContentType(..#CONTENTTYPEJSON)
    return $$$OK
}

ClassMethod Write(response) As %Status
{
	do ##Class(%REST.Impl).%WriteResponse(response)
	return $$$OK
}

}
