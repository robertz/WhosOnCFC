<cfif thisTag.ExecutionMode is "start">
	
	<cfset baseTags = getBaseTagList()>
	
	<cfif not listFindNoCase(baseTags,"cf_timeline")>
		<cfthrow type="cf_timelineevent" message="The cf_timelineevent tag must be nested within a cf_timeline.">
	</cfif>
	
	<cfset timeline = getBaseTagData("cf_timeline")>
	<cfif len(timeline.attributes.xmlEvents) or len(timeline.attributes.jsonEvents)>
		<cfthrow type="cf_timelineevent" message="You may not specify both cf_timelineevent tags and an external xml or json event source.">
	</cfif>
	<!--- associate this tag with the parent tag --->
	<cfassociate basetag="cf_timeline" datacollection="events">
	<!--- param attributes --->
	<cfparam name="attributes.start" default=""><!--- req --->
	<cfparam name="attributes.latestStart" default=""><!--- opt --->
    <cfparam name="attributes.earliestEnd" default=""><!--- opt --->
    <cfparam name="attributes.end" default=""><!--- opt --->
    <cfparam name="attributes.isDuration" default="false"><!--- opt --->
    <cfparam name="attributes.title" default=""><!--- req --->
	<cfparam name="attributes.description" default=""><!--- opt --->
    <cfparam name="attributes.image" default=""><!--- opt --->
    <cfparam name="attributes.link" default=""><!--- opt --->
    <cfparam name="attributes.icon" default=""><!--- opt --->
    <cfparam name="attributes.color" default=""><!--- opt --->
    <cfparam name="attributes.textColor" default=""><!--- opt --->
	
	<cfif not len(attributes.start)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: start is required.">
	</cfif>
	<cfif not isDate(attributes.start)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: The value of the attribute start which is currently '#attributes.start#' must be a valid date.">	
	</cfif>
	<cfif len(attributes.latestStart) and not isDate(attributes.latestStart)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: The value of the attribute latestStart which is currently '#attributes.latestStart#' must be a valid date.">	
	</cfif>
	<cfif len(attributes.earliestEnd) and not isDate(attributes.earliestEnd)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: The value of the attribute earliestEnd which is currently '#attributes.earliestEnd#' must be a valid date.">	
	</cfif>
	<cfif len(attributes.end) and not isDate(attributes.end)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: The value of the attribute end which is currently '#attributes.end#' must be a valid date.">	
	</cfif>
	<cfif len(attributes.isDuration) and not isBoolean(attributes.isDuration)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: The value of the attribute isDuration which is currently '#attributes.isDuration#' must be boolean.">	
	</cfif>
	<cfif not len(attributes.title)>
		<cfthrow type="cf_timelineevent" message="cf_timelineevent: title is required.">
	</cfif>	
<cfelse>
</cfif>