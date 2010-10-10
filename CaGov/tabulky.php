<?
/*
funkce pro tvoreni tabulek urcene pro administratorskou cast
pouziti:
  Na zacatku se vola funkce tabletop, ktera vygeneruje hlavicku tabulky vcetne jejiho jmena
  a nejakeho uvodniho radku
  Funkce tablerow generuje jeden radek tabulky
  Funkce tablebottom ukonci table tag

  do jednotlivych funkci vstupuje promenna data, ktera ma nasledujici format
  jednotlive sloupce jsou oddeleny znakem ^, pokud je potreba colspan nekolika sloupcu, tak se daji znaky * (pocet se rovna poctu sloupcu, ktere zmizi) a potom zase oddeleny znakem ^ nasleduje popis sloupce, ktery bude vypsan

  parametr pocet znaci, kolik ma tabulka celkove sloupcu
*/

//$pocet - pocet sloupcu tabulky
//$nazev - nazev tabulky
//$data - jednotlive sloupce hlavicky daneho formatu
function tabletop($pocet,$nazev,$data) {
  print "<TABLE border=0 bgcolor=#000000 cellspacing=1 cellpadding=2>\n";
  print "<TR><TD colspan=$pocet align=center bgcolor=#cccccc><B><FONT SIZE=-1 FACE=\"Tahoma\">$nazev</FONT></B></TD></TR>\n";
  $pole=explode("^",$data);
  $colspan=1;
  $vysledek='';
  for($i=0;$i<$pocet;$i++) {
    if (StrCmp($pole[$i],'*')==0) { $colspan++; }
	else {
	  $vysledek.="<TH COLSPAN=$colspan bgcolor=#cccccc><FONT SIZE=-1 FACE=\"Tahoma\">$pole[$i]</FONT></TH>";
	  $colspan=1;
	}
  }
  echo $vysledek."\n";
}

//$pocet - pocet sloupcu tabulky
//$data - jednotlive sloupce hlavicky daneho formatu
function tablerow($pocet,$data) {
	static $barva;
	if ($barva==0) { $barva=1;$color="#ffffff"; }
	else { $barva=0; $color="#efefef"; }
	$pole=explode("^",$data);
  $colspan=1;
  $vysledek='';
  for($i=0;$i<$pocet;$i++) {
    if (StrCmp($pole[$i],'*')==0) { $colspan++; }
	else {
	  $vysledek.="<TD BGCOLOR=$color COLSPAN=$colspan><FONT SIZE=-1 FACE=\"Tahoma\">$pole[$i]</FONT></TD>";
	}
  }
  echo "<TR>$vysledek</TR>\n";
}

function tablebottom() {
  echo "</TABLE>";
}
?>