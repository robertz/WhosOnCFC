<cfsetting enablecfoutputonly="true">

<cfscript>
/**
 * Converts text string of ISO Date to datetime object; useful for parsing RSS and RDF.
 * 
 * @param str 	 ISO datetime string to parse. (Required)
 * @return Returns a date. 
 * @author James Edmunds (jamesedmunds@jamesedmunds.com) 
 * @version 1, September 21, 2004 
 */
function ISODateToTS(str) {
	return ParseDateTime(ReplaceNoCase(left(str,16),"T"," ","ALL"));
}
</cfscript>


	<cfset baseSource=application.whoson.WhosOnline(showAll=true,showHidden=true)>


<cfquery name="users" dbtype="query">
	SELECT *
	FROM baseSource
	WHERE (0=0)
</cfquery>


<cffunction name="getDescription" returntype="string" hint="I write the description text" >
	<cfargument name="clientID" required="true" type="string">
	<cfargument name="dataset" type="query">
	
	<cfset var ret ="" />
	<cfset var hist = "" />
	<cfset var histArray = "" />
	<cfset var rs = "" />
	<cfset var n="" />
	
	<cfquery name="rs" dbtype="query">
		SELECT *
		FROM arguments.dataset
		WHERE ClientID='#arguments.clientid#'
	</cfquery>
	
	<cfoutput>
		<cfsavecontent variable="ret">
		<table style="width:100%" cellpadding="0" cellpadding="0" border="0">
			<tr>
				<td width="90">ClientID</td>
				<td>#rs.clientid#</td>
			</tr>
			<tr>
				<td width="90">User</td>
				<td>#rs.userid#</td>
			</tr>
			<tr>
				<td width="90">Roles</td>
				<td>#rs.roles#</td>
			</tr>			
			<tr>
				<td width="90">Hidden</td>
				<td>#YesNoFormat(rs.hideClient)#</td>
			</tr>					
			<tr>
				<td width="90">Created</td>
				<td>#DateFormat(rs.Created,"mm/dd/yyyy")# #TimeFormat(rs.Created,"h:mm:ss tt")#</td>
			</tr>	
			<tr>
				<td width="90">Updated</td>
				<td>#DateFormat(rs.LastUpdated,"mm/dd/yyyy")# #TimeFormat(rs.LastUpdated,"h:mm:ss tt")#</td>
			</tr>								
			<tr>
				<td>Country</td>
				<td>#rs.country#</td>
			</tr>
			<tr>
				<td>City</td>
				<td>#rs.City#</td>
			</tr>
			<tr>
				<td valign="top">Entry Page</td>
				<td><a href="#rs.EntryPage#" style="color: blue;" target="_blank">#rs.EntryPage#</a></td>
			</tr>
			<tr>
				<td valign="top">Current Page</td>
				<td><a href="#rs.CurrentPage#" style="color: blue;" target="_blank">#rs.CurrentPage#</a></td>
			</tr>
			<tr>
				<td>Page Count</td>
				<td>#rs.PageCount#</td>
			</tr>				
			<tr>
				<td valign="top">Referer</td>
				<td><a href="#rs.Referer#" style="color: blue;" target="_blank">#rs.Referer#</a></td>
			</tr>
			<tr>
				<td>IP Address</td>
				<td><a href="http://www.who.is/whois-ip/ip-address/#rs.ip#" style="color: blue;" target="_blank">#rs.IP#</a></td>
			</tr>	
			<tr>
				<td>Hostname</td>
				<td>#rs.HostName#</td>
			</tr>
			<tr>
				<td valign="top">User-Agent</td>
				<td>#rs.UserAgent#</td>
			</tr>										
		</table>
		</cfsavecontent>
	</cfoutput>	
	
    <cftry>
	<cfset histArray=application.whoson.getRawData(arguments.clientid).PageHistory />
	
	<cfif arrayLen(histArray)>
	<cfoutput>
		<cfsavecontent variable="hist">
		<p>PageHistory available: #arrayLen(rs.PageHistory)# page(s).</p>
		<table style="width:100%" cellpadding="0" cellpadding="0" border="0">
			<tr>
				<td style="border-bottom: 1px solid black;">Page</td>
				<td style="border-bottom: 1px solid black;">Time</td>
			</tr>
			<cfloop from="1" to ="#arrayLen(histArray)#" index="n">
			<tr>
				<td>#histArray[n].page#</td>
				<td>#histArray[n].pagetime#</td>
			</tr>				
			</cfloop>						
		</table>
		<br />
		</cfsavecontent>
	</cfoutput>
	</cfif>
    
    <cfcatch></cfcatch>
    </cftry>
	<cfreturn ret & hist />
</cffunction>

<cffunction name="getXML" returntype="string" hint="I handle writing the XML data">
	<cfset var outXML="" />
    
<cfsavecontent variable="outXML">
<cfoutput><?xml version="1.0" encoding="UTF-8"?><data><cfloop query="users"><cfset started="#DateFormat(users.created,"mm/dd/yyyy")# #TimeFormat(users.created,"HH:mm:ss")#" /><cfset updated="#DateFormat(users.LastUpdated,"mm/dd/yyyy")# #TimeFormat(users.LastUpdated,"HH:mm:ss")#" /><event start="#XmlFormat(started)#" end="#XmlFormat(Updated)#" title="<cfif users.userid is "Guest">#XMLFormat(users.hostname)#<cfelse>#XMLFormat(users.userid)#</cfif>" <cfif len(users.referer) and not(users.hideClient)>icon="#XmlFormat("ref.jpg")#"<cfelseif not len(users.referer) and not(users.hideClient)>icon="#XmlFormat("noref.jpg")#"<cfelseif users.hideClient>icon="#XmlFormat("hidden.jpg")#"</cfif>>#XmlFormat(getDescription(clientid=users.clientid,dataset=users))#</event></cfloop></data></cfoutput>
</cfsavecontent>
    
    <cfreturn outXML />
</cffunction>

<cfset done=0>

<!--- 
	Do a little error checking.  Occasionally it generates an error because the data file is not returning valid XML.
	
	This should hopefully fix it's little red wagon, so to speak.
 --->
 
<cfloop condition="done equal 0">
	<cfset outXML=getXML() />
    <cfif isXML(outXML)><cfset done=1 /></cfif>
</cfloop>

<cfcontent type="text/xml">
<cfoutput>#outXML#</cfoutput>


<cfsetting enablecfoutputonly="false" />