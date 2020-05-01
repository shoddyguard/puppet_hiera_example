# I think this is needed to apply classes to nodes in the way I want (eg the Redgate way 0:))
# It should assign classes to nodes via Hirea instead of through this site.pp
lookup('classes', Array[String], 'unique', []).include

# A default empty node is needed for puppet to get far enough to lookup classes from hiera...
node default { }
