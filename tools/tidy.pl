#! /usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Find;
use File::Slurp;
use HTML::TreeBuilder;
use Web::Scraper;
use Text::MicroTemplate;
use Encode;
my $scraper = scraper {
    process '//title', 'title' => 'TEXT';
    process '#pageText', 'pageText' => 'HTML';
};

my $mt = Text::MicroTemplate::build_mt(join "\n", <DATA>);

find(
    {
        wanted => sub {
            my $fn = $_;
            return if -d $fn;
            $fn =~ s|^orig/||;
            my $html = read_file("orig/$fn");
            if ( ! defined $html ) {
                die "failed to read file:orig/$fn:$!";
            }
            my $res = $scraper->scrape(\$html);
            if ( $res->{pageText} ) {
                $res->{pageText} =~ s{</p>}{</p>\n}g;
                $res->{pageText} =~ s{</li>}{</li>\n}g;
            }
            my $result = $mt->($res)->as_string;
            system("mkdir -p " . dirname("doc/$fn")) == 0
                or die "mkdir failed:$?";

            Encode::_utf8_off($result); # FIXME: Can't output Wild character error.
            write_file("doc/$fn", $result);
        },
        no_chdir => 1,
    },
    'orig',
);

__END__
<? my $res = shift ?>
<html>
<head><?= $res->{title} ?></head>
<body>
<?= Text::MicroTemplate::encoded_string($res->{pageText} || "") ?>
<div class="Footer">
      <p id="license">Content is available under <a href="https://developer.mozilla.org/Project:Copyrights">these licenses</a></p>
      <p id="footabout"><a href="https://developer.mozilla.org/Project:ja/About">abount MDC</a></p>
</div>
</body>
</html>

