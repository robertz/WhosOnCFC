<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>jQuery Enhanced Viewer</title>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<link href="screen.css" rel="stylesheet" type="text/css" />
</head>

<body>
<div id="head" class="wrapper">
WhosOnCFC jView Viewer
</div>
<div id="wrapper" class="wrapper">
	<div id="leftpane" style="width: 300px; float: left;"></div>
	<div id="rightpane" style="width: 495px; float: right;">
		<div id="detail" class="detail">Click on an item to see the details</div>
	</div>
	<br style="clear: both;" />
</div>

<script type="text/javascript">
	appInit = 0;
	oldData = new Object();
	jsonData = new Object();
	colMap = new Object();
	currentClient = '';
	
	function drawScreens(){
		var pane = '';
		var div1 = '<div id="';
		var div2 = '';
		var thisClient = '';
		
		// leftpane
		
		if(appInit == 0){
			for(var i=0; i<jsonData.DATA.length; i++){
				pane = $('#leftpane').html();
				thisClient = "'" + jsonData.DATA[i][colMap["CLIENTID"]] + "'";
				
				div2 = '" class="client" onclick="viewClient(' + thisClient + ')" >';
			
				pane += div1 + jsonData.DATA[i][colMap["CLIENTID"]] + div2;
				pane += jsonData.DATA[i][colMap['IP']] + '<br />';
				pane += jsonData.DATA[i][colMap['LASTUPDATED']] + '<br />';
				pane += '</div>';
				
				$('#leftpane').html(pane);
				
				$('[id^=' + jsonData.DATA[i][colMap["CLIENTID"]] +']').fadeIn(1000);
			}
			appInit=1;
		} else {
			// App initialized, update the client list
			
			// Delete timed out clients
			$('[class^=client]').each(function(){
				var found = 0;
				
				for(var i=0; i<jsonData.DATA.length; i++){	
					if( $(this).attr('id') == jsonData.DATA[i][colMap["CLIENTID"]] ) found=1;
				}
				
				if(!found){
					//if( currentClient == $(this).attr('id') ) viewClient(jsonDataDATA[0][colMap["CLIENTID"]];
					$(this).fadeOut(1000, function() { $(this).remove(); });
				}
			});
			
			for(i=0; i<jsonData.DATA.length; i++){
				if( $('[id^=' + jsonData.DATA[i][colMap["CLIENTID"]] +']').length == 0){
				
					pane = $('#leftpane').html();
					thisClient = "'" + jsonData.DATA[i][colMap["CLIENTID"]] + "'";
					
					div2 = '" class="client" onclick="viewClient(' + thisClient + ')" >';
				
					pane += div1 + jsonData.DATA[i][colMap["CLIENTID"]] + div2;
					pane += jsonData.DATA[i][colMap['IP']] + '<br />';
					pane += jsonData.DATA[i][colMap['LASTUPDATED']] + '<br />';
					pane += '</div>';				
					
					$('#leftpane').html(pane);
					
				} else {
					pane = '';
					
					pane += jsonData.DATA[i][colMap['IP']] + '<br />';
					pane += jsonData.DATA[i][colMap['LASTUPDATED']] + '<br />';
					
					$('[id^=' + jsonData.DATA[i][colMap["CLIENTID"]] +']').html(pane);
				}
			}

		}
		
		if(currentClient.length) viewClient(currentClient);
		setTimeout('getData()',30000);
	}
	
	function setHover(){
		$('[class^=client]').hover(
							  
			function () {
				$(this).css({ 'background-color' : '#666666', 'color' : '#FFF' });
			}, 
			function () {
				$(this).css({ 'background-color' : '#ccc', 'color' : '#000' });
			}
							  
		); 		
	}
	
	function getData(){
		
		var data =  $.ajax({
			url:	'ajaxProxy.cfc?method=getUserData',
			async:	false
		}).responseText;
		
		jsonData = JSON.parse(data);
		
		for(var i = 0; i < jsonData.COLUMNS.length; i++) {
			colMap[jsonData.COLUMNS[i]] = i;        
		}		
		
		drawScreens();
	}
	
	function viewClient(id){
		currentClient=id;
		for(var i=0; i<jsonData.DATA.length; i++){
			if(jsonData.DATA[i][colMap['CLIENTID']]==id){
				var innerHTML = ''
				innerHTML += '<strong>Viewing details for</strong>: ' + id + '<br /><br />';
				innerHTML += '<strong>Created</strong>: ' + jsonData.DATA[i][colMap['CREATED']] + '<br />';
				innerHTML += '<strong>City/Country</strong>: ' + jsonData.DATA[i][colMap['CITY']] + '/' + jsonData.DATA[i][colMap['COUNTRY']] + '<br />';
				innerHTML += '<strong>Entry Page</strong>: ' + jsonData.DATA[i][colMap['ENTRYPAGE']] + '<br />';
				innerHTML += '<strong>Referrer</strong>: ' + jsonData.DATA[i][colMap['REFERER']] + '<br />';				
				innerHTML += '<strong>Last Updated</strong>: ' + jsonData.DATA[i][colMap['LASTUPDATED']] + '<br />';
				innerHTML += '<strong>IP</strong>: ' + jsonData.DATA[i][colMap['IP']] + '<br />';
				innerHTML += '<strong>Host Name</strong>: ' + jsonData.DATA[i][colMap['HOSTNAME']] + '<br />';
				innerHTML += '<strong>Current Page</strong>: ' + jsonData.DATA[i][colMap['CURRENTPAGE']] + '<br />';
				innerHTML += '<strong>Pages in History</strong>: ' + jsonData.DATA[i][colMap['PAGEHISTORY']].length + '<br />';
				
				for(var j=0; j<jsonData.DATA[i][colMap['PAGEHISTORY']].length; j++){
					innerHTML += jsonData.DATA[i][colMap['PAGEHISTORY']][j].PAGETIME + 's ';
					innerHTML += jsonData.DATA[i][colMap['PAGEHISTORY']][j].PAGE + '<br />';
				}
				
				$('#detail').html(innerHTML); 
			}
		}
	}
	
	$(document).ready(function(){
		getData();	
		setHover();
	});
</script>

</body>
</html>