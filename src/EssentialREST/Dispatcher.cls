Class EssentialREST.Dispatcher Extends EssentialREST.Base
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/" Method="GET" Call="GetAllAvailableUrls" Cors="true"/>
<Route Url="/:taskname" Method="GET" Call="GetTaskDetails" Cors="true"/>
</Routes>
}

ClassMethod GetAllAvailableUrls()
{
	do ..Write(##class(Implementation).AvailableEndPoints())
	return $$$OK
}

ClassMethod GetTaskDetails(TaskName As %String = "")
{
	if $$$LOWER(TaskName)="namespaces" {
		do ..Write(##class(Implementation).GetNameSpaces())
	}
	else {
		do ..Write(##class(Implementation).GetDetails(TaskName))
	}
	return $$$OK
}
}
