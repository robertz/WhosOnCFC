<!---
	Name         : whoson.cfc
	Author       : Robert Shane Zehnder
	Created      : November 13, 2007
	Last Updated : December 12, 2009
	History      :
				 : Minor cosmetic changes, switched to Application.cfc (rsz 12.12.09)
				 : Added support for non-standard ports (rsz 9.19.08)
				 : Added abilility to ingore specified domains (rsz 9.19.08)
				 : Now stores 24 hours of history.
				 : Now passes config as an argument collection (rsz 7.12.08)
				 : Now reads botlist.xml to set botlist (rsz 6.30.08)
	 			 : Stats data is now purged when ipBlockListThreshhold is met (rsz 4.25.08)
				 : Max user count is now adjusted when ipBlockListThreshhold is met (rsz 4.25.08)
				 : Added in IP block list to set an option for blocking bots (rsz 4.17.08)
				 : Will no longer track more than 10 sessions from 1 IP address (rsz 4.16.08)
				 : Modified code to work with Rob Gonda's ObjectFactory code (rsz 1.14.08)
				 : Setup for WhosOnCFCStats package (rsz 1.14.08)
				 : Moved botList back into WhosOnCFC (rsz 1.14.08)
				 : Added EntryPage and PageCount variables per Joe Danziger's request (rsz 12.14.07)
				 : botList is now an argument passed when the init method is called (rsz 12.13.07)
				 : Added getUserList() function to return a CSV list of users online (rsz 11.27.07)
				 : Modified WhosOnPageTracker() to update userid on update (rsz 11.26.07)
				 : Modified WhosOnPageTracker() to return a boolean value (rsz 11.26.07)
				 : Modified to ignore pre-defined user agents (rsz 11.16.07)
				 : Updated to use Joshua Cyr's botList (rsz 11.20.07)
	             : Added getGeoInfo from Joshua Cyr's code (rsz 11.20.07)
				 : Added getHostName from Joshua Cyr's code (rsz 11.20.07)
				 : Added PageHistory from Joshua Cyr's code (rsz 11.20.07)
	Purpose		 : User tracking component
--->

