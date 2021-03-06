use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::Telnet::Cisco',
    'VERSION_FROM'	=> 'Cisco.pm', # finds $VERSION
    'PREREQ_PM'		=> { Net::Telnet => 3.02,
			     Term::ReadKey => 2,
			     Test::More => undef,
			     Cwd => undef,
			   }, # e.g., Module::Name => 1.1
     ($] ge '5.005') ? (
			'AUTHOR' => 'Joshua Keroes (joshua@cpan.org)',
			'ABSTRACT' => 'automate Cisco management',
		       ) : (),
);
