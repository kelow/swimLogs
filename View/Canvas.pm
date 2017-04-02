package View::Canvas;
use Moo;
use IUP::Constants ':cd';
use IUP::Canvas;
use IUP::Canvas::FileVector;
use Data::Dumper;
use SVG;

#size of image IN MILLIMETERS!!!
has w => (is => 'rw', default => 3000); 
has h => (is => 'rw', default => 400);

#real world sizes, time in seconds for X
has xSize => (is => 'rw', default => 2800);
has ySize => (is => 'rw', default => 600);

#scale from real world to image
has xScale => (is => 'rw', default => .5);
has yScale => (is => 'rw', default => 1);

#time offset
has xOffset => (is => 'rw', default => 1491048000);
#swimline offset
has yOffset => (is => 'rw', default => 0);

has canvas => (is => 'rw');

has strips => (is => 'rw');

has scaleDecreaseRate => (is => 'rw', default => 0.1);

has isSvg => (is => 'rw', default => 0);

has fontSize => (is => 'rw', default => 12);
has fontWidth => (is => 'rw', default => 0.55);


sub create(){
	my ($self, $isSvg) = @_;
	$self -> isSvg($isSvg);
	
	if ($self -> isSvg){
		$self -> canvas(SVG->new( width =>  $self->w, height => $self->h, onload=>"init(evt)"));
		my $style = $self -> canvas->style(
		    type => 'text/css',
		) -> cdata('.func_g:hover { stroke:black; stroke-width:0.5; }');
		
		my $srcipt = $self -> canvas -> script(
			type => 'text/ecmascript',
		) -> cdata_noxmlesc ('<![CDATA[
			var details;
			function init(evt) { details = document.getElementById("details").firstChild; }
			function s(info) { details.nodeValue = info; }
			function c() { details.nodeValue = \' \'; }
		]]>');
		
		my $details = $self -> canvas->text(
		    x => '10',
		    y => '225',
		    'font-size' => $self->fontSize,
		    id => 'details',
		    'font-family'=>'Verdana'
		)->cdata(' ');
		
		print "Create SVG with " . $self->w . 'x' . $self->h . "\n";
	}
}

sub fitScaleX{
	my ($self) = @_;
	$self->xScale($self->w / $self -> xSize);
}

sub color {
	my ($color) = @_;
	unless (defined $color){
		my $r = 205 + int(rand(50));
		my $g = 0 + int(rand(230));
		my $b = 0 + int(rand(55));
		$color = "rgb($r,$g,$b)";
	}
	
	return $color;
}

sub decreaseScaleX{
	my ($self) = @_;
	$self -> xScale ($self -> xScale * (1 - $self -> scaleDecreaseRate));
}

sub increaseScaleX{
	my ($self) = @_;
	$self -> xScale ($self -> xScale * (1 + $self -> scaleDecreaseRate));
}

sub getVisibleLimits{
	my ($self) = @_;
	my $min = $self->xOffset;
	my $width = $self -> w / $self -> xScale;
	return ($min, $min + $width);
	
}

sub worldToCanvas{
	my ($self, $wx, $wy) = @_;
	my $x = ($wx - $self -> xOffset) * $self -> xScale;
	my $y = ($wy - $self -> yOffset) * $self -> yScale;
	return ($x, $y);
}

sub redrawSvg {
	my ($self) = @_;
	
	my @sorted = @{$self -> strips()};
	#sort so that longer events are drawn first (z-order issues for parallel events on the same level)
	@sorted = sort {$b->w <=> $a->w} @sorted;
	
	foreach my $strip (@sorted){
		if ($strip -> isInside ($self->getVisibleLimits)){
		#	print "Strip is inside: ";
		#	print Dumper $strip;
			my ($xMin, $yMin) = $self -> worldToCanvas($strip->minX, $strip->minY);
			my ($xMax, $yMax) = $self -> worldToCanvas($strip->maxX, $strip->maxY);
			#print "Strip draw $xMin, $xMax, $yMin, $yMax\n" ;
			
			my $text =  $strip -> text;
			$text .= ': ' . $strip -> details if $strip -> details;
			
			#each event in a new group
			my $group = $self->canvas->group(
				class=>'func_g',
				onmouseover=>"s('$text')",
				onmouseout=>'c()'
			);
			
			#add title for hover text
			$group -> title () -> cdata($text);
			
			#add rectangle with default or random color
			$group -> rectangle(
				x     => $xMin + 0.5, 		y      => $yMin,
    			width => $xMax - $xMin - 1, height => $yMax - $yMin,
    			rx    => 3, ry     => 3,
    			fill => color($strip->color),
    			opacity => 0.8
			);
			
			#calculate how many characters will fit and add text
			my $chars = int( ($xMax - $xMin) / ($self-> fontSize * $self->fontWidth) + 0.5);
			$text = substr $text, 0, $chars;
			$group -> text(
				x => $xMin + 1.5, 
				y => ($yMin + $yMax)/2 +  $self -> fontSize / 4 ,
				"font-size" => $self -> fontSize,    			
    			fill => 'rgb(0,0,0)'
			) -> cdata($text);
			
		} else {
			print "Strip is outside: ";
			print Dumper $strip;
		}
	}
	
	open (my $fh, '>', 'test.svg') or die $!;
	print $fh $self -> canvas -> xmlify;
}

sub redraw{
	my ($self) = @_;
	$self->canvas->cdForeground(CD_RED);
	foreach my $strip (@{$self -> strips()}){
		if ($strip -> isInside ($self->getVisibleLimits)){
		#	print "Strip is inside: ";
		#	print Dumper $strip;
			my ($xMin, $yMin) = $self -> worldToCanvas($strip->minX, $strip->minY);
			my ($xMax, $yMax) = $self -> worldToCanvas($strip->maxX, $strip->maxY);
			print "Strip draw $xMin, $xMax, $yMin, $yMax\n" ;
			$self->canvas->cdfBox($xMin, $xMax, $yMin, $yMax);
		} else {
			print "Strip is outside: ";
			print Dumper $strip;
		}
	}
	if ($self -> isSvg){
		$self->canvas->cdKillCanvas;
	}
}
1;