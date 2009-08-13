<?php
// Script:  To output OpenGFX's authoroverview.csv into a searchable HTML website
// By:      FooBar (Jasper Vries) <foobar@jaspervries.nl>
// License: GNU GPL v2
// Version: 1.2; 2009/08/13

// This script comes with a config.inc.php and a style.css.

//include db config information
require_once('config.inc.php');

//connect to db
$cfg_db['server_link'] = mysql_connect($cfg_db['server'], $cfg_db['user'], $cfg_db['pass']) or die (mysql_error());
//select database
mysql_select_db($cfg_db['db'], $cfg_db['server_link']) or die (mysql_error());

//function to update table
function update_table($forceupdate = FALSE) {
	global $cfg_db;
	global $cfg_csv;
	global $cfg;
	
	//get last update from storage file
	$lastupdate = @file_get_contents($cfg['lastupdate_file']);
	if ($lastupdate == FALSE) $lastupdate = 0;
	//get current rev from file
	$current = file_get_contents($cfg['current_rev_url']);
	
	//see if update is required
	if (($current > $lastupdate) || ($forceupdate == TRUE)) {
		//update lastupdate.txt
		$handle = fopen($cfg['lastupdate_file'], 'w+');
		fwrite($handle, $current);
		fclose($handle);

		//drop table if exists
		@mysql_query("DROP TABLE `".$cfg_db['table']."`;", $cfg_db['server_link']);	
		
		//create new table
		mysql_query("CREATE TABLE `".$cfg_db['table']."` (
		`id` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
		`file` VARCHAR(255),
		`range_start` MEDIUMINT UNSIGNED,
		`range_end` MEDIUMINT UNSIGNED,
		`num_sprites` MEDIUMINT UNSIGNED,
		`description` VARCHAR(255),
		`graphics` VARCHAR(255),
		`alignment`  VARCHAR(255),
		`ticket` MEDIUMINT UNSIGNED,
		`done` BOOL
		) ENGINE = MYISAM;", $cfg_db['server_link']) or die (mysql_error());	
		
		//get csv data
		$csv_array = file($cfg_csv['location']);
		//loop through each line
		foreach ($csv_array as $csv_line) {
			if ($cfg_csv['header'] == FALSE) {
				//split line into array
				$csv_line = trim($csv_line);
				$csv_line_array = split($cfg_csv['delimiter'], $csv_line);
				//construct SQL statement
				$sql = "INSERT INTO `".$cfg_db['table']."` 
				(`id`, `file`, `range_start`, `range_end`, `num_sprites`, `description`, `graphics`, `alignment`, `ticket`, `done`)
				VALUES (
				NULL,
				'".mysql_real_escape_string($csv_line_array[0])."',
				'".mysql_real_escape_string($csv_line_array[1])."',
				'".mysql_real_escape_string($csv_line_array[2])."',
				'".mysql_real_escape_string($csv_line_array[3])."',
				'".mysql_real_escape_string($csv_line_array[4])."',
				'".mysql_real_escape_string($csv_line_array[5])."',
				'".mysql_real_escape_string($csv_line_array[6])."',
				'".mysql_real_escape_string($csv_line_array[7])."',
				'".mysql_real_escape_string($csv_line_array[8])."'
				);";
				//insert in table
				mysql_query($sql, $cfg_db['server_link']);
			}
			else {
				//skip header and proceed
				$cfg_csv['header'] = FALSE;
			}
		}
		
		echo '<h1>Data Cache Updated</h1>';
	}
}

