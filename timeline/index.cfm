<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>kisdigital.com user timeline</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta http-equiv="Pragmas" content="no-cache" />
	<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE" />
	<meta http-equiv="Express" content="-1" />
	<META HTTP-EQUIV="Expires" CONTENT="Mon, 06 Jan 1990 00:00:01 GMT" />	
	<style>
		P, TD{
			font-size: .7em; font-family: Trebuchet MS, Helvetica, Arial, sans serif;
		}
	</style>	
</head>

<body>

WhosOnCFC <cfoutput>#application.whoson.getCurrentControlSet().version#</cfoutput><br >
<br />
<a href="../?reinit" style="color: blue;">Reinit WhosOnCFC</a><br />
<a href="../" style="color: blue;">Home Page</a><br />
<br />
<cfoutput>

<cfif not structKeyExists(session,"sessionFilter")>
	<cfset session.sessionFilter = "" />
</cfif>

<cfif structKeyExists(form,"sessFilter")>
	<cfset session.sessionFilter=PreserveSingleQuotes(form.sessFilter) />
</cfif>

	<cfset datafile="data.cfm">


<!--- <cfoutput>
<cfset postUrl=CGI.SCRIPT_NAME />
<cfif structKeyExists(url,"stats")><cfset postUrl=postUrl & "?stats" /></cfif>
<form action="#postUrl#" method="post">
	<input type="text" name="sessFilter" value="#session.SessionFilter#" />
	<input type="submit" value="Set Filter">
</form>
</cfoutput> --->

<cfsavecontent variable="center">
<script type="text/javascript">
center = function(){
	var dt = cfTimeline.getLatestDate(whosonTimeline,0);
	cfTimeline.scrollToCenter(whosonTimeline, 0, dt)
}
</script>
</cfsavecontent>
<cfhtmlhead text="#center#">

<input type="button" name="test" value="Load XML Feed And Re-center" onclick="refreshGrid();">
</cfoutput>

<cfoutput>
<script language="javascript">
	var interval=0;
	
	refreshGrid=function(){
		cfTimeline.loadXML('whosonTimeline','#datafile#', center);
	}
	
	setInt=function(func){
		interval=window.setInterval(func,1000*60*2);
	}
	
	setInt(refreshGrid);	
</script>
</cfoutput>

<cf_timeline 
		id="whosonTimeline" 
		timelineHeight="475"
		start="#Now()#"
		XmlEvents="#datafile#"
		creationComplete="center" 
		bubblewidth="600" 
		bubbleheight="375" 
		labelwidth="400" 
		style="font-size: .7em; font-family: Trebuchet MS, Helvetica, Arial, sans serif; border: 1px solid ##aaa;" 
	>
	
	<cf_timelineband 
				showEventText="true"
				dateUnit="hour" 
				intervalWidth="400" 
				bandheight="90" 
			/>
			
	<cf_timelineband 
				dateUnit="day" 
				intervalWidth="150" 
				bandheight="10" 
				showEventText="false" 
				trackHeight="0.2" 
				trackGap="0.5" 
			/>
				
</cf_timeline>

</body>
</html>