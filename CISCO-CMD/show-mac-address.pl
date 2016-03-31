#! /usr/bin/perl 

# ============================================================================
#	http://cpansearch.perl.org/src/DTOWN/Net-SNMP-5.2.0/examples/snmpwalk.pl
# ============================================================================

use Net::SNMP v5.1.0 qw(:snmp DEBUG_ALL);
use Getopt::Std;

use strict;
use vars qw(%OPTS);

autoflush STDOUT 1;

# Validate the command line options
if (!getopts('a:A:c:dD:E:m:n:p:r:t:u:v:x:X:', \%OPTS)) {	_usage();}

# Do we have enough/too much information?
if (@ARGV != 1) {	_usage();	}

my $host = $ARGV[0];

my $s;		# SNMP session
my $e;		# SNMP error
my $community;
my @RESULT;

# ============================================================================
#				MAIN
# ============================================================================

# ---------------------------------------------------------------------------
# 				Liste des Vlans 
  my @VlanList;
  @RESULT ="";
  $community = $OPTS{c};
  _openSession();
  _get(".1.3.6.1.4.1.9.9.46.1.3.1.1.2");
  
  foreach (@RESULT) {
	if(/\.1\.3\.6\.1\.4\.1\.9\.9\.46\.1\.3\.1\.1\.2\.1\.(\d+) = INTEGER: 1/) {
		push @VlanList, $1;
		print ".";
	}
  } 
  _closeSession();

# ---------------------------------------------------------------------------
# 				Table index/Alias
  my %Alias; 
  @RESULT ="";
  $community = $OPTS{c};
  _openSession();
  _get(".1.3.6.1.2.1.31.1.1.1.1");
  
  foreach (@RESULT) {
	if(/\.1\.3\.6\.1\.2\.1\.31\.1\.1\.1\.1\.(\d+) = OCTET STRING: (.+)/) {
		my $index = $1;
		my $Alias = $2;
		$Alias{$index} = $Alias;
		print ".";
	}
  } 
  _closeSession();


# ---------------------------------------------------------------------------
# 				Pour chaque VLAN:
#					- liste des ports/index
#					- liste des mac/ports
  my %Ports;
  my %AddMac;
  foreach my $vlan (@VlanList) {

  	$community = $OPTS{c} ."\@". $vlan;

  	@RESULT ="";
  	_openSession();
  	_get(".1.3.6.1.2.1.17.1.4.1.2");		# Table ports/index
	foreach (@RESULT) {	

		if(/\.1\.3\.6\.1\.2\.1\.17\.1\.4\.1\.2\.(\d+) = INTEGER: (\d+)/) {
			my $port  = $1;
			my $index = $2;
			$Ports{$index} = $port;
			print ".";
		}	
  	}
	_closeSession();
 

  	@RESULT ="";
  	_openSession();
  	_get(".1.3.6.1.2.1.17.4.3.1.2");		# Table Mac(decimal)/port
	foreach (@RESULT) {	

		if(/\.1\.3\.6\.1\.2\.1\.17\.4\.3\.1\.2\.(\d+\.\d+\.\d+\.\d+\.\d+\.\d+) = INTEGER: (\d+)/) {
			my $mac   = $1;
			my $port  = $2;
			push @{ $AddMac{$port} }, $vlan ."_". $mac; 
			print ".";
		}
#		print "o";
	}	
  	_closeSession();
  }

 
# ---------------------------------------------------------------------------
#				Affichage 
  print "\n\n\n";  
  printf ("%10s %15s %10s %10s %25s\n", "Index", "Alias", "Port", "Vlan", "Mac");
  print  ("--------------------------------------------------------------------------\n");
  foreach my $k (sort {$a<=>$b} keys(%Alias)) {

	my $portNumber = $Ports{$k};
	
	if ( $AddMac{$portNumber}[0] ) {
		foreach (@{ $AddMac{$portNumber} }) {
		
			my $vlan; my $mac1; my $mac2; my $mac3; my $mac4; my $mac5; my $mac6;
			($vlan, $mac1,$mac2,$mac3,$mac4,$mac5,$mac6) = /(\d+)_(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)/;

			my $mac =  sprintf("%02X.%02X.%02X.%02X.%02X.%02X",$mac1, $mac2, $mac3, $mac4, $mac5, $mac6);

			printf ("%10s %15s %10s %10s %25s\n", $k, $Alias{$k}, $portNumber, $vlan, $mac);

		}	
	} else {
			printf ("%10s %15s %10s\n", $k, $Alias{$k}, $portNumber);
	}

 
  }
  print "\n";  
  
