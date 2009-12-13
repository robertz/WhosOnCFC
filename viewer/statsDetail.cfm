<html>
	<head>
		<title>Stats Detail</title>
	</head>

<body>


<style>
body,td,#main{
	font-family: "Trebuchet MS", verdana, arial, sans-serif; 
	font-size: .8em; 
	color: #000000; 
}
</style>

<div id="main" style="margin-left: 25px; margin-top: 25px;">
	<script>
		ColdFusion.navigate('blank.cfm','mainDiv');
		ColdFusion.Layout.collapseArea('myLayout','left');
	</script>
	
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
<table cellpadding="2" cellspacing="2" border="1" style="border: 1px solid gray; width: 97%;">
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
	
</div>

</body>
</html>