//function to create spritelist for use in other functions
function create_spritelist() {
	global $cfg;
	global $result;
	global $columns;
	global $files;
	global $ogfx;
	global $ttd;
	global $bpp32;
	
	//output table
	if (mysql_num_rows($result) > 0) {
		echo '<table>';
		echo '<tr>';
		for ($i = 0; $i < count($columns); $i++) {
			echo '<th><b>';
			echo '<a href="?feature=';
			echo urlencode(htmlspecialchars($_GET['feature']));
			echo '&amp;q=';
			echo urlencode(htmlspecialchars($_GET['q']));
			echo '&amp;orderby=';
			echo $columns[$i];
			echo '&amp;direction=';
			if ($_GET['direction'] == 'DESC') echo 'ASC';
			else echo 'DESC';
			echo '">';
			echo $columns[$i];
			echo '</a>';
			echo '</b></th>';
		}
		echo '<th><b>Sprite | TTD | OpenGFX';
		if ($cfg['display_32bpp'] == TRUE)  echo ' | 32bpp';
		echo '</b></th>';
		echo '</tr>';
		while ($data = mysql_fetch_array($result)) {
			echo '<tr><td>';
			echo htmlspecialchars($data[$columns[0]]);
			echo '</td><td>';
			//if ($files[$data[$columns[0]]] == 'e') {
				echo htmlspecialchars($data[$columns[1]]);
			/*}
			else {
				unset($spritesarray);
				for ($i = 0; $i < $data[$columns[3]]; $i++) {
					$spritesarray .= ($data[$columns[1]] + $i);
					if($i < ($data[$columns[3]] - 1)) $spritesarray .= ',';
				}
				echo '<a href="http://mz.openttdcoop.org/opengfx/index.php?';
				echo $files[$data[$columns[0]]];
				echo '=';
				echo $spritesarray;
				echo '">';
				echo htmlspecialchars($data[$columns[1]]);
				echo '</a>';
			}*/
			echo '</td><td>';
			echo htmlspecialchars($data[$columns[2]]);
			echo '</td><td>';
			echo htmlspecialchars($data[$columns[3]]);
			echo '</td><td>';
			echo htmlspecialchars($data[$columns[4]]);
			echo '</td><td>';
			echo htmlspecialchars($data[$columns[5]]);
			echo '</td><td>';
			echo htmlspecialchars($data[$columns[6]]);
			echo '</td><td>';
			if ($data[$columns[7]] > 0) echo '<a href="'.$cfg['ticket_url'].urlencode($data[$columns[7]]).'">#'.htmlspecialchars($data[$columns[7]]).'</a>';
			else echo '&nbsp;';
			echo '</td><td>';
				echo '<table class="transparent">';
					if ($files[$data[$columns[0]]] == 'e') {
					echo '<tr><td>Image display not supported for [extra]</td></tr>';
				}
				else {
					for ($i = $data[$columns[1]]; $i <= $data[$columns[2]]; $i++) {
						echo '<tr><td>';
						echo $i;
						echo '</td><td>';
						echo '<img src="';
						echo $ttd[$files[$data[$columns[0]]]].'sprite'.$i.'.png';
						echo '" alt="';
						echo 'TTD '.$data[$columns[0]].'.'.$i;
						echo '" />';
						echo '</td><td>';
						echo '<img src="';
						echo $ogfx[$files[$data[$columns[0]]]].'sprite'.$i.'.png';
						echo '" alt="';
						echo 'OpenGFX '.$data[$columns[0]].'.'.$i;
						echo '" />';
						if ($cfg['display_32bpp'] == TRUE) {
							if (file_exists($bpp32[$files[$data[$columns[0]]]].$i.'.png')) {
								echo '</td><td>';
								echo '<img src="';
								echo $bpp32[$files[$data[$columns[0]]]].$i.'.png';
								echo '" alt="';
								echo '32bpp '.$data[$columns[0]].'.'.$i;
								echo '" />';
							}
							else echo 'n/a';
						}
						echo '</td></tr>';
					}
				}
				echo '</table>';
			echo '</td></tr>';
		}
		echo '</table>';
	}
	else {
		echo '<p>none</p>';
	}
}

//function to list missing sprites
function list_missing_sprites($orderby = 'file', $direction = 'ASC') {
	global $cfg_db;
	global $result;
	global $columns;
	
	//check orderby validity
	if (!in_array($orderby, $columns)) $orderby = $columns[0];
	if ($direction != 'DESC') $direction = 'ASC';
	
	echo '<h1>All Missing Sprites</h1>';
	
	//get resultset
	$result = mysql_query("SELECT * FROM `".$cfg_db['table']."` WHERE `done`=0 ORDER BY `".$orderby."` ".$direction." , `range_start`, `id`;", $cfg_db['server_link']);
	
	//call to create spritelist
	create_spritelist();
}

