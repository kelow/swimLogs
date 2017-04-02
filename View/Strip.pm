package View::Strip;
use Moo;

has w => (is=>'rw');
has h => (is=>'rw');

has minX => (is=>'rw');
has minY => (is=>'rw');

has color => (is=>'rw');

has text => (is=>'rw');
has details => (is=>'rw');

sub isInside{
	my ($self, $xMin, $xMax) = @_;
	if ($self->minX < $xMax and $self->maxX > $xMin){
		return 1;
	}
	print "Strip " . $self -> minX . ', ' . $self->maxX . " is outside $xMin, $xMax\n";
	return 0;
}

sub maxX{
	my ($self) = @_;
	my $w = $self -> w;
	$w = 5 if $w < 5;
	return $self -> minX + $w;
}

sub maxY{
	my ($self) = @_;
	return $self -> minY + $self -> h;
}

1;