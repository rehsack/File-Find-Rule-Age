#!perl

use strict;
use warnings;

use FindBin;
use File::Spec;
use File::Temp qw/tempdir/;
use File::Touch;

use Test::More;
use File::Find::Rule::Age;

my $test_dir = File::Temp->newdir( CLEANUP => 1 );
my $dir_name = $test_dir->dirname;

my $cmp_test_dir = File::Temp->newdir( CLEANUP => 1 );
my $cmp_dir_name = $cmp_test_dir->dirname;

my $now   = DateTime->now();
my $today = DateTime->now();
$today->truncate( to => 'day' );
my $yesterday = DateTime->now();
$yesterday->truncate( to => 'day' );
$yesterday->subtract( days => 2 );
my $lastday = DateTime->now();
$lastday->subtract( days => 1 );

File::Touch->new( atime => $now->epoch )->touch( File::Spec->catfile( $dir_name,     'now' ) );
File::Touch->new( atime => $now->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'now' ) );
File::Touch->new( atime => $today->epoch )->touch( File::Spec->catfile( $dir_name,     'today' ) );
File::Touch->new( atime => $today->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'today' ) );
File::Touch->new( atime => $lastday->epoch )->touch( File::Spec->catfile( $dir_name,     'lastday' ) );
File::Touch->new( atime => $lastday->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'lastday' ) );
File::Touch->new( atime => $yesterday->epoch )->touch( File::Spec->catfile( $dir_name,     'yesterday' ) );
File::Touch->new( atime => $yesterday->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'yesterday' ) );

my @fl;

@fl = find(
    file => accessed_since => File::Spec->catfile( $cmp_dir_name, 'now' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_since now (File)" );
@fl = find(
    file => accessed_since => $now->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_since now (Number)" );
@fl = find(
    file => accessed_since => $now,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_since now (DateTime)" );
@fl = find(
    file => accessed_since => $now - $now,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_since now (DateTime::Duration)" );

@fl = find(
    file => accessed_after => File::Spec->catfile( $cmp_dir_name, 'today' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_after today (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => accessed_after => $today->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_after today (Number)" ) or diag( explain( \@fl ) );
@fl = find(
    file => accessed_after => $today,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_after today (DateTime)" ) or diag( explain( \@fl ) );
@fl = find(
    file => accessed_after => $now - $today,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "accessed_after today (DateTime::Duration)" )
  or diag( explain( \@fl ) );

@fl = find(
    file => accessed_until => File::Spec->catfile( $cmp_dir_name, 'yesterday' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_until yesterday (File)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => accessed_until => $yesterday->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_until yesterday (Number)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => accessed_until => $yesterday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_until yesterday (DateTime)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => accessed_until => $now - $yesterday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_until yesterday (DateTime::Duration)" )
  or diag( explain( \@fl ) );

@fl = find(
    file => accessed_before => File::Spec->catfile( $cmp_dir_name, 'lastday' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_before lastday (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => accessed_before => $lastday->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_before lastday (Number)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => accessed_before => $lastday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_before lastday (DateTime)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => accessed_before => $now - $lastday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "accessed_before lastday (DateTime::Duration)" )
  or diag( explain( \@fl ) );

done_testing;
