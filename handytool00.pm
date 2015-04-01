
# Central repository. #
 
sub interface {
$dbh = DBI->connect("DBI:mysql:my_db_engine:mysql.yourserver.com","your_site_admin","z1x2v3b4") || die "failed to connect to database\n";
return $dbh;
}

sub retrieve1 {

my $sql = qq{ SELECT title, last, type FROM Handle WHERE (charname = '$handle') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$test[0], \$test[1], \$test[2] );
$sth->fetch();
$sth->finish();

my $sql = qq{ SELECT face, age FROM Description WHERE (charname = '$handle') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$test[3], \$test[5] );
$sth->fetch();
$sth->finish();


my $sql = qq{ SELECT race FROM Basics WHERE (charname = '$handle') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$test[4] );
$sth->fetch();
$sth->finish();

$test[4] = "Dream" if ($test[2] eq 'NPC');
$test[4] = "Immortal" if ($test[2] eq 'GM' || $test[2] eq 'GH');

return @test;
}



sub update1 {
my ($query) = "UPDATE Occupant SET expirytime = " .
time . ", " .
"secstamp = " . $dbh->quote($record) . ", " .
"type = " . $dbh->quote($test[2]) . " " .
"WHERE charname = " . $dbh->quote($handle);
$dbh->do($query) || die "no";
}

sub retrieve2 {
print "";
my $sql = qq{ SELECT room FROM Occupant WHERE (charname = '$handle') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$location );
$sth->fetch();
$sth->finish();
return $location;
}

sub retrieve3 {
my $sql = qq{ SELECT charname FROM Occupant WHERE room = '$location' AND expirytime > $deadline}; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$sth->bind_columns( \$charname );
$s=0;
while ($sth->fetch()) {
print "";
$listname[$s] = $charname;
$s = $s + 1;
}
$sth->finish();
print "";
return @listname;
}

sub retrieve3a {
my $sql = qq{ SELECT type FROM Occupant WHERE room = '$location' AND expirytime > $deadline}; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$sth->bind_columns( \$type );
$s=0;
while ($sth->fetch()) {
print "";
$listtype[$s] = $type;
$s = $s + 1;
}
$sth->finish();
print "";
return @listtype;
}

sub retrieve4 {
my $sql = qq{ SELECT room FROM Rooms ORDER BY room }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$s=0;
while ($roomname=$sth->fetchrow) {
print "";
$roomname[$s] = $roomname;
$s = $s + 1;
}
$sth->finish();
print "";
return @roomname;
}

sub retrieve4a {
my $sql = qq{ SELECT room FROM Rooms ORDER BY room }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$s=0;
while ($roomname=$sth->fetchrow) {
$roomselect = $roomselect . "<option value=\"$roomname\">$roomname</option>";
}
$sth->finish();

return $roomselect;
}

sub retrieve4b {
my $sql = qq{ SELECT DISTINCT region FROM Rooms ORDER BY region }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$s=0;
while ($region=$sth->fetchrow) {
$regionselect = $regionselect . "<option value=\"$region\">$region</option>";
}
$sth->finish();

return $regionselect;
}


sub retrieve5 {
my $sql = qq{ SELECT counter,daycount,day FROM Basics WHERE (charname = '$handle') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$counter[0], \$counter[1], \$counter[2] );
$sth->fetch();
$sth->finish();
print "";
return @counter;
}

sub retrieve6 {
$face="";
my $sql = qq{ SELECT face FROM Description WHERE (charname = '$posthandle[$u]') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$face );
$sth->fetch();
$sth->finish();
return $face;
}

sub retrieve6a {
$face="";
my $sql = qq{ SELECT face FROM Description WHERE (charname = '$handle') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$face );
$sth->fetch();
$sth->finish();
return $face;
}

sub retrieve7 {
my $sql = qq{ SELECT name FROM Weapons ORDER BY name }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$s=0;
while ($weapon=$sth->fetchrow) {
$weaponselect = $weaponselect . "<option value=\"$weapon\">$weapon</option>";
}
$sth->finish();

return $weaponselect;
}

