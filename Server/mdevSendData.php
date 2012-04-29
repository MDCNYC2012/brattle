<?php

class lcstate {
	
	private $db;
	
	//Constuctor open DB connectio
	
	// destructor - close DB connection// Constructor - open DB connection
    function __construct() {
        $this->db = new mysqli('127.0.0.1', 'marty', '890wea', 'RBT');
		
		
		if (mysqli_connect_errno())		 {
			$retval=mysqli_connect_error();
			echo "connect error="+$retval;
		}
		$this->db->autocommit(TRUE);	
    }
	
	function __destruct() {
		$this->db->close();
	}

	// main method to redeem a code
	function lcstate_update() {
		
		$unique_ID= $_GET["unique_ID"];
		$meditation= $_GET["meditation"];
		$attention= $_GET["attention"];
		$blink= $_GET["blink"];
		$heartRate= $_GET["heartRate"];
		//echo "un=$unique_ID ";
		//echo "hd=$headValue ";
	
		
		//brute fore delete then insert as the update didn't update if no vale changed
		$stmt = $this->db->prepare("DELETE FROM mdev_headsets WHERE unique_ID=?");
		$stmt->bind_param("s", $unique_ID);
		$stmt->execute();
		$stmt->close();
		
		$stmt = $this->db->prepare("INSERT INTO mdev_headsets (
			unique_ID,
 			meditation,
			attention,
			blink,
			heartRate) 
			VALUES (?,?,?,?,?)"); 

		$stmt->bind_param("siiii", $unique_ID,$meditation,$attention,$blink,$heartRate);

/*		$stmt = $this->db->prepare("UPDATE mdev_headsets SET
 			meditation=?,
			attention=?,
			blink=?,
			heartRate=?
			where unique_ID=?"); 

		$stmt->bind_param("iiiis",$meditation,$attention,$blink,$heartRate, $unique_ID);
*/

		$stmt->execute();	
		$stmt->close();
		$doc=new DOMDocument('1.0');
		$root=$doc->createElement('root');
		$root=$doc->appendChild($root);
		//if($stmt->affected_rows == 1)	{
			$this->getState($root, $doc);
		//}
		/* {
			$child=$doc->createElement('state');
			$child=$root->appendChild($child);
			$value=$doc->createTextNode("err=un=$unique_ID,me=$meditation,at=$attention,bl=
			$blink,hr=$heartRate");
			$value=$child->appendChild($value);
		}		*/
		
		
		$xml_string = $doc->saveXML();
		echo $xml_string;
		return true;	
	}
	
	function getState($occ1, $doc){
		//echo "in populate track, track_id=$track_ID";
		$stmt = $this->db->prepare("select 
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

	
}    

//this is the first thing that gets called when this page is loaded
// create a new instance of the RedeemAPI class call calls the redeem method
$api = new lcstate;
$api->lcstate_update();

/*


// Helper method to get a string description for an HTTP status code
// From http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
function g