<html>
<head>
	<title>WhosOnStats Test Page</title>
	<meta http-equiv="refresh" content="60" />
	<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</head>

<body>

<style>
body,td,#myDiv {
	font-family: "Trebuchet MS", verdana, arial, sans-serif; 
	font-size: .7em; 
	color: #000000; 
	margin-left: 25px;
}
</style>

<a href="/" style="color: blue;">Back to Main</a> <br/>

<div id="myDiv" style="border: 1px dotted black; width: 630px; margin: 25px 0 25px 0; font-size: .9em; background-color: ffff80; padding: 4px;">
These are the stats for the last 24 hours.  WhosOnStats will show you the total hits from the highest number of hits to the lowest
for each category it is currently tracking.  Some features have been disabled for security purposes.  The page will automatically
refresh every 60 seconds.
</div>

<cfset catList="city,country,currentpage,entrypage,pagecount,referer,useragent">
Quick Links:
<cfloop list="#catList#" index="ndx">
<cfoutput><a href="###ndx#" style="color: blue;">#ndx#</a> <cfif ndx neq listLast(catList)>| </cfif></cfoutput>
</cfloop>

<cfloop list="#catList#" index="ndx">

<cfset myQuery=application.whoson.getQuery(sortOn=ndx)>

<br /><br />

<div id="<cfoutput>#ndx#</cfoutput>">
Top stats by <cfoutput><font style="color: blue;">#ndx#</font></cfoutput>:<br /><br />
<table cellpadding="2" cellspacing="2" border="1" style="border: 1px solid gray; width: 630px;">
	<tr>
		<td style="background-color: silver;">Data</td>
		<td style="background-color: silver;">Total</td>
	</tr>
	<cfoutput query="myQuery">
	<tr>
		<td>
			<cfif findNoCase("http:",data,1) eq 1>
			<a href="#data#" target="_blank" style="color: blue;">#data#</a>
			<cfelse>
				<cfif len(data)>
					#data#
				<cfelse>
					<cfif ndx is "referer">Direct Traffic<cfelse>No data</cfif>
				</cfif>
			</cfif>
			&nbsp;
		</td>
		<td style="width: 50px;">#total#</td>
	</tr>	
	</cfoutput>
	
</table>
</div>
</cfloop>

</body>
</html>
