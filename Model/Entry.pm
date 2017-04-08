package Model::Entry;
use Moo;
use List::Object;


has name => (is => 'rw');
has show => (is => 'rw');
has level => (is => 'rw');
has color => (is => 'rw');


1;