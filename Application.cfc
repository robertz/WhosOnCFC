<cfcomponent output="false">
<cfset this.name = "WhosOnCFCTestApp">
<cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>
<cfset this.clientManagement = true>
<cfset this.loginStorage = "session">
<cfset this.sessionManagement = true>
<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>
<cfset this.setClientCookies = true>
<cfset this.setDomainCookies = false>
<!--- Run when application starts up --->

<cffunction name="onApplicationStart" returnType="boolean" output="false">
	<cfscript>
				// Configure WhosOnCFC settings
				whosonconfig=structNew();
				
				whosonconfig.trackTime=24;													// How many hours do we want WhosOnCFC to track
				whosonconfig.botTrackTime=2;												// How many hours do we want to track bots
				whosonconfig.ignoreIPs='';													// Supply a CSV list of FULL IP addresses to ignore
				
				whosonconfig.ignoreDomains='yahoo.com,search.msn.com';						// CSV list of domains to ignore
				
				whosonconfig.defaultTimeout=30;												// How many minutes to wait before timing out a session
				whosonconfig.botListUrl='http://www.kisdigital.com/botlist.xml';		// URL for botlist.xml, leave blank if you do not wish to use the XML file
				whosonconfig.ipBlockListThreshhold=5;										// How many clientid's allowed from 1 IP address before it assumes its a bot
				whosonconfig.storeHistory=10;												// Minutes to retain history
				whosonconfig.botList='';													// Supply a CSV list of user-agents to ignore
				whosonconfig.ignorePages='';											// Supply a CSV list of files or directories you want ignored. Ex: '/admin/,/test/myfile.cfm'
				whosonconfig.showBots=true;													// Whether or not to keep track of bots {true/FALSE}
				whosonconfig.geoTrack=true;												    // Do we want to track geophysical location (true/FALSE)
				whosonconfig.pageHistory=true;												// Do we want to keep a history of pages the client visited? (true/FALSE)
				whosonconfig.useBlockList=false;											// Whether or not we want to use the internal block list (FALSE)
				
				application.whoson=createObject('component','com.kisdigital.whoson').init(whosonconfig);
				application.lastInit=Now();
				application.whosoninit=1;
				
			</cfscript>
	<cfreturn true>
</cffunction>

<!--- Run before the request is processed --->
<cffunction name="onRequestStart" returnType="boolean" output="no">
	<cfargument name="thePage" type="string" required="true">
	<cfif not isdefined("application.whosoninit") or isdefined("url.reinit")>
		<cfset onApplicationStart() />
		<cfset session.user="Guest" />
	</cfif>
	<cfif not structKeyExists(session,"userinfo") or structKeyExists(url,"logout")>
		<cfset session.userinfo.user="Guest" />
		<cfset session.userinfo.roles="" />
	</cfif>
	<cfscript>
			VARIABLES.thisRequest=structNew();
			VARIABLES.thisRequest.thisClient=session.sessionid;
			VARIABLES.thisRequest.thisUser=session.userinfo.user;
			VARIABLES.thisRequest.Roles=session.userinfo.roles;
			VARIABLES.thisRequest.Referer=CGI.HTTP_REFERER;
			VARIABLES.thisRequest.IP=CGI.REMOTE_ADDR;
			if(CGI.PATH_INFO is CGI.SCRIPT_NAME){
				VARIABLES.thisRequest.CurrentPage=CGI.SCRIPT_NAME;
			}else{
				VARIABLES.thisRequest.CurrentPage=CGI.SCRIPT_NAME & CGI.PATH_INFO;
			}
			VARIABLES.thisRequest.QueryString=CGI.QUERY_STRING;
			VARIABLES.thisRequest.ServerName=CGI.SERVER_NAME;
			VARIABLES.thisRequest.ServerPort=CGI.SERVER_PORT;
			VARIABLES.thisRequest.Prefix="http://";
			if(CGI.HTTPS is "on") VARIABLES.thisRequest.Prefix="https://";
			VARIABLES.thisRequest.UserAgent=CGI.HTTP_USER_AGENT;
			VARIABLES.thisRequest.trackedUser=application.whoson.WhosOnPageTracker(whoson=thisRequest);
			if(session.userinfo.user is not thisRequest.trackedUser){
				session.userinfo.user=thisRequest.trackedUser;
				session.userinfo.roles='';
			} 
		</cfscript>
		
		<cfif lcase(listLast(listLast(cgi.script_name,'/'),'.')) EQ "cfc">
    		<cfset StructDelete(this, "onRequest") />
			<cfset StructDelete(variables,"onRequest")/>
      	</cfif>	
			
	<cfreturn true>
</cffunction>

<cffunction
     name="OnRequest"
     access="public"
     returntype="boolean"
     output="true"
     hint="Executes the requested ColdFusion template.">
	<!--- Define arguments. --->
	<cfargument
    name="TargetPage"
     type="string"
     required="true"
    hint="The requested ColdFusion template."
     />
	<!--- Include the requested ColdFusion template. --->
	<cfinclude template="#ARGUMENTS.TargetPage#" />
	<!--- Return out. --->
	<cfreturn true />
</cffunction>

<!--- Fired when user requests a CFM that doesn't exist. --->
<cffunction name="onMissingTemplate" returnType="boolean" output="false">
	<cfargument name="targetpage" required="true" type="string">
	<cflocation url="/" addtoken="no" />
	<cfreturn true>
</cffunction>
<!--- Runs on error 
	<cffunction name="onError" returnType="void" output="false">
		<cfargument name="exception" required="true">
		<cfargument name="eventname" type="string" required="true">
		
		<cflocation url="/" addtoken="no" />
		<cfreturn true />
	</cffunction>--->
</cfcomponent>