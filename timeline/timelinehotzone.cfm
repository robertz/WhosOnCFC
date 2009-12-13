<cfif thisTag.ExecutionMode is "start">
	<cfset baseTags = getBaseTagList()>
	<cfif not listFindNoCase(baseTags,"cf_timelineband")>
		<cfthrow type="cf_timelinehotzone" message="The cf_timelinehotzone tag must be nested within a cf_timelineband.">
	</cfif>
	<!--- associate this tag with the timelineband --->
	<cfassociate basetag="cf_timelineband" datacollection="zones">

	<cfparam name="attributes.start" default=""><!--- req --->
	<cfparam name="attributes.end" default=""><!--- req --->
	<cfparam name="attributes.magnification" default=""><!--- req --->
	<cfparam name="attributes.dateUnit" default=""><!--- req --->
	<cfparam name="attributes.multiple" default=""><!--- opt --->	
	
	<!--- clean up attributes --->
	<cfset attributes.multiple = replaceList(attributes.multiple, "px,em,%", "")>
	<cfset attributes.magnification = replaceList(attributes.magnification, "px,em,%", "")>
	
	<cfif not len(attributes.start)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: start is required.">
	</cfif>
	<cfif not isDate(attributes.start)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: The value of the attribute start which is currently '#attributes.start#' must be a valid date.">
	</cfif>
	<cfif not len(attributes.end)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: end is required.">
	</cfif>
	<cfif not isDate(attributes.end)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: The value of the attribute end which is currently '#attributes.end#' end must be a valid date.">
	</cfif>
	<cfif not len(attributes.magnification)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: magnification is required.">
	</cfif>
	<cfif not isNumeric(attributes.magnification)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: The value of the attribute magnification which is currently '#attributes.magnification#' magnification must be a number.">
	</cfif>
	<cfif not len(attributes.dateUnit)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: dateUnit is required.">
	</cfif>
	<cfif not listFindNoCase("millisecond,second,minute,hour,day,week,month,year,decade,century,millennium,era", attributes.dateUnit)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: The value of the attribute dateUnit which is currently '#attributes.dateUnit#' must be one of the following: 'millisecond,second,minute,hour,day,week,month,year,decade,century,millennium,era'">
	</cfif>
	<cfif len(attributes.multiple) and not isNumeric(attributes.multiple)>
		<cfthrow type="cf_timelinehotzone" message="cf_timelinehotzone: The value of the attribute multiple which is currently '#attributes.multiple#' must be a number.">
	</cfif>                             
<cfelse>
<!--- end mode --->
</cfif>