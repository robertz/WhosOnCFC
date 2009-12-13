				<cfajaxproxy bind="javascript:showInfo({myGrid.clientid})" />

				<script>
					//var gridUpdateID=setInterval(refreshGrid, 1000*60*5);
					ColdFusion.Layout.expandArea('myLayout','left');
				</script>
				
				<cfform name="myForm">
					<cfgrid format="html" name="myGrid" bind="cfc:viewer.whosonProxy.WhosOnline({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})" pagesize="10" selectmode="browse" striperows="true" autowidth="true">
						<cfgridcolumn name="city" display="false" />
						<cfgridcolumn name="clientid" display="false" />
						<cfgridcolumn name="coords" display="false" />
						<cfgridcolumn name="Created" display="true" width="110" /> 
						<cfgridcolumn name="currentpage" display="false" />
						<cfgridcolumn name="entrypage" display="false" />   
						<cfgridcolumn name="hostname" header="hostname" display="false"/> 
						<cfgridcolumn name="ip" display="true" header="IP" width="139"/>
						<cfgridcolumn name="lastupdated" display="false" />
						<cfgridcolumn name="pagecount" display="false" />
						<cfgridcolumn name="pagehistory" display="false" />
						<cfgridcolumn name="referer" display="false" />
						<cfgridcolumn name="useragent" display="false" />
						<cfgridcolumn name="userid" display="false" />
					</cfgrid>
					<cfinput type="button" name="btnRefresh" value="Refresh Now" onclick="javascript:refreshGrid();" />
				</cfform>