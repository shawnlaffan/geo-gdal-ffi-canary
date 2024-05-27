use strict;
use warnings;

use Test2::V0;

use File::Find;
use List::Util qw /max/;

diag '';
diag 'Aliens:';
my %alien_versions;
my @aliens = qw /
    Alien::gdal   Alien::geos::af  Alien::sqlite
    Alien::proj   Alien::libtiff   Alien::spatialite
    Alien::freexl
/;
my $longest_name = max map {length} @aliens;
foreach my $alien (@aliens) {
    eval "require $alien; 1";
    if ($@) {
        #diag "$alien not installed";
        diag sprintf "%-${longest_name}s: not installed", $alien;
        next;
    }
    diag sprintf "%-${longest_name}s: version:%7s, install type: %s",
        $alien,
        $alien->version // 'unknown',
        $alien->install_type;
    $alien_versions{$alien} = $alien->version;
}

if ($alien_versions{'Alien::gdal'} ge 3) {
    if ($alien_versions{'Alien::proj'} lt 7) {
        diag 'Alien proj is <7 when gdal >=3';
    }
}
else {
    if ($alien_versions{'Alien::proj'} ge 7) {
        diag 'Alien proj is >=7 when gdal <3';
    }
}

my $locale_is_comma;
BEGIN {
    use POSIX qw /locale_h/;
    my $locale_values = localeconv();
    $locale_is_comma = $locale_values->{decimal_point} eq ',';
}
use constant LOCALE_USES_COMMA_RADIX => $locale_is_comma;
diag "Radix char is "
    . (LOCALE_USES_COMMA_RADIX ? '' : 'not ')
    . 'a comma.';


my $data_dir = Alien::gdal->data_dir;
diag "Alien::gdal data_dir: $data_dir";
my @dynamic_libs = Aien::gdal->dynamic_libs;
diag "Alien::gdal dynamic_libs: " . join ' ', @dynamic_libs;
diag $ENV{HOMEBREW_PREFIX};
diag `which -a pkg-config` if $^O ne 'MSWin32';

ok (1);
done_testing();
