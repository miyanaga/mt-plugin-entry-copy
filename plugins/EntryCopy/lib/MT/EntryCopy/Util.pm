package MT::EntryCopy::Util;

use strict;
use warnings;
use base qw(Exporter);

use Data::Dumper;

our @EXPORT = qw(plugin pp plugin_config);

sub plugin { MT->component('EntryCopy'); }

sub pp { print STDERR Dumper(@_); }

sub plugin_config {
    my ( $blog_id, $param ) = @_;
    my $scope = $blog_id ? "blog:$blog_id" : "system";

    my %config;
    plugin->load_config(\%config, $scope);

    my $saving = 0;
    if ( ref $param eq 'HASH' ) {
        foreach my $k ( %$param ) {
            $config{$k} = $param->{$k};
        }
        $saving = 1;
    } elsif ( ref $param eq 'CODE' ) {
        $saving = $param->(\%config);
    }

    plugin->save_config(\%config, $scope) if $saving;
    \%config;
}

1;
