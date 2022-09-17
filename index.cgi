#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use feature qw(say);
use Encode;
use YAML::Syck qw(LoadFile Dump);
use Template;
use CGI;
use FindBin::libs "Bin=${FindBin::RealBin}";
use QRCode;
use open ':std' => ':utf8';

$|                           = 1;
$YAML::Syck::ImplicitUnicode = 1;

my $q = new CGI;
$q->charset('utf-8');
my $tt = Template->new(
    {   INCLUDE_PATH => './templates',
        ENCODING     => 'utf-8',
    }
) or die( Template->error() );

my $query  = { map { $_ => [ $q->multi_param($_) ]; } $q->multi_param() };
my $text   = $q->param('textareaText') || '';
my $qrcode = makeQRCode($text);

my $out = $q->header(
    -type    => 'text/html',
    -charset => 'utf-8',
);
$tt->process(
    'index.html',
    {   title  => "QREncodes",
        info   => undef,               # Dump($query),
        text   => $text,
        fname  => $qrcode->{'name'},
        qrcode => $qrcode->{'body'},
    },
    \$out
) or die( $tt->error );

say $out;
