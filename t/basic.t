 #!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::MockObject;
use Test::MockObject::Extends;
use Test::Exception;

my $m; BEGIN { use_ok($m = "Catalyst::Plugin::Authorization::Roles") }

# cheat Test::MockObject::Extends
$INC{"Catalyst/Plugin/Authentication/User.pm"} = 1;
@Catalyst::Plugin::Authentication::User::ISA = ();

my $user = Test::MockObject::Extends->new("Catalyst::Plugin::Authentication::User");

$user->set_list(roles => qw/admin user moose_trainer/);
$user->mock( supports => sub { shift; @_ == 1 and $_[0] eq "roles" });

my $c = Test::MockObject::Extends->new( $m );

$c->set_always( "user", $user );

$c->set_false("debug");

can_ok( $m, "assert_user_roles" );
can_ok( $m, "check_user_roles" );
can_ok( $m, "assert_any_user_role" );
can_ok( $m, "check_any_user_role" );

lives_ok { $c->assert_user_roles( "admin" ) } "existing role is OK";
lives_ok { $c->assert_user_roles( $user->roles ) } "all roles is OK";
throws_ok { $c->assert_user_roles( "moose_feeder" ) } qr/missing role.*moose_feeder/i, "missing role throws error";
throws_ok { $c->assert_user_roles( qw/moose_trainer moose_feeder/ ) } qr/missing role.*moose_feeder/i, "also when there are existing roles";
throws_ok { $c->assert_user_roles( $user->roles, "moose_feeder" ) } qr/missing role.*moose_feeder/i, "even all roles";

lives_ok { $c->assert_any_user_role( qw/admin moose_feeder/ ) } "assert_any_user_role: has at least one role is OK";
lives_ok { $c->assert_any_user_role( $user->roles ) } "assert_any_user_role: has all roles is OK";
throws_ok { $c->assert_any_user_role( qw/moose_feeder climber/ ) } qr/missing role/i, "assert_any_user_role: has none of the listed roles";

ok( $c->check_user_roles( "admin" ), "check_user_roles true" );
ok( !$c->check_user_roles( "moose_feeder" ), "check_user_roles false" );

ok( $c->check_any_user_role( qw/admin moose_feeder/ ), "check_any_user_role true" );
ok( !$c->check_any_user_role( qw/moose_feeder climber/ ), "check_any_user_role false" );

$c->set_false( "user" );

throws_ok { $c->assert_user_roles( "moose_trainer" ) } qr/no logged in user/i, "can't assert without logged user";
lives_ok { $c->assert_user_roles( $user, "moose_trainer" ) } "unless supplying user explicitly";

throws_ok { $c->assert_any_user_role( qw/moose_trainer/ ) } qr/no logged in user/i, "assert_any_user_role: can't assert without logged user";
lives_ok { $c->assert_any_user_role( $user, "moose_trainer" ) } "unless supplying user explicitly";
