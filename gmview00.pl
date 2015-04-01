#!/usr/bin/perl

$path = $ENV{DOCUMENT_ROOT} . "/core";
use Crypt::Blowfish;
eval "use DBI";
BEGIN {
	unshift (@INC,$path);
} 

use handytool;
$| = 1;
$refer = $ENV{HTTP_REFERER};
@thetime = dates();
@theclock = clocks();
$now = "$thetime[0] $thetime[1] $thetime[2] $theclock[0]\:$theclock[1] $ampm"; 
@months = montharray();
%monthtonum = months();
%longmonth = longmonth();

$stamp[1]=$monthtonum{$thetime[1]};
$hidepage = "fullencrypt";
if ($thetime[2] < 10) {
				$stamp[2] = '0' . $thetime[2];
				}
else				{
				$stamp[2] = $thetime[2];
				}

$stamp[3]=$thetime[4];

$record = $stamp[1] . "/" . $stamp[2] . "/" . $stamp[3] . " $theclock[0]\:$theclock[1]\:$theclock[2] $ampm";
%input = retrieval();
$ip = $ENV{REMOTE_ADDR};
$user = $input{'user'};
$password = $input{'password'};
$handle = $input{'handle'};
$password = "Not required" if ($password eq '');
$page = "gmview.pl";
$dbh = interface();
$charview = $input{'viewchar'};

security();

@test=retrieve1();

my $sql = qq{ SELECT title, last, type FROM Handle WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$title, \$last, \$chartype );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT id FROM Location WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$testid );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT leftcarry, rightcarry, bodyworn FROM Location WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$left, \$right, \$body );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT alignment, age, face, personality, description, source FROM Description WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$align, \$age, \$face, \$pers, \$desc, \$source );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT hgp, gp, hxp, xp, mana, jipotens, hp, updategm, gmstamp, NPC FROM Life WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$hgp, \$gp, \$hxp, \$xp, \$mana, \$jipoints, \$hp, \$updategm, \$gmstamp, \$npcstate );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT hand, race, sex, counter, class, special, notes FROM Basics WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$hand, \$race, \$sex, \$counter, \$class, \$specialization, \$notes );
$sth->fetch();
$sth->finish();