sub retrieve7a {
my $sql = qq{ SELECT armor FROM Armor ORDER BY armor }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$s=0;
while ($armor=$sth->fetchrow) {
$armorselect = $armorselect . "<option value=\"$armor\">$armor</option>";
}
$sth->finish();

return $armorselect;
}

sub retrieve7b {
my $sql = qq{ SELECT equip FROM Equipment ORDER BY equip }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";
$s=0;
while ($equip=$sth->fetchrow) {
$equipselect = $equipselect . "<option value=\"$equip\">$equip</option>";
}
$sth->finish();

return $equipselect;
}

sub months {
	%monthtonum = ("Jan" => "01",
			 "Feb" => "02",
			 "Mar" => "03",
			 "Apr" => "04",
			 "May" => "05",
			 "Jun" => "06",
			 "Jul" => "07",
			 "Aug" => "08",
			 "Sep" => "09",
			 "Oct" => "10",
			 "Nov" => "11",
			 "Dec" => "12"
			);

return %monthtonum;
	}

sub num2month {
	%numtomonth = ("01" => "Jan",
			 "02" => "Feb",
			 "03" => "Mar",
			 "04" => "Apr",
			 "05" => "May",
			 "06" => "Jun",
			 "07" => "July",
			 "08" => "Aug",
			 "09" => "Sep",
			 "10" => "Oct",
			 "11" => "Nov",
			 "12" => "Dec"
			);

return %numtomonth;
	}

sub montharray {
@months = qw/None January February March April May June July August September October November December/;
return @months;
}

sub dates {
	$now_string = localtime;
	@thetime = split(/ +/,$now_string);
	return @thetime;
}

sub clocks {
	@theclock = split(/:/,$thetime[3]);
	$ampm = 'AM';
	if ($theclock[0] > 11)
	{ $ampm = 'PM'; }
	if ($theclock[0] == 0)
	{ $theclock[0] = 12; }
	if ($theclock[0] > 12)
	{ $theclock[0] -= 12; }
	else
	{ $theclock[0] += 0; }
	return @theclock;
}


sub longmonth {
	%longmonth = ("Jan" => "January",
			 "Feb" => "February",
			 "Mar" => "March",
			 "Apr" => "April",
			 "May" => "May",
			 "Jun" => "June",
			 "Jul" => "July",
			 "Aug" => "August",
			 "Sep" => "September",
			 "Oct" => "October",
			 "Nov" => "November",
			 "Dec" => "December"
			);
return %longmonth;
}

sub longday {
	%longday = ("Sun" => "Sunday",
			 "Mon" => "Monday",
			 "Tue" => "Tuesday",
			 "Wed" => "Wednesday",
			 "Thu" => "Thursday",
			 "Fri" => "Friday",
			 "Sat" => "Saturday"
			);
return %longday;
}

sub retrieval {
     if ( $ENV{'REQUEST_METHOD'} eq "GET" || $ENV{'REQUEST_METHOD'} eq "get" ) { 
    	$input_line = $ENV{'QUERY_STRING'}; 
      } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    	read(STDIN,$input_line,$ENV{'CONTENT_LENGTH'});
      } else {
    	    # Added for command line debugging
    	    # Supply name/value form data as a command line argument
    	    # Format: name1=value1\&name2=value2\&... 
    	    # (need to escape & for shell)
    	    # Find the first argument that's not a switch (-)
    	    $in = ( grep( !/^-/, @ARGV )) [0];
    	    $in =~ s/\\&/&/g;
      }
if ($hidepage eq "fullencrypt" && $ENV{'REQUEST_METHOD'} ne "POST") {
$input_line = &Decrypt($input_line);
}
$input_line =~ tr/+/ /;
$input{'all'} = $input_line;
$input{'all'} =~ s/%(..)/pack("c",hex($1))/ge; 
@fields = split(/\&/,$input_line);
$input_line = (); # free up memory
foreach $i (0 .. $#fields) {
   ($name,$value) = split(/=/,$fields[$i]);
   $name =~ s/%(..)/pack("c",hex($1))/ge; 
   $value =~ s/%(..)/pack("c",hex($1))/ge; 
   if ($name eq 'post_to') {
   if ($input{'post_to'} eq '') {
   $input{'post_to'} = $value;
   }
   else {
   $input{'post_to'} = "$input{'post_to'}&$value";
   }
   }
   else {
   $input{$name} = $value;
   }
}
return %input;
}


