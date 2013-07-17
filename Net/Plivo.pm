package Net::Plivo;

use warnings;
use strict;

use version; 
our $VERSION = qv('0.1.0');

use LWP::UserAgent;
use HTTP::Request;
use XML::Simple;
use JSON;


=head1 NAME

 Net::Plivo

=head1 SYNOPSIS

  use Net::Plivo;
  my $object = Net::Plivo->new({ auth_id=>your_auth_id, auth_token=>your_auth_token });
  my $args = {
      from       => '18888888888',
      to         => '15101121122',
      answer_url => 'https://sample.com/',
  };
  $boject->call( $args );
  return;

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

=head1 DESCRIPTION

this module was made to help user make calls to plivo eaiser


=head2 sub new

Returns a new Net::Plivo object

=head3 Arguments:

  Attribute Name     Description
  ---------------------------------------------------------------------------------------------------------------------
   auth_id         | Auth id From Plivo
  ---------------------------------------------------------------------------------------------------------------------
   auth_token      | Auth token From Plivo
  ---------------------------------------------------------------------------------------------------------------------

=cut

sub new {
    my $proto = shift;
    my $args  = shift;

    my $class = ref( $proto ) || $proto;
    my $self = {};
    bless( $self, $class );

    $self->{AUTH_ID} = $args->{auth_id};
    $self->{AUTH_TOKEN} = $args->{auth_token};
    $self->{BASE_URI}   = "https://api.plivo.com/v1/Account/$self->{AUTH_ID}";

    return $self;
}

=head1 API Request

=head2 sub call

  The following actions can be performed with the Call APIs

  - Make an Outbound Call
    Required Parameters
    $params = {
        form       => 'The phone number to be used as the caller id (with the country code)',
        to         => 'The regular number(s) or sip endpoint(s) to call',
        answer_url => 'The URL invoked by Plivo when the outbound call is answered',
    };
    $object->call( $params );

  - Get All Call Details
    $object->call( $params, 'details' );

  - Get Call Detail Record (CDR) Of a Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $object->call( $params, 'details' );

  - Get All Live Calls

    $object->call( { status=>live }, 'details' );

  - Get Details Of a Live Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
        status    => 'live',
    };
    $object->call( $params, 'details' );

  - Hangup a Specific Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $object->call( $params, 'hangup' );

  - Transfer a Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $boject->call( $params );

  - Record a Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $boject->call( $params, 'record' );

  - Stop Recording a Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $boject->call( $params, 'stop_record' );

  - Play and control sounds during a call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $boject->call( $params, 'play' );

  - Stop playing sounds during a call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $boject->call( $params, 'stop_play' );

  - Play Text During a Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
        text      => 'Text to be played',
    };
    $boject->call( $params, 'speak' );

  - Stop Playing Text During a Call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
    };
    $boject->call( $params, 'stop_speak' );

  - Send digits to a call
    Required Parameters
    $params = {
        call_uuid => 'Caller User ID',
        digits    => 'Digits to be sent',
    };
    $boject->call( $params, 'dtmf' );

  - Hangup a Call Request
    Required Parameters
    $params = {
        request_uuid => 'Request User ID',
    };
    $boject->call( $params, 'hangup_request' );

    For more information please visit http://plivo.com/docs/api/call/

