<?php
require 'tabulky.php';
require 'functions.php';
require 'login.php'; // fills id_user, power, db, login, anon variables

$limitone = $_GET[limitone];
?>
<html>
<head>
<title>CaGov</title>
 <style> 
    <!--
		A:link {text-decoration: underline; color:Blue;}
		A:visited {text-decoration: underline;color:Blue;}
		A:active {text-decoration: underline;color:Blue;}
		A:hover {text-decoration: none;color:Blue;}
    -->
   </style>
</head>
<body>
<div style="width: <?= $limitone?"625":"800"?>px">
<?

if (!$limitone) {
	// login form
	echo "<a href='index.php'>Refresh</a><br>";
	echo "<div style='border: 1px dotted blue'><b><i>Login: </i></b><br>";
	if ($id_user > 0) {
		echo $login." - votes:".$power;
		?>
		<form method="post" action="index.php?act=changepassword">Change password: <input type="password" name="password"><input type="submit"></form>
		<?
		echo "<b>";
		if ($id_user > 0) echo "<a href='index.php?act=addpoll'>Add new poll</a>";
		if ($power > 1) echo "&nbsp;|&nbsp<a href='index.php?act=adduser'>Add developer</a>";
		echo "&nbsp;|&nbsp;<a href='index.php?act=logout'>Logout</a></b>";
	} else {
		?>
		<form method="post" action="index.php?act=login"> 
		Login: <input type="text" name="login" value="<?= $_COOKIE["login"]?>">
		Password: <input type="password" name="password">
		<input type="submit">	</form>
	<?
	}
	echo "</div><br>";
	
	?>	
	You dont have to ask before implementing something, polls are for conflict resolving. <br/>
	For decision making use polls with only yes/no options.<br/>
	Do not add polls about things you wont implement yourself!<br/>
	Adding a vote like "make all units OTA free" is pointless unless you plan to do it yourself.<br/>
	<br/>
	<?
}


