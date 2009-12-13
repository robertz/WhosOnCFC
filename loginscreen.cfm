<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Login</title>
</head>

<body>

<cfdump var="#session.userinfo#" />
<br />


<cfif isDefined("form.uname")>

<!--- Build our query --->
<cfscript>
	myQuery=queryNew("username,password,roles");
	queryAddrow(myQuery);
	querySetCell(myQuery,"username","admin");
	querySetCell(myQuery,"password","admin");
	querySetCell(myQuery,"roles","user,admin");

	queryAddrow(myQuery);
	querySetCell(myQuery,"username","user");
	querySetCell(myQuery,"password","user");
	querySetCell(myQuery,"roles","user");	
</cfscript>

<cfquery name="validateUser" dbtype="query">
	SELECT username, password, roles
	FROM myQuery
	WHERE username='#form.uname#' and password='#form.pass#'
</cfquery>

<cfoutput>
Count: #validateUser.RecordCount#<br />
</cfoutput>

<cfdump var="#validateUser#" />

<cfif validateUser.RecordCount>
	<cfscript>
		session.userinfo.user=validateUser.username;
		session.userinfo.roles=validateUser.roles;
	</cfscript>
	<cflocation url="/" addToken="false" />
</cfif>


</cfif>

<cfoutput>

<a href="/">HOME</a><br /><br />

<cfif session.userinfo.user is "Guest">
<cfform name="loginForm" action="#CGI.SCRIPT_NAME#" method="post">
User	<cfinput type="text" name="uname"  required="true" message="Username is required" validateat="onSubmit" /><br />
Pass	<cfinput type="text" name="pass" required="true" message="Password is required" validateat="onSubmit"  /><br />
<br />
<br />
<input type="submit" value="Login Now!">
</cfform>

<cfelse>
<a href="/?logout">LOGOUT</a>
</cfif>

</cfoutput>

<br /><br />
Admin: admin/admin<br />
User: user/user<br />
<br />

</body>
</html>