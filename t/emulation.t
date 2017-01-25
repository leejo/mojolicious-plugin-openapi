use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

use Mojolicious::Lite;

plugin OpenAPI => {
  url => 'data://main/emulation.json',
  emulate_not_implemented => 1,
};

my $t = Test::Mojo->new;
$t->post_ok('/api/emulate')
  ->status_is(200)
  ->json_is({});

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
