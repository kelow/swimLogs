package View::LogFrame;
use IUP qw(:all);
use Moo;

has frame => (is => 'rw');
has file  => (is => 'rw');
has ids   => (is => 'rw');
has types => (is => 'rw');


has fFile  => (is => 'rw');
has lIDs   => (is => 'rw');
has lTypes => (is => 'rw');



sub create {
   my ($class) = @_;
   my $self = $class->new();
   
   $self->fFile(IUP::Text->new());
   $self->lIDs(IUP::List->new(MULTIPLE=>"YES", VISIBLE_ITEMS=>"5"));
   $self->lTypes(IUP::List->new(MULTIPLE=>"YES", VISIBLE_ITEMS=>"5"));
   
   $self->frame(IUP::Vbox->new(child=>[$self->fFile, $self->lIDs, $self->lTypes]));
   return $self;
   
}



1;