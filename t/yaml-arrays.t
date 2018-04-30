use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use Mojolicious;

my $n = 0;
my %modules = ('YAML::XS'=>'0.67');
for my $module (keys %modules) {
  unless (eval "use $module $modules{$module};1") {
    diag "Skipping test when $module $modules{$module} is not installed"; 
    next;
  }

  no warnings qw(once redefine);
  use JSON::Validator;
  local *JSON::Validator::_load_yaml = eval "\\\&$module\::Load";
  $n++;
  diag join ' ', $module, $module->VERSION || 0;
  my $app = Mojolicious->new;
  eval { $app->plugin(OpenAPI => {url => 'data://main/yaml_arrays.yaml'}); 1 };
  ok !$@, "parsed API spec" or diag $@;
}

ok 1, 'no yaml modules available' unless $n;

done_testing;

__DATA__
@@ yaml_arrays.yaml
---
swagger: '2.0'
basePath: /api/v1.0
info:
    title: Our API
    version: "1.0"
paths:
    "/properties/{external_id}":
        get:
            responses:
                200:
                    description: A property object
                    schema:
                        type: object
                        $ref: '#/definitions/Property'
definitions:
    Property:
        type: object
        properties:
            address:
                type: object
                properties:
                    city:
                        type:
                            - string
                            - null
                        x-example: "Villars-sur-Ollon"
                    country:
                        type: [ 'string','null' ]
                        x-example: "Villars-sur-Ollon"
