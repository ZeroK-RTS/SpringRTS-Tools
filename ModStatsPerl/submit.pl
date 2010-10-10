#!/usr/bin/perl

use strict;
use SOAP::Lite;

#collect data

my $gameId;
my $modName;
my $mapName;
my @statsData;

my $isCheating;
my $isDemo;

$isCheating = 0;
$isDemo = 0;

my ($file) = @ARGV;

open FILE, $file or die $!;
while (my $line = <FILE>) {
  if ($line =~ m/^\[.*/i) {
    $line = substr($line, index($line, "]") + 2);
  }

  chomp($line);

  if ($line =~ "Using mod" && not ($line =~ "Using mod archive")) {
    $modName = substr($line, 10);
  }

  if ($line =~ "Using map") {
    $mapName = substr($line, 10);
  }

  if ($line =~ "GameID: ") {
    $gameId = substr($line, 8);
  }

  if ($line =~ "STATS:") {
    push(@statsData, substr($line, 6));
  }

  if ($line =~ "Beginning demo playback") {
    $isDemo = 1;
  }

  if ($line =~ "Cheating!") {
    $isCheating = 1;
  }

}
close(FILE);

print $gameId," ",$isCheating,$isDemo,"\n";
print $modName,"\n";
print $mapName,"\n";
print @statsData,"\n";

if ((@statsData < 2) || ($isCheating) || ($isDemo)) { # not enough stats lines found
  exit;
} else {
  print "sending data...\n";
}

# send data
# SubmitGameEx(gameId, modName, mapName, statsData.ToArray());

my $gameIDString;
my $mod;
my $map;
my $data;

$gameIDString = SOAP::Data->name('gameIDString')->value($gameId);
$mod = SOAP::Data->name('mod')->value($modName);
$map = SOAP::Data->name('map')->value($mapName);
$data = SOAP::Data->name('data')->value(\SOAP::Data->name('string')->value(@statsData));

my $result = SOAP::Lite
  -> proxy('http://planet-wars.eu/ModStats/StatsCollector.asmx')
  -> uri('http://planet-wars.eu/ModStats')
  -> on_action(sub { sprintf '"%s/SubmitGameEx"', shift })
  -> SubmitGameEx($gameIDString, $mod, $map, $data);

unless ($result->fault) {
  print $result->result();
} else {
  print join ', ', $result->faultcode, $result->faultstring;
}

