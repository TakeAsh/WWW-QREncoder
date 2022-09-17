package QRCode;
use 5.010;
use strict;
use warnings;
use Carp qw(croak);
use utf8;
use feature qw(say);
use Encode;
use Exporter 'import';
use YAML::Syck qw(LoadFile DumpFile Dump);
use Imager::QRCode;
use Data::GUID;
use File::Slurp  qw(read_file);
use MIME::Base64 qw(encode_base64);
use version 0.77; our $VERSION = version->declare("v0.0.1");

our @EXPORT = qw(
    makeQRCode
);

$YAML::Syck::ImplicitUnicode = 1;

sub makeQRCode {
    my $text   = shift or return;
    my $qrcode = Imager::QRCode->new(
        level         => 'H',
        casesensitive => 1,
    );
    my $img  = $qrcode->plot($text);
    my $name = Data::GUID->new;
    my $path = "/tmp/${name}.png";
    $img->write( file => $path ) or die( "Failed to write: " . $img->errstr );
    my $contents = read_file( $path, { binmode => ':raw' } )
        or die("Failed to read: $!");
    unlink($path);
    $text =~ s/([\x00-\x1f\x21-\x2c\x2e\x2f\x3a-\x3f\x5b-\x5e\x60\x7b-\x7f]) 
        /sprintf("%%%02X",ord($1))
        /gex;
    return {
        body => 'data:image/png;base64,' . encode_base64($contents),
        name => $text,
    };
}

1;
