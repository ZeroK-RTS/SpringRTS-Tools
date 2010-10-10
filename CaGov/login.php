<?
$db = new SQLiteDatabase('../cagov.db');
$trac_db = new PDO('sqlite:../trac/db/trac.db');

if (!isset($_COOKIE["anon"])) $anon = rand(1, 2147483647); else $anon = $_COOKIE["anon"]; // anonymous cookie
setcookie("anon",$anon, time() + 60*60*24*365);

if ($_GET["act"] == "login") {
	$login = $_POST["login"];
	$password = md5($_POST["password"]);
} else {
	$login = $_COOKIE["login"];
	$password = $_COOKIE["password"];
}

if ($_GET["act"] == "logout") {
	$password="";
	setcookie("password","",time()+60*60*24*30);
}


$elogin = sqlite_escape_string($login);

// login check
$res = $db->query("select id,power from Users where login='$elogin' and password='$password'");
if ($res->numRows()) {
	setcookie("login",$login,time()+60*60*24*30);
	setcookie("password",$password,time()+60*60*24*30);
	$arr = $res->fetch();
	$id_user = $arr["id"];
	$power = $arr["power"];
}

?>