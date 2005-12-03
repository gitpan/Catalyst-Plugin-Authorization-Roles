#!/usr/bin/perl

package Catalyst::Plugin::Authorization::Roles;

use strict;
use warnings;

use Set::Object         ();
use Scalar::Util        ();
use Catalyst::Exception ();

our $VERSION = "0.02";

sub check_user_roles {
    my $c = shift;
    local $@;
    eval { $c->assert_user_roles(@_) };
}

sub assert_user_roles {
    my $c = shift;

    my $user;

    if ( Scalar::Util::blessed( $_[0] )
        && $_[0]->isa("Catalyst::Plugin::Authentication::User") )
    {
        $user = shift;
    }
    elsif ( not $user = $c->user ) {
        Catalyst::Exception->throw(
            "No logged in user, and none supplied as argument");
    }

    my $have = Set::Object->new( $user->roles(@_) );
    my $need = Set::Object->new(@_);

    if ( $have->superset($need) ) {
        $c->log->debug( 'Role granted: ' . join( ', ', $need->elements ) )
            if $c->debug;
        return 1;
    }
    else {
        $c->log->debug( 'Role denied: ' . join( ', ', $need->elements ) )
            if $c->debug;
        Catalyst::Exception->throw( "Missing roles: "
              . join( ", ", $need->difference($have)->members ) );
    }
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Catalyst::Plugin::Authorization::Roles - Role based authorization for
L<Catalyst> based on L<Catalyst::Plugin::Authentication>.

=head1 SYNOPSIS

	use Catalyst qw/
		Authentication
		Authentication::Store::ThatSupportsRoles
		Authorization::Roles
	/;

	sub delete : Local {
		my ( $self, $c ) = @_;

		$c->assert_user_roles( qw/admin/ ); # only admins can delete

		$c->model("Foo")->delete_it();
	}

=head1 DESCRIPTION

Role based authentication is very simple: every user has a list of roles, which
that user is allowed to assume.

Whenever an area that is restricted for e.g. admins, or members, or any other
role is accessed a check is made to see whether or not the user has all the
required roles.

In this plugin the user objects being checked have the C<roles> method invoked.
This method is supposed to return a list of the roles the user is allowed to
assume. The roles may be any item that can be compared using L<Set::Object>.

For example, if you have a CRUD application, for every mutating action you
probably want to check that the user is allowed to edit. To do this, create an
editor role, and add that role to every user who is allowed to edit.

	sub edit : Local {
		my ( $self, $c ) = @_;
		$c->assert_user_roles( qw/editor/ );
		$c->model("TheModel")->make_changes();
	}

=head1 METHODS

=over 4

=item assert_user_roles [ $user ], @roles

Cheks that the user (as supplied by the first argument, or, if omitted,
C<<$c->user>>) has the specified roles.

If for any reason (C<<$c->user>> is not defined, the user is missing a role,
etc) the check fails, an error is thrown.

=item check_user_roles [ $user ], @roles

Takes the same args as C<assert_user_roles>, and performs the same check, but
instead of throwing errors returns a boolean value.

=back

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>

=head1 AUTHOR

Yuval Kogman, C<nothingmuch@woobling.org>

=head1 COPYRIGHT & LICNESE

        Copyright (c) 2005 the aforementioned authors. All rights
        reserved. This program is free software; you can redistribute
        it and/or modify it under the same terms as Perl itself.

=cut



