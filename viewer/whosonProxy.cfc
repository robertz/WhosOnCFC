<cfcomponent output="false">

<cffunction name="WhosOnline" access="remote" returnType="Any" output="false">
      <cfargument name="page" required="yes">
      <cfargument name="pageSize" required="yes">
      <cfargument name="gridsortcolumn" required="no" default="">
      <cfargument name="gridsortdirection" required="no" default="">
	
	<cfset var retQuery="">
	<cfset var myQuery=getWhoson().WhosOnline()>
	
	<cfquery name="retQuery" dbtype="query">
		Select *
		from myQuery
      <cfif gridsortcolumn neq ''>
      order by #gridsortcolumn# #gridsortdirection#
      </cfif>		
	</cfquery>
	
	
	<cfreturn QueryConvertForGrid(retQuery,page,pagesize) />
</cffunction>

<cffunction name="WhosOnlineStats" access="remote" returnType="Any" output="false">
      <cfargument name="page" required="yes">
      <cfargument name="pageSize" required="yes">
      <cfargument name="gridsortcolumn" required="no" default="">
      <cfargument name="gridsortdirection" required="no" default="">
	
	<cfset var retQuery="">
	<cfset var myQuery=getWhoson().WhosOnline(true,true)>
	
	<cfreturn QueryConvertForGrid(myQuery,page,pagesize) />
</cffunction>

<cffunction name="getWhoson" access="private" output="false">
<cfreturn application.whoson>
</cffunction>

</cfcomponent>