package Processor::DateFormats;
use Time::Piece;
use 5.010;
use Data::Dumper;
use Try::Tiny;

my %formats = (
	'\d{2}[.\/ -]\d{2}[.\/ -]\d{4}[.\/ -]\d{2}[.\/: ]\d{2}[.\/: ]\d{2}' => "%d %m %Y %H %M %S",
	'\d{4}[.\/ -]\d{2}[.\/ -]\d{2}[.\/ -]\d{2}[.\/: ]\d{2}[.\/: ]\d{2}' => "%Y %m %d %H %M %S",
	'\d{2}[.\/ -]\w{3}[.\/ -]\d{4}[.\/ -]\d{2}[.\/: ]\d{2}[.\/: ]\d{2}' => "%d %b %Y %H %M %S",
	'\d{4}[.\/ -]\w{3}[.\/ -]\d{2}[.\/ -]\d{2}[.\/: ]\d{2}[.\/: ]\d{2}' => "%Y %b %d %H %M %S",
	
	'\d{2}[.\/: ]\d{2}[.\/: ]\d{2}[.\/ -]\d{4}[.\/ -]\d{2}[.\/ -]\d{2}' => "%H %M %S %Y %m %d",
	'\d{2}[.\/: ]\d{2}[.\/: ]\d{2}[.\/ -]\d{2}[.\/ -]\d{2}[.\/ -]\d{4}' => "%H %M %S %d %m %Y",
	'\d{2}[.\/: ]\d{2}[.\/: ]\d{2}[.\/ -]\d{4}[.\/ -]\w{3}[.\/ -]\d{2}' => "%H %M %S %Y %b %d",
	'\d{2}[.\/: ]\d{2}[.\/: ]\d{2}[.\/ -]\d{2}[.\/ -]\w{3}[.\/ -]\d{4}' => "%H %M %S %d %b %Y",
	
	
);

sub getDate{
	my ($str) = @_;
	
	my ($foundFormat, $foundDate);
	foreach my $format (keys %formats){
		if ($str =~ /($format)/){
			$foundFormat = $formats{$format};
			$foundDate = $1;
			last;
		}
	}
	
	return undef unless defined $foundFormat;
	
	#transform date so that it only contains single spaces as separators
	$foundDate =~ s/[:.\/-]/ /g;
	$foundDate =~ s/[ ]{2,}/ /g;
	
	#print "FoundDate: $foundDate, foundFormat: $foundFormat\n";
	my $time;
	try {
		$time = Time::Piece->strptime($foundDate, $foundFormat);
	} catch {
   	    warn "$foundDate matches $foundFormat but it wasn't possible to parse, caught error: $_"; # 
  	};
	
	
	return $time;
}

=test
say getDate('01/04/2017 11:05:15')->datetime;
say getDate('01/Apr/2017/11.05.15')->datetime;
say getDate('2017-04-01 11.05.15')->datetime;
say getDate('2017-Apr-01 11.05.15')->datetime;
say getDate('2017.04.01 11.05.15')->datetime;
say getDate('11.05.15 01.04.2017')->datetime;
say getDate('11.05.15 2017.04.01')->datetime;
say getDate('11.05.15 2017.Apr.01')->datetime;
say getDate('11.05.15 01.Apr.2017')->datetime;
=cut

1;