exit 0;


# [private] ------------------------------------------------------------------
sub _openSession
{

	($s, $e) = Net::SNMP->session(
	   -hostname => $host,
	   exists($OPTS{a}) ? (-authprotocol =>  $OPTS{a}) : (),
	   exists($OPTS{A}) ? (-authpassword =>  $OPTS{A}) : (),
	   -community    =>  $community,
	   exists($OPTS{D}) ? (-domain       =>  $OPTS{D}) : (),
	   exists($OPTS{d}) ? (-debug        => DEBUG_ALL) : (),
	   exists($OPTS{m}) ? (-maxmsgsize   =>  $OPTS{m}) : (),
	   exists($OPTS{p}) ? (-port         =>  $OPTS{p}) : (),
	   exists($OPTS{r}) ? (-retries      =>  $OPTS{r}) : (),
	   exists($OPTS{t}) ? (-timeout      =>  $OPTS{t}) : (),
	   exists($OPTS{u}) ? (-username     =>  $OPTS{u}) : (),
	   exists($OPTS{v}) ? (-version      =>  $OPTS{v}) : ( -version      =>  '2c'),	
	   exists($OPTS{x}) ? (-privprotocol =>  $OPTS{x}) : (),
	   exists($OPTS{X}) ? (-privpassword =>  $OPTS{X}) : ()
	);

	# Was the session created?
	if (!defined($s)) {
  		 _exit($e);
	}
}
sub _closeSession
{
	# Close the session
	$s->close();
}
sub _get 
{
	my ($OID) = (@_);

	my @args = (
	   exists($OPTS{E}) ? (-contextengineid => $OPTS{E}) : (),
	   exists($OPTS{n}) ? (-contextname     => $OPTS{n}) : (),
	   -varbindlist    => [$OID]
	);
	
	if ($s->version == SNMP_VERSION_1) {
	
	   my $oid;
	
	   while (defined($s->get_next_request(@args))) {
	      $oid = ($s->var_bind_names())[0];
	
	      if (!oid_base_match($OID, $oid)) { last; }
	      push(@RESULT, $oid .' = '. snmp_type_ntop($s->var_bind_types()->{$oid}) .': '. $s->var_bind_list()->{$oid} );
	
	      @args = (-varbindlist => [$oid]);
	   }
	
	} else {
	
	   push(@args, -maxrepetitions => 25); 
	
	   outer: while (defined($s->get_bulk_request(@args))) {
	
	      my @oids = oid_lex_sort(keys(%{$s->var_bind_list()}));
	
	      foreach (@oids) {
	
	         if (!oid_base_match($OID, $_)) { last outer; }
	      	 push(@RESULT, $_ .' = '. snmp_type_ntop($s->var_bind_types()->{$_}) .': '. $s->var_bind_list()->{$_} );

	         # Make sure we have not hit the end of the MIB
	         if ($s->var_bind_list()->{$_} eq 'endOfMibView') { last outer; } 
	      }
	
	      # Get the last OBJECT IDENTIFIER in the returned list
	      @args = (-maxrepetitions => 25, -varbindlist => [pop(@oids)]);
	   }
	
	}

	# Let the user know about any errors
	if ($s->error() ne '') {
	   _exit($s->error());
	}
}
sub _printTab
{
	#foreach (@_) {	print '['. $_ ."]\n"; }	
	foreach (@_) {	print  $_ ."\n"; }	
}
sub _exit
{
   	printf join('', sprintf("%s: ", $0), shift(@_), ".\n"), @_;
   	exit 1;
}

sub _usage
{
   print << "USAGE";

Usage: $0 [options] <hostname> 
Options: -v 1|2c|3      SNMP version
         -d             Enable debugging
   SNMPv1/SNMPv2c:
         -c <community> Community name
   SNMPv3:
         -u <username>  Username (required)
         -E <engineid>  Context Engine ID
         -n <name>      Context Name
         -a <authproto> Authentication protocol <md5|sha>
         -A <password>  Authentication password
         -x <privproto> Privacy protocol <des|3des|aes>
         -X <password>  Privacy password
   Transport Layer:
         -D <domain>    Domain <udp|udp6|tcp|tcp6>
         -m <octets>    Maximum message size
         -p <port>      Destination port
         -r <attempts>  Number of retries
         -t <secs>      Timeout period

USAGE
   exit 1;
}

# ============================================================================

