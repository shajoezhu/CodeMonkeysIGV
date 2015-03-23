#!/usr/bin/perl -w

use strict;
require("igvlib.pl");

my $socket = igv_connect();

open(LOCI, "loci.txt");
chomp(my @loci = <LOCI>);
close(LOCI);

igv_maxPanelHeight($socket, 5000);
igv_snapshotDirectory($socket, "/Users/kiran/Desktop/");

foreach my $locus (@loci) {
    my ($chr, $start, $stop) = split(/[:-]/, $locus);
    my $regionStart = $start + 200;
    my $regionStop = $stop - 200;
    (my $file = "$locus.png") =~ s/[:-]/_/g;

    igv_goto($socket, $locus);
    igv_region($socket, $chr, $regionStart, $regionStop);
    igv_snapshot($socket, $file);
}

igv_close($socket);
