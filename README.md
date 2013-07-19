Plivo-Perl-Helper
=================

Perl version Helper for Plivo

This is a Perl version of Helper for Plivo, to make Plivo easier to use.

Require

  LWP::UserAgent;
  HTTP::Request;
  JSON;
  XML::Simple;

For calling Plivo api

    use Net::Plivo;
    my $object = Net::Plivo->new({ auth_id=>your_auth_id, auth_token=>your_auth_token });
    my $args = {
        from       => '18888888888',
        to         => '15101121122',
        answer_url => 'https://sample.com/',
    };
    $boject->call( $args );
    return;

For returning XML

    use Net::Plivo;
    my $object = Net::Plivo->new({ auth_id=>your_auth_id, auth_token=>your_auth_token });
    my $params = {
        action => "https://www.sample.com/?params=1",
        speak  => 'Hello World',
        finishonkey => '#',
    };
    $object->add_getdigits( $params );
    $object->add_speak({ speak=>'Input not received. Thank you' });
    my $xml = $object->respond();

    print "Content-Type: text/xml\n\n";
    print $xml;
    return;

use perldoc to get more info from the code.
