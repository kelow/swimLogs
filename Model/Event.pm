package Model::Event;
use Moo;
use MooX::late;


has startLine => (is => 'rw');
has endLine => (is => 'rw');

has startTime => (is => 'rw', isa=>'Time::Piece');
has endTime => (is => 'rw');

has details => (is => 'rw');
has name => (is => 'rw');

has children => (is => 'rw');
has color => (is => 'rw');
has level => (is => 'rw');




1;