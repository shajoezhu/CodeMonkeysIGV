#!/usr/bin/perl -w

use strict;
use Socket;

sub igv_connect {
    my $remote = "127.0.0.1";
    my $port = 60151;

    my $socket;

    my $proto = getprotobyname('tcp');
    socket($socket, AF_INET, SOCK_STREAM, $proto) or die $!;

    my $iaddr = inet_aton($remote) or die $!;
    my $paddr = sockaddr_in($port, $iaddr);

    connect($socket, $paddr) or die $!;

    print "Connected to $remote on port $port\n";

    return $socket;
}

sub igv_close {
    my ($socket) = @_;
    close($socket);
}

# Echo command to the terminal, send the command to IGV, and echo the response to the terminal again
sub igv_cmd {
    my ($socket, $command) = @_;
    print "Command: $command\n";

    send($socket, "$command\n", 0);

    my $msg;
    recv($socket, $msg, 2000, 0);

    print "Received: $msg\n";
}

# Create a new session.  Unloads all tracks except the default genome annotations.
sub igv_new {
    my ($socket) = @_;

    igv_cmd($socket, "new");
}

# Loads data or session files.  Specify a comma-delimited list of full paths or URLs.
sub igv_load {
    my ($socket, @files) = @_;

    igv_cmd($socket, "load " . join(",", @files));
}

# Collapses a given trackName. trackName is optional, however, and if it is not supplied all tracks are collapsed.
sub igv_collapse {
    my ($socket, $trackName) = @_;

    igv_cmd($socket, "collapse $trackName");
}

# Writes "echo" back to the response.  (Primarily for testing)
sub igv_echo {
    my ($socket) = @_;

    igv_cmd($socket, "echo");
}

# Exit (close) the IGV application.
sub igv_exit {
    my ($socket) = @_;

    igv_cmd($socket, "exit");
}

# Expands a given trackName. trackName is optional, however, and if it is not supplied all tracks are expanded.
sub igv_expand {
    my ($socket, $trackName) = @_;

    igv_cmd($socket, "expand $trackName");
}

# Selects a genome. 
sub igv_genome {
    my ($socket, $genomeId) = @_;

    igv_cmd($socket, "genome $genomeId");
}

# Scrolls to a single locus or a space-delimited list of loci. If a list is provided, these loci will be displayed in a split screen view.  Use any syntax that is valid in the IGV search box.
sub igv_goto {
    my ($socket, @loci) = @_;

    igv_cmd($socket, "goto " . join(" ", @loci));
}

# Defines a region of interest bounded by the two loci (e.g., region chr1 100 200).
sub igv_region {
    my ($socket, $chr, $start, $end) = @_;

    igv_cmd($socket, "region $chr $start $end");
}

# Sets the number of vertical pixels (height) of each panel to include in image. Images created from a port command or batch script are not limited to the data visible on the screen. Stated another way, images can include the entire panel not just the portion visible in the scrollable screen area. The default value for this setting is 1000, increase it to see more data, decrease it to create smaller images.
sub igv_maxPanelHeight {
    my ($socket, $height) = @_;

    igv_cmd($socket, "maxPanelHeight $height");
}

# Sets a delay (sleep) time in milliseconds.  The sleep interval is invoked between successive commands.
sub igv_setSleepInterval {
    my ($socket, $ms) = @_;

    igv_cmd($socket, "setSleepInterval $ms");
}

# Sets the directory in which to write images.
sub igv_snapshotDirectory {
    my ($socket, $path) = @_;

    igv_cmd($socket, "snapshotDirectory $path");
}

#snapshot filename   Saves a snapshot of the IGV window to an image file.  If filename is omitted, writes a PNG file with a filename generated based on the locus.  If filename is specified, the filename extension determines the image file format, which must be .png, .jpg, or .svg.
sub igv_snapshot {
    my ($socket, $filename) = @_;

    igv_cmd($socket, "snapshot $filename");
}

#Sorts an alignment track by the specified option.  Recognized values for the option parameter are: base, position, strand, quality, sample,  readGroup, AMPLIFICATION, DELETION, EXPRESSION, SCORE, and MUTATION_COUNT.  The locus option can define a single position, or a range.  If absent sorting will be perfomed based on the region in view, or the center position of the region in view, depending on the option.
sub igv_sort {
    my ($socket, $option, $locus) = @_;

    igv_cmd($socket, "sort $option $locus");
}

# Squish a given trackName. trackName is optional, and if it is not supplied all annotation tracks are squished.
sub igv_squish {
    my ($socket, $trackName) = @_;

    igv_cmd($socket, "squish $trackName");
}

# Set the display mode for an alignment track to "View as pairs".  trackName is optional.
sub igv_viewaspairs {
    my ($socket, $trackName) = @_;

    igv_cmd($socket, "viewaspairs $trackName");
}

# Temporarily set the preference named key to the specified value. This preference only lasts until IGV is shut down.
sub igv_preference {
    my ($socket, $key, $value) = @_;

    igv_cmd($socket, "preference $key $value");
}

sub igv_help {
    my $help = qq{ 
new                         Create a new session.  Unloads all tracks except the
                            default genome annotations.
load file                   Loads data or session files.  Specify a comma-delimited
                            list of full paths or URLs.
collapse trackName          Collapses a given trackName. trackName is optional, however,
                            and if it is not supplied all tracks are collapsed.
echo                        Writes "echo" back to the response.  (Primarily for testing)
exit                        Exit (close) the IGV application.
expand trackName            Expands a given trackName. trackName is optional, however,
                            and if it is not supplied all tracks are expanded.
genome genomeId             Selects a genome. 
goto locus or listOfLoci    Scrolls to a single locus or a space-delimited list of loci.
                            If a list is provided, these loci will be displayed in a split
                            screen view.  Use any syntax that is valid in the IGV search box.
region chr start end        Defines a region of interest bounded by the two loci
                            (e.g., region chr1 100 200).
maxPanelHeight height       Sets the number of vertical pixels (height) of each
                            panel to include in image. Images created from a port
                            command or batch script are not limited to the data visible
                            on the screen. Stated another way, images can include the entire
                            panel not just the portion visible in the scrollable
                            screen area. The default value for this setting is 1000,
                            increase it to see more data, decrease it to create smaller
                            images.
setSleepInterval ms         Sets a delay (sleep) time in milliseconds.  The sleep
                            interval is invoked between successive commands.
snapshotDirectory path      Sets the directory in which to write images.
snapshot filename           Saves a snapshot of the IGV window to an image file.
                            If filename is omitted, writes a PNG file with a filename
                            generated based on the locus.  If filename is specified,
                            the filename extension determines the image file format,
                            which must be .png, .jpg, or .svg.
sort option locus           Sorts an alignment track by the specified option.  Recognized
                            values for the option parameter are: base, position, strand,
                            quality, sample,  readGroup, AMPLIFICATION, DELETION,
                            EXPRESSION, SCORE, and MUTATION_COUNT.  The locus option can
                            define a single position, or a range.  If absent sorting will
                            be perfomed based on the region in view, or the center position
                            of the region in view, depending on the option.
squish trackName            Squish a given trackName. trackName is optional, and if
                            it is not supplied all annotation tracks are squished.
viewaspairs trackName       Set the display mode for an alignment track to "View as pairs".
                            trackName is optional.
preference key value        Temporarily set the preference named key to the specified
                            value. This preference only lasts until IGV is shut down.
};
    print "Commands available:\n";
    print "$help\n";
}

1;
