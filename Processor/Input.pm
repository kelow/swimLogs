package Processor::Input;
use Moo;
use MooX::late;
use Try::Tiny;

has lines => (is => "rw");

has lineIndex => (is => 'rw', isa => 'Int', default => 0);
has file => (is => 'rw');

sub fromFile{
	my($self, $fileName) = @_;
	open (my $fh, '<', $fileName) or die "Can't open file $fileName: $!\n";
	my @lines = <$fh>;
	close $fh;
	$self->lines(\@lines);
	$self ->file($fileName);
}

sub getLine{
	my ($self) = @_;
	return $self->lines()->[$self->lineIndex()];
	
}

sub accept{
	my ($self) = @_;
	$self->lineIndex($self->lineIndex()+1);
}

sub getLineAndAccept{
	my ($self) = @_;
	my $l = $self -> getLine();
	$self -> accept;
	return $l;
	
}


1;