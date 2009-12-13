<cfcomponent output="no">

	<cffunction name="getUserData" access="remote" returntype="query" returnformat="json">
		<cfargument name="showAll" type="boolean" required="false" default="true" />
		<cfargument name="showHidden" type="boolean" required="false" default="true" />
		
		<cfscript>
			return this.getWhosOn().whosOnline(showAll=arguments.showAll,showHidden=arguments.showHidden);
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getWhosOn" access="private" returntype="any">
		<cfreturn application.whoson />
	</cffunction>
	
</cfcomponent>