sub web {
print "Content-type: text/html\n\n";
}

sub validate_fail {
&web;
print <<END;
<html>
<head>
<link rel=StyleSheet href="../style2.css" />
<title>Access Denied</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body bgcolor="#FFFFFF" text="#000000" link="#999999" vlink="#6666FF" alink="#66FF33">
<br><br><FONT FACE="Arial" SIZE="4">Authentication Failed</FONT><br><br>
<table width=90%>
<FONT FACE="Arial" SIZE="2">Authentication has failed. Your information has been recorded in our logs. If this transaction has been made in error, our investigation will reveal same. However, if this has been an unauthorized attempt to invade or abuse the system, we will provide all information to the authorities for their handling.</font>
</table>
<br>
</FONT>
</BODY>
</HTML>
END

exit 1;

}

sub log_fail {
&web;
$go = "../index.html";
print <<END;
<html>
<head>
<link rel=StyleSheet href="../style2.css" />
<title>User Not Logged In</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body bgcolor="#FFFFFF" text="#000000" link="#999999" vlink="#6666FF" alink="#66FF33">
<br><br><FONT FACE="Arial" SIZE="4">Must Log In</FONT><br><br>
<table width=90%>
<FONT FACE="Arial" SIZE="2">For security reasons, all sessions must be logged into, to use the system, and logged out of when done. All sessions time out after 30 minutes of being idle. According to our records, you show as currently logged out. You must log in again to use the system. $fetchuser, $fetchpassword, $active, $timein
$ENV{HTTP_REFERRER}
</font>
</table>
<script>
function redirect() {
parent.document.location.href='$go';
}
setTimeout('redirect()',3000);
</script>
<br>
</FONT>
</BODY>
</HTML>
END

exit 1;

}

sub time_fail {
&web;
$go = "../index.html";
print <<END;
<html>
<head>
<link rel=StyleSheet href="../style2.css" />
<title>Session Timed Out</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body bgcolor="#FFFFFF" text="#000000" link="#999999" vlink="#6666FF" alink="#66FF33">
<br><br><FONT FACE="Arial" SIZE="4">User Idle Too Long</FONT><br><br>
<table width=90%>
<FONT FACE="Arial" SIZE="2">You have timed out because you have not used the system for over 60 minutes and were timed out by the internal security measures. Please log in again if you still wish to continue.
</table>
<script>
function redirect() {
parent.document.location.href='$go';
}
setTimeout('redirect()',2000);
</script>
<br>
</FONT>
</BODY>
</HTML>
END

exit 2;

}


sub access_fail {
&web;
$go = "../index.html";
print <<END;
<html>
<head>
<link rel=StyleSheet href="../style2.css" />
<title>Access Denied</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body bgcolor="#FFFFFF" text="#000000" link="#999999" vlink="#6666FF" alink="#66FF33">
<br><br><FONT FACE="Arial" SIZE="4">Insufficient Authorization Level</FONT><br><br>
<table width=90%>
<FONT FACE="Arial" SIZE="2">Access denied. You do not have access level privileges sufficient to perform that transaction. Your information has been recorded in our logs. If this transaction has been made in error, please seek an individual with sufficient access privileges with your request.
</table>
<script>
function redirect() {
parent.document.location.href='$go';
}
setTimeout('redirect()',2000);
</script>
<br>
</FONT>
</BODY>
</HTML>
END

exit 2;

}

sub dayarray {
@days = qw/Sunday Monday Tuesday Wednesday Thursday Friday Saturday/;
return @days;
}