switch ($_GET["act"]) {
	
	case "changepassword":
		if ($id_user > 0) {
			$pas = trim($_POST["password"]);
			$pas = md5($pas);
			if (strlen($pas)>0) {
				$db->query("UPDATE Users SET password='$pas' WHERE id=$id_user");
				echo "Password changed, <a href='index.php'>login</a>";
				exit();
			}
		}
		break;
		
	
	case "editpoll"; // editing poll
		if ($power <= 0) return;
		$pinfo = $db->query("SELECT * FROM Polls WHERE id = $_GET[id_poll]")->fetch();
		?>		
		
		<div style="border:1px black solid;">
		<b><i>Edit poll:</i></b>
		<form method="post" action="index.php?act=editpollsubmit&id_poll=<?= $_GET["id_poll"]?>&limitone=<?= $limitone?>">
		<table>
		<tr><td>Question: </td><td><textarea name="question" cols="40"><?= $pinfo["question"] ?></textarea></td></tr>
		<?php 
		$res = $db->query("SELECT * FROM Options WHERE id_poll = $_GET[id_poll] AND abstain = 0 ORDER BY id");
		while (($arr = $res->fetch())) {
			?>	
			<tr><td></td><td><input type='text' name='id_<?=$arr["id"]?>' value="<?= $arr["text"]?>"></td></tr>
			<?
		}
		?>
		<tr><td>Add options (one per line): </td><td><textarea name="options" rows="4" cols="40"></textarea>
		</td></tr>
		<tr><td colspan="2" align="center">
		<input type="submit" value="Modify">
		</td></tr>
		</table>
		</form>
		</div>
		<?
		break;
		
	case "editpollsubmit": // submit editing poll
		if ($power > 0) {
			$question = sqlite_escape_string($_POST["question"]);
			$db->queryExec("UPDATE Polls SET question='$question' WHERE id = $_GET[id_poll]");
			$res = $db->query("SELECT * FROM Options WHERE id_poll = $_GET[id_poll] AND abstain = 0 ORDER BY id");
			while (($arr = $res->fetch())) {
				$val = $_POST["id_".$arr[id]];
				$text = sqlite_escape_string($val);
				if (strlen(trim($val))> 0) {
					$db->queryExec("UPDATE Options SET text = '$text' WHERE id = $arr[id]");
				} else {
					$db->queryExec("DELETE FROM Options WHERE id = $arr[id]");				
				}
			}
			
			$qlist = split("\n",$_POST["options"]);
			for ($i = 0; $i < count($qlist); $i++) {
				$trimmed = trim($qlist[$i]);
				if (strlen($trimmed) == 0) continue;
				$db->query("insert into Options (id_poll, text) values ($_GET[id_poll], '".sqlite_escape_string($trimmed)."')");
			}
		}
		break;
		
	
	case "vote": // voting
		if ($id_user > 0) {
			$db->queryExec("INSERT OR REPLACE INTO Votes (id_poll, id_user,id_option) VALUES ($_GET[id_poll], $id_user, $_GET[id_option])");
		} 
		$db->queryExec("INSERT OR REPLACE INTO AnonymousVotes (id_poll, cookie,id_option) VALUES ($_GET[id_poll], $anon, $_GET[id_option])");
		break;
		
		
	case "addpollsubmit": // creating new poll
		if ($id_user > 0) {
			$question = sqlite_escape_string($_POST["question"]);
			$db->queryExec("insert into Polls (question, creator, creation_time,secret) values ('$question', '$login', ".time().", ".($_POST["secret"] == "on" ? 1:0).")", $err);
			$pid = $db->lastInsertRowid();
			$qlist = split("\n",$_POST["options"]);
			for ($i = 0; $i < count($qlist); $i++) {
				$trimmed = trim($qlist[$i]);
				if (strlen($trimmed) == 0) continue;
				$db->query("insert into Options (id_poll, text) values ($pid, '".sqlite_escape_string($trimmed)."')");
			}
			$db->query("insert into Options (id_poll, text, abstain) values ($pid, 'Abstain',1)");
			
			if ($_POST["addtrac"] == "on") {
				$qline = split("[\\.\\?\\!]+", $question);
				$summary = $trac_db->quote("Poll: ".$qline[0]);
				$text=$trac_db->quote("{{{\n#!html\n<iframe src='http://gov.caspring.org/index.php?limitone=$pid' width='650' height='250' style='border:0; margin:0; padding:0;' frameborder='0'></iframe>\n}}}");
				$trac_db->exec("insert into ticket (type, time, changetime, component, priority, reporter, status, summary, description) values ('poll',".time().",".time().", 'CA','major','$login','new',$summary, $text)");
				$tracid = $trac_db->lastInsertId();
				$db->queryExec("update Polls set id_trac = $tracid WHERE id=$pid");
			}
		}
		break;
		
	case "addpoll":
		?>
		<div style="border:1px black solid;">
		<b><i>Add new poll:</i></b>
		<form method="post" action="index.php?act=addpollsubmit">
		<table>
		<tr><td>Question: </td><td><textarea name="question" cols="40"></textarea></td></tr>
		<tr><td>Options (one per line): </td><td><textarea name="options" rows="4" cols="40"></textarea></td></tr>
		<tr><td>Is secret vote: </td><td><input type="checkbox" name="secret"></td></tr>
		<tr><td>Add trac ticket: </td><td><input type="checkbox" name="addtrac" checked="checked"></td></tr>
		<tr><td colspan="2" align="center">
		<input type="submit" value="Add">
		</td></tr>
		</table>
		(Note that abstain option is added automtically)
		</form>
		</div>
		<?php 
		break;
		
	case "addusersubmit":
		if ($power > 1) {
			$uid = $_GET["uid"];
			if ($uid > 0) {
				$db->queryExec("UPDATE Users SET login='$_POST[login]', power='$_POST[power]' WHERE id = $uid");
			} else {
				$db->queryExec("INSERT INTO Users (login, power) VALUES ('$_POST[login]', $_POST[power])");
			}
		}
		break;
		
	case "adduser":
		if ($power <= 1) exit();
		unset($arr);
		if ($_GET["uid"] > 0) {
			$arr = $db->query("SELECT login, power FROM Users WHERE id = $_GET[uid]")->fetch();	
		}
		?>
		<div style="border:1px black solid;">
		<b><i>Add/modify user:</i></b>
		<form method="post" action="index.php?act=addusersubmit&uid=<?=$_GET["uid"]?>">
		<table>
		<tr><td>Login: </td><td><input type="text" name="login" value="<?= $arr[login]?>"></td></tr>
		<tr><td>Votes: </td><td><input type="text" name="power" value="<?= $arr[power]?>"></td></tr>
		</td></tr>
		<tr><td colspan="2" align="center">
		<input type="submit" value="Add/modify">
		</td></tr>
		</table>
		Note default new password is 'default'
		</form>
		</div>
		<?php 
		break;
				
		
		break;
	
		
	case "closepoll": // close existing poll
		if ($power > 0) {
			$total_power = $db->singleQuery("SELECT sum(power) FROM Users");
			$bestp = 0;
			$bestt = "";
			$tot_abstain = $db->singleQuery("select sum(power) from v_VotePowers JOIN Options o ON id_option = o.id AND o.abstain=1 AND v_VotePowers.id_poll=$_GET[id_poll]");
		
			$res = $db->query("SELECT text, sum(power) as cadev, sum(abstain) as abst, o.id as ido FROM Options o LEFT OUTER JOIN v_VotePowers p ON o.id_poll = p.id_poll AND o.id = p.id_option WHERE o.id_poll = $_GET[id_poll] GROUP BY id ORDER BY id");
			while (($arr = $res->fetch())) {
				if ($arr[abst]) continue;
				if ($total_power - $tot_abstain > 0) $percentage = (int)(100 *$arr["cadev"] / ($total_power - $tot_abstain)); else $percentage = 0;
				if ($percentage > $bestp) {
					$bestp = $percentage;
					$bestt = $arr["text"];
				} 
			}
			if ($bestp > 0) {
				$bestt = sqlite_escape_string($bestt);
			} else {
				$bestt = "";
			}
			$db->queryExec("UPDATE Polls SET resolution = '$bestt', resolution_percentage = $bestp, active = 0 WHERE id = $_GET[id_poll]");
			
			$id_trac = $db->singleQuery("SELECT id_trac FROM Polls WHERE id = $_GET[id_poll]");
			if ($id_trac) {
				$time = time();
				$trac_db->exec("UPDATE ticket SET changetime=$time, status='closed' WHERE id=$id_trac");
				$trac_db->exec("INSERT INTO ticket_change (ticket, time, author, field, oldvalue, newvalue) values ($id_trac, $time, '$login', 'status','new','closed')");
				$trac_db->exec("INSERT INTO ticket_change (ticket, time, author, field, oldvalue, newvalue) values ($id_trac, $time,'$login', 'comment','','Winner: $bestt ($bestp%)')");
			}
			
		}
		break;
		
	case "reopenpoll":
		if ($power > 0) {
			$db->queryExec("UPDATE Polls SET active=1 WHERE id=$_GET[id_poll]");
			$id_trac = $db->singleQuery("SELECT id_trac FROM Polls WHERE id = $_GET[id_poll]");
			if ($id_trac) {
				$time = time();
				$trac_db->exec("UPDATE ticket SET changetime=$time, status='reopened' WHERE id=$id_trac");
				$trac_db->exec("INSERT INTO ticket_change (ticket, time, author, field, oldvalue, newvalue) values ($id_trac, $time, '$login', 'status','closed','reopened')");
			}
		}
		break;
		
	case "deletepoll":
		if ($power > 1) $db->queryExec("DELETE FROM Polls WHERE id=$_GET[id_poll]");
		break;
	case "deleteuser":
		if ($power > 1) $db->queryExec("DELETE FROM Users WHERE id=$_GET[uid]");
		break;
	
}


