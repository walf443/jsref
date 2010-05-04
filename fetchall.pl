#! /usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Slurp;
use LWP::UserAgent;

my $prefix = 'https://developer.mozilla.org/ja/Core_JavaScript_1.5_Reference';
my @queue = ( 'index' );
my %fetched;

my $BASEDIR = "orig";
system("mkdir $BASEDIR") unless -d $BASEDIR;

my $counter = 0;
while (my $fn = shift @queue) {
    # next if -e rewrite_ctor_op($fn) .".html";
    next if $fetched{$fn};
    print STDERR scalar(@queue), " $fn\n";
    system("mkdir -p " . dirname("$BASEDIR/$fn") . " 2> /dev/null");
    $fetched{$fn} = 1;
    my $html = "";
    my $ua = LWP::UserAgent->new;
    my $res = $fn eq 'index' ? $ua->get("$prefix") : $ua->get("$prefix/$fn");
    if ( $res->is_success ) {
        $html = $res->content;
    }
    while ( $html =~ s|(<a.*href=")$prefix/(.*?)"|$1 . handle_link($fn, $2) . ".html\""|eg ) {
        # do
    }
    write_file("$BASEDIR/$fn.html", $html);

    if ( $counter % 3 == 0 ) {
        sleep(1);
    }
    $counter++;
}

sub handle_link {
    my ($fn, $keyword) = @_;
    warn $keyword;
    if ( ! $fetched{$keyword} ) {
        push @queue, $keyword;
    }
    return $keyword;
}
