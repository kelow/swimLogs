package Model::TypeEntry;
use Moo;
use List::Object;
use FindBin;
use lib $FindBin::Bin . '\..';

BEGIN { extends "Model::Entry" };


has ids => (is => 'rw', isa => 'List::Object', builder => '_buildIds');
has count => (is => 'rw', default => 0);

sub _buildIds {
	return List::Object->new(type => "Model::Entry");
}

1;