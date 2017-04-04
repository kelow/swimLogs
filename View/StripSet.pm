package View::StripSet;
use Moo;

use FindBin;
use lib $FindBin::Bin . '\\..';

use Util::Flatten;
use View::Strip;
	
has events => (is => 'rw');
has strips => (is => 'rw',);
has filters => (is => 'rw');
has minTime => (is => 'rw', default => 9999999999);
has maxTime => (is => 'rw', default => 0);
has levels => (is => 'rw');


has set => (is => 'rw');

sub genStrips{
	my ($self, $setIndex) = @_;
	
	$setIndex = 0 unless defined $setIndex;
	                 
	my $strips = $self -> strips;
	$strips = [] unless defined $strips;
	my $events = Util::Flatten::flatten($self -> events -> [$setIndex]);
	
	my $maxLevel = 0;
	my $levelOffset = 0;
	if ($setIndex > 0){
		$levelOffset = $self -> levels -> [$setIndex - 1];
	}
	
	print "getStrips $setIndex starting at level $levelOffset\n";
	
	foreach my $event (@$events){
		my $strip = View::Strip -> new();
		$strip ->minX($event->startTime->epoch);
		$strip ->w($event->endTime->epoch - $event->startTime->epoch);
		
		$strip ->minY($levelOffset + $event->level * 15);
		$strip ->h(14);
		
		
		if ($strip->minX < $self->minTime){
			$self->minTime($strip->minX);
		}
		if ($strip->maxX > $self->maxTime){
			$self->maxTime($strip->maxX);
		}
		$maxLevel = $strip->minY if ($strip->minY > $maxLevel); 
		
		$strip -> text($event->name);
		
		my $details = defined $event->details ? $event->details : ' ';
		$strip -> id($details);

		$strip -> details( $details . ' from ' . $event->startTime . ' at line ' . $event->startLine);
		if ($event->endLine){
			$strip -> details($strip -> details . ' to ' . $event->endTime . ' at line ' . $event->endLine );
		}
			
		$strip -> color($event->color);
		
		
		push @$strips, $strip;
	}
	
	$self -> levels([]) unless defined $self -> levels;
	$self -> levels -> [$setIndex] = $maxLevel + 15 * 2;
	
	$self -> strips($strips);
}

1;
