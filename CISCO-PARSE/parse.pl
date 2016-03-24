#!/usr/bin/perl


$ARP_FILE  = "show-ip-arp";
$MAC_FILE  = "show-mac-address";



open ($F, "<", $ARP_FILE);
while ($LINE = <$F>) {
        chomp $LINE;



        if (grep(/Vlan/, $LINE)) {

		$IP   = substr($LINE, 10, 20);
		$MAC  = substr($LINE, 38, 16);
		$VLAN = substr($LINE, 61, 10);

		$IP   =~ s/ //g;
		$MAC  =~ s/ //g;
		$VLAN =~ s/ //g;
		$VLAN =~ s/Vlan//g;

		$MAC  = $MAC ."_". $VLAN;

		@DATA_MAC_IP{$MAC} = $IP;
		#print "[". $MAC ."][". $IP ."]\n";
        }
}
close $F;

open ($F, "<", $MAC_FILE);
while ($LINE = <$F>) {
        chomp $LINE;

		$INT  = substr($LINE, 0, 9);
		$VLAN = substr($LINE, 9, 3);
		$MAC  = substr($LINE, 13, 16);

		$INT  =~ s/ //g;
		$VLAN =~ s/ //g;
		$MAC  =~ s/ //g;

		$MAC2 = $MAC ."_". $VLAN;

		print $INT ." ". $VLAN ." ". $MAC ." ". @DATA_MAC_IP{$MAC2} ." ";

		if (@DATA_MAC_IP{$MAC2}) {

			$HOST = `host @DATA_MAC_IP{$MAC2}`;

			if (grep(/pointer/, $HOST)) {
			$HOST =~ s/.eu.els.local.//g;
			$HOST =~ s/.* pointer//g;
			$HOST =~ s/\n/ /g;
			
			print $HOST;

			}
		} 

		print "\n";
}
close $F


