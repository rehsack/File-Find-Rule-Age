#!perl

use strict;
use warnings;

use FindBin;
use File::Spec;
use File::Temp qw/tempdir/;
use File::Touch;

use Test::More;
use File::Find::Rule::Age;

my $extended_testing = $ENV{EXTENDED_TESTING} || $ENV{RELEASE_TESTING};
$extended_testing or plan skip_all => "Long running tests are unwanted";

my $test_dir = File::Temp->newdir( CLEANUP => 1 );
my $dir_name = $test_dir->dirname;

my $cmp_test_dir = File::Temp->newdir( CLEANUP => 1 );
my $cmp_dir_name = $cmp_test_dir->dirname;

my $yesterday = DateTime->now();
File::Touch->new( time => $yesterday->epoch )->touch( File::Spec->catfile( $dir_name,     'yesterday' ) );
File::Touch->new( time => $yesterday->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'yesterday' ) );
sleep 2;

my $lastday = DateTime->now();
File::Touch->new( time => $lastday->epoch )->touch( File::Spec->catfile( $dir_name,     'lastday' ) );
File::Touch->new( time => $lastday->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'lastday' ) );
sleep 2;

my $today = DateTime->now();
File::Touch->new( time => $today->epoch )->touch( File::Spec->catfile( $dir_name,     'today' ) );
File::Touch->new( time => $today->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'today' ) );
sleep 2;

my $now = DateTime->now();
File::Touch->new( time => $now->epoch )->touch( File::Spec->catfile( $dir_name,     'now' ) );
File::Touch->new( time => $now->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'now' ) );

my @fl;

@fl = find(
    file => created_since => File::Spec->catfile( $cmp_dir_name, 'now' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_since now (File)" );
@fl = find(
    file => created_since => $now->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_since now (Number)" );
@fl = find(
    file => created_since => $now,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_since now (DateTime)" );
@fl = find(
    file => created_since => $now - $now,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_since now (DateTime::Duration)" );

@fl = find(
    file => created_after => File::Spec->catfile( $cmp_dir_name, 'today' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_after today (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => created_after => $today->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_after today (Number)" ) or diag( explain( \@fl ) );
@fl = find(
    file => created_after => $today,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_after today (DateTime)" ) or diag( explain( \@fl ) );
@fl = find(
    file => created_after => $now - $today,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "created_after today (DateTime::Duration)" )
  or diag( explain( \@fl ) );

@fl = find(
    file => created_until => File::Spec->catfile( $cmp_dir_name, 'yesterday' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_until yesterday (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => created_until => $yesterday->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_until yesterday (Number)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => created_until => $yesterday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_until yesterday (DateTime)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => created_until => $now - $yesterday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_until yesterday (DateTime::Duration)" )
  or diag( explain( \@fl ) );

@fl = find(
    file => created_before => File::Spec->catfile( $cmp_dir_name, 'lastday' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_before lastday (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => created_before => $lastday->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_before lastday (Number)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => created_before => $lastday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_before lastday (DateTime)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => created_before => $now - $lastday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "created_before lastday (DateTime::Duration)" )
  or diag( explain( \@fl ) );

done_testing;
