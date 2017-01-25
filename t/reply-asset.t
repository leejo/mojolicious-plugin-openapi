use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

my $ASSET = Mojo::Asset::File->new(path => $0);
my $render = 'openapi';

plan skip_all => 'Cannot read $0' unless -r $ASSET->path;

use Mojolicious::Lite;
get '/file' => sub {
  my $c = shift->openapi->valid_input or return;
  return $c->reply->asset($ASSET) if $render eq 'default';
  $c->res->headers->content_type('text/plain') if $render eq 'headers';
  $c->reply->openapi(200 => $ASSET);
  },
  'File';

plugin OpenAPI => {url => 'data://main/file.json'};

my $t = Test::Mojo->new;

$render = 'headers';
$t->get_ok('/api/file')->status_is(200)->header_is('Content-Type' => 'text/plain')
  ->content_like(qr{skip_all.*Cannot read});

$render = 'openapi';
$t->get_ok('/api/file')->status_is(200)->header_is('Content-Type' => 'application/octet-stream')
  ->content_like(qr{skip_all.*Cannot read});

$render = 'default';
$t->get_ok('/api/file')->status_is(200)->content_like(qr{skip_all.*Cannot read});

SKIP: {
  $ASSET = Mojo::Asset::File->new(path => 't/data/image.jpeg');
  skip 'Cannot read t/data/image.jpeg', 4 unless -r $ASSET->path;
  $render = 'openapi';
  $t->get_ok('/api/file')->status_is(200)->header_is('Content-Type' => 'image/jpeg')
    ->content_like(qr{some binary data});
}

done_testing;

package main;
__DATA__
@@ file.json
{
  "swagger" : "2.0",
  "info" : { "version": "0.8", "title" : "Test binary data" },
  "schemes" : [ "http" ],
  "basePath" : "/api",
  "paths" : {
    "/file" : {
      "get" : {
        "operationId" : "File",
        "responses" : {
          "200": {
            "description": "response",
            "schema": { "type": "file" }
          }
        }
      }
    }
  }
}
