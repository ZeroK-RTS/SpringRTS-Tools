<?
////// Bos To Lua script converter by CarRepairer /////
?>
<html>
<head>
	<title>
		Spring Bos to Lua Converter
	</title>
</head>
<body>
<pre>
<?
	$bos = isset( $_POST['bos'] ) ? $_POST['bos'] : '';
	
	
	$lua = bos2lua( $bos );
	
	
	function bos2lua( $bos )
	{
		$bos2 = $bos;
		$bos2 = convert_pieces($bos2);
		$bos2 = convert_littleparts($bos2);
		$bos2 = convert_blocks($bos2);
		$bos2 = convert_functions($bos2);
		$bos2 = convert_script_fcn_names($bos2);
		
		$bos2 = cleanup($bos2);
	
		$lua = $bos2;
		
		return $lua;
	}
	
	function convert_pieces($bos)
	{
		$bos2 = '';
		$piece_statements = preg_match_all('/piece ([^;]*);/', $bos, $matches );
		

		foreach( $matches[1] as $pieces )
		{
			
			$pieces_arr = explode(',',$pieces);
			foreach( $pieces_arr as $piece )
			{
				$piece = trim($piece);
				$bos2 .= "local $piece = piece '$piece' \n";
			}
		}
		$bos2 .= preg_replace('/piece [^;]*;/', '', $bos );
		
		return $bos2;
	}

	function convert_littleparts($bos)
	{
		$bos2 = $bos;
		$find = array(
			'//',
			'!=',
			'!',
			'TRUE',
			'FALSE',
			'static-var',
			'}',
		);
		$rep = array(
			'--',
			'~=',
			'not ',
			'true',
			'false',
			'local',
			'end',
		);
		$bos2 = str_replace($find, $rep, $bos2 );
		
		$bos2 = preg_replace('/#define[\s]*([^\s]*)[\s]*([^\s]*)/', 'local \1 = \2', $bos2 );
		
		return $bos2;
	}
	
	function convert_script_fcn_names($bos)
	{
		$bos2 = $bos;
		$find = array(
			'Create',
			'Killed',
			
			'StartMoving',
			'StopMoving',
			
			'QueryWeapon1',
			'QueryWeapon2',
			'QueryWeapon3',
			
			'QueryPrimary',
			'QuerySecondary',
			'QueryTertiary',
			
			'AimFromWeapon1',
			'AimFromWeapon2',
			'AimFromWeapon3',
			
			'AimFromPrimary',
			'AimFromSecondary',
			'AimFromTertiary',
			
			'AimWeapon1',
			'AimWeapon2',
			'AimWeapon3',
			
			'AimPrimary',
			'AimSecondary',
			'AimTertiary',
			
			'Shot1',
			'Shot2',
			'Shot3',
			
			'Activate',
			'Deactivate',
			
			'setSFXoccupy',
			'HitByWeapon',
			
			
		);
		$rep = array(
			'Create',
			'Killed',
			
			'StartMoving',
			'StopMoving',
			
			'QueryWeapon1',
			'QueryWeapon2',
			'QueryWeapon3',
			
			'QueryWeapon1',
			'QueryWeapon2',
			'QueryWeapon3',
			
			'AimFromWeapon1',
			'AimFromWeapon2',
			'AimFromWeapon3',
			
			'AimFromWeapon1',
			'AimFromWeapon2',
			'AimFromWeapon3',
			
			'AimWeapon1',
			'AimWeapon2',
			'AimWeapon3',
			
			'AimWeapon1',
			'AimWeapon2',
			'AimWeapon3',
			
			'Shot1',
			'Shot2',
			'Shot3',
			
			'Activate',
			'Deactivate',
			
			'setSFXoccupy',
			'HitByWeapon',
		);
		$rep2 = array();
		foreach($rep as $rep_str)
		{
			$rep2[] = 'function script.' . $rep_str;
		}
		$bos2 = str_replace($find, $rep2, $bos2 );
		return $bos2;
	}

	function convert_blocks($bos)
	{
		$bos2 = $bos;
		$bos2 = preg_replace('/(.*)if.*\((.*)\)/', '\1if \2 then', $bos2 );
		$bos2 = preg_replace('/(.*)while.*\((.*)\)/', '\1while \2 do', $bos2 );
		
		return $bos2;
	}
	
	function convert_functions($bos)
	{
		$bos2 = $bos;
		
		$bos2 = str_replace(array('[',']'), '', $bos2 );
		
		$find = array(
			'/start-script ([^\(]*)\(.*\)/',
			'/sleep([^;]*);/',
			'/set-signal-mask([^;]*);/',
			'/signal([^;]*);/', //must be after set-signal-mask
			'/show([^;]*);/',
			'/hide([^;]*);/',
			'/emit-sfx(.*)from(.*);/',
			
			'/turn[\s]*(.*)[\s]*to[\s]*(.)-axis.*<(.*)>.*speed.*<(.*)>[\s]*[\s]*;/',
			'/turn[\s]*(.*)[\s]*to[\s]*(.)-axis.*<(.*)>.*speed[\s]*(.*)[\s]*[\s]*;/',
			'/turn[\s]*(.*)[\s]*to[\s]*(.)-axis[\s]*(.*)[\s]*speed.*<(.*)>[\s]*[\s]*;/',
			'/turn[\s]*(.*)[\s]*to[\s]*(.)-axis[\s]*(.*)[\s]*speed[\s]*(.*)[\s]*[\s]*;/',
			'/turn[\s]*(.*)[\s]*to[\s]*(.)-axis.*<(.*)>.*now/',
			'/turn[\s]*(.*)[\s]*to[\s]*(.)-axis[\s]*(.*)[\s]*now/',
			
			'/wait-for-turn (.*) around (.)-axis/',
			'/wait-for-move (.*) along (.)-axis/',
			
			'/move[\s]*(.*)[\s]*to[\s]*(.)-axis.*<(.*)>.*speed.*<(.*)>[\s]*;/',
			'/move[\s]*(.*)[\s]*to[\s]*(.)-axis.*<(.*)>.*speed (.*)[\s]*;/',
			'/move[\s]*(.*)[\s]*to[\s]*(.)-axis[\s]*(.*)[\s]*speed.*<(.*)>[\s]*;/',
			'/move[\s]*(.*)[\s]*to[\s]*(.)-axis[\s]*(.*)[\s]*speed[\s]*(.*)[\s]*;/',
			'/move[\s]*(.*)[\s]*to[\s]*(.)-axis[\s]*(.*)[\s]*now/',
			
			'/spin[\s]*(.*)[\s]*around[\s]*(.)-axis[\s]*speed[\s]*<(.*)>/',
			'/spin[\s]*(.*)[\s]*around[\s]*(.)-axis[\s]*speed[\s]*(.*)/',
			
			'/explode[\s]+(.*)[\s]+type[\s]+(.*);/',
			
			'/\|[\s]*([^\s]*)/',
			'/<<<[\s]*([^\s]*)/',
			
			
		);
		$rep = array(	
			'StartThread(\1)',
			'Sleep(\1)',
			'SetSignalMask(\1)',
			'Signal(\1)',
			'Show(\1)',
			'Hide(\1)',
			'EmitSfx(\2, \1)',
			
			/*
			'Turn( \1, \2_axis, math.rad(\3), \4 )',
			'Turn( \1, \2_axis, math.rad(\3), \4 )',
			'Turn( \1, \2_axis, math.rad(\3), \4 )',
			'Turn( \1, \2_axis, math.rad(\3), \4 )',
			*/
			'Turn( \1, \2_axis, math.rad(\3), math.rad(\4) )',
			'Turn( \1, \2_axis, math.rad(\3), math.rad(\4) )',
			'Turn( \1, \2_axis, math.rad(\3), math.rad(\4) )',
			'Turn( \1, \2_axis, math.rad(\3), math.rad(\4) )',
			
			'Turn( \1, \2_axis, math.rad(\3) )',
			'Turn( \1, \2_axis, math.rad(\3) )',
			
			'WaitForTurn(\1, \2_axis)',
			'WaitForMove(\1, \2_axis)',
			
			'Move( \1, \2_axis, \3, \4 )',
			'Move( \1, \2_axis, \3, \4 )',
			'Move( \1, \2_axis, \3, \4 )',
			'Move( \1, \2_axis, \3, \4 )',
			'Move( \1, \2_axis, \3 )',
			
			'Spin( \1, \2_axis, \3 )',
			'Spin( \1, \2_axis, \3 )',
			
			'Explode( \1, <<<\2)',
			
			'+ sfx\1',
			'sfx\1',
			
		);
		$bos2 = preg_replace($find, $rep, $bos2 );
		
		$find = array( 'sfxFALL', 'sfxSMOKE', 'sfxFIRE', 'sfxEXPLODE_ON_HIT', 'sfxSHATTER', );
		$rep = array( 'sfxFall', 'sfxSmoke', 'sfxFire', 'sfxExplodeOnHit', 'sfxShatter', );
		$bos2 = str_replace($find, $rep, $bos2 );
		
		$find = '/Move\( (.*), x_axis, (.*), (.*) \)/';
		$rep = 'Move( \1, x_axis, -\2, \3 )';
		$bos2 = preg_replace($find, $rep, $bos2 );
		
		$find = '/Turn\( (.*), z_axis, math\.rad(.*), (.*) \)/';
		$rep = 'Turn( \1, z_axis, math.rad(-\2), \3 )';
		$bos2 = preg_replace($find, $rep, $bos2 );
		
		//$bos2 = preg_replace( '/(.*)turn(.*)to.*(.)-axis.*<(.*)>.*speed.*<(.*)>/', '\1Turn2( \2, \3_axis, \4, \5 )', $bos2 );
		return $bos2;
	}
	
	function cleanup($bos)
	{
		$bos2 = $bos;
		$bos2 = preg_replace( '/end\s*else/', 'else', $bos2 );
		$bos2 = str_replace(array('{', ';', 'call-script'), '', $bos2 );
		//$bos2 = str_replace('math.rad(0)', '0', $bos2 ); // not needed, see below
		$bos2 = preg_replace( '/math\.rad\([\.0]*\)/', '0', $bos2 );
		return $bos2;
		
	}
	
	