=cut
sub call {
    my $self = shift;
    my $args = shift || {};
    my $type = shift || '';

    my $url  = "$self->{BASE_URI}/Call/";
    if ( $args->{call_uuid} ) {
        $url  .= "$args->{call_uuid}/";
    }

    $url .= 'Record/' if ( $type =~ /record/ );
    $url .= 'Speak/' if ( $type =~ /speak/ );
    $url .= 'Play/' if ( $type =~ /play/ );
    $url .= 'DTMF/' if ( $type eq 'dtmf' );
    $url = "$self->{BASE_URI}/Request/$args->{request_uuid}/" if ( $type eq 'hangup_request');

    my $method = 'POST';
    if ( $type =~ 'details' ) {
        $method = 'GET';
    } elsif ( $type =~ /(hangup|stop_record|stop_speak|hangup_request|stop_play)/ ) {
        $method = 'DELETE';
    }

    delete $args->{request_uuid};
    delete $args->{call_uuid};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub account

  The following actions can be performed with the Account APIs:

  - Get Account Details
    $object->account( $params );

  - Modify an Account
    $object->account( $params, 'modify' );

  - Create a Subaccount
    Required Parameters
    $params = {
        name    => 'Name of the subaccount',
        enabled => 'Specify if the subaccount should be enabled or not. Takes a value of True or False',
    };
    $object->account( $params, 'create_subaccount' );

  - Modify a Subaccount
    Required Parameters
    $params = {
        name       => 'Name of the subaccount',
        enabled    => 'Specify if the subaccount should be enabled or not. Takes a value of True or False',
        subauth_id => 'Subaccount Auth ID',
    };
    $object->account( $params, 'modify_subaccount' );

  - Get Details Of a Specific Subaccount
    Required Parameters
    $params = {
        subauth_id => 'Subaccount Auth ID',
    };
    $object->account( $params, 'subaccount' );

  - Get Details Of All Subaccounts
    $object->account( $params, 'subaccount' );

  - Delete a Subaccount
    Required Parameters
    $params = {
        subauth_id => 'Subaccount Auth ID',
    };
    $object->account( $params, 'delete_subaccount' );

  For more information please visit http://plivo.com/docs/api/account/

=cut
sub account {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || 'details';
    my $method = 'GET';

    my $url = "$self->{BASE_URI}/";

    if ( $type eq 'modify' ) {
        $method = 'POST';
    } elsif ( $type =~ /subaccount/i ) {
        $url .= 'Subaccount/';
        if ( $args->{subauth_id} ) {
            $url .= "Subaccount/$args->{subauth_id}/";
        }
       
        if ( $type =~ /create_subaccount|modify_subaccount|/i ) {
            $method = 'POST';
        } elsif ( $args->{subauth_id} && $type eq 'delete_subaccount' ) {
            $method = 'DELETE';
        }
    }

    delete $args->{subauth_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}
=head2 sub application

  The following actions can be performed with the Application APIs:

  - Create an Application
    Required Parameters
    $params = {
        answer_url => 'The URL Plivo will fetch when a call executes this application',
        app_name   => 'The name of your application',
    };
    $object->application( $params );

  - Get Details of All Applications
    $object->application( $params, 'details' );

  - Get Details of a Single Application
    Required Parameters
    $params = {
        app_id => 'Application ID',
    };
    $object->application( $params, 'details' );

  - Modify an Application
    Required Parameters
    $params = {
        app_id => 'Application ID',
    };
    $object->application( $params );

  - Delete an Application
    Required Parameters
    $params = {
        app_id => 'Application ID',
    };
    $object->application( $params, 'delete' );

  For more information please visit http://plivo.com/docs/api/application/

=cut
sub application {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';
    my $method = 'POST';

    my $url = "$self->{BASE_URI}/Application/";
    $url .= "$args->{app_id}/" if ( $args->{app_id} );

    if ( $type eq 'details' ) {
        $method = 'GET';
    } elsif ( $type eq 'delete' && $args->{app_id} ) {
        $method = 'DELETE';
    }

    delete $args->{app_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub conference

  The following actions can be performed with the Conference APIs.

  - Retrieve List of All Conferences
    $object->conference( $params );

  - Retrieve Details of a Particular Conference
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
    };
    $object->conference( $params );

  - Hangup All Conferences
    $object->conference( $params, 'delete' );

  - Hangup a Particular Conference
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
    };
    $object->conference( $params, 'delete' );

  For more information please visit http://plivo.com/docs/api/conference/

=cut
sub conference {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';
    my $method = ( $type eq 'delete' ) ? 'DELETE' : 'GET';

    my $url = "$self->{BASE_URI}/Conferences/";
    $url .= "$args->{conference_name}/" if ( $args->{conference_name} );

    delete $args->{conference_name};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub conference_member

  The following actions can be performed with the Member APIs:

    - Hangup a Particular Member
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
    };
    $object->conference_member( $params, 'hangup' );

    - Kick Member(s)
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'kick' );

    - Mute Member(s)
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'mute' );

    - Unmute Member(s)
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'unmute' );

    - Start Playing Sound to Member(s)
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'play' );

    - Stop Playing Sound to Member(s)
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'stop_play' );

    - Make Member(s) Hear a Speech
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
        text            => 'The text that the member must hear',
    };
    $object->conference_member( $params, 'speak' );

    - Make Member(s) Deaf
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'deaf' );

    - Enable Hearing For Member(s)
    Required Parameters
    $params = {
        conference_name => 'Name of the conference',
        member_id       => 'Member ID',
    };
    $object->conference_member( $params, 'undeaf' );

  For more information please visit http://plivo.com/docs/api/conference/member/

