<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta http-equiv="Pragmas" content="no-cache">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<meta http-equiv="Express" content="-1">
<META HTTP-EQUIV="Expires" CONTENT="Mon, 06 Jan 1990 00:00:01 GMT">
<title>WhosOnCFC Test Application</title>
</head>

<body>

WhosOnCFC <cfoutput>#application.whoson.getCurrentControlSet().version#</cfoutput><br /> 
<a href="/?reinit" style="color: blue;">Reinit WhosOnCFC</a><br />

<br />
<br />

<cfoutput>
 	You are logged in as : #session.userinfo.user#<br />
	UsersOnline() Results: #application.whoson.usersOnline()#<br/>
	getUserList() Results: #application.whoson.getUserList()#<br/>
	<br/>
	
	<cfif application.whoson.userIsInRole(session.userinfo.user,"admin")>
	If you are logged in as an admin, you can read this!<br /><br />
	</cfif>
	
	<cfif application.whoson.userIsInRole(session.userinfo.user,"user")>
	If you are logged in as a user, you can read this!<br /><br />
	</cfif>
		
</cfoutput>

<a href="/whosondump.cfm" style="color: blue;">Dump</a> | 
<a href="/loginscreen.cfm" style="color: blue;">Login Screen (Security Demo)</a> | 
<a href="/whosonstats.cfm" style="color: blue;">WhosOnStats Demo Page</a> |
<a href="/viewer/" style="color: blue;">Enhanced WhosOn Viewer</a> | 
<a href="/timeline/" style="color: blue;">cfTimeline View</a> | 
<a href="/jView/" style="color: blue;">jQuery Viewer</a> | 
<a href="/botlist.xml" style="color: blue;">View Current Bot List</a> 

<br /><br />
<cfdump var="#variables#" label="Variables scope" />

<br />
<cfdump var="#application.whoson.getMaxCounts()#" label="WhosOnCFC MaxCounts() Struct" />

<br />
<cfdump var="#application.whoson.getCurrentControlSet()#" label="getCurrentControlSet()">
</body>
</html>