use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

use Mojolicious::Lite;
use Mojo::JSON;

plugin OpenAPI => {
  url => 'data://main/emulation.json',
  renderer => sub {
    my ($c,$data) = @_;
    my $spec = $c->openapi->spec;
    is($data->{status},501,'got to renderer via not implemented');
    is($spec->{operationId}, 'dig', ' ... and we can get the spec');
    $data = [{status => "passed"}];
    $c->stash(openapi => $data);
    $c->stash(status => 200);
    return Mojo::JSON::encode_json($data);
  },
};

my $t = Test::Mojo->new;

$t->post_ok('/api/emulate')
  ->status_is(200)
  ->json_is([{status => "passed"}]);

done_testing;

__DATA__
@@ emulation.json
{
  "swagger" : "2.0",
  "info" : { "version": "0.8", "title" : "Test emulation" },
  "consumes" : [ "application/json" ],
  "produces" : [ "application/json" ],
  "schemes" : [ "http" ],
  "basePath" : "/api",
  "paths" : {
    "/emulate" : {
      "post" : {
        "operationId" : "dig",
        "parameters" : [
          { "in": "body", "name": "body", "schema": { "type" : "object" } }
        ],
        "responses" : {
          "200": {
            "description": "response",
            "schema": { "type": "object" }
          }
        }
      }
    }
  }
}
