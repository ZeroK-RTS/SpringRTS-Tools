<?
function linkify($t) {
	return preg_replace("/(http:\/\/|www\.)([^ \n\)]+)/i", '<a href="http://$2">$1$2</a>', $t);	
}

function display_weight($w) {
	if ($w > 50) $col = "orange";
	if ($w > 66) $col = "red";
	return "<span style='color:$col;'>".$w."%</span>";
}

function poll_query($active, $voted, $id_user) {
	global $db;
	global $anon;
	if ($id_user > 0) $query = "SELECT count(v.id_option) as voted, p.id as pid FROM Polls p LEFT OUTER JOIN Votes v ON p.id = v.id_poll AND v.id_user=$id_user  WHERE active=$active GROUP BY p.id HAVING voted=$voted ORDER BY creation_time DESC"; else $query="SELECT count(v.id_option) as voted, p.id as pid FROM Polls p LEFT OUTER JOIN AnonymousVotes v ON p.id = v.id_poll AND v.cookie=$anon WHERE active=$active GROUP BY p.id HAVING voted=$voted ORDER BY creation_time DESC";
	return $db->query($query);
}


function display_poll($id, $id_user, $power) {
	global $db;
	global $anon;
	global $limitone;
	$pinfo = $db->query("SELECT active, question, secret, id_trac, (select count(*) from AnonymousVotes where id_poll=$id) as anonymous, (select sum(power) from v_VotePowers WHERE id_poll = $id) as cadev, (select sum(power) from v_VotePowers JOIN Options o ON id_option = o.id AND o.abstain=1 AND v_VotePowers.id_poll=$id) as abstain FROM Polls WHERE id = $id")->fetch();
	$tot_anon = $pinfo["anonymous"];
	$tot_cadev = $pinfo["cadev"];
	$tot_abstain = $pinfo["abstain"];
	$total_power = $db->singleQuery("SELECT sum(power) FROM Users");


	$myvote = @$db->singleQuery("SELECT id_option FROM Votes WHERE id_user=$id_user AND id_poll=$id");
	$myanon = $db->singleQuery("SELECT id_option FROM AnonymousVotes WHERE cookie=$anon AND id_poll=$id");
	
	$voted = ($id_user > 0 && $myvote > 0) || ($id_user <=0 && $myanon > 0);
		
	echo "<div style='border: 1px black solid; margin: 2px; padding:3px; ".(!$voted ? "background-color: #FFDDDD;" : "")."'><b><i>".linkify($pinfo["question"])."</b></i>";
	if ($pinfo[id_trac] && (!$limitone || $_GET[traclink])) {
		echo "<br/><b><a href='http://trac.caspring.org/ticket/$pinfo[id_trac]'>Trac discussion</a></b>";
	}
	
	// options
	$res = $db->query("SELECT text, sum(power) as cadev, sum(abstain) as abst, o.id as ido FROM Options o LEFT OUTER JOIN v_VotePowers p ON o.id_poll = p.id_poll AND o.id = p.id_option WHERE o.id_poll = $id GROUP BY id ORDER BY id");

	$barlen = 200;
	

	echo "<table>";
	while (($arr = $res->fetch())) {
		if ($total_power - $tot_abstain > 0) $percentage = (int)(100 *$arr["cadev"] / ($total_power - $tot_abstain)); else unset($percentage);
		$anon_votes = $db->singleQuery("SELECT count(*) FROM AnonymousVotes WHERE id_option = $arr[ido]");
	
		if ($tot_cadev > 0) $len = $barlen * $arr["cadev"] / $tot_cadev; else $len = 0;
		if ($tot_anon > 0) $lena = $barlen*$anon_votes / $tot_anon; else $lena = 0;

		$weight= "$anon_votes";
		if (!$arr["abst"]) $weight.= ", votes: <b>".display_weight($percentage)."</b>";
		
		$bar = "<img src='img/bar_blue.png' width='$len' height='10px'><br/><img src='img/bar_red.png' width='$lena' height='2px'>";
		
		if (($id_user > 0 && $myvote == $arr[ido]) || ($id_user <= 0 && $myanon == $arr[ido])) $votelink = "Voted"; 
		else if ($pinfo[active] > 0) $votelink = "<a href='index.php?act=vote&id_poll=$id&id_option=$arr[ido]&limitone=$limitone'>Vote</a>";
		else $votelink = "Vote";
		
		?>
		<tr>
		<td><?= $votelink ?></td>
		<td><?= linkify($arr["text"])?></td>
		<td width="<?=$barlen?>"><?= $bar?></td>
		<td><?= $weight?></td>
		</tr>
		<?
		if (!$pinfo[secret]) {
			echo "<tr><td colspan='4' align='center'><font size='-1'>";
			$res2 = $db->query("SELECT login FROM Votes v LEFT JOIN Users u ON id_user = u.id AND v.id_option=$arr[ido]");
			$cnt = 0;
			while (($arr2 = $res2->fetch())) {
				if ($cnt++ > 0) echo ", ";
				echo $arr2[login];
			}
			echo "</font></td></tr>";
		}
	}

	echo "<tr><td colspan='2' valign='bottom'>";
	

	$up = ((int)($tot_cadev*100/$total_power));
	if ($power > 0) {
		echo "&nbsp;&nbsp;&nbsp;<b>";
		if ($pinfo[active] > 0) echo "<a href='index.php?act=closepoll&id_poll=$id&limitone=$limitone'>Close</a>";
		else echo "<a href='index.php?act=reopenpoll&id_poll=$id&limitone=$limitone'>Reopen</a>";
		echo "&nbsp;&nbsp;|&nbsp;&nbsp;<a href='index.php?act=editpoll&id_poll=$id&limitone=$limitone'>Edit</a></b>";
	}
	echo "</td><td>";
	echo "</td><td valign='top'>";
	echo "<font size='-1'>Votes used: $up%</font>";
	if (!$pinfo[secret] && $up > 60 && $up<100) {
		echo "<br/><font size='-1'>Need: ";
		$res2 = $db->query("SELECT id, login FROM Users WHERE power > 0 AND id not in (SELECT id_user FROM Votes WHERE id_poll = $id)");
		$cnt = 0;
		while (($arr2 = $res2->fetch())) {
			if ($cnt++ > 0) echo ", ";
			echo $arr2[login];
		}
		echo "</font>";
	}
	echo "</td></table>";
	echo "</div>";
	if ($limitone) {
		$rows = poll_query(1,0,$id_user)->numRows();
		echo "&nbsp;&nbsp;<a href='http://gov.caspring.org/' target='_parent'>Other polls</a>";
		if ($rows > 0) echo " - $rows need your vote";
	}
	echo "<br/>";
	
}

?>