<cfcomponent output="false" hint="WhosOn User Tracking component">

	<cffunction name="init" access="public" returnType="WhosOn" output="false" hint="Returns an instance of the CFC.">
		<cfargument name="args" type="struct" required="false" hint="User defined configuration" />
		
		<!--- Currently running version --->
		<cfset variables.version="2.2.5" />
        
        <!--- Configuring tracking times.  Added in 2.2.1 --->
        <cfset variables.trackTime=24 />
		<cfset variables.botTrackTime=3 />
        <cfset variables.ignoreIPs="" />
		
		<!--- Add ingored domains 2.2.3 --->
		<cfset variables.ignoreDomains = "" />
		
		<!--- Configure internal variables --->
		<cfset variables.activeusers=arrayNew(1) />
		<cfset variables.ipBlockList=arrayNew(1) />
		<cfset variables.structKeys="" />
		<cfset variables.ignorePages="" />
		
		<cfset variables.users=structNew() />
		
		<cfset variables.botlist="" />
		
		<!--- These settings moved from WhosOnPageTracker() function --->
		
		<cfset variables.showBots=false />
		<cfset variables.geoTrack=true />
		<cfset variables.pageHistory=false />
		<cfset variables.useBlockList=false />
		
		
		<!--- Configure variables if the argument collection is not passed --->
		<cfset variables.botListUrl="http://www.kisdigital.com/botlist.xml" />
		<!--- 
			What is the threshhold (how many hits from 1 IP address) before we assume it's
			a bot and should not be tracked by WhosOnCFC?
		--->
		<cfset variables.ipBlockListThreshhold=5 />
		
		<!--- How long should we default the session time too --->
		<cfset variables.defaultTimeout=30 />
		
		<!--- How many minutes do we want to remember session history? --->
		<cfset variables.storeHistory=10 />

		
		<!--- Check to see if the argument collection has been passed. --->
		<cfif structKeyExists(arguments,"args") and isStruct(arguments.args)>
			<cfscript>
				// Added trackTime and botTrackTime in v2.2.1
				variables.trackTime=arguments.args.trackTime;
				variables.botTrackTime=arguments.args.botTracktime;
				variables.ignoreIPs=arguments.args.ignoreIPs;
				
				// Added ignoreDomains in v2.2.3
				variables.ignoreDomains = arguments.args.ignoreDomains;
				
				variables.defaultTimeout=arguments.args.defaultTimeout;
				variables.botListUrl=arguments.args.botListUrl;
				variables.ipBlockListThreshhold=arguments.args.ipBlockListThreshhold;
				variables.storeHistory=arguments.args.storeHistory;
				variables.botList=arguments.args.botList;
				variables.ignorePages=arguments.args.ignorePages;
				variables.showBots=arguments.args.showBots;
				//variables.geoTrack=arguments.args.geoTrack;
				variables.geoTrack=true;
				variables.pageHistory=arguments.args.pageHistory;
				variables.useBlockList=arguments.args.useBlockList;
			</cfscript>
		</cfif>
		
		<!--- 
			User Agents to ignore if ignore bots is activated 
			getBotList() expects an URL to the botlist.xml to be specified.
			Change this to match your server.
		--->		
		
		<cfif len(variables.botListUrl)>
			<cfset variables.botList=this.getBotList(variables.botListUrl) />
		</cfif> 
		
		<cfif not len(variables.botList)>
			<!--- No botList supplied, default to internal list --->
			<cfset variables.botList="ColdFusion" />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<!--- 
	
	End of initialization code
	
	 --->
	
	<cffunction name="createQuery" access="public" output="false" returntype="query">
		<cfargument name="theData" type="array" required="true">
		
		<cfset var myQuery=QueryNew(structKeyList(arguments.theData[1]))>
		<cfset var ptrData="">
		<cfset var n="">
		<cfset var c="">
			
		<cfloop from="1" to="#arrayLen(arguments.theData)#" index="n">
			<cfset ptrData=arguments.theData[n]>
			<cfset QueryAddRow(myQuery)>
			<cfloop item="c" collection="#ptrData#">
				<cfif c is "PageHistory">
					<cfset querySetCell(myQuery,c,"Not Tracked.")>
				<cfelse>
					<cfset querySetCell(myQuery,c,ptrData[c])>
				</cfif>
				
			</cfloop>
		</cfloop>
		
		<cfquery name="c" dbtype="query">
			select *
			from myQuery
			Order by Total desc
		</cfquery>
		
		<cfreturn c />	
	</cffunction>

	<cffunction name="getBotList" access="public" output="false" returntype="string" hint="I read in the botlist.xml file.">
		<cfargument name="theUrl" type="string" required="false" default="#variables.botListUrl#" />
		
		<cfset var feed = "" />
		<cfset var n = "" />
		<cfset var data = "" />
		<cfset var result = "" />
		<cfset var myArray="" />

		<cftry>
			
			<cfhttp url="#theUrl#" resolveurl="true" result="feed" />
			<cfset data=XmlParse(feed.filecontent)>
			
			<cfset myArray=arrayNew(1) />
		

			<cfloop from="1" to="#arrayLen(data.botlistdata.XmlChildren)#" index="n">
				<cfset result=data.botlistdata.XmlChildren[n].XmlText />
				<cfset arrayAppend(myArray,result) />
			</cfloop>
			
	        <cfset result="" />
	        
			<cfscript>
				for(i=1; i lte arrayLen(myArray); i=i+1){
					result=listAppend(result,myArray[i]);
				}
			</cfscript>
		
			<cfcatch type="any"></cfcatch>
		</cftry>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getCurrentControlSet" access="public" output="false" returntype="struct" hint="I return the current operation perameters">
	
		<cfset var ret=structNew() />
		
			<cfscript>
				ret.trackTime=variables.trackTime;
				ret.botTrackTime=variables.botTrackTime;
				ret.ignoreIPs=variables.ignoreIPs;
				
				// Added ignoreDomains in v2.2.3
				ret.ignoreDomains = variables.ignoreDomains;
				
				ret.version=variables.version;
				ret.defaultTimeout=variables.defaultTimeout;
				ret.botListUrl=variables.botListUrl;
				ret.ipBlockListThreshhold=variables.ipBlockListThreshhold;
				ret.storeHistory=variables.storeHistory;
				ret.botList=variables.botList;
				ret.ignorePages=variables.ignorePages;
				ret.showBots=variables.showBots;
				ret.geoTrack=variables.geoTrack;
				ret.pageHistory=variables.pageHistory;
				ret.useBlockList=variables.useBlockList;
			</cfscript>
			
			<cfreturn ret />
	</cffunction>
	
	<cffunction name="getGeoInfo" access="private" returntype="struct" hint="Gets geographical info on an address, if available">
		<cfargument name="address" type="string" required="true">
		
		<cfset var myipxml="">
		<cfset var geoInfo = structNew()>
		
		<cftry>
			<cfhttp url="http://api.hostip.info/?ip=#arguments.address#" result="myipxml"  method="get" timeout="2">
			<cfset myipxml = xmlparse(myipxml.filecontent)>
			
			<cfcatch type="any">
				<cfset myipxml = ''>
			</cfcatch>
		</cftry>
		
		
		<cfif isDefined('myipxml.HostipLookupResultSet.featureMember.hostip.CountryName.XmlText')>
			<cfset geoInfo.country = myipxml.HostipLookupResultSet.featureMember.hostip.CountryName.XmlText>
		<cfelse>
			<cfset geoInfo.country = 'Unknown'>
		</cfif>
		
		<cfif isDefined('myipxml.HostipLookupResultSet.featureMember.hostip.name.XmlText')>
			<cfset geoInfo.local = myipxml.HostipLookupResultSet.featureMember.hostip.name.XmlText>
		<cfelse>
			<cfset geoInfo.local = 'Unknown'>
		</cfif>
		
		<cfif isDefined('myipxml.HostipLookupResultSet.featureMember.hostip.ipLocation.PointProperty.point.coordinates.XmlText')>
			<cfset geoInfo.coordinates = myipxml.HostipLookupResultSet.featureMember.hostip.ipLocation.PointProperty.point.coordinates.XmlText>
		<cfelse>
			<cfset geoInfo.coordinates = 'Unknown'>
		</cfif>
		
		<cfreturn geoInfo>
	</cffunction>
	
	<cffunction name="getHostName" access="private" returntype="string" hint="Performs a DNS lookup on an address">
		<cfargument name="address" type="string" required="true">
		
		<cfscript>
		/**
		 * Performs a DNS lookup on an IP address.
		 * 
		 * @param address 	 IP address to look up. 
		 * @return Returns a domain name. 
		 * @author Ben Forta (ben@forta.com) 
		 * @version 1, December 19, 2001 
		 */
		
		   // Variables
		   var iaclass="";
		   var addr="";
		   
		   // Init class
		   iaclass=CreateObject("java", "java.net.InetAddress");
		
		   // Get address
		   addr=iaclass.getByName(arguments.address);
		
		</cfscript>	
		<cfreturn addr.getHostName()>
	</cffunction>
	
	<cffunction name="getMaxCounts" access="public" returntype="struct" hint="Returns the max user and time values">
		<cfreturn variables.users>
	</cffunction>

	<cffunction name="getQuery" access="public" returntype="query" output="false" hint="Prepare data for display">
		<cfargument name="sortOn" type="string" required="true">
		
		<cfset var z="" />
		
		<cfset z=this.createQuery(this.sortData(theData=variables.activeusers,sortOn=arguments.sortOn))>	
		
		<cfreturn z />
	</cffunction>

	<cffunction name="getRawData" access="public" returntype="struct" hint="Returns our raw user data">
		<cfargument name="ClientID" type="string" required="true">
		
		<cfset var i=0 />
		<cfset var ret="" />
		
		<cfscript>
			for(i=1; i lte arrayLen(variables.activeusers);i=i+1){
				if(variables.activeusers[i].clientid is arguments.clientid) ret=variables.activeusers[i];
			}		
		</cfscript>
		
		<cfreturn ret />
	</cffunction>

	<cffunction name="getPageHistory" access="public" returntype="array" hint="Returns our users page history">
		<cfargument name="ClientID" type="string" required="true">
		
		<cfset var i=0 />
		<cfset var ret=arrayNew(1) />
		
		<cfscript>
			for(i=1; i lte arrayLen(variables.activeusers);i=i+1){
				if(variables.activeusers[i].clientid is arguments.clientid) ret=variables.activeusers[i].PageHistory;
			}		
		</cfscript>
		
		<cfreturn ret />
	</cffunction>
        
	<cffunction name="getUserList" access="public" returntype="string" hint="Returns a CSV list of users">
	
		<cfset var qUsers = "" />
		<cfset var uList="" />
		
		<cfset qUsers=this.WhosOnline() />
		
		<cfloop query="qUsers">
			<cfset uList=ListAppend(uList," " & qUsers.UserID,",")>
		</cfloop>
		
		<cfreturn trim(uList)>
	</cffunction>

	<cffunction name="sortData" output="false" returntype="array">
		<cfargument name="theData" type="array" required="true" hint="Array data to sort">
		<cfargument name="sortOn" type="string" required="false" default="entrypage" hint="What column to sort on">
			
		<cfset var arrayOut=arrayNew(1)>
		<cfset var n=1>
		<cfset var m=1>
		<cfset var tmp="">
		<cfset var result=0>
		<cfset var isInStruct=0>
		
        <cftry>
		<cfscript>
			for(n=1; n lte arrayLen(arguments.theData); n=n+1){
				if(not arrayLen(arrayOut)){
					tmp=structNew();
					tmp.data=arguments.theData[n][sorton];
					tmp.total=1;
					result=arrayAppend(arrayOut,tmp);
				} else {
					isInStruct=0;
					for(m=1; m lte arrayLen(arrayOut); m=m+1){
						if(arrayOut[m].data is arguments.theData[n][sorton]) isInStruct=m;
					}
					
					if(isInStruct){
						arrayOut[isInStruct].total=arrayOut[isInStruct].total+1;
					} else {
						tmp=structNew();
						tmp.data=arguments.theData[n][sortOn];
						tmp.total=1;
						result=arrayAppend(arrayOut,tmp);
					}
				}
			}
		</cfscript>
		
        <cfcatch></cfcatch>
        </cftry>
        
		<cfreturn arrayOut>
	</cffunction>

	<cffunction name="stripHTML" access="public" returntype="string" hint="function to remove html and js tags from html string">
    	<cfargument name="str" type="string" required="false" default="" hint="String to process" />

        <cfreturn REReplaceNoCase (str, "(<[^>]+>)" , "", "ALL") />                
    </cffunction>
    			
	<cffunction name="WhosOnline" access="public" returntype="query" hint="Returns a query object of users">
		<cfargument name="showAll" type="boolean" required="false" default="false" />
		<cfargument name="showHidden" type="boolean" required="false" default="false" />
		
		<cfset var myQuery=QueryNew(variables.structKeys)>
		<cfset var result = "">
		<cfset var ptrData="">
		<cfset var n="">
		<cfset var c="">
		
		<cfloop from="1" to="#arrayLen(variables.activeusers)#" index="n">
			<cfset ptrData=variables.activeusers[n]>
			<cfset QueryAddRow(myQuery)>
			<cfloop item="c" collection="#ptrData#">
				<cfset querySetCell(myQuery,c,ptrData[c])>
			</cfloop>
		</cfloop>
		
		<cfset n=DateAdd("n",+variables.defaultTimeout,Now())>
		<cfset c=DateAdd("n",-variables.defaultTimeout,Now())>
		
        <cftry>
            <cfquery name="result" dbtype="query">
                SELECT *
                FROM myQuery
                WHERE (0=0)
                <cfif arguments.showAll is false>
                AND LastUpdated Between <cfqueryparam cfsqltype="cf_sql_timestamp" value="#c#"> and <cfqueryparam cfsqltype="cf_sql_timestamp" value="#n#">
                </cfif>
                <cfif arguments.showHidden is false>
                AND hideClient=0
                </cfif>
            </cfquery>
        <cfcatch><cfreturn myQuery /></cfcatch>
		</cftry>
        
		<cfreturn result>
	</cffunction>




	<cffunction name="userIsInRole" access="public" returntype="boolean" hint="I return whether a user has a given role">
		<cfargument name="user" type="string" required="true" />
		<cfargument name="roles" type="string" required="true" />

		<cfset var uQuery="" />
		<cfset var filter="" />
		<cfset var m="" />
		<cfset var n="" />
		
		<cfset uQuery=this.WhosOnline(true,true)>
		<cfquery name="filter" dbtype="query">
			SELECT *
			FROM uQuery
			WHERE userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user#" />
		</cfquery>
		
		<cfif filter.RecordCount and len(filter.roles)>
		<cfscript>
			for(m=1; m lte listLen(arguments.roles); m=m+1){
				for(n=1; n lte listLen(filter.roles); n=n+1){
					if(listGetAt(filter.roles,n) is listGetAt(arguments.roles,m)) return true;
				}
			}
		</cfscript>
		
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	
	<cffunction name="UsersOnline" access="public" returntype="numeric" hint="Returns the number of active users">
		<cfset var users="" />
		
        <!--- Hide sessions that are not active and anything in the botList --->
		<cfset users=this.WhosOnline(showAll=false,showHidden=false) />
		
		<cfreturn users.recordCount />
	</cffunction>
	
	<cffunction name="WhosOnPageTracker" access="public" returntype="string" hint="Tracks a page hit">
		<cfargument name="whoson" type="struct" required="true" />
		
		<cfset var userCount=0 />
		<cfset var n = 0/>
		<cfset var j = 0/>
		<cfset var i = 0/>
		<cfset var userData = ""/>
		<cfset var result = ""/>
		<cfset var updateFlag = 0/>
		<cfset var skipUpdate = 0/>
		<cfset var hideClient = 0/>
		<cfset var skipIPCheck = 0/>
		<cfset var gInfo = ""/>
		<cfset var tempHistory = ""/>
		
        <cfset var botListLength = listLen(variables.botlist)/>
		<cfset var z = 0/>  
        <cfset var retUser=whoson.thisUser />
        <cfset var methodStart = getTickCount()/>
		
		<!--- 
		Check to see if our client is in the activeusers array
		 --->
        
		<cftry>
			<cflock name="TrackerLockForWritingUsers" type="exclusive" timeout="30">
			<cfscript>
			
				// Reset the userCount if we purged out any data	
				userCount=arrayLen(variables.activeusers);
					
				// Purge out old entries
				if(userCount gt 0){
					for(n=userCount; n gte 1; n=n-1){
						if(variables.ActiveUsers[n].hideClient){
							// This client was found in the botlist, store it for 3 hours
							if(DateDiff("n",variables.ActiveUsers[n].LastUpdated,Now()) gte (60*variables.botTrackTime)){// save history for 3 hours
								 ArrayDeleteAt(variables.ActiveUsers,n);
							}						
						}else{
							// This is an actual user, store it for 24 hours
							if(DateDiff("n",variables.ActiveUsers[n].LastUpdated,Now()) gte (60*variables.trackTime)){// save history for 24 hours
								 ArrayDeleteAt(variables.ActiveUsers,n);
							}
						}				
					}
					userCount=arrayLen(variables.activeusers);
				}
				// See if we can find the client in active user array
				for(n=1; n lte userCount; n=n+1){
					if(variables.ActiveUsers[n].ClientID is WhosOn.thisClient) updateFlag=n;
				}
				if(updateFlag){
				 skipUpdate = variables.ActiveUsers[updateFlag].hideClient;
				}																	
				if((hideClient gt 0) and (variables.showbots eq 0)){
					skipUpdate=skipUpdate+hideClient;
				}
				// Check ignored pages every request
				z = listLen(variables.ignorePages);
				for(j=1; j lte z; j=j+1){
					skipUpdate = skipUpdate + findNoCase(listGetAt(variables.ignorePages,j),arguments.whoson.CurrentPage,1);
				}
				n=0;
				// Insert / Update a client
				if(updateFlag eq 0){
					// Check these values on the first run through
					for(j=1; j lte botListLength; j=j+1){
						hideClient = hideClient + findNoCase(listGetAt(variables.botList,j),arguments.whoson.UserAgent,1);
					}
					z = listLen(variables.ignoreIPs);
					if(z){
						for(j=1; j lte z; j=j+1){
							hideClient = hideClient + findNoCase(listGetAt(variables.ignoreIPs,j),arguments.whoson.IP,1);
						}
					}
					z = listLen(variables.ignoreDomains);
					if(z){
						n=getHostName(address=WhosOn.IP);
						for(j=1; j lte z; j=j+1){
							hideClient = hideClient + findNoCase(listGetAt(variables.ignoreDomains,j),n,1);
						}
						n=0;
					}
						
					if(not skipUpdate){			
						retUser="Guest";
						userData=structNew();
						// This defines the information tracked on your user
						userData.UserID=WhosOn.thisUser;
						userData.ClientID=WhosOn.thisClient;
						userData.Roles=Whoson.roles;
						userData.Created=Now();
						userData.LastUpdated=Now();
						userData.Referer=WhosOn.Referer;
						userData.IP=WhosOn.IP;
						userData.HostName=getHostName(address=WhosOn.IP);
						if(hideClient gt 0){
							userData.hideClient=1;
						} else {
							userData.hideClient=0;
						}
						if(variables.geoTrack){
							gInfo=getGeoInfo(address=whoson.ip);
							userData.Coords=gInfo.coordinates;
							userData.Country=gInfo.country;
							userData.City=gInfo.local;
						}
						userData.CurrentPage = WhosOn.Prefix & WhosOn.ServerName;
						//Account for non-standard web ports
						if((WhosOn.ServerPort is not '80') AND (WhosOn.ServerPort is not '443')) userData.CurrentPage = userData.CurrentPage & ':' & WhosOn.ServerPort;
						userData.CurrentPage = userData.CurrentPage & WhosOn.CurrentPage;	
						//Joe Danziger requested MOD
						userData.EntryPage=userData.CurrentPage;
						userData.PageCount=1;
						if(len(trim(WhosOn.QueryString))) userData.CurrentPage=userData.CurrentPage & "?#WhosOn.QueryString#";
						userData.UserAgent=this.StripHTML(WhosOn.UserAgent);
						if(variables.pagehistory){
							userData.PageHistory=ArrayNew(1);
							tempHistory=structNew();
							tempHistory.Page=userData.CurrentPage;
							tempHistory.PageTime=0;
							ArrayAppend(userData.PageHistory,tempHistory);
						}
						userData.execTime = getTickCount() - methodStart;
						arrayAppend(variables.activeusers,userData);
						variables.structKeys=structKeyList(userData);
						userCount=arrayLen(variables.activeusers);
					}					
				} else {	
					if(not skipUpdate){
						// This defines the information updated after a user has been created
						// If user is already stored, check to see if their session has expired
						// and set the userid to guest
						if(DateDiff("n",variables.ActiveUsers[updateFlag].LastUpdated,Now()) gte variables.defaultTimeout){
							retUser="Guest";
						}
						variables.activeusers[updateFlag].UserID=WhosOn.thisUser;
						variables.activeusers[updateFlag].Roles=Whoson.roles;				
						variables.activeusers[updateFlag].IP=WhosOn.IP;
						variables.activeusers[updateFlag].CurrentPage=WhosOn.Prefix & WhosOn.ServerName;
						// Account for non-standard web ports
						if((WhosOn.ServerPort is not '80') AND (WhosOn.ServerPort is not '443')) variables.activeusers[updateFlag].CurrentPage = variables.activeusers[updateFlag].CurrentPage & ':' & WhosOn.ServerPort;
						variables.activeusers[updateFlag].CurrentPage = variables.activeusers[updateFlag].currentPage &  WhosOn.CurrentPage;
						if(len(trim(WhosOn.QueryString))) variables.activeusers[updateFlag].CurrentPage = variables.activeusers[updateFlag].CurrentPage & "?#WhosOn.QueryString#";
						if(variables.pagehistory){
							result=arrayLen(variables.activeusers[updateFlag].PageHistory);
							variables.activeusers[updateFlag].PageHistory[result].PageTime=DateDiff("s",variables.activeusers[updateFlag].LastUpdated,Now());
							tempHistory=structNew();
							tempHistory.Page=variables.activeusers[updateFlag].CurrentPage;
							tempHistory.PageTime=0;
							ArrayAppend(variables.activeusers[updateFlag].PageHistory,tempHistory);	
							// Clean the user history
							result=arrayLen(variables.activeusers[updateFlag].PageHistory);
							n=0;
							for(j=result; j gt 0; j=j-1){
								n=n+variables.activeusers[updateFlag].PageHistory[j].PageTime;
								if(n gt variables.storeHistory*60) arrayDeleteAt(variables.activeusers[updateFlag].PageHistory,j);
							}
						}
						variables.activeusers[updateFlag].PageCount=variables.activeusers[updateFlag].PageCount+1;
						variables.activeusers[updateFlag].LastUpdated=Now();
						variables.activeusers[updateFlag].execTime = getTickCount() - methodStart;
					}					
				}				
			</cfscript>
			</cflock>
			<cfcatch type="any">
				<cfthrow type="custom" message="An error has occured">
			</cfcatch> 
		</cftry>
		
		
		<cfif not structKeyExists(variables.users,"maxcount")>
			<cfset variables.users.maxcount=this.usersOnline()>
			<cfset variables.users.maxtime=Now()>
		<cfelse>
			<cfif variables.users.maxcount lt this.usersOnline()>
				<cfset variables.users.maxcount=this.usersOnline()>
				<cfset variables.users.maxtime=Now()>			
			</cfif>
		</cfif>
		
		<cfreturn retUser>
	</cffunction>
	
</cfcomponent>
