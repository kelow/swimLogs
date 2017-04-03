use IUP ':all';
use Data::Dumper;
use JSON;

use FindBin;
use lib $FindBin::Bin;
use Model::Event;
use Processor::Input;
use Processor::Base;
use Processor::DateFormats;
use Processor::DateInterpolator;
use View::StripSet;
use View::Canvas;
use View::LogFrame;


my @GVfiles = @ARGV;
push @GVfiles, $FindBin::Bin . '\\Examples\\basic.log' unless @GVfiles;
push @GVfiles, $FindBin::Bin . '\\Examples\\basic.log';
print "Generate for files: ";
print @GVfiles;
print "\n";
my $program = {};

my $stripSet = View::StripSet->new();

loadDefinitions();
my $events = addAllFiles();

$stripSet -> events($events);
my $i = 0;
foreach my $e (@$events){
	print "GenStrips from below table at $i\n";
	print Dumper $e;
	$stripSet -> genStrips($i++);
}

print Dumper $stripSet->strips();

my $cnv = View::Canvas->new();
$cnv->xOffset($stripSet->minTime());
$cnv->xSize($stripSet->maxTime() -$stripSet->minTime());
$cnv->fitScaleX();

$cnv->create(1);
$cnv->strips($stripSet->strips());
$cnv->redrawSvg();


sub loadDefinitions{
	my $resDir = $FindBin::Bin . '\\Resources';
	opendir (my $dh, $resDir) or die "Can't open resources: $!";
	my @files = grep { /^[^.].*json/ && -f "$resDir\\$_" } readdir($dh);
	print "Found definitions: ";
	{
		local $, = ", ";
		print @files;
		print "\n";
	}
	
	foreach my $f (@files){
		$f =~ /(.*)\..*/;
		$program -> {definitionTypes} -> {$1} = $f;
	}
	
	$program -> {definitionDir} = $resDir;
}

sub addAllFiles{
	my @events;
	foreach my $log (@GVfiles){
		print "Loading file: $log\n";
		my $e = loadFile($log);
		push @events, $e;
	}
	return \@events;
}

sub loadFile{
	my ($file) = @_;
	my $input = Processor::Input->new();
	$input->fromFile($file);
	
	my $definition;
	foreach my $def (keys $program -> {definitionTypes}){
		if ($file =~ /$def/){
			$definition = $program->{definitionDir} . '\\' .$program -> {definitionTypes} -> {$def};
		}
	}
	
	my $basicProcessor = Processor::Base->new(definition => $definition);
	$basicProcessor -> load();
	$basicProcessor -> input ($input);
	$basicProcessor -> processInput();
	
	my $events = $basicProcessor -> getEvents();
	
	my $interpolator = Processor::DateInterpolator->new(input=> $input);
	$interpolator -> loadDates();
	$interpolator -> fillDatesInEvents($events);
	#print "Dumping events for file $file :";
	#print Dumper $events;
	
	return $events;
}

sub init_dialog{
	my $f1 = View::LogFrame->create();
	my $ff1 = $f1->frame();
	my $hbox = IUP::Hbox -> new(child=>$ff1);
	return IUP::Dialog->new( TITLE=>"Swim Logs", child=>$hbox, SIZE=>"400x" );
}

my $dlg = init_dialog();
$dlg->Show();
IUP->MainLoop();