<html>
	<head>
		<title>Default Detail</title>
	</head>

<body>
<cfparam name="clientid" type="string" default="" />

<style>
body,td,#main{
	font-family: "Trebuchet MS", verdana, arial, sans-serif; 
	font-size: .8em; 
	color: #000000; 
}
</style>

<cfset thisClient=application.whoson.getRawData(clientid=clientid)>

<div id="main" style="margin-left: 25px; margin-top: 25px;">
	
Live View &raquo; <a href="/" style="color: blue;">Default Page</a> 

<cfform>
	<cfinput type="button" name="btnRefresh" value="Refresh Data" onclick="javascript:ColdFusion.navigate('defaultDetail.cfm?clientid=#url.clientid#','mydiv');">
</cfform>

<p style="font-size: .9em;">
Client overview:
</p>

<cfoutput>
<table cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="150">Time active:</td>
		<td>#DateDiff("n",thisClient.Created,Now())# minutes</td>
	</tr>
	<tr>
		<td width="150">Time To Live:</td>
		<td>
			<cfset InactiveTime=DateDiff("n",thisClient.LastUpdated,Now())>
			#application.whoson.getCurrentControlSet().defaultTimeout - InactiveTime# minutes
		</td>
	</tr>	
</table>
</cfoutput>

<br /><br />
<table cellspacing="0" cellpadding="2" border="0" style="width: 98%; border-left: 1px solid black;border-right: 1px solid black;border-top: 1px solid black;">
	
<cfloop collection="#thisClient#" item="i">
	<cfoutput>
		<cfif i neq "PageHistory">
			<tr>
				<td style="border-right: 1px solid black; border-bottom: 1px solid black; background-color: d0cbfe; color: black;">#i#</td>
				<td style="border-bottom: 1px solid black;">
					<cfif isDate(thisClient[i])>
						#DateFormat(thisClient[i],"m/d/yy")# #TimeFormat(thisClient[i],"h:mm tt")#
					<cfelse> 
						#thisClient[i]#
					</cfif>
					&nbsp;
				</td>
			</tr>
		</cfif>
	</cfoutput>
</cfloop>

</table>

<cfif structKeyExists(thisClient,"PageHistory") and isArray(thisClient.PageHistory)>
	
	<p>
	Page history for this client:
	</p>
	
	<table cellspacing="0" cellpadding="2" border="0" style="width:98%; border-left: 1px solid black;border-right: 1px solid black;border-top: 1px solid black;">
		<tr>
			<td style="border-bottom: 1px solid black; border-right: 1px solid black; background-color: d0cbfe;">Page</td>
			<td style="border-bottom: 1px solid black; background-color: d0cbfe;">Secs</td>
		</tr>	
		<cfloop from="1" to="#ArrayLen(thisClient.PageHistory)#" index="i">
		<cfoutput> 
		<tr>
			<td style="border-bottom: 1px solid black; border-right: 1px solid black;">#thisClient.PageHistory[i].page#</td>
			<td style="border-bottom: 1px solid black;">#thisClient.PageHistory[i].pagetime#</td>
		</tr>		
		</cfoutput>
		</cfloop>
	</table>
</cfif>
</div>

</body>
</html>