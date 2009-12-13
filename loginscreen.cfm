<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Login</title>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
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
	WHERE username=<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.uname#"> and password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.pass#">
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
<form id="loginForm" action="#CGI.SCRIPT_NAME#" method="post">
User	<input type="text" name="uname" id="uname" /><br />
Pass	<input type="text" name="pass" id="pass" /><br />
<br />
<br />
<input type="submit" value="Login Now!">
</form>

<cfelse>
<a href="/?logout">LOGOUT</a>
</cfif>

</cfoutput>

<script type="text/javascript">
	$(document).ready(function(){
		$('#loginForm').submit(function(){
			if( $('#uname').val().length & $('#pass').val().length ){
				return true;
			} else {
				alert('Doh! You must enter a username and password!');
				return false;
			}
		});
	});
</script>

<br /><br />
Admin: admin/admin<br />
User: user/user<br />
<br />

</body>
</html>