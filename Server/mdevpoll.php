<?php
class mdevpollAPI{
	
	
	
	private $db;
	private $words;
	
	//Constuctor open DB connectio
	
	// destructor - close DB connection// Constructor - open DB connection
    function __construct() {
    		// we need three connections to get 3 levels deep
        $this->db = new mysqli('127.0.0.1', 'marty', '890wea', 'RBT');
		
		if (mysqli_connect_errno())		 {
			$retval=mysqli_connect_error();
			echo "connect errno= $retval";
		}	
		
        $this->db2 = new mysqli('127.0.0.1', 'marty', '890wea', 'RBT');
		
		if (mysqli_connect_errno())		 {
			$retval=mysqli_connect_error();
			echo "connect errno= $retval";
		}	
        $this->db3= new mysqli('127.0.0.1', 'marty', '890wea', 'RBT');
		
		if (mysqli_connect_errno())		 {
			$retval=mysqli_connect_error();
			echo "connect errno= $retval";
		}	
    }
	
	function __destruct() {
		$this->db->close();
		$this->db2->close();
		$this->db3->close();
	}

	function mdevpoll() { 
		
		//$MDN= $_GET["MDN"];
		
		

		$doc=new DOMDocument('1.0');
		$root=$doc->createElement('root');
		$root=$doc->appendChild($root);
		
		$this->getState($root, $doc);
		$this->getHeadsetValues($root, $doc);
		//$this->getDeviceData($root, $doc);
		
		$xml_string = $doc->saveXML();
		echo $xml_string;
		return true;	
	}
		

	function getState($occ1, $doc){
		//echo "in populate track, track_id=$track_ID";
		$stmt = $this->db3->prepare("select 
			state 
			from mdev_state");
		//echo "after pop rack prepare";
		//$stmt->bind_param("i", $track_ID);
		$results= $stmt->execute();
		//if($results) echo "executeOK"; else echo "execute not OK";
		$stmt->bind_result($state);
		
//echo "after eecute";

		if ($row = $stmt->fetch()){
			// $occ2 = $doc->createElement($xml_title);
			// $occ2=$occ1->appendChild($occ2);
			// $atLeastOne=true;
			
			$child=$doc->createElement('state');
			$child=$occ1->appendChild($child);
			$value=$doc->createTextNode($state);
			$value=$child->appendChild($value);
	
			$stmt->close();
		}		
	}


	function getHeadsetValues($occ1, $doc){
 //echo "in populte messages recid=$rating_record_ID";
 
		$stmt = $this->db2->prepare("select 
			mdev_headsets.unique_ID,
			meditation,
			attention,
			blink,
			heartRate,
			color,
			spheroMacro
			from mdev_headsets inner join mdev_deviceData
			on mdev_headsets.unique_ID = mdev_deviceData.unique_ID");

		//echo "after prepare";
		//$stmt->bind_param("i", $rating_record_ID);
		//echo "after bind";
		$results= $stmt->execute();
		//if($results) echo "executeOK"; else echo "execute not OK";
		$stmt->bind_result($unique_ID, $meditation,$attention,
		$blink,$heartRate, $color, $spheroMacro);
		
//echo "after eecute";
		$atLeastOne=false;
		$occ2= $doc->createElement('headSetList');
		$occ2=$occ1->appendChild($occ2);
		
		while ($row = $stmt->fetch()){
			// silly execute on a select doesnt have a record count. if no items would neer have 'ownedRBT' item
			if(!$atLeastOne){
				$atLeastOne=true;
			}
			
			//echo "in while, cnt=$ratings_cnt";

			//echo "in while cnt=$cnt";
			//$printout.="$code has $uses_remaining uses remaining\n";
			$occ3= $doc->createElement('headSetItem');
			$occ3=$occ2->appendChild($occ3);
		//$stmt->bind_result($from_MDN, $rating, $comment, $create_date);
			
			$child=$doc->createElement('unique_ID');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($unique_ID);
			$value=$child->appendChild($value);

			$child=$doc->createElement('meditation');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($meditation);
			$value=$child->appendChild($value);
	
			$child=$doc->createElement('attention');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($attention);
			$value=$child->appendChild($value);
	
			$child=$doc->createElement('blink');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($blink);
			$value=$child->appendChild($value);
	
			$child=$doc->createElement('heartRate');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($heartRate);
			$value=$child->appendChild($value);
	
			$child=$doc->createElement('color');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($color);
			$value=$child->appendChild($value);
	
			$child=$doc->createElement('spheroMacro');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($spheroMacro);
			$value=$child->appendChild($value);
	
				
		}

		$stmt->close();
		
	}

	function getDeviceData($occ1, $doc){
 //echo "in populte messages recid=$rating_record_ID";
 
		$stmt = $this->db2->prepare("select 
			unique_ID,
			color,
			spheroMacro
			from mdev_deviceData");
		//echo "after prepare";
		//$stmt->bind_param("i", $rating_record_ID);
		//echo "after bind";
		$results= $stmt->execute();
		//if($results) echo "executeOK"; else echo "execute not OK";
		$stmt->bind_result($unique_ID, $color,$spheroMacro);
		
//echo "after eecute";
		$atLeastOne=false;
		$occ2= $doc->createElement('deviceList');
		$occ2=$occ1->appendChild($occ2);
		
		while ($row = $stmt->fetch()){
			// silly execute on a select doesnt have a record count. if no items would neer have 'ownedRBT' item
			if(!$atLeastOne){
				$atLeastOne=true;
			}
			
			//echo "in while, cnt=$ratings_cnt";

			//echo "in while cnt=$cnt";
			//$printout.="$code has $uses_remaining uses remaining\n";
			$occ3= $doc->createElement('deviceItem');
			$occ3=$occ2->appendChild($occ3);
		//$stmt->bind_result($from_MDN, $rating, $comment, $create_date);
			
			$child=$doc->createElement('unique_ID');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($unique_ID);
			$value=$child->appendChild($value);

			$child=$doc->createElement('color');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($color);
			$value=$child->appendChild($value);
	
			$child=$doc->createElement('spheroMacro');
			$child=$occ3->appendChild($child);
			$value=$doc->createTextNode($spheroMacro);
			$value=$child->appendChild($value);

			
		}

		$stmt->close();
		
	}


}    

//this is the first thing that gets called when this page is loaded
$api = new mdevpollAPI;
$api->mdevpoll();

?>