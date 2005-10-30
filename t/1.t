# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
BEGIN { use_ok('Image::Resize') };
use File::Spec;
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $image = Image::Resize->new(File::Spec->catfile('t', 'large.jpg'));

#printf "Original image size: %s x %s\n", $image->gd->width, $image->gd->height;

my @array = (
#    [10, 15],
#    [15, 10],
#    [12, 10],
#    [20, 20],
#    [21, 20],
#    [20, 21],
#    [100, 95],
#    [100, 100],
#    [120, 100],
#    [100, 120],
#    [$image->width, $image->height],
#    [$image->height, $image->width],
#    [500, 500],
#    [300, 500]
    [250, 250],
    [120, 120],
    [40, 40],
    [40, 24],
);

foreach my $dimensions ( @array ) {
    my ($width, $height) = @$dimensions;
    printf "RESIZE: %dx%d...", $width, $height;
    my $gd = $image->resize($width, $height);
    open(FH, sprintf(">t/resized-%sx%s.jpg", $gd->width, $gd->height)) or die $!;
    print FH $gd->jpeg();
    close(FH) or die $!;
}
