package Util::Flatten;

sub flatten {
	my ($ar) = @_;
	my $ret = [];
	
	foreach my $el(@$ar){
		if (ref($el) eq "ARRAY") {
			my $flat = flatten($el);
			foreach my $f (@$flat){
				push @$ret, $f;
			}
		} else{
			push @$ret, $el;
		}
	}
	
	return $ret;
}

1;
