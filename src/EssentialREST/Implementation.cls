Include %occErrors

Class EssentialREST.Implementation Extends %RegisteredObject
{

ClassMethod GetNameSpaces(GetAllInfo As %Boolean = 1) As %DynamicArray
{
	#dim znsArray As %DynamicArray = ##class(%DynamicArray).%New()
	do ##Class(%SYS.Namespace).ListAll(.namespaces)
	set namespace=""
	for {
		set namespace = $order(namespaces(namespace)) quit:namespace=""
		do ##Class(%SYS.Namespace).GetAllNSInfo(namespace,.property)
		set json = {"namespace":(namespace)}
		set:GetAllInfo json.information= {
					"globalDBDirectory" : ( property("GlobalDB","Directory")),
					"globalDBMounted"   : ( property("GlobalDB","Mounted") ),
					"routineDBDirectory" : ( property("RoutineDB","Directory")),
					"routineDBMounted"   : ( property("RoutineDB","Mounted") )
				}	
	
		do znsArray.%Push(json)
	}
	return znsArray
}

ClassMethod GetDetails(TaskType As %String = "") As %DynamicArray
{
	try {
		new $namespace
		set $namespace="%SYS"
		set clsList = ..ClassList(TaskType)
		if clsList = "" throw ##class(%Exception.General).%New("something went worng. No such endpoints available")
		set cls = $listget(clsList)
		set method = $listget(clsList,2)
		if '$system.CLS.IsMthd(cls,method_"Func") {
			throw ##class(%Exception.General).%New("No such class or method available",$$$GeneralError)
		}
		if $listlength(clsList) = 2 {
			set result = $classmethod(cls,method_"Func")
		}
		else {
			set param = $listget(clsList,3)
			set result = $classmethod(cls,method_"Func",,,param)
		}
		do ..ProcessSQLResultToJSON(result,.response)
		}
	catch ex {
		set response={"status":"error","message":(ex.BinDisplayString())}
	}
	return response
}

ClassMethod ClassList(TaskType As %String = "") As %List [ CodeMode = expression ]
{
$Case($$$LOWER(TaskType),
		"database"	 			:	$listbuild("Config.Databases","List"),
		"x509"	 	 			:	$listbuild("%SYS.X509Credentials","ListDetails"),
		"licenseservers"	 	:	$listbuild("Config.LicenseServers","List"),
		"ldap"	 				:	$listbuild("Security.LDAPConfigs","List"),
		"ssltls"	 			:	$listbuild("Security.SSLConfigs","List"),
		"docdb"	 				:	$listbuild("Security.DocDBs","List"),
		"webapp"	 			:	$listbuild("Security.Applications","List"),
		"clientapp"	 			:	$listbuild("Security.Applications","List",2),
		"privilegedroutine"	 	:	$listbuild("Security.Applications","List",3),
		"users"					:	$listbuild("Security.Users","Detail"),
		"roles"					:	$listbuild("%SQL.Manager.CatalogPriv","RolesFilter"),
		"resources"				:	$listbuild("Security.Resources","List"),
		"wqm"					:	$listbuild("Config.WorkQueues","ListFilter"),
					 			:	""
	
	)
}

ClassMethod AvailableEndPoints()
{
}

ClassMethod ProcessSQLResultToJSON(result, Output response) As %Status
{
	set response = []
	#dim meta As %SQL.StatementMetadata = result.%GetMetadata()
	while result.%Next() {
		set task = ##class(%DynamicObject).%New()
		for col = 1: 1: meta.columnCount {
			set column = meta.columns.GetAt(col).colName
			do task.%Set(column, $Property(result, column))
		}
		do response.%Push(task)
	}
	return $$$OK
}

}