=cut
sub conference_member {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my @require = qw/conference_name member_id/;
    my @missing = map( !$args->{$_} ? $_ : (), @require );
    return 'Missing ' . join(', ', @missing) if ( scalar(@missing) );

    my $url = "$self->{BASE_URI}/Conference/$args->{conference_name}/Member/$args->{member_id}/";

    my $method = ( $type =~ /hangup|unmute|stop_play|undeaf/ ) ? 'DELETE' : 'POST';

    $url .= "Deaf/" if ( $type =~ /deaf/i );
    $url .= "Kick/" if ( $type eq 'kick' );
    $url .= "Mute/" if ( $type =~ /mute/i );
    $url .= "Play/" if ( $type =~ /play/i );
    $url .= "Speak/" if ( $type eq 'speak' );

    delete $args->{conference_name};
    delete $args->{member_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub conference_record

  The following actions can be performed with the Conference/Record APIs:

  - Start Recording a Conference
    $params = {
        conference_id => 'Conference ID',
    };
    $object->conference_record( $params );

  - Stop Recording a Conference
    $params = {
        conference_id => 'Conference ID',
    };
    $object->conference_record( $params, 'stop_record' );

  For more information please visit http://plivo.com/docs/api/conference/record/

=cut

sub conference_record {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my @require = qw/conference_id/;
    my @missing = map( !$args->{$_} ? $_ : (), @require );
    return 'Missing ' . join(', ', @missing) if ( scalar(@missing) );

    my $url = "$self->{BASE_URI}/Conference/$args->{conference_id}/Record/";

    my $method = ( $type =~ /stop_record/ ) ? 'DELETE' : 'POST';

    delete $args->{conference_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub endpoint

  An endpoint, also known as SIP endpoint, can be any IP phone, mobile phone, wireless device or PDA, 
  a laptop or deskop PC, that uses the Session Initiation Protocol (SIP) to perform telephony operations.

  The following actions can be performed using the Endpoint API:

  - Retrieve a List of All Endpoints
    $object->endpoint( $params );

  - Create an Endpoint
    Required Parameters
    $params = {
        username => 'The username for the endpoint to be created',
        password => 'The password for your endpoint username',
        alias    => 'Alias for this endpoint',
    };

    $object->endpoint( $params, 'create' );

  - Get Details of a Particular Endpoint
    Required Parameters
    $params = {
        endpoint_id => 'Endpoint ID',
    };

    $object->endpoint( $params );

  - Get Details of All Endpoints
    $object->endpoint( $params );

  - Modify an Endpoint
    Required Parameters
    $params = {
        endpoint_id => 'Endpoint ID',
    };

    $object->endpoint( $params, 'modify' );

  - Delete an Endpoint
    Required Parameters
    $params = {
        endpoint_id => 'Endpoint ID',
    };

    $object->endpoint( $params, 'delete' );

  For more information please visit http://plivo.com/docs/api/endpoint/

=cut
sub endpoint {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my $url = "$self->{BASE_URI}/Endpoint/";
    my $method = ( $type =~ /create|modify/ ) ? 'POST' : 'GET';

    $url .= "$args->{endpoint_id}/" if ( $args->{endpoint_id} );

    if ( $args->{endpoint_id} && $type eq 'delete' ) {
        $method = 'DELETE';
    }

    delete $args->{endpoint_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub message
  The following actions can be performed with the Message API.

  - Send a Message
    Required Parameters
    $params = {
        src  => 'The phone number to be used as the caller id (with the country code)',
        dst  => 'The number to which the message needs to be sent',
        text => 'The text to send',
    };

    $object->message( $params, 'send' );

  - Get All Message Recordings
    $object->message( $params );

  - Get a Specific Message Recording
    Required Parameters
    $params = {
        message_uuid => 'Message User ID',
    };
    $object->message( $params );

  For more information please visit http://plivo.com/docs/api/message/

=cut
sub message {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my $url = "$self->{BASE_URI}/Message/";
    my $method = ( $type =~ /send/ ) ? 'POST' : 'GET';

    $url .= "$args->{message_uuid}/" if ( $args->{message_uuid} );

    delete $args->{message_uuid};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub number

  The following actions can be performed using the Number APIs.

  - List All Rented Numbers
    $object->number( $params );

  - Get Details of a Rented Number
    Required Parameters
    $params = {
        rent_number => 'Rented Number',
    };
    $object->number( $params );

  - Add a number from your own carrier
    Mandatory Parameters
    $params = {
        numbers => 'A comma separated list of numbers that need to be added for the carrier',
        carrier => 'The carrier_id of the IncomingCarrier that the number is associated with',
        region  => 'This is the region that is associated with the Number',
    };

    $object->number( $params, 'add' );

  - Edit a Number
    Required Parameters
    $params = {
        rent_number => 'Rented Number',
    };
    $object->number( $params, 'modify' );

  - Unrent a Number
    Required Parameters
    $params = {
        rent_number => 'Rented Number',
    };
    $object->number( $params, 'unrent' );

  For more information please visit http://plivo.com/docs/api/numbers/number/

=cut
sub number {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my $url = "$self->{BASE_URI}/Number/";
    $url .= "$args->{rent_number}/" if ( $args->{rent_number} );

    my $method = ( $type =~ /add|modify/ ) ? 'POST' : 'GET';

    if ( $args->{rent_number} && $type eq 'unrent' ) {
        $method = 'DELETE';
    }

    delete $args->{rent_number};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub available_number_group

  The following actions can be performed with the AvailableNumberGroup APIs. 
  The available numbers are grouped together according to their country, number type, 
  area code/prefix and pricing. Each number group is available as a resource from which numbers can be ordered.

  - Search for New Numbers
    Required Parameters
    $params = {
        country_iso => 'The ISO code A2 of the country ( BE for Belgium, DE for Germany, GB for United Kingdom, US for United States etc )',
    };
    $object->available_number_group( $params );

  - Rent New Number(s)
    Required Parameters
    $params = {
        group_id => 'Group ID',
    };
    $object->available_number_group( $params );

  For more information please visit http://plivo.com/docs/api/numbers/availablenumbergroup/

=cut
sub available_number_group {
    my $self   = shift;
    my $args   = shift || {};

    my $url = "$self->{BASE_URI}/AvailableNumberGroup/";
    $url .= "$args->{group_id}/" if ( $args->{group_id} );

    my $method = ( $args->{group_id} ) ? 'POST' : 'GET';

    delete $args->{group_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub incoming_carrier

  You can use this API if you own phone numbers from a carrier and want to route incoming calls on those carrier's numbers through Plivo.
  The APIs enables you to perform the following actions

  - List All Incoming Carriers
    $object->incoming_carrier( $params );

  - Get Details of a Particular Incoming Carrier
    Required Parameters
    $params = {
        carrier_id => 'Carrier ID',
    };
    $object->incoming_carrier( $params );

  - Add a New Incoming Carrier
    $object->incoming_carrier( $params );
    Required Parameters
    $params = {
        name   => 'The name of the carrier being added. It is just a representation and the name can be chosen at will',
        ip_set => 'Comma separated list of ip addresses from which calls belonging to the carrier will reach Plivo',
    };
    $object->incoming_carrier( $params, 'add' );

  - Modify an Existing Carrier
    Required Parameters
    $params = {
        carrier_id => 'Carrier ID',
    };
    $object->incoming_carrier( $params, 'modify' );

  - Remove an Incoming Carrier
    Required Parameters
    $params = {
        carrier_id => 'Carrier ID',
    };
    $object->incoming_carrier( $params, 'delete' );

  For more information please visit http://plivo.com/docs/api/carrier/incomingcarrier/

=cut
sub incoming_carrier {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my $url = "$self->{BASE_URI}/IncomingCarrier/";
    $url .= "$args->{carrier_id}/" if ( $args->{carrier_id} );

    my $method = ( $type =~ /add|modify/ ) ? 'POST' : 'GET';
    $method = 'DELETE' if ( $args->{carrier_id} && $type eq 'delete' );

    delete $args->{carrier_id};

    return $self->_send_request({ url=>$url, method=>$method, params=>$args });
}

=head2 sub pricing

  The following actions can be performed with the Pricing APIs:

  - Get Pricing for a country
    Required Parameters
    $params = {
        country_iso => 'The 2 digit country ISO code. eg. US, GB, QA',
    };
    $object->pricing( $params );

  For more information please visit http://plivo.com/docs/api/pricing/

=cut
sub pricing {
    my $self   = shift;
    my $args   = shift;

    my $url = "$self->{BASE_URI}/Pricing/";

    return $self->_send_request({ url=>$url, method=>'GET', params=>$args });
}

=head2 sub recording

The following actions can be performed with the Recording APIs:

  - List All Recordings
    $object->recording( $params );

  - List a Particular Recording
    Required Parameters
    $params = {
        recording_id => 'Recording ID',
    };
    $object->recording( $params );

  For more information please visit http://plivo.com/docs/api/recording/

=cut

sub recording {
    my $self   = shift;
    my $args   = shift || {};
    my $type   = shift || '';

    my $url = "$self->{BASE_URI}/Recording/";
    $url .= "$args->{recording_id}/" if ( $args->{recording_id} );

    delete $args->{recording_id};

    return $self->_send_request({ url=>$url, method=>'GET', params=>$args });
}

=head2 sub _send_request

Send a post request to plivo

=head3 Arguments:

  Attribute Name     Description
  ---------------------------------------------------------------------------------------------------------------------
   url             | Post url
  ---------------------------------------------------------------------------------------------------------------------
   params          | Parameters passing to server
  ---------------------------------------------------------------------------------------------------------------------
   method          | POST, GET, DELETE
  ---------------------------------------------------------------------------------------------------------------------

=cut
sub _send_request {
    my $self = shift;
    my $args = shift;

    my $method = $args->{method} || 'POST';

    my $request;
    if ( $method eq 'POST' ) {
        my $json = JSON->new();
        my $json_args = $json->encode($args->{params});
        $request = HTTP::Request->new($method, $args->{url});
        $request->authorization_basic($self->{AUTH_ID}, $self->{AUTH_TOKEN});
        $request->header('Content-Type'=>'application/json');
        $request->content($json_args);
    } else {
        my $has = 0;
        foreach my $k ( keys %{$args->{params}} ) {
            my $add_on = '&';
            if ( !$has || index($args->{url}, '?') > -1 ) {
                $has = 1;
                $add_on = '?';
            }

            $args->{url} .= $add_on . $k . '=' . $args->{params}{$k};
        }

        $request = HTTP::Request->new($method, $args->{url});
        $request->authorization_basic($self->{AUTH_ID}, $self->{AUTH_TOKEN});
    }

    my $ua = LWP::UserAgent->new();
    return $ua->request($request);
}

=head1 XML Response
To create XML response for Plivo

=head2 Sample Code

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

=head2 sub add_conference

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   content         | The conference room name.
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/conference/

=cut
sub add_conference {
    my $self = shift;
    my $args = shift;

    my @info = qw/waitSound beep endConferenceOnExit callbackUrl callbackMethod digitsMatch muted startConferenceOnEnter content/;
    my @conference = qw/Redirect/;

    $self->_build_response_format( 'Conference', $args, \@info, \@conference );
}

=head2 sub add_dial

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   action          | Redirect to this URL after leaving Dial.             | absolute URL           | none
  ---------------------------------------------------------------------------------------------------------------------
   method          | Submit to action URL using GET or POST.              | GET, POST              | POST
  ---------------------------------------------------------------------------------------------------------------------
   hangupOnStar    | The caller can press the '*' key to hang up on the   | truse, false           | false
                   | called party but can continue with other operations  |                        |
                   | depending on the application's response.             |                        |
  ---------------------------------------------------------------------------------------------------------------------
   timeLimit       | Used to preset the duration (in seconds) of the call.| positive integer       | 14400 seconds
                   |                                                      | (in seconds)           | (4 hours)
  ---------------------------------------------------------------------------------------------------------------------
   timeout         | The duration (in seconds) for which the called       | positive integer       | none
                   | party has to be given a ring.                        | (seconds)              |
  ---------------------------------------------------------------------------------------------------------------------
   callerId        | If set to a string, caller number will be set to     | valid phone number     | Current caller's
                   | this string value.Default is current caller number.  |                        | callerId
  ---------------------------------------------------------------------------------------------------------------------
   callerName      | If set to a string, caller name will be set to       | String or default      | Caller's
                   | this string value.Default is current caller name.    |                        | callerName
  ---------------------------------------------------------------------------------------------------------------------
   confirmSound    | Is a remote URL fetched with POST HTTP request       | absolute URL           | empty
                   | which must return an XML response with Play, Wait    |                        |
                   | and/or Speak elements only (all others are ignored). |                        |
                   | The sound indicated by the XML is played to the      |                        |
                   | called party when the call is answered. Note: This   |                        |
                   | parameter must be specified for confirmKey> to work. |                        |
  ---------------------------------------------------------------------------------------------------------------------
   confirmKey      | The digit to be pressed by the called party to accept| any digit, #, *        | empty
                   | the call.Used in conjunction with confirmSound.      |                        |
  ---------------------------------------------------------------------------------------------------------------------
   dialMusic       | Music to be played to the caller while the call is   | absolute URL           | empty
                   | being connected.Is a remote URL fetched with POST    |                        |
                   | HTTP request which must return an XML with Play, Wait|                        |
                   | and/or Speak elements only (all others are ignored). |                        |
                   | The sound indicated by the XML is played to the      |                        |
                   | called party when the call is answered.              |                        |
  ---------------------------------------------------------------------------------------------------------------------
   callbackUrl     | URL that is notified by Plivo when one of the        | absolute URL           | empty
                   | following events occur :                             |                        |
                   |  - called party is bridged with caller               |                        |
                   |  - called party hangs up                             |                        |
                   |  - caller has pressed any digit                      |                        |
  ---------------------------------------------------------------------------------------------------------------------
   callbackMethod  | Method used to notify callbackUrl.                   | GET, POST              | POST
  ---------------------------------------------------------------------------------------------------------------------
   redirect        | If set to false, do not redirect to action URL.      | true, false            | true
                   | Send to request_url and continue to next element.    |                        |
  ---------------------------------------------------------------------------------------------------------------------
   digitsMatch     | Set matching key combination for the caller (A leg). | List of digit patterns | empty
                   |                                                      | separated by comma     |
  ---------------------------------------------------------------------------------------------------------------------
   Number          | Number(s) to be called, example see below            | String or Array with   | none
                   |                                                      | hashes                 | 
  ---------------------------------------------------------------------------------------------------------------------
   User            | User(s) to be called, example see below              | String or Array with   | none
                   |                                                      | hashes                 | 
  ---------------------------------------------------------------------------------------------------------------------

  Example
    number = '15101111111';
    number = [{ sendDigits=>123, content=>'15101111111' }, 
              { sendOnPreanswer=>'true', content=>'15102222222' }]; 
             

    user = 'sip:john1234@phone.plivo.com';
    user = [{ sendDigits=>'www2410', content=>'sip:john1234@phone.plivo.com' }, 
            { sendOnPreanswer=>'true', content=>'sip:mike1234@phone.plivo.com' }];

  For more information please visit http://plivo.com/docs/xml/dial/
                                    http://plivo.com/docs/xml/number/
                                    http://plivo.com/docs/xml/user/

=cut
sub add_dial {
    my $self = shift;
    my $args = shift;

    my @info = qw/action method hangupOnStar timeLimit timeout callerId callerName confirmSound confirmKey dialMusic callbackUrl callbackMethod redirect digitsMatch sipHeaders/;
    my @dial = qw/Number callbackUrl User/;

    $self->_build_response_format( 'Dial', $args, \@info, \@dial );
}

=head2 sub add_speak

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   content         | The text to be read out                              |                        |
  ---------------------------------------------------------------------------------------------------------------------
   voice           | The tone to be used for reading out the text         | WOMAN, MAN             | WOMAN
  ---------------------------------------------------------------------------------------------------------------------
   loop            | Specifies number of times to speak out the text.     | integer >= 0           | 1
                   | If value set to 0, speaks indefinitely               | (0 indicates a         |
                   |                                                      | continuous loop.)      |
  ---------------------------------------------------------------------------------------------------------------------
   language        | Language used to read out the text.                  | See Supported voice    | en-US
                                                                          | and languages          |
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/speak

=cut
sub add_speak {
    my $self = shift;
    my $args = shift;

    my @info  = qw/voice language loop/;
    my @speak = qw/Speak/;

    $self->_build_response_format( 'Speak', $args, \@info, \@speak );
}

=head2 sub add_hangup

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   reason          | Used to specify reason of hangup                     | rejected, busy         | none
  ---------------------------------------------------------------------------------------------------------------------
   schedule        | Used to sechedule a cal hangup. Sould be followed by | interger > 0           | none
                   | an element such as <Speak>, otherwise call will be   | (in seconds)           |
                   | hung up immediately                                  |                        |
  ---------------------------------------------------------------------------------------------------------------------

=cut
sub add_hangup {
    my $self = shift;
    my $args = shift;

    my @info = qw/reason schedule/;

    $self->_build_response_format( 'Hangup', $args, \@info );
}

=head2 sub add_getdigits

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   action          | The URL to which the digits are sent.                | absolute URL           | none
  ---------------------------------------------------------------------------------------------------------------------
   method          | Submit to action URL using GET or POST.              | GET, POST              | POST
  ---------------------------------------------------------------------------------------------------------------------
   timeout         | Time in seconds to wait to receive the first digit.  | positive integer       | 5 seconds
                   | If the user fails to provide an input within the     |
                   | timeout period, the next element in the response is  |
                   | processed.                                           |
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/getdigits/

=cut
sub add_getdigits {
    my $self = shift;
    my $args = shift;

    my @info = qw/action method timeout digitTimeout finishOnKey numDigits retires redirect playBeep validDigits invalidDigitsSound/;
    my @getdigits = qw/Speak/;

    $self->_build_response_format( 'GetDigits', $args, \@info, \@getdigits );
}

=head2 sub add_message

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   content         | Message that wants to send out                       | string                 | none
  ---------------------------------------------------------------------------------------------------------------------
   src             | Source Number. For eg.1202322222                     | Must be a purchased,   | none
                   |                                                      | valid number.          | 
  ---------------------------------------------------------------------------------------------------------------------
   dst             | Destination Number. Can be bulk numbers delimited by | Must be a valid number.| none
                   | <. For eg.1203443444<1203345564                      |                        |
  ---------------------------------------------------------------------------------------------------------------------
   type            | Type of the message. For eg. sms                     | sms                    | sms
  ---------------------------------------------------------------------------------------------------------------------
   callbackUrl     | URL that is notified by Plivo when a response is     | absolute URL           | none
                   | available and to which the response is sent.         |                        | 
  ---------------------------------------------------------------------------------------------------------------------
   callbackMethod  | The method used to notify the callbackUrl.           | GET, POST              | POST
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/message/

=cut

sub add_message {
    my $self = shift;
    my $args = shift;

    my @info = qw/src dst type callbackUrl callbackMethod content/;

    $self->_build_response_format( 'Message', $args, \@info );
}

=head2 sub add_play

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   content         | Message that wants to send out                       | string                 | none
  ---------------------------------------------------------------------------------------------------------------------
   loop            | Play the audio file repeatedly. Value set to 0,      | integer >= 0           | 1
                   | plays indefinitely.                                  |                        |
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/play/

=cut

sub add_play {
    my $self = shift;
    my $args = shift;

    my @info = qw/loop content/;

    $self->build_response_format( 'Play', $args, \@info );
}

=head2 sub add_preanswer

  For more information please visit http://plivo.com/docs/xml/preanswer/

=cut

sub add_preanswer {
    my $self = shift;
    my $args = shift;

    my @info;
    my @preanswer = qw/Play/;

    $self->build_response_format( 'PreAnswer', $args, \@info, \@preanswer );
}

=head2 sub add_redirect

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   content         | Message that wants to send out                       | string                 | none
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/redirect/

=cut

sub add_redirect {
    my $self = shift;
    my $args = shift;

    my @info = qw/content method/;

    $self->build_response_format( 'Redirect', $args, \@info  );
}

=head2 sub add_wait

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   length          | Time to wait in seconds                              | integer > 0            | 1
  ---------------------------------------------------------------------------------------------------------------------
   silence         |                                                      | true or false          | false
  ---------------------------------------------------------------------------------------------------------------------
   minSilence      |                                                      | interger > 0           | 2000
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/wait/

=cut

sub add_wait {
    my $self = shift;
    my $args = shift;

    my @info = qw/length silence minSilence/;

    $self->build_response_format( 'Wait', $args, \@info  );
}

=head2 sub add_dtmf

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   content         | Send DTMF digits from the current call. Use the      | 1234567890*#wW         | 2000 ms
                   | character 'w' for a 0.5 second delay and the         | [@tone_duration]       |
                   | character 'W' for a 1 second delay.                  |                        |
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/dtmf/

=cut

sub add_dtmf {
    my $self = shift;
    my $args = shift;

    my @info = qw/content/;

    $self->build_response_format( 'DTMF', $args, \@info  );
}

=head2 sub add_record

=head3 Arguments:

  Attribute Name     Description                                            Allowed Values           Default Value
  ---------------------------------------------------------------------------------------------------------------------
   action          | Submit the result of the record to this URL.         | absolute URL           | no default
  ---------------------------------------------------------------------------------------------------------------------
   method          | Submit to action url using GET or POST               | GET, POST              | POST
  ---------------------------------------------------------------------------------------------------------------------
   fileFormat      | The format of the recording. Valid formats: mp3,wav. | mp3, wav               | mp3
                   | Defaults to mp3.                                     |                        | 
  ---------------------------------------------------------------------------------------------------------------------
   redirect        | If false, don.t redirect to action url, only request | true, false            | true
                   | the url and continue to next element.                |                        |
  ---------------------------------------------------------------------------------------------------------------------
   timeout         | Seconds of silence before considering the recording  | positive integer       | 15
                   | complete (default 500). Only used when recordSession |                        |
                   | and startOnDialAnswer are 'false'.                   |                        |
  ---------------------------------------------------------------------------------------------------------------------

  For more information please visit http://plivo.com/docs/xml/record/

=cut

sub add_record {
    my $self = shift;
    my $args = shift;

    my @info = qw/action method fileFormat redirect timeout maxLength playBeep finishOnKey recordSession startOnDialAnswer transcriptionType transcriptionUrl transcriptionMethod callbackUrl callbackMethod/;

    $self->_build_response_format( 'Record', $args, \@info );
}

# building data format with case insensitive
sub _build_response_format {
    my $self = shift;
    my $type = shift || '';
    my $args = shift || {};
    my $string = shift || [];
    my $array  = shift || [];

    foreach my $key ( keys %$args ) {
        my ($ks) = grep( /^$key$/i, @$string );

        if ( $ks ) {
           $self->{respond_data}{$type}{$ks} = $args->{$key}; 
        } else {
            ($ks) = grep( /^$key$/i, @$array );
            if ( $ks ) {
                my $value = ( ref $args->{$key} eq 'ARRAY' ) ? $args->{$key} : [ $args->{$key} ];
                $self->{respond_data}{$type}{$ks} ||= [];
                @{$self->{respond_data}{$type}{$ks}} = ( @{$self->{respond_data}{$type}{$ks}}, @$value );
            }
        }
    }
}

sub respond {
    my $self   = shift;
    my $args   = shift;

    return $self->_xml_response({ data=>$self->{respond_data} });
}

# create XML 
sub _xml_response {
    my $self = shift;
    my $args = shift;
    my $data = $args->{data};

    my $XML = XML::Simple->new;
    return $XML->XMLout( $data, RootName=>'Response' );
}
