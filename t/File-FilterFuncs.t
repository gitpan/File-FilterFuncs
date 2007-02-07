use strict;
use warnings;
use Test::More tests => 9;
use File::FilterFuncs qw(:all);
# use File::Slurp;
use File::Spec::Functions;
use Fatal qw(open close);
use Fcntl qw(:seek);
use t::FF_Common;

t::FF_Common::init();

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

# Test using a fixed line length.
unslurp_file(testfile(7), 'ABCDEFGHIJKLM');
open ($infh, '<', testfile(7));
open ($outfh, '>', testfile('7b'));
{
	local $/ = \3;
	print $outfh "$_\n" while (<$infh>)
}
close $outfh;
close $infh;

filters (testfile(7), '$/' => \3, sub { "$_\n" }, testfile('7c'));
ok(diff(testfile('7b'), testfile('7c')),
	'setting $/ to an integer reference');

# # Test using the 'grepper' option.
# open ($infh, '<', $source);
# open ($outfh, '>', testfile(8));
# while (<$infh>) {
# 	last if $. >= 5;
# 	print $outfh $_;
# }
# close $outfh;
# close $infh;
# 
# filters ($source, grepper => sub { $. < 5 }, testfile('8b'));
# ok(diff(testfile(8),testfile('8b')),'grepper option');

# Test reading paragraphs.
open ($infh, '<', $source);
open ($outfh, '>', testfile(8));
{
	local $/ = '';
	print $outfh "GROUP:$_" while (<$infh>);
}
close $outfh;
close $infh;

filters ($source, '$/' => '', sub { "GROUP:$_" }, testfile('8b'));
ok(diff(testfile(8),testfile('8b')), 'paragraph reading mode ($/ = "")');

# Test filtering lines.
open ($infh, '<', $source);
open ($outfh, '>', testfile(9));
while (<$infh>) {
	print $outfh $_ if (/[^\s]/);
}
close $outfh;
close $infh;

my $sub = sub {
	unless (/[^\s]/) {
		ignore_line();
		return;
	};
	$_;
};
filters($source, $sub, testfile('9b'));
ok(diff(testfile(9),testfile('9b')),'ignore_lines');

t::FF_Common::cleanup;

##############################################

sub diff {
	my ($name1, $name2) = @_;
	my $file1 = slurp_file($name1, binmode => ':raw');
	my $file2 = slurp_file($name2, binmode => ':raw');
	$file1 eq $file2;
}

sub testfile {
	catfile($Common{tempdir},'t.' . shift());
}


