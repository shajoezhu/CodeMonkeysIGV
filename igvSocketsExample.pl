#!/usr/bin/perl -w

use strict;
use Socket;

# Set server address (our own computer) and port for IGV access
my $remote = "127.0.0.1";
my $port = 60151;

# Open a socket and connect to IGV
my $proto = getprotobyname('tcp');
my($socket);
socket($socket, AF_INET, SOCK_STREAM, $proto) or die $!;
my $iaddr = inet_aton($remote) or die $!;
my $paddr = sockaddr_in($port, $iaddr);
connect($socket, $paddr) or die $!;
print "Connected to $remote on port $port\n";

# Issue a command to IGV
my $command = "echo";
print "$command\n";
send($socket, "$command\n", 0);

close($socket);
