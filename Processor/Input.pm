package Processor::Input;
use Moo;
use MooX::late;
use Try::Tiny;

has lines => (is => "rw");


has lineIndex => (is => 'rw', isa => 'Int', default => 0);
has file => (is => 'rw');

sub fromFile{
	my($self, $fileName) = @_;
	open (IN, '<', $fileName) or die "Can't open file $fileName: $!\n";
	local $/ = undef;
	my $content = <IN>;
	#print "Content $content";
	my @lines = split /\r\n|\n|\r/, $content;
	#close $fh;
	local $, = "\n";
	#print @lines;
	
	$self->lines(\@lines);
	$self ->file($fileName);
	foreach my $line (@{$self->lines}){
		$line .= "\n";
	}
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