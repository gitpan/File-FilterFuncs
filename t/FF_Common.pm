package t::FF_Common;
use strict;
use warnings;
use POSIX qw(tmpnam);
use Exporter qw(import);
use File::Spec::Functions;

BEGIN {
	our @ISA = qw(Exporter);
	our @EXPORT = qw(%Common);
}

my $tmpnam = tmpnam();
# my $tmpnam = '/tmp/ff.test.dir';

our %Common = (
	tempdir => $tmpnam,
	tempin => catfile($tmpnam,'input'),
	tempout => catfile($tmpnam,'output'),
);

sub init {
	return if (-d $Common{tempdir});
	mkdir $Common{tempdir};
}


sub cleanup {
	unlink $Common{tempin};
	unlink $Common{tempout};
	my @temps = glob(catfile($Common{tempdir},'t.*'));
	unlink @temps;
	rmdir $Common{tempdir};
}


1;

