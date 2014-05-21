#!perl

use strict;
use warnings;

use FindBin;
use File::Spec;
use File::Temp qw/tempdir/;
use File::Touch;

use Test::More;
use File::Find::Rule::Age;

my $test_dir = File::Temp->newdir(CLEANUP => 1);
my $dir_name = $test_dir->dirname;

my $now = DateTime->now();
my $today = DateTime->now();
   $today->truncate( to => 'day' );
my $yesterday = DateTime->now();
   $yesterday->truncate( to => 'day' );
$yesterday->subtract( days => 2 );

File::Touch->new(time => $now->epoch)->touch( File::Spec->catfile( $dir_name, 'newer' ) );
File::Touch->new(time => $yesterday->epoch)->touch( File::Spec->catfile( $dir_name, 'older' ) );

my @older = find( file => age => [ older => "1D" ], in => $dir_name );
is_deeply( \@older, [File::Spec->catfile($dir_name, 'older')], "older" );
my @newer = find( file => age => [ newer => "1D" ], in => $dir_name );
is_deeply( \@newer, [File::Spec->catfile($dir_name, 'newer')], "newer" );

done_testing;