sub bar {
print <<END;
<div id="bar" style="font-size:10pt;font-family:Arial">

<span id="progress0">| </span> 
<span id="progress1"> &#160;&#160;&#160;</span>
<span id="progress2">&#160;&#160;&#160;</span> 
<span id="progress3">&#160;&#160;&#160;</span>
<span id="progress4">&#160;&#160;&#160;</span> 
<span id="progress5">&#160;&#160;&#160;</span>
<span id="progress6">&#160;&#160;&#160;</span> 
<span id="progress7">&#160;&#160;&#160;</span>
<span id="progress8">&#160;&#160;&#160;</span> 
<span id="progress9">&#160;&#160;&#160;</span>
<span id="progress10">&#160;&#160;&#160;</span> 
<span id="progress11">&#160;&#160;&#160;</span>
<span id="progress12">&#160;&#160;&#160;</span> 
<span id="progress13">&#160;&#160;&#160;</span>
<span id="progress14">&#160;&#160;&#160;</span> 
<span id="progress15">&#160;&#160;&#160;</span>
<span id="progress16">&#160;&#160;&#160;</span> 
<span id="progress17">&#160;&#160;&#160;</span>
<span id="progress18">&#160;&#160;&#160;</span> 
<span id="progress19">&#160;&#160;&#160;</span>
<span id="progress20">&#160;&#160;&#160; </span> 
<span>|</span> 
 
<span><br>Loading Progress</span> 
</div> 

<script language="javascript"> 

var progressEnd = 20; 
var progressColor = '#990000'; 
var progressInterval = 40; 
var progressAt = progressEnd; 
var progressTimer;

function progress_clear() { 
for (var i = 1; i <= progressEnd; i++)
{
document.getElementById('progress'+i).style.backgroundColor = 'transparent';
}
progressAt = 0; 
}

function progress_update() { 
progressAt++; 
if (progressAt > progressEnd) 
{
progress_clear(); 
}
else
{
document.getElementById('progress'+progressAt).style.backgroundColor = progressColor;
}
progressTimer = setTimeout('progress_update()',progressInterval); 
}

function progress_stop() { 
clearTimeout(progressTimer); 
progress_clear(); 
} 
</script>
END
}

sub progress {
print <<END;
<!-- 
function submitForm(s) {
document.all.bar.style.visibility='visible';
s.value = "Please Wait"; 
return true; 
} 
//-->
END
} 

sub delay {
&bar;
print <<END;
<div id="content">
END
}

sub loader {
print <<END;
<style type="text/css">
	#bar { position: absolute; visibility: visible }
	#content { position: absolute; visibility: hidden }
</style>
<script>
	function display_it()
	{
	document.all.content.style.visibility='visible';
	document.all.bar.style.visibility='hidden';
	}
</script>
END
}



sub security {
$browser = $input{'nav'} . " " . $input{'ver'};
$contents = $input{'all'};
$contents =~ s/\cM\n/ /g;

if ($page ne "right2.pl") {
$dbh->do("INSERT INTO Logs (Log_URL, Log_Time, Log_User, Log_IP, Log_Password, Log_Browser, Contents) VALUES (" . 
$dbh->quote($page) . "," . 
$dbh->quote($record) . "," .
$dbh->quote($user) . "," . 
$dbh->quote($ip) . "," .
$dbh->quote($password) . "," .
$dbh->quote($browser) . "," .
$dbh->quote($contents) . ")")
|| die "Couldn't add record, " . $dbh->errstr();
}

$sql = qq{ SELECT user, password, Active, Time_In FROM Account WHERE (user = '$user') };
my $sth = $dbh->prepare( $sql );
$sth->execute() || die $sql;
$sth->bind_columns( \$fetchuser, \$fetchpassword, \$active, \$timein );
$sth->fetch();
$sth->finish();

if (($active ne "In") && ($_[0] ne 'login')) {
&log_fail;
}

if (((time - $timein) > 3700) && ($_[0] ne 'login')) {
&time_fail;
}

if ($password ne $fetchpassword) {
&validate_fail;
}

$newact = "In";

if ($page ne "right2.pl") {
my ($query) = "UPDATE Account SET Time_In = " .
time . ", " .
"Active = " . $dbh->quote($newact) . " " .
"WHERE user = " . $dbh->quote($user);
$dbh->do($query) || die "no";
}
}

