<cfif thisTag.ExecutionMode is "start">
	<cfprocessingdirective pageencoding="utf-8">
	<!--- attributes --->
	<cfparam name="attributes.id" default="">
	<cfparam name="attributes.timelineHeight" default="150">
	<cfparam name="attributes.start" default="#now()#">
	<cfparam name="attributes.timezone" default="0">
	<cfparam name="attributes.syncBands" default="true">
	<cfparam name="attributes.xmlEvents" default="">
	<cfparam name="attributes.jsonEvents" default="">
	<cfparam name="attributes.theme" default="classic">
	<cfparam name="attributes.labelWidth" default="250"><!--- opt --->
	<cfparam name="attributes.bubbleWidth" default="250"><!--- opt --->
	<cfparam name="attributes.bubbleHeight" default="200"><!--- opt --->
	<cfparam name="attributes.style" default=""><!--- opt --->
	<cfparam name="attributes.creationComplete" default=""><!--- opt --->
	<!--- 
	known bug with vertical layout (http://simile.mit.edu/issues/browse/TIMELINE-8) - omitting this feature until resolved
	<cfparam name="attributes.orientation" default="horizontal"> 
	--->
	
	<!--- clean up attributes --->
	<cfset attributes.timelineHeight = replace(attributes.timelineHeight, "px", "")>
	<cfset attributes.bubbleWidth = val(attributes.bubbleWidth)>
	<cfset attributes.bubbleHeight = val(attributes.bubbleHeight)>
	<cfset attributes.labelWidth = val(attributes.labelWidth)>
	
	<cfset validTZ = "-12,-11,-10,-9:30,-9,-8,-7,-6,-5,-4,-3:30,-3,-2:30,-2,-1,-0:44,-0:25,0,0:20,0:30,1,2,3,3:30,4,4:30,4:51,5,5:30,5:40,5:45,6,6:30,7,7:20,7:30,8,8:30,8:45,9,9:30,10,10:30,11,11:30,12,12:45,13,13:45,14">
	<!--- do some error checking --->
	<cfif not len(attributes.id)>
		<cfthrow type="cf_timeline" message="cf_timeline: id is required.">
	</cfif>
	<cfif not isNumeric(attributes.timelineHeight)>
		<cfthrow type="cf_timeline" message="cf_timeline:  The value of the attribute timelineHeight which is currently '#attributes.timelineHeight#' must be numeric.">
	</cfif>
	<cfif not isValid("date", attributes.start)>
		<cfthrow type="cf_timeline" message="cf_timeline: The value of the attribute start which is currently '#attributes.start#' must be a date.">
	</cfif>
	<cfif not listFindNoCase(validTZ, attributes.timezone)>
		<cfthrow type="cf_timeline" message="cf_timeline: The value of the attribute timezone which is currently '#attributes.timezone#' must be a valid timezone offset.">
	</cfif>
	<cfif not isBoolean(attributes.syncBands)>
		<cfthrow type="cf_timeline" message="cf_timeline: The value of the attribute syncBands which is currently '#attributes.syncBands#' must be a boolean value.">
	</cfif>


	<!--- 
	convert the user friendly theme 
	currently there is only one theme but i'm putting in a switch to accomodate future...
	--->

	<cfswitch expression="#attributes.theme#">
		<cfcase value="classic">
			<cfset attributes.theme = "ClassicTheme">
		</cfcase>
		<cfdefaultcase>
			<cfset attributes.theme = "ClassicTheme">
		</cfdefaultcase>>
	</cfswitch>
	
	<!---
	<cfif not listFindNoCase("horizontal,vertical", attributes.orientation)>
			<cfthrow type="cfTimeline" message="The value of orientation which is currently '#attributes.orientation#' must be one of the following:  horizontal, vertical.">
	</cfif>
	--->
	

<cfelse>
	<!--- we're in end mode --->
	
	<!--- include the simile api --->
	<cfsavecontent variable="simileJS">
	<script src="http://simile.mit.edu/timeline/api/timeline-api.js" type="text/javascript"></script>
	</cfsavecontent>
	
	<!--- write api to header --->
	<cfhtmlhead text="#simileJS#">
	
	<!--- check where we're going to get the data from --->
	<cfif not structKeyExists(thisTag, "event") and not len(attributes.xmlEvents)>
<!--- 		<cfthrow type="cfTimeline" message="You have not provided a datasource.  You must either specify xmlEvents or use cf_timelineevents to specify data to be plotted on this timeline."> --->
	</cfif>

	<cfsavecontent variable="timelineJS">
		<script type="text/javascript">
		
		<!--- set up some helper functions for dynamic data loading --->
		// Create cfTimeline namespace
		var cfTimeline;
		if (!cfTimeline) cfTimeline = {};
		
		cfTimeline.parseCFDate = function(dt){
			var yyyy = dt.substring(5,9);
			var mm = Number(dt.substring(10,12))-1;
			var dd = dt.substring(13,15);
			var HH = dt.substring(16,18);
			var MM = dt.substring(19,21);
			var SS = dt.substring(22,24);
			return new Date(yyyy,mm,dd,HH,MM,SS);
		}
		
		cfTimeline.isDate = function(str){
			var str;
			var result;
			var str = new Date(str);
			str == 'Invalid Date' ? result = false : result = true;
			return result;
		}
		
		cfTimeline.clearTimeline = function(){
			eventSource.clear();
		}
		
		cfTimeline.scrollToCenter = function(id,band,dt){
			if(!cfTimeline.isDate(dt)){
				var isTs = dt.indexOf('ts');
				if(isTs != -1){
					dt = cfTimeline.parseCFDate(dt);
				}
				else{
					dt = new Date(dt)
				}
			}
			id = eval(id); //if the id is passed as a quoted value
			dt = Timeline.DateTime.parseGregorianDateTime(dt);
			id.getBand(band).scrollToCenter(dt);
		}
		
		cfTimeline.setCenterVisibleDate = function(id,band,dt){
			if(!cfTimeline.isDate(dt)){
				var isTs = dt.indexOf('ts');
				if(isTs != -1){
					dt = cfTimeline.parseCFDate(dt);
				}
				else{
					dt = new Date(dt)
				}
			}
			id = eval(id); //if the id is passed as a quoted value
			dt = Timeline.DateTime.parseGregorianDateTime(dt);
			id.getBand(band).setCenterVisibleDate(dt);
		}
		
		cfTimeline.getEarliestDate = function(id,band){
			id = eval(id); //if the id is passed as a quoted value
			return id.getBand(band).getEventSource().getEarliestDate();
		}	
		
		cfTimeline.getLatestDate = function(id,band){
			id = eval(id); //if the id is passed as a quoted value
			return id.getBand(band).getEventSource().getLatestDate();
		}		
		<cfoutput>

		cfTimeline.loadJSON = function(id,src,func){
			id = eval(id); //if the id is passed as a quoted value; 
			id.loadJSON(src, 
				function(json, url) {
					eventSource.clear(); 
					eventSource.loadJSON(json, url); 
					if(func != undefined){
						func();
					}	
				}
			);
			id.layout();
		}
		cfTimeline.loadXML = function(id,src,func){
			id = eval(id); //if the id is passed as a quoted value;
			id.loadXML(src, 
				function(xml, url) {
					eventSource.clear(); 
					eventSource.loadXML(xml, url); 
					if(func != undefined){
						func();
					}	
				}
			);
			id.layout();
		}
		
		<!--- set up the timeline js functions --->
		var #attributes.id#;
		var eventSource;
		
		function #attributes.id#_onLoad() {
			eventSource = new Timeline.DefaultEventSource();
			
			<cfif structKeyExists(thisTag, "bands")>
				<!--- check that all heights = 100 --->
				<cfset heightArr = arrayNew(1)>
				<cfloop from="1" to="#arrayLen(thisTag.bands)#" index="bnds">
					<cfset arrayAppend(heightArr, thisTag.bands[bnds].bandHeight)>
				</cfloop>
				<cfset bndHeight = arraySum(heightArr)>
				<cfif bndHeight neq 100>
					<cfthrow type="cfTimeline" message="The height of all cf_timelinebands combined must equal 100.">
				</cfif>
				//set up a theme var
				var theme;
				theme = Timeline.#attributes.theme#.create();
	            theme.event.label.width = #attributes.labelWidth#; 
	            theme.event.bubble.width = #attributes.bubbleWidth#;
	            theme.event.bubble.height = #attributes.bubbleHeight#;
	            
	            var date = new Date(#year(attributes.start)#, #month(attributes.start)-1#, #day(attributes.start)#, #hour(attributes.start)#, #minute(attributes.start)#, #second(attributes.start)#);
				var d = Timeline.DateTime.parseGregorianDateTime(date);
				<cfset thisSeperator = "">
				<cfset realSeperator = ",">
				var #attributes.id#_bandInfos = [
				<cfloop from="1" to="#arrayLen(thisTag.bands)#" index="i">
					#thisSeperator##thisTag.bands[i].thisBand#
					<cfset thisSeperator = realSeperator>
				</cfloop>	
			];
				
				<cfloop from="1" to="#arrayLen(thisTag.bands)#" index="j">
					<cfif attributes.syncBands and arrayLen(thisTag.bands) gt 1 and j neq arrayLen(thisTag.bands)>
					#attributes.id#_bandInfos[#j#].syncWith = 0;
					</cfif>
					#attributes.id#_bandInfos[#j-1#].highlight = #thisTag.bands[j].highlight#;
				</cfloop>
			<cfelse>
				<cfthrow type="cf_timeline" message="At least one cf_timelineband must be specified.">
			</cfif>
	
			#attributes.id# = Timeline.create(document.getElementById("#attributes.id#"), #attributes.id#_bandInfos); 
			<!--- third argument when vertical layout is fixed = Timeline.#ucase(attributes.orientation)# --->
			
			<!--- if we have timelineevent tags there will be an array of events --->
			<cfif structKeyExists(thisTag, "events")>
					var timelineEvents = [];	
					<cfloop from="1" to="#arrayLen(thisTag.events)#" index="e">
						<cfset evt = thisTag.events[e]>
						timelineEvents.push(new Timeline.DefaultEventSource.Event(
						new Date(#year(evt.start)#, #month(evt.start)-1#, #day(evt.start)#, #hour(evt.start)#, #minute(evt.start)#, #second(evt.start)#),
					    <cfif len(evt.end)>new Date(#year(evt.end)#, #month(evt.end)-1#, #day(evt.end)#, #hour(evt.end)#, #minute(evt.end)#, #second(evt.end)#)<cfelse>null</cfif>,
					    <cfif len(evt.latestStart)>new Date(#year(evt.latestStart)#, #month(evt.latestStart)-1#, #day(evt.latestStart)-1#, #hour(evt.latestStart)#, #minute(evt.latestStart)#, #second(evt.latestStart)#)<cfelse>null</cfif>, 
					    <cfif len(evt.earliestEnd)>new Date(#year(evt.earliestEnd)#, #month(evt.earliestEnd)-1#, #day(evt.earliestEnd)-1#, #hour(evt.earliestEndd)#, #minute(evt.earliestEnd)#, #second(evt.earliestEnd)#)<cfelse>null</cfif>, 
						'#evt.isDuration#',
						<cfif len(evt.title)>"#jsStringFormat(evt.title)#"<cfelse>null</cfif>, 
						<cfif len(evt.description)>"#jsStringFormat(evt.description)#"<cfelse>null</cfif>, 
						<cfif len(evt.image)>'#evt.image#'<cfelse>null</cfif>, 
						<cfif len(evt.link)>'#evt.link#'<cfelse>null</cfif>, 
						<cfif len(evt.icon)>'#evt.icon#'<cfelse>null</cfif>, 
						<cfif len(evt.color)>'#evt.color#'<cfelse>null</cfif>, 
						<cfif len(evt.textColor)>'#evt.textColor#'<cfelse>null</cfif>
						));
					</cfloop>
					eventSource.addMany(timelineEvents); 
			</cfif>
			
			<cfif len(attributes.xmlEvents)>
			cfTimeline.loadXML(#attributes.id#,'#attributes.xmlEvents#'<cfif len(attributes.creationComplete)>,#attributes.creationComplete#</cfif>);
			</cfif>
			<cfif len(attributes.jsonEvents)>
			cfTimeline.loadJSON(#attributes.id#,'#attributes.xmlEvents#'<cfif len(attributes.creationComplete)>,#attributes.creationComplete#</cfif>);
			</cfif>
		}
		</cfoutput>
		</script>
	</cfsavecontent>
	<!--- write timeline to header --->
	<cfhtmlhead text="#timelineJS#">
	
	<cfsavecontent variable="loadJS">
		<script type="text/javascript">
		
		function addLoadListener(handler,type)
		{
			if(type == 'load'){
			var listenerType = 'load';
			var eventType = 'onload'
			}
			if(type == 'resize'){
			var listenerType = 'resize';
			var eventType = 'onresize'
			}
			
			if (typeof window.addEventListener != 'undefined')
				window.addEventListener(listenerType, handler, false);
			else if (typeof document.addEventListener != 'undefined')
				document.addEventListener(listenerType, handler, false);
			else if (typeof window.attachEvent != 'undefined')
				window.attachEvent(eventType, handler);
		}

		<cfoutput>
		var resizeTimerID = null;
		function #attributes.id#_onResize() {
		    if (resizeTimerID == null) {
		        resizeTimerID = window.setTimeout(function() {
		            resizeTimerID = null;
		            #attributes.id#.layout();
		        }, 500);
		    }
		}
		
		//register the onLoad/onResize functions
		addLoadListener(#attributes.id#_onLoad, 'load');
		addLoadListener(#attributes.id#_onResize, 'resize');
		</cfoutput>
		
		</script>
	</cfsavecontent>
	<!--- write load to header --->
	<cfhtmlhead text="#loadJS#">
	
	
	<!--- create the timeline container --->
	<cfoutput>
	<div id="#attributes.id#" style="height: #attributes.timelineHeight#px; #attributes.style#"></div>
	</cfoutput>
</cfif>
