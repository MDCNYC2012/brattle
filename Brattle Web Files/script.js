var isStarted = false;
var strStartedURL = "http://108.12.134.59/RBT/mdevSetState.php/?state=started";
var strStoppedURL = "http://108.12.134.59/RBT/mdevSetState.php/?state=done";
var strGameStatusURL = "http://108.12.134.59/RBT/mdevpoll.php";
var strTestXMLResponseDoc = "http://192.168.11.25/~teresabrooks/MDCNYC_Tbrooks/testdata/Response.xml";
var counter = 0;
var isGameDone = false;
var strSelectedGame = "";

 function startGame(selectedGameType)
 {
 	strSelectedGame = selectedGameType;
 	isGameDone = false;
 	
 	//alert('game type: ' + strSelectedGame);
 	 	
    $.post(strStartedURL, function(data)
    {
    	//alert(data);
    });        
                   
    getCurrentGameStatus(); 
 } 
 
 function stopGame()
 {
 	isGameDone = true;
 	
 	alert('Game Stopped!');
 	
 	$.post(strStoppedURL, function(data)
    {
    	//alert(data);
    });   
 }
 
 /*function startGame()
 {
 	//alert('getting response');
 	
    $.post(strTestXMLResponseDoc, function(data)
    {
    	//alert(data);
    });        
                   
    getCurrentGameStatus(); 
 } */
 
 function getCurrentGameStatus()
 {
 	$.post(strGameStatusURL, function(data)
 	{
 		if(isGameDone == false)
 		{
 	   		counter++;
 	   		// alert("counter: " + counter + "\n response: " + data);
 	   		setTimeout(getCurrentGameStatus,30000);
			parseResponseAndDrawGraph(data);
		}
 	});
 }
 
 function parseResponseAndDrawGraph(xml)
 {
 	var strColor="";
 	var strScore = "";
 	var strPlayerId = ""
 	var intPlayerCounter = 0;
 	var intDisplayCounter = 1;
 	var arrayOfData = new Array();

 	$(xml).find('headSetItem').each(function()
 	{
 		//get player data properties
 		strColor = getColorHexValue($(this).find('color').text());
 		
 		if(strSelectedGame == "meditation")
 			strScore = $(this).find('meditation').text();
 		else if(strSelectedGame == "attention")
 			strScore = $(this).find('attention').text();
 		else if(strSelectedGame == "blink")
 			strScore = $(this).find('blink').text();
 		else if(strSelectedGame == "heartRate")
 			strScore = $(this).find('heartRate').text();
 			
 		strPlayerId = "Player " + intDisplayCounter;//$(this).find('unique_ID').text();
 		
 		//alert(strColor + " " + strScore + " " + strPlayerId);
 		//alert("intPlayerCounter: " + intPlayerCounter);
 		
 		//add each player's data to the array
 		arrayOfData[intPlayerCounter] = [strScore,strPlayerId,strColor];
 		
 		//update counters
 		intPlayerCounter++;
 		intDisplayCounter++;
 	});

 	//get game status and set flag to true if game is done.
 	var gameStatus = $(xml).find('done').text();

 	if(gameStatus == "done")
 	{
 		isGameDone = true;
 		//alert("isGameDone: " + isGameDone);
 	}

 	//clear div so we can re-draw the graph
 	$('#graph').empty();
 	
 	//bind data to array
 	$('#graph').jqBarGraph({ data: arrayOfData }); 
 }
 
 function getColorHexValue(strColorName)
 {
 	var strColorHexValue = "";
 	
 	if(strColorName == "red")
 		strColorHexValue = "#ff0000";
 	else if(strColorName == "green")
 		strColorHexValue = "#00C000";
 		
 	return strColorHexValue;
 }
 