sub Encrypt
{
my $Blowfish_Cipher = new Crypt::Blowfish $Blowfish_Key;
my $String = $_[0];

my $Temp = $String;
my $Encrypted = "";
while (length $Temp > 0)  
  {

  while (length $Temp < 8) {$Temp .= "\t";}

  my $Temp2 = $Blowfish_Cipher->encrypt(substr($Temp,0,8));

  $Encrypted .= $Temp2; 

  if (length $Temp > 8) {$Temp = substr($Temp,8);} else {$Temp = "";}
  }

my $Unpacked = unpack("H*",$Encrypted);

return ($Unpacked);
}

sub Decrypt
{
my $Blowfish_Cipher = new Crypt::Blowfish $Blowfish_Key;
my $String = $_[0];

my $Packed = pack("H*",$String);

my $Temp = $Packed;
my $Decrypted = "";
while (length $Temp > 0)  
  {
  my $Temp2 = substr($Temp,0,8);

  if (length $Temp2 == 8) 
    {
    my $Temp3 = $Blowfish_Cipher->decrypt($Temp2);
    $Decrypted .= $Temp3;
    } 
  if (length $Temp > 8) {$Temp = substr($Temp,8);} else {$Temp = "";}
  }

$Decrypted =~ s/\t+$//g;

return ($Decrypted);
}



sub roomselect {
my $sql = qq{ SELECT room, region FROM Rooms ORDER BY region, room }; 
my $sth = $dbh->prepare( $sql );
$sth->execute() || die "Could not execute SQL statement, maybe invalid?";

my( $roomntemp, $roomctemp, @room, @roomregion );
my $x=0;
$sth->bind_columns( \$roomntemp, \$roomctemp );

while( $sth->fetch() ) {
$room[$x] = $roomntemp;
$roomregion[$x] = $roomctemp;
$x++;
}
$sth->finish();

if ($_[0] eq "js") {
print <<END;
<SCRIPT>
var store = new Array();



END



my $x=0;
foreach $z (0 .. $#room) {
	if ($roomregion[$z] ne $roomregion[$z-1]) {
		if ($z ne 0) {
		$x++;
print ");\n\nstore[$x] = new Array( '$room[$z]', '$room[$z]'";
		}
		else {
print "store[$x] = new Array( '$room[$z]', '$room[$z]'";
		}
	}
	else {
print ", '$room[$z]', '$room[$z]'";
	}
}





print <<END;
);
END

$y=$x+1;

print <<END;
store[$y] = new Array( 'Room not selected', 'Cradle of Civilization');


function optionTestIt()
{
	optionTest = true;
	lgth = document.forms['mvtfrm'].destination.options.length - 1;
	document.forms['mvtfrm'].destination.options[lgth] = null;
	if (document.forms['mvtfrm'].destination.options[lgth]) optionTest = false;
}

function populate()
{
	var box = document.forms['mvtfrm'].roomregion;
	var number = box.options[box.selectedIndex].value;
	if (!number) return;
	var list = store[number];
	var box2 = document.forms['mvtfrm'].destination;
	while (box2.options.length) box2.options[0] = null;
	for(i=0;i<list.length;i+=2)
		{
		box2.options[i/2] = new Option(list[i],list[i+1]);
		}
}

</SCRIPT>
END
}



if ($_[0] eq "sel1") {
print <<END;
<b>Region:</b> <select name="roomregion" onChange="populate()">
<option value="$y">Select a region</option>
END




my $x=0;

foreach $z (0 .. $#room) {

			if ($roomregion[$z] ne $roomregion[$z-1]) {
print <<END;
<option value="$x">$roomregion[$z]</option>

END



			$x++;
			}
}
print <<END;
</SELECT>
END
}

if ($_[0] eq "sel2") {
print <<END;
<b>Location</b>: <SELECT NAME="destination">
</SELECT>
END
}

}



1;
