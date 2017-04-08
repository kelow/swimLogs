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
   my ($class, @others) = @_;
  # print @others;
   my $self = $class->new(@others);
   
   my $i = 0;
   my %idh;
   foreach my $id (sort @{$self->ids}){
       $idh{$i++} = $id;
   }
   
   $i = 0;
   my %typeh;
   foreach my $type (sort @{$self->types}){
       $typeh{$i++} = $type;
   }
   
   $self->fFile(IUP::Text->new(READONLY => "YES", VALUE=>$self->file, EXPAND => "HORIZONTAL"));
   $self->lIDs(IUP::List->new(MULTIPLE=>"YES", VISIBLE_ITEMS=>"5", EXPAND => "HORIZONTAL" , %idh));
   $self->lTypes(IUP::List->new(MULTIPLE=>"YES", VISIBLE_ITEMS=>"5", EXPAND => "HORIZONTAL" , %typeh));
   
  
   
   $self->frame(IUP::Vbox->new(child=>[$self->fFile, $self->lIDs, $self->lTypes], EXPAND => "HORIZONTAL"));
   
   
   
   return $self;
}





1;