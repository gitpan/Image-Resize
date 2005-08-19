package Image::Resize;

# $Id: Resize.pm,v 1.3 2005/08/19 16:58:23 sherzodr Exp $

use strict;
use Carp ('croak');
use GD;

$Image::Resize::VERSION = '0.03';


#
# Thanks to Paul Allen <paul.l.allen AT comcast.net> for this tip
#
GD::Image->trueColor( 1 );

sub new {
    my ($class, $image) = @_;

    unless ( $class && defined($image) ) {
        croak "Image::Resize->new(): usage error";
    }

    unless ( -e $image ) {
        croak "Image::Resize->new(): file '$image' does not exist";
    }
    my ($type) = $image =~ m/\.(\w\w\w\w?)$/;
    unless ( $type ) {
        require Image::Info;
        my $info = Image::Info::image_info($image);
        if ( my $error = $info->{error} ) {
            croak "Image::Info::info(): $error";
        }
        $type = $info->{file_ext} or croak "Image::Resize->new(): type of file '$image' is not known";
    }
    my %type_map = (
        jpg         => 'newFromJpeg',
        jpeg        => 'newFromJpeg',
        gif         => 'newFromGif',
        png         => 'newFromPng'
    );

    my $method;
    unless ( $method = $type_map{ $type } ) {
        croak "Image::Resize->new(): '$type' is an unsupported format"
    }

    my $gd = GD::Image->$method($image) or die $@;
    return bless {
        file_path   => $image,
        type        => $type,
        gd          => $gd
    }, $class;
}


sub width {
    return ($_[0]->gd->getBounds)[0];
}

sub height {
    return ($_[0]->gd->getBounds)[1];
}

sub gd      {   return $_[0]->{gd}  }
sub type    {   return $_[0]->{type}}

sub resize {
    my $self = shift;
    my ($width, $height, $constraint) = @_;

    unless ( defined $constraint ) {
        $constraint = 1;
    }

    unless ( $width && $height ) {
        croak "Image::Resize->resize(): usage error";
    }

    if ( $constraint ) {
        my $k;
        if ( $self->width > $self->height ) {
            $k = $width / $self->width;
        } else {
            $k = $height / $self->height;
        }
        $height = int($self->height * $k);
        $width  = int($self->width * $k);
    }

    my $image = GD::Image->new($width, $height);
    $image->copyResampled($self->gd,
        0, 0,               # (destX, destY)
        0, 0,               # (srcX,  srxY )
        $width, $height,    # (destX, destY)
        $self->width, $self->height
    );
    return $image;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Image::Resize - Simple image resizer using GD

=head1 SYNOPSIS

    use Image::Resize;
    $image = Image::Resize->new('large.jpg');
    $gd = $image->resize(250, 250);

=head1 ABSTRACT

Resizes images using GD graphics library

=head1 DESCRIPTION

Despite its heavy weight, I've always used Image::Magick for creating image thumbnails. I know it can be done using lighter-weight GD, I just never liked its syntax. Really, who wants to remember the lengthy arguments list of copyResized() or copyResampled() functions:

    $image->copyResampled($sourceImage,$dstX,$dstY,
                        $srcX,$srcY,$destW,$destH,$srcW,$srcH);

when Image::Magick lets me say:

    $image->Scale(-geometry=>'250x250');

Image::Resize is one of my attempts to make image resizing easier, more intuitive using GD.

=head1 METHODS

=over 4

=item new('path/to/image.jpeg')'

Constructor method. Creates and returns Image::Resize object. Expects path to the image as its first and only argument. Supported image formats are I<jpeg>, I<png> and I<gif>. Starting 0.3 extension is no longer required. If it's missing, it will attempt to retrieve the file type using L<Image::Info|Image::Info>, so Image::Info has to be installed to be able to process images without any extension.

=item resize($width, $height);

=item resize($width, $height, $constraint);

Returns a GD::Image object for the new, resized image. Original image is not modified. This lets you create multiple thumbnails of an image using the same Image::Resize object.

First two arguments are required, which define new image dimensions. By default C<resize()> retains image proportions while resizing. This is always what you expect to happen. In case you don't care about retaining image proportions, pass C<0> as the third argument to C<resize()>.

Following example creates a 120x120 thumbnail of a "large" image, and stores it in disk:

    $image = Image::Resize->new("large.jpg");
    $gd = $image->resize(120, 120);

    open(FH, '>thumbnail.jpg');
    print FH $gd->jpeg();
    close(FH);

=item gd()

Returns internal GD::Image object for the original image (the one passed to Image::Resize->new).

=item width()

=item height()

Returns original image's width and height respectively. If you want to get resized image's dimensions, call width() and height() methods on the returned GD::Image object, like so:

    $gd = $image->resize(120, 120);
    printf("Width: %s, Height: %s\n", $gd->width, $height);

=item type()

Returns suggested file-extension for the image. It's always the same as the extension of the original image. type() is particularly useful if original image didn't have an extension.

=back

=head1 BUGS AND LIMITATIONS

=over 4

=item *

To fool Image::Resize all you need is a false file extension. This is because it tries not to rely on L<Image::Info|Image::Info>, but tries to guess the type by looking at extension alone. It will invoke Image::Info only if an extension is missing. I realize it may be better if it ignores file extensions altogether, and relies solely on Image::Info. I just didn't want to add a prerequisite to fix a rarely encountered problem.

=item *

Someone needs to have a look at my scaling routine. I'm not sure if it's compatible with Image::Magick's C<Scale()>. Needs testing.

=back

=head1 CREDITS

Thanks to Paul Allen <paul.l.allen AT comcast.net> for trueColor(1) tip. Now GD::Resize should work fine for photographs too.

=head1 SEE ALSO

L<Image::Info>, L<GD>, L<Image::Magick>

=head1 AUTHOR

Sherzod B. Ruzmetov, E<lt>sherzodr@cpan.orgE<gt>
http://author.handalak.com/

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Sherzod B. Ruzmetov

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut



