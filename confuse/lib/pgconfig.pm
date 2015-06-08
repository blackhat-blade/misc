package pgconfig;
use Moose;
extends 'node';
has instanceclass => (is => 'rw', default => 'pgconfiginstance');


package pgconfiginstance;
use Moose;
extends 'pgconfig';
with 'graphinstance';
1;
