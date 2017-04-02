package Processor::DateInterpolator;
use Moo;
use MooX::late;
use List::Object;
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin . '\\..';
use Processor::Input;
use Processor::DateFormats;

has input => (is => 'rw', isa => 'Processor::Input');

has data => (is => 'rw', isa => 'List::Object');

sub loadDates{
	my ($self) = @_;
	my $input = $self -> input;
	unless($input){
		print "DateInterpolator: no input!\n";
		return;
	}
	$self -> data(List::Object->new());
	$input -> lineIndex(0);
	$self -> {linesMap} = {};
	
	while (my $line = $input -> getLineAndAccept){
		if (my $date = Processor::DateFormats::getDate($line) ){
			$self -> data -> add({'line' => $input -> lineIndex, 'date' => $date});
			$self -> {linesMap} -> {$input -> lineIndex} = $self -> data -> count - 1;
			#print "Matches date : $line " . $date . "\n";
		} else {
			#print "doesnt match date : $line";
		}
	}
	
}

sub fillDatesInEvents{
	my ($self, $events) = @_;
	foreach my $event (@$events ){
		if (ref($event) eq "ARRAY") {
			$self -> fillDatesInEvents($event);
		} else{
			#assume it's Model::Event
			$self -> fillDatesInEvent($event);
		}
	}
}

sub fillDatesInEvent{
	my ($self, $event) = @_;
	my $start = $event -> startLine;
	$event -> startTime($self->findClosestDateForLine($start));
	
	my $end = $event -> endLine;
	if ($end){
		$event -> endTime($self->findClosestDateForLine($end));
	} else {
		$event -> endTime($event -> startTime);
	}
}

sub findClosestDateForLine {
	my ($self, $line) = @_;
	my $idx = $self -> {linesMap} -> {$line};
	if (defined $idx){
		return $self -> data -> get($idx) -> {date};
	} else {
		my $nextDateLine;
		my $previousDateLine;
		
		#find closest lines on both sides of our line
		foreach my $o ($self -> data -> array) {
			my $curLine = $o -> {line};
			if ($curLine > $line){
				$nextDateLine = $curLine;
				last;
			}
			$previousDateLine = $curLine;
		}
		
		#if later date was not found tie current date to the last date stored in previousDateLine
		unless (defined $nextDateLine){
			return $self->getDateForLine($previousDateLine);
		}
		
		#interpolate dates;
		return  $self -> interpolate($previousDateLine, $line, $nextDateLine);
	}
}

sub getDateForLine{
	my ($self, $line) = @_;
	my $idx = $self -> {linesMap} -> {$line};
	return $self -> data -> get($idx) -> {date};
}

#interpolate date for L1 between L0 and L2
sub interpolate {
	my ($self, $l0, $l1, $l2) = @_;
	
	my $date0 = $self -> getDateForLine($l0);
	my $date2 = $self -> getDateForLine($l2);
	return $date0 if $l0 == $l2; #should never happen, just in case
	
	my $diff = $date2 - $date0 ; #Time::Seconds
	my $ratio = ($l1 - $l0) / ($l2 - $l0);
	my $date1 = $date0 + $diff * $ratio;
#	print ("Lines: $l0, $l1, $l2, from $date0, $date2, result: $date1\n");
	return $date1;
	
}

1;