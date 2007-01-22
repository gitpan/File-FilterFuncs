
package File::FilterFuncs;
use strict;
use warnings;
use Exporter ();
use Fatal qw(open close);

BEGIN {
	our $VERSION = '0.50';
	our @EXPORT_OK = qw(filters);
	our @ISA = qw(Exporter);
}

# These are options that accept arguments.
my @arg_options = qw(binmode boutmode $/);
my %arg_options = map +($_ => 1), @arg_options;

sub filters {
	local $_;
	my %opts = &parse_args;

	open my $in, '<', $opts{source};
	open my $out, '>', $opts{dest};
	binmode $in, $opts{binmode} if $opts{binmode};
	binmode $out, $opts{boutmode} if $opts{boutmode};
	local $/ = $opts{'$/'} if $opts{'$/'};

	while ($_ = <$in>) {
		foreach my $transform (@{$opts{subs}}) {
			$_ = $transform->();
		}
		print $out $_;
	}

	close $out;
	close $in;

}

sub parse_args {
	local $_;
	my %hash;

	die "No source file name" unless ($_[0] && '' eq ref $_[0]);
	die "No destination file name" unless ($_[-1] && '' eq ref $_[-1]);
	$hash{source} = '' . shift;
	$hash{dest} = '' . pop;

	while (@_) {
		$_ = shift;
		if ($arg_options{$_}) {
			$hash{$_} = shift;
		} elsif ('CODE' eq ref($_)) {
		 	push @{$hash{subs}}, $_;
		}
	}

	%hash;
}


1;