?>
</pre>
<center>
<h1>
Spring Bos to Lua Converter
</h1>
<h2>
Guaranteed to work!*
</h2>
</center>
<span style="color:red; font-size:xx-small; position:fixed; right:20px; top:10px ">
<pre>
$$$$$$$$$$$$$$$$$$$$ZZZZZZZZZZZZZOOOOOO 
$$$$$$$$$$$$$$$$$$$$$ZZZZZZZZZZZZOOOOOO 
$$$$$$$$$$$$$$$$$$77$$ZZZZZZZZZZOOOOOOO 
$$$$$$$$$$$$$$$$7I+ I7$ZZZZZZZZZOOOOOOO 
$$$$$$$$7777$$$7I=   ?7$ZZZ$$$ZZOOOOOOO 
$$$$$$$7I ??IIII      ?I77II  $ZZOOOOOO 
$$$$$$$7I              ?      7ZOOOOOOO 
$$$$$$$7I      II77777II     ?7ZOOOOOOO 
$$$$$$$7I   ?I7$$ZZZZZ$$7I   I7ZOOOOOOO 
$$$$$77I?? ?7$$ZZZZZZZZZZ$7= ?I7$ZZOOOO 
Z$$7I?    ?7$ZZZZZZZZZZZZZ$7     I7$ZOO 
Z$$       I$ZZZZZZZZZZZZZZZ$I       ZOO 
ZZ$7I    ?7$ZZZZZZZZZZZOOOZ$7     7$OOO 
ZZZ$$7I  I$ZZZZZZZZZZOOOOOOZ$   I$ZOOO8 
ZZZZZZ$$$$ZZZZZZZZZOOOOOOOOOZZ$ZZOOOO88 
ZZZZZZZZZZZZZZZZZOOOOOOOOOOOOOOOOOOO888 
ZZZZZZZZZZZZZZOOOOOOOOOOOOOOOOOOOOO8888 
</pre>
</span>

<form action="index.php" method="post">

	<input type=submit value="Convert stupid dumb Bos to amazing awesome Lua" />

	<br />
	<br />

	<b>Bos:</b>
	
	<textarea rows="12" cols="90" name='bos' style="background-color:lightblue; vertical-align:top"><? echo $bos; ?></textarea>

	<br />
	<br />

	<b>Lua:</b>
	
	<textarea rows="12" cols="90" style="background-color:lightgreen; vertical-align:top"><? echo $lua; ?></textarea>

</form>

<div style="font-size:x-small; ">
	*Not a guarantee.
	<span style="right:1px; position:absolute; ">
		Written by CarRepairer
	</span>
</div>

</body>
</html>