// set old polls to abstain
$res = $db->query("SELECT id FROM Polls WHERE active=1 AND creation_time < ".(time()- 7*24*3600));
while (($arr = $res->fetch())) {
	$idp = $arr[id];
	$db->queryExec("INSERT INTO Votes (id_user, id_poll, id_option) SELECT id, $idp, (SELECT id FROM Options WHERE id_poll=$idp AND abstain=1) FROM Users WHERE id NOT IN (SELECT id_user FROM Votes WHERE id_poll=$idp)");
}
					
	

// limit display to just one poll
if ($limitone) {
	display_poll($limitone, $id_user, $power);

} else  {
	// active not voted
	$res = poll_query(1,0,$id_user);

	while (($arr = $res->fetch())) {
		display_poll($arr["pid"], $id_user, $power);
	}

	// active voted
	$res = poll_query(1,1,$id_user);

	while (($arr = $res->fetch())) {
		display_poll($arr["pid"], $id_user, $power);
	}

	// closed poll list
	tabletop(7, "Closed polls", "Details^Question^Resolution^Votes^Created by^Secret^Admin");
	$res = $db->query("SELECT * FROM Polls WHERE active=0 ORDER BY creation_time DESC");
	while (($arr = $res->fetch())) {
		if ($power > 0) $admin = "<a href='index.php?act=reopenpoll&id_poll=$arr[id]'>Reopen</a>";
		if ($power > 1) $admin.= " | <a href='index.php?act=deletepoll&id_poll=$arr[id]'>Delete</a>";
		tablerow(7, "<a href='index.php?limitone=$arr[id]&traclink=1'>Details</a>^".linkify($arr[question])."^".linkify($arr[resolution])."^".display_weight($arr[resolution_percentage])."^$arr[creator]^".($arr[secret]?"yes":"no")."^$admin");
	}
	tablebottom();

	echo "<br>&nbsp;<br>";

	// developers
	tabletop(3, "Developers", "Name^Votes^Admin");
	$res = $db->query("SELECT login,power,id FROM Users ORDER BY power DESC, login");
	while (($arr = $res->fetch())) {
		if ($power > 1) $admin = "<a href='index.php?act=adduser&uid=$arr[id]'>Edit</a>&nbsp;|&nbsp;<a href='index.php?act=deleteuser&uid=$arr[id]'>Delete</a>";
		else $admin = "";
		tablerow(3, "$arr[login]^$arr[power]^$admin");
	}
	tablebottom();
	?>
	<p>
	<b>Explanation:</b><br>
	Each developer has different number of votes (default 1 for developers, 2 for core developers).<br>
	<br>
	Each poll can be either <b>secret</b> or not  - secret polls don't show who voted for what option.<br>
	<br>
	In each poll both public (anonymous) and logged users (developers) can vote. Developer votes show as blue bars and public votes as thin red line below.<br>
	<b>Vote percentage</b> is the amount of developer's votes for this option out of <b>all</b> developers.  (except those abstaining)<br>
	<br>
	You can put links to both question and options to link to trac.
	</p>

	<p>
	<b>Guidelines:</b><br/>
	For general poll (sampling, no decision making yet) use any number of options.<br/>
	<br/>
	For decision making use only yes/no (abstain added automatically).<br/>
	This ensures that at least one option has 50+% votes if all devs vote.<br/>
	<br/>
	Note that you cannot force anyone to do anything using poll - its just for decision making and solving conflicts in dev team<br/>
	Adding a vote like "make all units OTA free" is pointless unless you plan to do it yourself.<br/>
	</p>	
	
	<?
}
?>
</div>
</body>
</html>