//function to create priority list
function list_objectives($orderby = 'file', $direction = 'ASC') {
	global $cfg_db;
	global $result;
	global $columns;
	
	//check orderby validity
	if (!in_array($orderby, $columns)) $orderby = $columns[0];
	if ($direction != 'DESC') $direction = 'ASC';
	
	echo '<h1>Sprite Objectives</h1>';
	
	//Targets for 0.1.0-beta1
	echo '<h2>Targets for 0.1.0-beta1</h2>';

	//get resultset
	$result = mysql_query("SELECT * FROM `".$cfg_db['table']."` WHERE (`done`=0 AND (
	(`file`='ogfx1_base' AND (`range_end`<1947 OR (`range_start`>1946 AND `range_end`<1968) OR `range_start`>4625))
	OR `file`='ogfxt_toyland'
	OR (`file`='ogfxe_extra' AND `description` LIKE '%[Type 0C]%')
	)) ORDER BY `".$orderby."` ".$direction." , `range_start`, `id`;", $cfg_db['server_link']);
	
	//call to create spritelist
	create_spritelist();
}

//function to list sprites by author
function list_author($author = '', $orderby = 'file', $direction = 'ASC') {
	global $cfg_db;
	global $result;
	global $columns;
	
	//check orderby validity
	if (!in_array($orderby, $columns)) $orderby = $columns[0];
	if ($direction != 'DESC') $direction = 'ASC';
	
	?><h1>Who worked on what</h1>
	<p><form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="get">
	<input type="hidden" name="feature" value="spritesbyauthor" />
	<input type="text" name="q" value="<?php echo htmlspecialchars($author); ?>" />
	<input type="submit" value="Search" />
	</form></p>
	<?php
	
	if (!empty($author)) {
		//get resultset
		$result = mysql_query("SELECT * FROM `".$cfg_db['table']."` WHERE (
		`graphics` LIKE '%".mysql_real_escape_string($author)."%' 
		OR `alignment` LIKE '%".mysql_real_escape_string($author)."%'
		) ORDER BY `".$orderby."` ".$direction." , `range_start`, `id`;", $cfg_db['server_link']);
		
		//call to create spritelist
		create_spritelist();
	}
}

//function to list sprites by file
function list_file($file = '', $orderby = 'file', $direction = 'ASC') {
	global $cfg_db;
	global $result;
	global $columns;
	global $files;
	
	//check validity
	if (!in_array($orderby, $columns)) $orderby = $columns[0];
	if ($direction != 'DESC') $direction = 'ASC';
	if (!array_key_exists($file, $files)) $file = '';
	
	?><h1>Generate overview by file</h1>
	<p><form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="get">
	<input type="hidden" name="feature" value="spritesbyfile" />
	<select name="q">
		<option value="" style="color:#999999;">Select File...</option>
		<?php
		$files_keys = array_keys($files);
		for ($i=0; $i < count($files); $i++) {
			echo '<option';
			if ($files_keys[$i] == $file) echo ' selected="selected"';
			echo ' value="';
			echo $files_keys[$i];
			echo '">';
			echo $files_keys[$i];
			echo '</option>';
		}
		?>
	</select>
	<input type="submit" value="Go" />
	</form></p>
	<?php
	
	if (!empty($file)) {
		//get resultset
		$result = mysql_query("SELECT * FROM `".$cfg_db['table']."` WHERE (
		`file` = '".mysql_real_escape_string($file)."'
		) ORDER BY `".$orderby."` ".$direction." , `range_start`, `id`;", $cfg_db['server_link']);
		
		//call to create spritelist
		create_spritelist();
	}
}

//start actual content
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>OpenGFX Authoroverview HTML Output</title>
<link rel="stylesheet" type="text/css" href="style.css" />
</head>
<body>

<ul class="menu">
	<li><a href="?feature=objectives">List objectives</a></li>
	<li><a href="?feature=missingsprites">List missing</a></li>
	<li><a href="?feature=spritesbyauthor">List by author</a></li>
	<li><a href="?feature=spritesbyfile">List by file</a></li>
	<li><a href="?feature=forceupdate">Force update</a></li>
</ul>
<div style="clear:both;"></div>

<?php 
update_table();

if ($_GET['feature'] == 'missingsprites') list_missing_sprites($_GET['orderby'], $_GET['direction']);
elseif ($_GET['feature'] == 'objectives') list_objectives($_GET['orderby'], $_GET['direction']);
elseif ($_GET['feature'] == 'spritesbyauthor') list_author($_GET['q'], $_GET['orderby'], $_GET['direction']);
elseif ($_GET['feature'] == 'spritesbyfile') list_file($_GET['q'], $_GET['orderby'], $_GET['direction']);
elseif ($_GET['feature'] == 'forceupdate') update_table(TRUE);
?>

</body>
</html>