<html>
	<head>
		<cfajaximport tags="cfform,cfgrid,cfwindow"/>
	</head>

<body>

<script language="javascript">
	var interval=0;
	
	refreshGrid=function(){
		ColdFusion.Grid.refresh('myGrid',true);
	}
	
	setInt=function(func){
		interval=window.setInterval(func,1000*60*5);
	}
	
	killInterval=function(e){
		window.clearInterval(e);
	}
		
	showInfo=function(clientid){
    	ColdFusion.navigate('defaultDetail.cfm?clientid='+clientid,'mydiv');
    }
	
	showHistory=function(clientid){
		ColdFusion.navigate('historyDetail.cfm?clientid='+clientid,'mydiv');
	}
	
	viewStats=function(){
		killInterval(interval);
		ColdFusion.navigate('statsDetail.cfm','mydiv');
		setInt(refreshStats);
	}
	
	viewInfo=function(){
		killInterval(interval);
		ColdFusion.navigate('defaultView.cfm','mainDiv');
		setInt(refreshGrid);
	}
		
	viewHistory=function(){
		killInterval(interval);
		ColdFusion.navigate('historyView.cfm','mainDiv');
		setInt(refreshGrid);	
	}
	
	refreshStats=function(){
		ColdFusion.navigate('statsDetail.cfm','mydiv');
	}
	
	function showHelp(){
		ColdFusion.Window.create('Window1', 'About WhosOnCFC Viewer','about.cfm',{height:300,width:400,modal:true,closable:true,draggable:true,resizable:false,center:true,initshow:true });
	}
	
	setInt(refreshGrid);	
</script>


        <cflayout name="myLayout" type="border" style="height:100%; width:100%">
            <!--- The 100% height style ensures that the background color fills 
                the area. --->
            <cflayoutarea title="Session Viewer" name="left" position="left" closable="false" collapsible="true" splitter="false"  style="height:100%; width:250px;">
			<cfdiv id="mainDiv" bind="url:defaultView.cfm" style="width:100%;"></cfdiv>
            </cflayoutarea>
			
            <cflayoutarea title="Data Selector" position="right" style="background-color:##FFFFFF; height:100%; width:150px;" closable="false" collapsible="true" name="right" splitter="false"> 
                <cfform>
					<cfinput type="button" name="btnLive" value="Live View" style="width:148px;" onclick="javascript:viewInfo();">
					<cfinput type="button" name="btnHistory" value="History View" style="width:148px;" onclick="javascript:viewHistory();">
					<cfinput type="button" name="btnStats" value="Stats View" style="width:148px;" onclick="javascript:viewStats();">
					<cfinput type="button" name="btnAbout" value="About" style="width:148px;" onclick="javascript:showHelp();">
				</cfform>
            </cflayoutarea>	
						
            <cflayoutarea position="center" style="background-color:##FFFFFF; height:100%; width:100%;"> 
                <cfdiv id="mydiv"></cfdiv>
            </cflayoutarea>
			
		</cflayout>

</body>
</html>