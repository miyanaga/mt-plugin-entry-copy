package MT::EntryCopy::CMS;

use strict;
use warnings;

use MT::Entry;
use MT::EntryCopy::Util;

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    return 1 unless $app->param('copy');

    my $blog = $app->blog || return 1;
    my $config = plugin_config($blog->id);

    # 新規の記事として振る舞う
    delete $param->{id};
    $param->{new_object} = 1;
    $param->{title} = '' if $config->{clear_title};
    $param->{basename} = '';

    # status_* は status_draft のみ1にする
    foreach my $key ( keys %$param ) {
        $param->{$key} = $key eq 'status_draft' if $key =~ /^status_/;
    }

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
    my $new_entry_id = $config->{new_entry_id} || return 1;

    my $new_entry = MT->model('entry')->load({ blog_id => $blog->id, id => $new_entry_id }) || return 1;

    # 内部的にidを書き換える
    $app->param('id', $new_entry_id);
    $app->param('copy', 1);
    $app->param('_entry_copy', 1);

    1;
}

sub cms_view_permission_filter_entry {
    my ( $cb, $app, $id, $objp ) = @_;

    # フィルタの序盤で記事のユーザーを自分に差し替える
    if ( $app->param('_entry_copy') ) {
        my $obj = $objp->force();
        $obj->author_id($app->user->id);
    }

    1;
}

1;
