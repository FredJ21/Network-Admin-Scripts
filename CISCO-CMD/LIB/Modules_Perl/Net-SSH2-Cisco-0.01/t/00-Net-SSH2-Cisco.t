#!/usr/bin/perl
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Net-SNMPTrapd.t'

use strict;
use warnings;

use Test::Simple tests => 1;

use Net::SSH2::Cisco;
ok(1, "Loading Module"); # If we made it this far, we're ok.

#########################
