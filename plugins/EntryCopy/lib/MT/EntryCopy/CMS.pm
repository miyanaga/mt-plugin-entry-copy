package MT::EntryCopy::CMS;

use strict;
use warnings;

use MT::EntryCopy::Util;

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    return 1 unless $app->param('copy');

    my $blog = $app->blog || return 1;
    my $config = plugin_config($blog->id);

    delete $param->{id};
    $param->{new_object} = 1;
    $param->{title} = '' if $config->{clear_title};

    1;
}

sub init_request {
    my ($cb, $app)   = @_;

    # 新規記事の作成(ブログのコンテキストで、__mode=view, _type=entry, id指定なし)の場合のみ動作
    my $blog = $app->blog || return 1;
    return 1 if !$app->param('__mode') || $app->param('__mode') ne 'view';
    return 1 if !$app->param('_type') || $app->param('_type') ne 'entry';
    return 1 if $app->param('id');

    my $config = plugin_config($blog->id);
    pp($config);
    my $new_entry_id = $config->{new_entry_id} || return 1;

    my $new_entry = MT->model('entry')->load({ blog_id => $blog->id, id => $new_entry_id }) || return 1;
    my %hash = $app->param_hash;

    my $copy_uri = $app->uri( mode => delete $hash{__mode}, args => {
        %hash, id => $new_entry_id, copy => 1,
    });

    print STDERR $copy_uri, "\n";
    $app->redirect($copy_uri);
}

1;