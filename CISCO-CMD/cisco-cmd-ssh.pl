#!/usr/bin/perl
# ----------------------------------------------------------------------------------------
#       CISCO automate by Fred J.
# ----------------------------------------------------------------------------------------

use Net::SSH2::Cisco;

$password    ;
$enable_pass ;

require '../../config.pl';		# variable $password & $enable_pass

$CO_V = "\033[92m"; #vert
$CO_R = "\033[91m"; #rouge
$CO_G = "\033[90m"; #gris
$CO_N = "\033[39m"; #normal

my $ip 		= "";
my $user 	= "admin";

my $line 	= "";

my $host	= "";
my @List_HOST;
my $FILE = 'host.ini';
my $FILE_OUT = 'cisco-cmd.out';

$CMD[0]  = 'show clock';

if ($ARGV[0]) { @CMD = split(';', $ARGV[0]); }

$SIG{ALRM} = \&input_timed_out;


open (F, ">".$FILE_OUT);
open (CONF, $FILE);
while ($line = <CONF>) {

   chomp ($line);

   if (grep(!/^#/, $line)) {
        my ($ip, $host, $desc) = split /;/, $line;

#	print "---------- ". $host. "(". $ip .")". $desc ."\n";

     $desc = $host. "(". $ip .")". $desc .":";
     print "------------------------------------------------------------------------------------------------------------------------\n";
     print $CO_V. $desc .$CO_N ."\n";

     $session = "";
     eval {
	alarm(3);
	$session = Net::SSH2::Cisco->new(host => $ip );
	alarm(0);
     };
	
     if (!$session) {	
	print $CO_G. $desc . $CO_R ."Time Out !!!\n". $CO_N;
	print F $desc .": Time Out !!!\n";

     } else {	

	$session->login($user, $password);
	$session->enable($enable_pass); 
	@output = $session->cmd("term len 0");

	foreach $C (@CMD) { 
		@output = $session->cmd($C);

		foreach $line (@output) {

			$line =~ s/\n//g;
			
			if ( $line ne "" ) {
				print $CO_G. $desc .$CO_N . $line ."\n";
				print F $desc . $line ."\n";
			} else {
				#print "\n";
				#print F "\n";
			}
		}	
	}

	$session->close;

     }
  }
}

close CONF;
close F;

sub input_timed_out {
        die "Timed out";
}


