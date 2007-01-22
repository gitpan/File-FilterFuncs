use strict;
use warnings;
use Test::More tests => 6;
use File::FilterFuncs qw(filters);
use File::Slurp;
use File::Spec::Functions;
use Fatal qw(open close);
use Fcntl qw(:seek);
use t::FF_Common;

t::FF_Common::init;

my ($infh, $outfh);
my $source = catfile(t => 'source.txt');

# Perform a simple copy.
filters ($source, testfile(1));
ok(diff($source,testfile(1)), 'simple copy');

# Perform a simple copy with a function.
filters ($source, sub { $_ }, testfile(2));
ok(diff($source,testfile(2)), 'simple copy with function');

# Uppercase the test file.
open ($infh, '<', $source);
open ($outfh, '>', testfile(3));
while (<$infh>) {
	print $outfh uc $_;
}
close $outfh;
close $infh;

filters ($source, sub { uc $_ }, testfile('3b'));
ok(diff(testfile(3),testfile('3b')), 'convert to uppercase');

# Uppercase the test file and add a prefix.
open ($infh, '<', $source);
open ($outfh, '>', testfile(4));
while (<$infh>) {
	print $outfh "Line:" . uc $_;
}
close $outfh;
close $infh;

filters ($source, sub { uc $_ }, sub { "Line:" . $_ }, testfile('4b'));
ok(diff(testfile(4),testfile('4b')), 'uppercase and add a prefix');

# Change the file's encoding to utf-8:
open ($infh, '<', $source);
open ($outfh, '>:utf8', testfile(5));
while (<$infh>) {
	print $outfh $_;
}
close $outfh;
close $infh;

filters ( $source, boutmode => ':utf8', testfile('5b'));
ok(diff(testfile(5),testfile('5b')), 'boutmode => :utf8');

# Change the file's encoding from utf-8 to iso-8859-1.
open ($infh, '<:utf8', testfile(5));
open ($outfh, '>', testfile(6));
while (<$infh>) {
	print $outfh $_;
}
close $outfh;
close $infh;

filters (testfile(5), binmode => ':utf8', testfile('6b'));
ok(diff(testfile(6),testfile('6b')), 'binmode => :utf8');

t::FF_Common::cleanup;

##############################################

sub diff {
	my ($name1, $name2) = @_;
	my $file1 = read_file $name1, binmode => ':raw';
	my $file2 = read_file $name2, binmode => ':raw';
	$file1 eq $file2;
}

sub testfile {
	catfile($Common{tempdir},'t.' . shift());
}



