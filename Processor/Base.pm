package Processor::Base;
use Moo;
use MooX::late;
use Try::Tiny;
use Time::Piece;
use JSON;
use Data::Dumper;
use File::Slurp;
use List::Object; 
use FindBin;
use lib $FindBin::Bin . '\\..';

use Model::Event;
use Processor::DateInterpolator;

#input - 
has definition => (is => 'ro', isa => 'Str');

has input => (is => 'rw', isa => 'Processor::Input');
has startedAt => (is => 'rw', isa => 'Time::Piece');
has endedAt => (is => 'rw', isa => 'Time::Piece');

has startMatcher => (is=> 'rw');
has endMatcher => (is => 'rw');
has singleMatcher => (is => 'rw');

has details => (is => 'rw');
has id => (is => 'rw');
has color => (is => 'rw');

has processorType => (is => 'rw');

has children => (is => 'rw', isa => 'List::Object');

has events => (is => 'rw', isa => 'List::Object') ;

has level => (is => 'rw');

sub load {
	my ($self, ) = @_;
	my $text = read_file(  $self->definition ) ;
	
	my $json = JSON->new->allow_nonref;
	
	my $ref = $json->decode($text);
	$self -> fromHashRef ($ref, 0);
	
	#print Dumper $self;
}

#generates tree of Base Objects from hashref
sub fromHashRef{
	my ($self, $ref, $level) = @_;
	
	$self -> processorType ($ref -> {name});
	$self -> startMatcher ($ref -> {startMatcher});
	$self -> endMatcher ($ref -> {endMatcher});
	$self -> singleMatcher ($ref -> {matcher});
	$self -> details ($ref -> {details});
	$self -> id($ref -> {id});
	$self -> singleMatcher ($ref -> {matcher});
	$self -> color ($ref -> {color});
	$self -> level($level);
	
	if ($ref -> {children}){
		$self->children(List::Object->new(type=>"Processor::Base"));
		foreach my $ch (@{$ref->{children}}){
			my $child = Processor::Base -> new();
			$child -> fromHashRef($ch, $level + 1);
			$self->children()->add($child);
		}
	}
}

#looks for: singleEvents, lastingEvents, any children events
sub processInput{
	my ($self) = @_;
	$self-> events(List::Object->new(type=>'Model::Event'));	
	
	if ($self -> singleMatcher){
		$self -> findSingleEvents();
	} elsif ($self -> startMatcher){
		$self -> findLastingEvents();
	} else {
		die "Processor " . $self -> processorType() . " has no single nor lasting matcher\n";
	}
	if ($self -> children){
		$self -> findForChildren();
	}
}

#calls all children but starting from our own first match
sub findForChildren{
	my ($self) = @_;
	foreach my $child ($self -> children -> array){
		my $firstEvent = $self -> events -> get(0);
		if ($firstEvent and $firstEvent -> startLine){
			$self -> input -> lineIndex($firstEvent-> startLine);
		} else {
			$self -> input -> lineIndex(0);
		}
		$child -> input($self -> input);
		$child -> processInput();
	}
}

sub findSingleEvents{
	my ($self) = @_;
	my $matcher = $self->singleMatcher;
	print "Match single against: $matcher\n";
	while (my $line = $self->input->getLineAndAccept){
		if ($line =~ /$matcher/){
			$self->events->add($self -> generateEvent());
			print "At line " . $self->input->lineIndex . " found $matcher, adding new event for " . $self -> processorType . "\n";
		}
	} 
}

sub findLastingEvents{
	my ($self) = @_;
	
	my $startMatcher = $self->startMatcher;
	my $endMatcher = $self->endMatcher;
	
	print "Match lasting against: $startMatcher "; print defined $endMatcher ? "-$endMatcher\n" : "\n";
	while (my $line = $self->input->getLineAndAccept){
		if ($line =~ /$startMatcher/){
			print "At line " . $self->input->lineIndex . " found $startMatcher, adding new event for " . $self -> processorType . "\n";
			$self->closeLastEvent();
			$self->events->add($self -> generateEvent());
			
		} elsif ($endMatcher && $line =~ /$endMatcher/){
			print "At line " . $self->input->lineIndex . " found $endMatcher, closing last event for " . $self -> processorType . "\n";
			$self->closeLastEvent();
		}
	} 
	$self->closeLastEvent();
}

sub generateEvent{
	my ($self) = @_;
	my $event = Model::Event->new(startLine=>$self->input->lineIndex, name => $self -> processorType, level => $self->level);
	if ($self-> details){
		$event->details(eval $self->details);
	}
	if ($self-> id){
		$event->id(eval $self->id);
		print "ID found: " . $event->id . "\n" if $event->id;
	}
	
	if ($self-> color){
		$event->color($self-> color);
	}
	
	return $event;
}

sub closeLastEvent{
	my ($self) = @_;
	return unless $self->events() -> array();
	my $lastEvent = $self->events()->last();
	if ($lastEvent and not $lastEvent->endLine()){
		print "At line " . $self->input->lineIndex . ", closing last event for " . $self -> processorType . "\n";
		$lastEvent->endLine($self->input->lineIndex);
	}
}

sub getEvents{
	my ($self) = @_;
	my @myEvents = $self->events() -> array();
	my $ret = \@myEvents;
	if ($self -> children){
		foreach my $child ($self -> children -> array){
			my $childEvents = $child -> getEvents();
			push @$ret, $childEvents;
		}
	}
	
	return $ret;
}



1;