#!/usr/bin/perl -w

use strict;
require("igvlib.pl");

my $socket = igv_connect();

while (1) {
    print "igv> ";

    chomp(my $cmd = <STDIN>);

    if ($cmd =~ /^help/) {
        igv_help();
    } else {
        igv_cmd($socket, $cmd);
    }
}

igv_close($socket);
