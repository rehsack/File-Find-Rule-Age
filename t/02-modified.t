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

File::Touch->new( time => $now->epoch )->touch( File::Spec->catfile( $dir_name,     'now' ) );
File::Touch->new( time => $now->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'now' ) );
File::Touch->new( time => $today->epoch )->touch( File::Spec->catfile( $dir_name,     'today' ) );
File::Touch->new( time => $today->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'today' ) );
File::Touch->new( time => $lastday->epoch )->touch( File::Spec->catfile( $dir_name,     'lastday' ) );
File::Touch->new( time => $lastday->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'lastday' ) );
File::Touch->new( time => $yesterday->epoch )->touch( File::Spec->catfile( $dir_name,     'yesterday' ) );
File::Touch->new( time => $yesterday->epoch )->touch( File::Spec->catfile( $cmp_dir_name, 'yesterday' ) );

my @fl;

@fl = find(
    file => modified_since => File::Spec->catfile( $cmp_dir_name, 'now' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_since now (File)" );
@fl = find(
    file => modified_since => $now->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_since now (Number)" );
@fl = find(
    file => modified_since => $now,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_since now (DateTime)" );
@fl = find(
    file => modified_since => $now - $now,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_since now (DateTime::Duration)" );

SCOPE:
{
    my @warns;
    local $SIG{__WARN__} = sub { push @warns, @_ };
    my @fail = find(
        file => modified_since => "Halli-Galli",
        in   => $dir_name
    );
    cmp_ok( scalar @warns, "==", 1, "catched 1 warning for missing 2nd operand" );
    like($warns[0], qr/^Cannot parse reference/, "Missing 2nd operator warning seen");
}

@fl = find(
    file => modified_after => File::Spec->catfile( $cmp_dir_name, 'today' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_after today (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => modified_after => $today->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_after today (Number)" ) or diag( explain( \@fl ) );
@fl = find(
    file => modified_after => $today,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_after today (DateTime)" ) or diag( explain( \@fl ) );
@fl = find(
    file => modified_after => $now - $today,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'now' ) ], "modified_after today (DateTime::Duration)" )
  or diag( explain( \@fl ) );

SCOPE:
{
    my @warns;
    local $SIG{__WARN__} = sub { push @warns, @_ };
    my @fail = find(
        file => modified_after => "Halli-Galli",
        in   => $dir_name
    );
    cmp_ok( scalar @warns, "==", 1, "catched 1 warning for missing 2nd operand" );
    like($warns[0], qr/^Cannot parse reference/, "Missing 2nd operator warning seen");
}

@fl = find(
    file => modified_until => File::Spec->catfile( $cmp_dir_name, 'yesterday' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_until yesterday (File)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => modified_until => $yesterday->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_until yesterday (Number)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => modified_until => $yesterday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_until yesterday (DateTime)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => modified_until => $now - $yesterday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_until yesterday (DateTime::Duration)" )
  or diag( explain( \@fl ) );

SCOPE:
{
    my @warns;
    local $SIG{__WARN__} = sub { push @warns, @_ };
    my @fail = find(
        file => modified_until => "Halli-Galli",
        in   => $dir_name
    );
    cmp_ok( scalar @warns, "==", 1, "catched 1 warning for missing 2nd operand" );
    like($warns[0], qr/^Cannot parse reference/, "Missing 2nd operator warning seen");
}

@fl = find(
    file => modified_before => File::Spec->catfile( $cmp_dir_name, 'lastday' ),
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_before lastday (File)" ) or diag( explain( \@fl ) );
@fl = find(
    file => modified_before => $lastday->epoch,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_before lastday (Number)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => modified_before => $lastday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_before lastday (DateTime)" )
  or diag( explain( \@fl ) );
@fl = find(
    file => modified_before => $now - $lastday,
    in   => $dir_name
);
is_deeply( \@fl, [ File::Spec->catfile( $dir_name, 'yesterday' ) ], "modified_before lastday (DateTime::Duration)" )
  or diag( explain( \@fl ) );

SCOPE:
{
    my @warns;
    local $SIG{__WARN__} = sub { push @warns, @_ };
    my @fail = find(
        file => modified_before => "Halli-Galli",
        in   => $dir_name
    );
    cmp_ok( scalar @warns, "==", 1, "catched 1 warning for missing 2nd operand" );
    like($warns[0], qr/^Cannot parse reference/, "Missing 2nd operator warning seen");
}

done_testing;