$newnotes=$notes;
for ($n = 1; $n < 100; $n++) {
$newnotes =~ s/<BR>/\cM\n/g; 
$newnotes =~ s/\`/\'/;
}

my $sql = qq{ SELECT strength, mental, agility, endurance FROM Stats WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$strength, \$mental, \$agility, \$endurance );
$sth->fetch();
$sth->finish();
$a{'Strength'} = $strength;
$a{'Mental'} = $mental;
$a{'Agility'} = $agility;
$a{'Endurance'} = $endurance;

my $sql = qq{ SELECT leftcarry, rightcarry, bodyworn FROM Location WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$left, \$right, \$body );
$sth->fetch();
$sth->finish();

$c=0;
$m=0;
$p=0;
$r=0;
$o=0;
$g=0;

my $sql = qq{ SELECT id, skill, value  FROM Primaries WHERE (charname = '$charview') ORDER BY skill };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$sid, \$skill, \$value );
while ( $sth->fetch() ) {
$gskill[$g]=$skill;
$gvalue[$g]=$value;
$gid[$g]=$sid;
$g=$g+1;
}
$sth->finish();

my $sql = qq{ SELECT Primaries.id, Primaries.skill, Primaries.value, Skills.Skill_Type, Skills.Skill_Class, Skills.Skill_Desc, Skills.Skill_Stat FROM (Primaries LEFT OUTER JOIN Skills ON Primaries.skill = Skills.Skill_Name) WHERE (Primaries.charname = '$charview') ORDER BY Skills.Skill_Type, Primaries.skill };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$sid, \$skill, \$value, \$type, \$sclass, \$sdesc, \$sstat );
while ( $sth->fetch() ) {

if ($type eq "Combat") {
$combat[$c]=$skill;
$clevel[$c]=$value;
$cclass[$c]=$sclass;
$cdesc[$c]=$sdesc;
$cstat[$c]=$sstat;
$c=$c+1;
}
if ($type eq "Mage") {
$mage[$m]=$skill;
$mlevel[$m]=$value;
$mclass[$m]=$sclass;
$mdesc[$m]=$sdesc;
$mstat[$m]=$sstat;
$m=$m+1;
}
if ($type eq "Priest") {
$priest[$p]=$skill;
$plevel[$p]=$value;
$pclass[$p]=$sclass;
$pdesc[$p]=$sdesc;
$pstat[$p]=$sstat;
$p=$p+1;
}
if ($type eq "Rogue") {
$rogue[$r]=$skill;
$rlevel[$r]=$value;
$rclass[$r]=$sclass;
$rdesc[$r]=$sdesc;
$rstat[$r]=$sstat;
$r=$r+1;
}
if ($type eq "Psi") {
$psi[$y]=$skill;
$ylevel[$y]=$value;
$yclass[$y]=$sclass;
$ydesc[$y]=$sdesc;
$ystat[$y]=$sstat;
$y=$y+1;
}

if ($type eq "Other") {
$other[$o]=$skill;
$olevel[$o]=$value;
$oclass[$o]=$sclass;
$odesc[$o]=$sdesc;
$ostat[$o]=$sstat;
$o=$o+1;
}
}
$sth->finish();

my $sql = qq{ SELECT charname FROM Specials WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$spectest );
$sth->fetch();
$sth->finish();

if ($spectest eq '') {
$specskill = "Contact GM To Create";
$specdesc = "To Be Approved - You must find a GM and submit a Jipotens Talent proposal.";
$speclevel = 25;
$dbh->do("INSERT INTO Specials (charname, skillname, skilldesc, level) VALUES (" . 
$dbh->quote($charview) . "," . 
$dbh->quote($specskill) . "," .
$dbh->quote($specdesc) . "," .
$dbh->quote($speclevel) . ")")
|| die "Couldn't add record, " . $dbh->errstr();
}

$jlevelxp = int($speclevel * .1) + 1;
if ($jlevelxp > 5) {
$jlevelxp = ($jlevelxp - 5) * $jlevelxp;
}
$jlevelmax = (((int($speclevel * .1) + 1) * 10) - $speclevel) * $jlevelxp;

my $sql = qq{ SELECT id, skillname, skilldesc, level FROM Specials WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$specid, \$specskill, \$specdesc, \$speclevel );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT id, sec, secdesc FROM Secondaries WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$secid, \$sec, \$secdesc );
$s=0;
while ( $sth->fetch() ) {
$secid[$s]=$secid;
$sec[$s]=$sec;
$secdesc[$s]=$secdesc;
$s=$s+1;
}
$sth->finish();

my $sql = qq{ SELECT id, language FROM Languages WHERE (charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$langid, \$language );
$l=0;
while ( $sth->fetch() ) {
$langid[$l]=$langid;
$language[$l]=$language;
$l=$l+1;
}
$sth->finish();

$sql = qq { select Skill_Name, Skill_Type from Skills ORDER BY Skill_Name };
$sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$sth->bind_columns( \$skillname, \$skilltype );
while( $sth->fetch() ) {
$smenu = $smenu . "<option value=\"$skillname\">$skillname ($skilltype)</option>\n";
}
$sth->finish();

$sql = qq { select tongue from Tongues ORDER BY tongue };
$sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$sth->bind_columns( \$tongue );
while( $sth->fetch() ) {
$tmenu = $tmenu . "<option value=\"$tongue\">$tongue</option>\n";
}
$sth->finish();

$ww=0;
my $sql = qq{ SELECT Offense.id, Offense.weapon, Offense.plus, Offense.comments, Offense.quantity, Weapons.weight, Weapons.speed, Weapons.SM, Weapons.L FROM Offense INNER JOIN Weapons ON Offense.weapon = Weapons.name WHERE (Offense.charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$oid, \$oweapon, \$oplus, \$ocomments, \$oquan, \$wweight, \$wspeed, \$wsm, \$wl );
while ( $sth->fetch() ) {
$oid[$ww] = $oid;
$oweapon[$ww] = $oweapon;
$oplus[$ww] = $oplus;
$ocomments[$ww] = $ocomments;
$oquan[$ww] = $oquan;
$wweight[$ww] = $wweight * $oquan;
$wspeed[$ww] = $wspeed;
$wsm[$ww] = $wsm;
$wl[$ww] = $wl;
$ww=$ww+1;
}
$sth->finish();

$aa=0;
my $sql = qq{ SELECT Defense.id, Defense.armor, Defense.plus, Defense.comments, Defense.quantity, Armor.weight, Armor.penalty, Armor.reduction FROM Defense INNER JOIN Armor ON Defense.armor = Armor.armor WHERE (Defense.charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$did, \$darmor, \$dplus, \$dcomments, \$dquan, \$aweight, \$apenalty, \$areduction );
while ( $sth->fetch() ) {
$did[$aa] = $did;
$darmor[$aa] = $darmor;
$dplus[$aa] = $dplus;
$dcomments[$aa] = $dcomments;
$dquan[$aa] = $dquan;
$aweight[$aa] = $aweight * $dquan;
$apenalty[$aa] = $apenalty;
$areduction[$aa] = $areduction;
$aa=$aa+1;
}
$sth->finish();

$ee=0;
my $sql = qq{ SELECT Items.id, Items.name, Items.plus, Items.comments, Items.quantity, Equipment.weight FROM Items LEFT OUTER JOIN Equipment ON Items.name = Equipment.equip WHERE (Items.charname = '$charview') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$pid, \$pname, \$pplus, \$pcomments, \$pquan, \$eweight );
while ( $sth->fetch() ) {
$pid[$ee] = $pid;
$pname[$ee] = $pname;
$pplus[$ee] = $pplus;
$pcomments[$ee] = $pcomments;
$pquan[$ee] = $pquan;
$eweight[$ee] = $eweight * $pquan;
$ee=$ee+1;
}
$sth->finish();

$dbh->disconnect();

$level = 1 if ($hxp < 100);
$level = 2 if ($hxp > 24 && $hxp < 50);
$level = 3 if ($hxp > 49 && $hxp < 75);
$level = 4 if ($hxp > 74 && $hxp < 100);
$level = 5 if ($hxp > 99 && $hxp < 125);
$level = 6 if ($hxp > 124 && $hxp < 150);
$level = 7 if ($hxp > 149 && $hxp < 175);
$level = 8 if ($hxp > 174 && $hxp < 200);
$level = 9 if ($hxp > 199 && $hxp < 250);
$level = 10 if ($hxp > 249 && $hxp < 300);
$level = 11 if ($hxp > 299 && $hxp < 350);
$level = 12 if ($hxp > 349 && $hxp < 400);
$level = 13 if ($hxp > 399 && $hxp < 450);
$level = 14 if ($hxp > 449 && $hxp < 500);
$level = 15 if ($hxp > 499 && $hxp < 600);
$level = 16 if ($hxp > 599 && $hxp < 800);
$level = 17 if ($hxp > 799 && $hxp < 1200);
$level = 18 if ($hxp > 1199 && $hxp < 1600);
$level = 19 if ($hxp > 1599 && $hxp < 2000);
$level = 20 + int (($hxp - 2000) / 400) if ($hxp > 1999);

$combat=int($level*5) if ($class eq "Fighter");
$combat=int($level*4) if ($class eq "Ranger");
$combat=int($level*4) if ($class eq "Paladin");
$combat=int($level*4.5) if ($class eq "Cavalier");
$combat=int($level*5.5) if ($class eq "Hun");
$combat=int($level*1) if ($class eq "Mage");
$combat=int($level*3) if ($class eq "Cleric");
$combat=int($level*3) if ($class eq "Animist");
$combat=int($level*4) if ($class eq "Martial Clerist");
$combat=int($level*3.5) if ($class eq "Rogue");
$combat=int($level*3.5) if ($class eq "Assassin");
$combat=int($level*3) if ($class eq "Scout");
$combat=int($level*3.5) if ($class eq "Bard");
$combat=int($level*3.75) if ($class eq "Fightermage");
$combat=int($level*2.5) if ($class eq "Psionicist");

$mage=int($level*1) if ($class eq "Fighter");
$mage=int($level*3) if ($class eq "Ranger");
$mage=int($level*2) if ($class eq "Paladin");
$mage=int($level*2) if ($class eq "Cavalier");
$mage=int($level*1) if ($class eq "Hun");
$mage=int($level*5) if ($class eq "Mage");
$mage=int($level*2) if ($class eq "Cleric");
$mage=int($level*3) if ($class eq "Animist");
$mage=int($level*3) if ($class eq "Martial Clerist");
$mage=int($level*2) if ($class eq "Rogue");
$mage=int($level*2) if ($class eq "Assassin");
$mage=int($level*3) if ($class eq "Scout");
$mage=int($level*3.5) if ($class eq "Bard");
$mage=int($level*3.75) if ($class eq "Fightermage");
$mage=int($level*3) if ($class eq "Psionicist");

$priest=int($level*2) if ($class eq "Fighter");
$priest=int($level*3) if ($class eq "Ranger");
$priest=int($level*4) if ($class eq "Paladin");
$priest=int($level*2) if ($class eq "Cavalier");
$priest=int($level*3.5) if ($class eq "Hun");
$priest=int($level*2) if ($class eq "Mage");
$priest=int($level*5) if ($class eq "Cleric");
$priest=int($level*4.75) if ($class eq "Animist");
$priest=int($level*4.5) if ($class eq "Martial Clerist");
$priest=int($level*1) if ($class eq "Rogue");
$priest=int($level*2) if ($class eq "Assassin");
$priest=int($level*1) if ($class eq "Scout");
$priest=int($level*3) if ($class eq "Bard");
$priest=int($level*3) if ($class eq "Fightermage");
$priest=int($level*3) if ($class eq "Psionicist");

$rogue=int($level*3) if ($class eq "Fighter");
$rogue=int($level*3.5) if ($class eq "Ranger");
$rogue=int($level*1) if ($class eq "Paladin");
$rogue=int($level*1) if ($class eq "Cavalier");
$rogue=int($level*4) if ($class eq "Hun");
$rogue=int($level*1) if ($class eq "Mage");
$rogue=int($level*1) if ($class eq "Cleric");
$rogue=int($level*2) if ($class eq "Animist");
$rogue=int($level*3) if ($class eq "Martial Clerist");
$rogue=int($level*3) if ($class eq "Fightermage");
$rogue=int($level*5) if ($class eq "Rogue");
$rogue=int($level*4.5) if ($class eq "Assassin");
$rogue=int($level*5) if ($class eq "Scout");
$rogue=int($level*4) if ($class eq "Bard");
$rogue=int($level*3.5) if ($class eq "Psionicist");

$psi=int($level*3.5) if ($class ne "Psionicist");
$psi=int($level*5) if ($class eq "Psionicist");

$jipotens=int($level*3.5);
$other=int($level*4);

if ($level < 11) {
$hlevel = $level;
}
else {
$hlevel = 10 + ($level * .1);
} 

if ($class eq "Fighter" || $class eq "Cavalier") {
$mhp = int($hlevel*9)+9;
$maxmana = int($hlevel*2.5)+10;
}

if ($class eq "Ranger" || $class eq "Paladin" || $class eq "Hun") {
$mhp = int($hlevel*8)+8;
$maxmana = int($hlevel*2.5)+10;
}

if ($class eq "Martial Clerist") {
$mhp = int($hlevel*8)+8;
$maxmana = int($hlevel*8)+10;
}

if ($class eq "Mage") {
$mhp = int($hlevel*5)+5;
$maxmana = int($hlevel*10)+10;
}

if ($class eq "Cleric") {
$mhp = int($hlevel*7)+7;
$maxmana = int($hlevel*9)+10;
}

if ($class eq "Scout" || $class eq "Assassin") {
$mhp = int($hlevel*7)+7;
$maxmana = int($hlevel*5)+10;
}

if ($class eq "Rogue") {
$mhp = int($hlevel*6)+6;
$maxmana = int($hlevel*5)+10;
}

if ($class eq "Animist" || $class eq "Fightermage") {
$mhp = int($hlevel*6)+6;
$maxmana = int($hlevel*8)+10;
}

if ($class eq "Psionicist" || $class eq "Bard") {
$mhp = int($hlevel*6)+6;
$maxmana = int($hlevel*8)+10;
}

web();

#####################################################################################
#  BEGIN SHEET SECTION											#
#####################################################################################

$npcstatus = "NPC" if ($npcstate eq "Yes");

if ($input{'edit'} eq "sheet") {
print <<END;
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<link rel=STYLESHEET href="../style5.css" type="text/css">

<title>Sheetview for $charview</title>
</head>
<body bgcolor="#eeeeff">

END

if ($face ne '') {
print <<END;
<table border="1" cellspacing="0" cellpadding="8" 
bgcolor="#000000" bordercolorlight="#000000" 
bordercolordark="#000000" align="center" background="../images/bg5.jpg">
<tr><td align="center"><img src="../pictures/$face" alt="$charview"></td></tr></table><br><br>
END
}

print <<END;
<table border="1" cellspacing="0" cellpadding="8" 
bgcolor="#000000" bordercolorlight="#000000" 
bordercolordark="#000000" align="center" background="../images/bg5.jpg">
<tr><td align="center"<p><font size="4">$npcstatus Character Sheet for $charview
</font></td></tr></table>
<br><br>
<table width="100%">

<tr><td width="20%"><p><b>Name</b></p></td>

<td><p>$title $charview $last</p></td>

<td width="20%"><p><b>Race</b></p></td>

<td><p>$race</p></td></tr>

<tr><td width="20%"><p><b>Class</b></p></td>

<td><p>$class</p></td>

<td width="20%"><p><b>Sex</b></p></td>

<td><p>$sex</p></td></tr>

<tr><td width="20%"><p><b>Historical XP</b></p></td>

<td><p>$hxp</p></td>

<td width="20%"><p><b>Current XP</b></p></td>

<td><p>$xp</p></td></tr>

<tr><td width="20%"><p><b>Strength</b></p></td>

<td><p>$strength</p></td>

<td width="20%"><p><b>Handedness</b></p></td>

<td><p>$hand</p></td></tr>

<tr><td width="20%"><p><b>Mental</b></p></td>

<td><p>$mental</p></td>

<td width="20%"><p><b>Specialization</b></p></td>

<td><p>$specialization</p></td></tr>

<tr><td width="20%"><p><b>Agility</b></p></td>

<td><p>$agility</p></td>

<td width="20%"><p><b>Armor Worn</b></p></td>

<td><p>$body</tr>

<tr><td width="20%"><p><b>Endurance</b></p></td>

<td><p>$endurance</p></td>

<td width="20%"><p><b>Current HP</b></p></td>

<td><p>$hp</p></td></tr>

<tr><td width="20%"><p><b>Right Hand</b></p></td>

<td>$right</td>

<td width="20%"><p><b>Left Hand</b></p></td>

<td>$left</td></tr>
<tr><td width="20%"><p><b>Alignment</b></p></td>

<td>$align</td>

<td width="20%"><p><b>Face Source</b></p></td>

<td>$source</td></tr>
END

$dodge=int((($agility+$combat)/2)+0.5);

print <<END;
<tr><td><p><b>Level</b></p></td><td>
<p>$level</p></td>
<td><p><b>Hit Points</b></p></td><td>
<p>$mhp</p></td></tr>
<tr><td><p><b>Current Spirit Points</b></p></td><td>
<p>$mana</p></td>
<td><p><b>Spirit Points</b></p></td><td>
<p>$maxmana</p></td></tr>
<tr><td><p><b>Historical Gold</b></p></td><td>
<p>$hgp</p></td>
<td><p><b>Gold</b></p></td><td>
<p>$gp</p></td></tr>
<tr><td><p><b>Age</b></p></td><td>
<p>$age</p></td>
<td><p><b>Dodge</b></p></td><td>
<p>$dodge</p></td></tr>
<tr><td><p><b>Max Ji Points</b></p></td><td>
<p>$maxmana</p></td>
<td><p><b>Current Ji Points</b></p></td><td>
<p>$jipoints</p></td></tr>
<tr><td valign="top"><p><b>Personality</b></p></td><td valign="top">
<p>$pers</p></td>
<td valign="top"><p><b>Description</b></p></td><td valign="top">
<p>$desc</p></td></tr>
</table>

<br><b>Jipotens Talent</b>

(<b>JIPOTENS LEVEL</b>: $jipotens)

<br>
<table width=100%>

<tr><td width="20%" valign="top"><p>$specskill (JN)</p></td>
<td width="80%" valign="top"><p>$speclevel</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$specdesc</p></td></tr>
</table>


<br><b>Combat Skills</b>

(<b>COMBAT LEVEL</b>: $combat; <b># of skills:</b> $c)

<br>
<table width=100%>
END

for ($u=0; $u<$c; $u++) {
$cstat=$cstat[$u];
$cattempt=int(($a{$cstat}+$combat+$clevel[$u])/3);
$cdattempt="";
$cbattempt="";
if ($cclass[$u] eq "FH" || $combat[$u] eq "Warrior Acrobatics") {
$dattempt=int((($a{$cstat}+$combat+$clevel[$u])/3)+0.5);
$cdattempt=" <b>Dodge:</B> $dattempt";
}
if ($combat[$u] eq "Shield") {
$battempt=int((($a{$cstat}+$combat+$clevel[$u])/3)+0.5);
$cbattempt=" <b>Block:</B> $battempt";
}
print <<END;
<tr><td width="20%" valign="top"><p>$combat[$u] ($cclass[$u])</p></td>
<td width="80%" valign="top"><p>$clevel[$u] (<b>Attempt:</b> $cattempt$cdattempt$cbattempt)</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$cdesc[$u]</p></td></tr>
END
}

print <<END;
</table>
END

if ($m > 0) {

print <<END;
<br><b>Mage Skills</b>

(<b>MAGE LEVEL</b>: $mage; <b># of skills:</b> $m)

<br>
<table width=100%>
END

for ($u=0; $u<$m; $u++) {
$mstat=$mstat[$u];
$mattempt=int(($a{$mstat}+$mage+$mlevel[$u])/3);
print <<END;
<tr><td width="20%" valign="top"><p>$mage[$u] ($mclass[$u])</p></td>
<td width="80%" valign="top"><p>$mlevel[$u] (<b>Attempt:</b> $mattempt)</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$mdesc[$u]</p></td></tr>
END
}

print <<END;
</table>
END

}


if ($p > 0) {

print <<END;
<br><b>Priest Skills</b>

(<b>PRIEST LEVEL</b>: $priest; <b># of skills:</b> $p)

<br>
<table width=100%>
END

for ($u=0; $u<$p; $u++) {
$pstat=$pstat[$u];
$pattempt=int(($a{$pstat}+$priest+$plevel[$u])/3);
print <<END;
<tr><td width="20%" valign="top"><p>$priest[$u] ($pclass[$u])</p></td>
<td width="80%" valign="top"><p>$plevel[$u] (<b>Attempt:</b> $pattempt)</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$pdesc[$u]</p></td></tr>
END
}

print <<END;
</table>
END

}

if ($y > 0) {

print <<END;
<br><b>Psionic Skills</b>

(<b>PSI LEVEL</b>: $psi; <b># of skills:</b> $y)

<br>
<table width=100%>
END

for ($u=0; $u<$y; $u++) {
$ystat=$ystat[$u];
$yattempt=int(($a{$ystat}+$psi+$ylevel[$u])/3);
print <<END;
<tr><td width="20%" valign="top"><p>$psi[$u] ($yclass[$u])</p></td>
<td width="80%" valign="top"><p>$ylevel[$u] (<b>Attempt:</b> $yattempt)</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$ydesc[$u]</p></td></tr>
END
}

print <<END;
</table>
END

}

if ($r > 0) {

print <<END;
<br><b>Rogue Skills</b>

(<b>ROGUE LEVEL</b>: $rogue; <b># of skills:</b> $r)

<br>
<table width=100%>
END

for ($u=0; $u<$r; $u++) {
$rstat=$rstat[$u];
$rattempt=int(($a{$rstat}+$rogue+$rlevel[$u])/3);
print <<END;
<tr><td width="20%" valign="top"><p>$rogue[$u] ($rclass[$u])</p></td>
<td width="80%" valign="top"><p>$rlevel[$u] (<b>Attempt:</b> $rattempt)</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$rdesc[$u]</p></td></tr>
END
}

print <<END;
</table>
END

}

print <<END;
<br><b>Other Skills</b>

(<b>OTHER LEVEL</b>: $other; <b># of skills:</b> $o)

<br>
<table width=100%>
END

for ($u=0; $u<$o; $u++) {
$ostat=$ostat[$u];
$oattempt=int(($a{$ostat}+$other+$olevel[$u])/3);
print <<END;
<tr><td width="20%" valign="top"><p>$other[$u] ($oclass[$u])</p></td>
<td width="80%" valign="top"><p>$olevel[$u] (<b>Attempt:</b> $oattempt)</p></td></tr>
<tr><td valign="top"></td><td valign="top"><p>$odesc[$u]</p></td></tr>
END
}

print <<END;
</table>

<br><b>Secondary Skills</b>
(<b># of skills:</b> $s)<br>
<table width=100%>
END

for ($u=0; $u<$s; $u++) {
print <<END;
<tr><td><p>$sec[$u]</p></td>
<td><p>$secdesc[$u]</p></td></tr>
END
}

print <<END;
</table>

<br><b>Languages</b>
(<b># of languages:</b> $l)<br>
<table width=100%>
END

for ($u=0; $u<$l; $u++) {
print <<END;
<tr><td><p>$language[$u]</p></td></tr>
END
}

print <<END;
</table>
<br><b>Armor, Helmets and Shields</b>
(<b># of Lines:</b> $aa)<br>
<table width=100%>
END

for ($u=0; $u<$aa; $u++) {
print <<END;
<tr><td>$dquan[$u] <b>$darmor[$u]</b>$dplus[$u]</td><td><b>Penalty:</b> $apenalty[$u]</td><td><b>Weight:</b> $aweight[$u]</td><td><b>Reduction:</b> $areduction[$u]</td><td><b>Notes: </b>$dcomments[$u]</td></tr>
END
}

print <<END;
</table>
<br><b>Weapons</b>
(<b># of Lines:</b> $ww)<br>
<table width=100%>
END

for ($u=0; $u<$ww; $u++) {
print <<END;
<tr><td>$oquan[$u] <b>$oweapon[$u]</b>$oplus[$u]</td><td><b>Wt:</b> $wweight[$u]</td><td><b>Speed:</b> $wspeed[$u]</td><td><b>SM:</b> $wsm[$u]$oplus[$u]</td><td><b>L:</b> $wl[$u]$oplus[$u]</td><td><b>Notes: </b>$ocomments[$u]</td></tr>
END
}

print <<END;
</table>
<br><b>Equipment</b>
(<b># of Lines:</b> $ee)<br>
<table width=100%>
END

for ($u=0; $u<$ee; $u++) {
print <<END;
<tr><td>$pquan[$u] <b>$pname[$u]</b>$pplus[$u]</td><td><b>Weight: </b>$eweight[$u]</td><td><b>Notes: </b>$pcomments[$u]</td></tr>
END
}

print <<END;
</table>
<br>
<table width=100%>
<tr><td><b>Notes from GM to Player</b></td></tr>
<tr><td>$notes</td></tr>
</table>
</p>
</body>
</html>
END
}

#####################################################################################
#                              BEGIN EDITING SECTION						#
#####################################################################################

if ($input{'edit'} eq "editing") {
print <<END;
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<link rel=STYLESHEET href="../style5.css" type="text/css">
<style>
textarea.imageOne{
background-color:FFFFFF;
background-image:url(../images/bg5.jpg);
color:000000;
}
textarea.imageTwo{
background-color:FFFFFF;
color:000044;
}
</style>
<title>Editview for $charview</title>
</head>
<body bgcolor="#eeeeff">
<form name="gmview" action="gmchange.pl" method="POST">
END

if ($face ne '') {
print <<END;
<table border="1" cellspacing="0" cellpadding="8" 
bgcolor="#000000" bordercolorlight="#000000" 
bordercolordark="#000000" align="center" background="../images/bg5.jpg">
<tr><td align="center"><img src="../pictures/$face" alt="$charview"></td></tr></table><br><br>
END
}

print <<END;
<table border="1" cellspacing="0" cellpadding="8" 
bgcolor="#000000" bordercolorlight="#000000" 
bordercolordark="#000000" align="center" background="../images/bg5.jpg">
<tr><td align="center"<p><font size="4">$npcstatus Editview for $charview
</font></td></tr></table>
<br><br>
<table width="100%">

<tr><td width="20%"><p><b>Name</b></p></td>

<td><p>$title $charview $last</p></td>

<td width="20%"><p><b>Race</b></p></td>

<td><p>$race</p></td></tr>

<tr><td width="20%"><p><b>Class</b></p></td>

<td><p>$class</p></td>

<td width="20%"><p><b>Sex</b></p></td>

<td><p>$sex</p></td></tr>

<tr><td width="20%"><p><b>Historical XP</b></p></td>

<td><p>$hxp</p></td>

<input type="hidden" name="hxp" value="$hxp">

<td width="20%"><p><b>Current XP</b></p></td>

<td><p><input type="text" name="xp" value="$xp"></p></td></tr>

<input type="hidden" name="oldxp" value="$xp">

<tr><td width="20%"><p><b>Strength</b></p></td>

<td><p><input type="text" name="strength" value="$strength"></p></td>

<td width="20%"><p><b>Handedness</b></p></td>

<td><p>$hand</p></td></tr>

<tr><td width="20%"><p><b>Mental</b></p></td>

<td><p><input type="text" name="mental" value="$mental"></p></td>

<td width="20%"><p><b>Specialization</b></p></td>

<td><p>$specialization</p></td></tr>

<tr><td width="20%"><p><b>Agility</b></p></td>

<td><p><input type="text" name="agility" value="$agility"></p></td>

<td width="20%"><p><b>Armor Worn</b></p></td>

<td><p>$body</tr>

<tr><td width="20%"><p><b>Endurance</b></p></td>

<td><p><input type="text" name="endurance" value="$endurance"></p></td>

<td width="20%"><p><b>Current HP</b></p></td>

<td><p><input type="text" name="hp" value="$hp"></p></td></tr>

<tr><td width="20%"><p><b>Right Hand</b></p></td>

<td>$right</td>

<td width="20%"><p><b>Left Hand</b></p></td>

<td>$left</td></tr>
END



print <<END;
<tr><td><p><b>Level</b></p></td><td>
<p>$level</p></td>
<td><p><b>Hit Points</b></p></td><td>
<p>$mhp</p></td></tr>
<tr><td><p><b>Current Spirit Points</b></p></td><td>
<p><input type="text" name="mana" value="$mana"></p></td>
<td><p><b>Spirit Points</b></p></td><td>
<p>$maxmana</p></td></tr>
<tr><td><p><b>Historical Gold</b></p></td>
<td>
<p>$hgp</p></td>
<input type="hidden" name="hgp" value="$hgp">
<td><p><b>Gold</b></p></td><td>
<p><input type="text" name="gp" value="$gp"></p></td></tr>
<input type="hidden" name="oldgp" value="$gp">
<tr><td><p><b>Age</b></p></td><td>
<p>$age</p></td>
<td><p><b>NPC?</b></p></td><td>
<p><input type="text" name="npcstate" value="$npcstate"></p></td></tr>
<tr><td><p><b>Max Ji Points</b></p></td><td>
<p>$maxmana</p></td>
<td><p><b>Current Ji Points</b></p></td><td>
<p><input type="text" name="jipoints" value="$jipoints"></p></td></tr>
<tr><td valign="top"><p><b>Personality</b></p></td><td valign="top">
<p>$pers</p></td>
<td valign="top"><p><b>Description</b></p></td><td valign="top">
<p>$desc</p></td></tr>
</table>

<br><b>Jipotens Talent Section</b>
<br><br>
<table width=100%>
<tr><td><b>Jipotens Title</b></td><td><b>Jipotens Description</b></td><td><b>Jipotens Level</b></td></tr>
<tr><td width="20%" valign="top"><p><input type="text" name="newspecname" value="$specskill" size="40">
</p></td>
<td width="30%" valign="top"><p><textarea name="newspecdesc" rows="8" cols="46"
onkeyup="update();" tabindex="1" style="overflow:hidden;" class="imageOne"
 onMouseOver="this.className='imageTwo'"
 onMouseOut="this.className='imageOne'">$specdesc
</textarea></p>
</td><td width="50%" valign="top"><p><input type="text" name="newspeclevel" value="$speclevel"></p>
</td></tr>
<input type="hidden" name="specid" value="$specid">
</table>
END

$toencrypt1 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Skill&method=Add";
$nowencrypt1 = Encrypt($toencrypt1);

print <<END;
<br><b>Skills</b>

(<b># of skills:</b> $g) <a href="langedit.pl?$nowencrypt1" target="_self">Add Skill</a>

<br>
<table width=100%>
END

for ($u=0; $u<$g; $u++) {
print <<END;
<tr><td width="20%"><p><select name="skill$u">
<option value="$gskill[$u]">$gskill[$u] - Selected</option>
$smenu
</select>
</p></td>
<td width="80%"><p><input type="text" name="svalue$u" value="$gvalue[$u]"></p>
</td></tr>
<input type="hidden" name="sid$u" value="$gid[$u]">
END
}

print <<END;
<input type="hidden" name="skillmax" value="$u">
</table>
END

print <<END;
<br><b>Secondary Skills</b>
(<b># of skills:</b> $s)<br>
<table width=100%>
END

for ($u=0; $u<$s; $u++) {
print <<END;
<tr><td width="20%"><p><input type="text" name="sec$u" value="$sec[$u]"></p></td>
<td width="80%"><p><input type="text" size="80" name="secdesc$u" value="$secdesc[$u]"></p>
</td></tr>
<input type="hidden" name="secid$u" value="$secid[$u]">
END
}

$toencrypt1 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Language&method=Add";
$nowencrypt1 = Encrypt($toencrypt1);

print <<END;
<input type="hidden" name="secmax" value="$s">
</table>

<br><b>Languages</b> 
(<b># of languages:</b> $l) <a href="langedit.pl?$nowencrypt1" target="_self">Add Language</a><br>
<table width=100%>
END

for ($u=0; $u<$l; $u++) {
print <<END;
<tr><td width="20%"><p><select name="language$u">
<option value="$language[$u]">$language[$u] - Selected</option>
$tmenu
</select>
</p></td>
<td width="80%"><p><input type="hidden" name="langid$u" value="$langid[$u]">
</td></tr>
<input type="hidden" name="langmax" value="$l">
END
}

$toencrypt1 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Armor&method=Add";
$nowencrypt1 = Encrypt($toencrypt1);
$toencrypt2 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Armor&method=Edit";
$nowencrypt2 = Encrypt($toencrypt2);
$toencrypt3 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Armor&method=Delete";
$nowencrypt3 = Encrypt($toencrypt3);

print <<END;
</table>
<br><b>Armor</b> <a href="weaponedit.pl?$nowencrypt1" target="_self">Add Armor</a>&nbsp;&nbsp;<a href="weaponedit.pl?$nowencrypt2" target="_self">Edit Armor</a>&nbsp;&nbsp;<a href="weaponedit.pl?$nowencrypt3" target="_self">Delete Armor</a><br>
<table>
END

for ($u=0; $u<$aa; $u++) {
print <<END;
<tr><td valign="top" width="20%">$dquan[$u] <b>$darmor[$u]</b>$dplus[$u]</td><td valign="top"><b>Penalty:</b> $apenalty[$u]</td><td valign="top"><b>Weight:</b> $aweight[$u]</td><td valign="top"><b>Reduction:</b> $areduction[$u]</td><td valign="top"><b>Notes: </b>$dcomments[$u]</td></tr>
END
}

$toencrypt1 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Weapon&method=Add";
$nowencrypt1 = Encrypt($toencrypt1);
$toencrypt2 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Weapon&method=Edit";
$nowencrypt2 = Encrypt($toencrypt2);
$toencrypt3 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Weapon&method=Delete";
$nowencrypt3 = Encrypt($toencrypt3);

print <<END;
</table>
<br>
<br><b>Weapons</b> <a href="weaponedit.pl?$nowencrypt1" target="_self">Add Weapon</a>&nbsp;&nbsp;<a href="weaponedit.pl?$nowencrypt2" target="_self">Edit Weapon</a>&nbsp;&nbsp;<a href="weaponedit.pl?$nowencrypt3" target="_self">Delete Weapon</a><br>
<table width="100%">
END

for ($u=0; $u<$ww; $u++) {
print <<END;
<tr><td valign="top" width="20%">$oquan[$u] <b>$oweapon[$u]</b>$oplus[$u]</td><td valign="top"><b>Speed:</b> $wspeed[$u]</td><td valign="top"><b>SM:</b> $wsm[$u]$oplus[$u]</td><td valign="top"><b>L:</b> $wl[$u]$oplus[$u]</td><td valign="top"><b>Notes: </b>$ocomments[$u]</td></tr>
END
}

$toencrypt1 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Equipment&method=Add";
$nowencrypt1 = Encrypt($toencrypt1);
$toencrypt2 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Equipment&method=Edit";
$nowencrypt2 = Encrypt($toencrypt2);
$toencrypt3 = "user=$user&password=$password&handle=$handle&viewchar=$charview&style=Equipment&method=Delete";
$nowencrypt3 = Encrypt($toencrypt3);

print <<END;
</table>
<br>
<br><b>Equipment</b> <a href="weaponedit.pl?$nowencrypt1" target="_self">Add Equipment</a>&nbsp;&nbsp;<a href="weaponedit.pl?$nowencrypt2" target="_self">Edit Equipment</a>&nbsp;&nbsp;<a href="weaponedit.pl?$nowencrypt3" target="_self">Delete Equipment</a><br>
<table width="100%">
END

for ($u=0; $u<$ee; $u++) {
print <<END;
<tr><td valign="top" width="20%">$pquan[$u] <b>$pname[$u]</b>$pplus[$u]</td><td valign="top"><b>Weight: </b>$eweight[$u]</td><td valign="top"><b>Notes: </b>$pcomments[$u]</td></tr>
END
}

print <<END;
</table>
<br>
<table width=100%>
<tr><td><b>Notes from GM to Player</b></td></tr>
<tr><td><textarea name="newnotes" rows="4" cols="80">$newnotes</textarea><br><br></td></tr>
</table>
<table width="100%">

<tr><td colspan="2"><br><br><b>Last Updated By:</b> $updategm</td></tr>
<tr><td colspan="2"><b>On:</b> $gmstamp</td></tr>
<tr><td colspan="2" align="center"><input type="submit" name="submit" value="Submit"></td></tr>
</table>
</p>
<input type="hidden" value="submission" name="subcheck">
<input type="hidden" name="viewchar" value="$charview">
<input type="hidden" name="user" value="$user">
<input type="hidden" name="password" value="$password">
<input type="hidden" name="handle" value="$handle">
</form>
</body>
</html>
END

}

exit 0;