#!/usr/bin/perl

# By Fred J. !!!

use Net::Ping;

autoflush STDOUT 1;

use constant false => 0;
use constant true  => 1;

$CO_V = "\033[1;32m"; #vert
$CO_R = "\033[1;31m"; #rouge
$CO_O = "\033[1;33m"; #orange
$CO_N = "\033[0;39m"; #normal

my $FILE_INIT   = 'host.ini';


# ---------------------------------- INIT ---------------------------
my $NB = 0;
my $OK = 0;
my $HS = 0;

open (F, $FILE_INIT);
while ($LINE = <F>) {

        chomp $LINE;

        if (!grep(/^#/, $LINE) ) {

           $LINE =~ s/ //g;
           $LINE =~ s/\t//g;

           @LIST = split(';', $LINE);
           $IP   = $LIST[0];
           $DESC = $LIST[1];

           if ($IP) {

                #print $A ." --> ". $IP ." - ". $DESC ." - ";
                #printf ("%3s ->%-15s %-40s ", $A, $IP, $DESC);

                $TEST_ICMP = &ping($IP);

                $NB++;
           }
        } else {

                print "\n". $LINE ."\n";

        }
}
close F;

print "\n\n";
print $CO_O . "Total: ". $NB;
print $CO_N . " - ";
print $CO_V . " OK: ". $OK; 
print $CO_N . " - ";
print $CO_R . " HS: ". $HS;
print $CO_N . "\n\n";
 

exit;


# ------------------------------------------------------------------
sub ping {

        $IP = $_[0];


        $p = Net::Ping->new("icmp", 1);

        if ($p->ping($IP)) {
                print $CO_V .$IP. $CO_N ."|";
                $TEST_ICMP = true;
		$OK++;
        } else {
                print $CO_R .$IP. $CO_N ."|";
                $TEST_ICMP = false;
		$HS++;
        }

        return ($TEST_ICMP);

        $p->close();
        undef $p;
}


