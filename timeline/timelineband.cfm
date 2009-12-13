<cfif thisTag.ExecutionMode is "start">
	<cfassociate basetag="cf_timeline" datacollection="bands">
	<cfparam name="attributes.bandHeight" default="0"><!--- req --->
	<cfparam name="attributes.dateUnit" default=""><!--- req --->
	<cfparam name="attributes.intervalWidth" default=""><!--- req --->
	<cfparam name="attributes.showEvents" default="true"><!--- opt --->
	<cfparam name="attributes.showEventText" default="true"><!--- opt --->
	<cfparam name="attributes.trackHeight" default=""><!--- opt --->
	<cfparam name="attributes.trackGap" default=""><!--- opt --->
	<cfparam name="attributes.highlight" default="false"><!--- opt --->
	<cfif not thisTag.HasEndTag>
		<cfthrow type="cf_timelineband" message="cf_timelineband:  The cf_timelineband tag must have an end tag.  You may optionally self close the tag like so: '&lt;cf_timelineband /&gt;'.">
	</cfif>
	<cfset baseTags = getBaseTagList()>
	<cfif not listFindNoCase(baseTags,"cf_timeline")>
		<cfthrow type="cf_timelineband" message="cf_timelineband:  The cf_timelineband tag must be nested within a cf_timeline.">
	</cfif>
	
	<!--- clean attributes --->
	<cfset attributes.bandHeight = val(attributes.bandHeight)>
	<cfset attributes.intervalWidth = val(attributes.intervalWidth)>
	<cfset attributes.trackHeight = replaceList(attributes.trackHeight, "px,em,%", "")>
	<cfset attributes.trackGap = replaceList(attributes.trackGap, "px,em,%", "")>
	<!--- param a var to contain the bandinfo which will be available to the parent tag --->
	<cfparam name="attributes.thisBand" default="">
	
	<cfparam name="timeline.attributes.timezone" default="0">
	<!--- get the base tag data --->
	<cfset timeline = getBaseTagData("cf_timeline")>


	<cfset tz = timeline.attributes.timezone>  
	
	<!--- error checks --->
	<cfif not len(attributes.bandHeight)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: bandHeight is required.">
	</cfif>
	<cfif not isNumeric(attributes.bandHeight)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: The value of the attribute bandHeight which is currently '#attributes.bandHeight#' must be numeric.">
	</cfif>
	<cfif not len(attributes.dateUnit)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: dateUnit is required.">
	</cfif>
	<cfif not listFindNoCase("millisecond,second,minute,hour,day,week,month,year,decade,century,millennium,era", attributes.dateUnit)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: The value of the attribute dateUnit which is currently '#attributes.dateUnit#' must be one of the following: 'millisecond,second,minute,hour,day,week,month,year,decade,century,millennium,era'.">
	</cfif>
	<cfif not len(attributes.intervalWidth)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: intervalWidth is required.">
	</cfif>
	<cfif not isNumeric(attributes.intervalWidth)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: The value of the attribute intervalWidth which is currently '#attributes.intervalWidth#' must be numeric." >
	</cfif>
	<cfif len(attributes.showEvents) and not isBoolean(attributes.showEvents)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: The value of the attribute showEvents which is currently '#attributes.showEvents#' must be boolean.">
	</cfif>
	<cfif len(attributes.showEventText) and not isBoolean(attributes.showEventText)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: The value of the attribute showEventText which is currently '#attributes.showEventText#' must be boolean.">
	</cfif>	
	<cfif len(attributes.trackHeight) and not isNumeric(attributes.trackHeight)>
		<cfthrow type="cf_timelineband" message="The value of the attribute trackHeight which is currently '#attributes.trackHeight#' must be numeric.">
	</cfif>
	<cfif len(attributes.trackGap) and not isNumeric(attributes.trackGap)>
		<cfthrow type="cf_timelineband" message="The value of the attribute trackGap which is currently '#attributes.trackGap#' must be numeric.">
	</cfif>
	<cfif len(attributes.highlight) and not isBoolean(attributes.highlight)>
		<cfthrow type="cf_timelineband" message="cf_timelineband: The value of the attribute highlight which is currently '#attributes.highlight#' must be boolean.">
	</cfif>	
	
<cfelse>
<!--- end mode --->
	<cfsavecontent variable="attributes.thisBand">
		<cfoutput>
		
		<!--- do we have hotzones? --->
		<cfif structKeyExists(thisTag, "zones")>
			<cfset thisSeperator = "">
			<cfset realSeperator = ",">
			Timeline.createHotZoneBandInfo({
				zones: [
				<cfloop from="1" to="#arrayLen(thisTag.zones)#" index="z">
					<cfset zone = thisTag.zones[z]>
					#thisSeperator#
					{
						start:    "#dateFormat(zone.start, "mmm dd yyyy")# #timeFormat(zone.start, "HH:mm:ss")#",
		                end:      "#dateFormat(zone.end, "mmm dd yyyy")# #timeFormat(zone.end, "HH:mm:ss")#",
		                magnify:  #zone.magnification#,
		                unit:     Timeline.DateTime.#ucase(zone.dateUnit)#
		                <cfif len(zone.multiple)>,multiple:	#zone.multiple#</cfif>
					}
					<cfset thisSeperator = realSeperator>
				</cfloop>
				],
		<cfelse>
			Timeline.createBandInfo({
		</cfif>
		
			
			width:			"#attributes.bandHeight#%",
			date:           d, //d is set in the cf_timeline tag!
			timezone:		#tz#,
			intervalUnit:   Timeline.DateTime.#ucase(attributes.dateUnit)#,
			intervalPixels: #attributes.intervalWidth#,
			theme:	theme
			<cfif len(attributes.showEvents)>,eventSource:		eventSource</cfif>
			<cfif len(attributes.showEventText)>,showEventText: #attributes.showEventText#</cfif>
			<cfif len(attributes.trackHeight)>,trackHeight:	#attributes.trackHeight#</cfif>
			<cfif len(attributes.trackGap)>,trackGap:	#attributes.trackGap#</cfif>
		})
		 </cfoutput>
	</cfsavecontent>
</cfif>