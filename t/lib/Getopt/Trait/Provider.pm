package # hide from PAUSE
    Getopt::Trait::Provider;
use strict;
use warnings;

use decorators ':for_providers';

sub Opt : TagMethod { () }

1;
