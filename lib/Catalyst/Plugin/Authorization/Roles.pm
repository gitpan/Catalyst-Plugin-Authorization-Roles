#!/usr/bin/perl

package Catalyst::Plugin::Authorization::Roles;

use strict;
use warnings;

use Set::Object         ();
use Scalar::Util        ();
use Catalyst::Exception ();

our $VERSION = "0.04";

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

    Catalyst::Exception->throw("User does not support roles")
      unless $user->supports(qw/roles/);

    if ( $user->supports(qw/roles self_check/) ) {
        if ( $user->check_roles(@_) ) {
            $c->log->debug( 'Role granted: ' . join( ', ', @_ ) ) if $c->debug;
            return 1;
        }
        else {
            $c->log->debug( 'Role denied: ' . join( ', ', @_ ) ) if $c->debug;
            Catalyst::Exception->throw("Missing roles");
        }
    }
    else {

        my $have = Set::Object->new( $user->roles() );
        my $need = Set::Object->new(@_);

        if ( $have->superset($need) ) {
            $c->log->debug( 'Role granted: ' . join( ', ', @_ ) ) if $c->debug;
            return 1;
        }
        else {
            $c->log->debug( 'Role denied: ' . join( ', ', @_ ) ) if $c->debug;
            Catalyst::Exception->throw( "Missing roles: "
                  . join( ", ", $need->difference($have)->members ) );
        }
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

Role based access control is very simple: every user has a list of roles,
which that user is allowed to assume, and every restricted part of the app
makes an assertion about the necessary roles.

If the user is a member in B<all> of the required roles access is granted.
Otherwise, access is denied.

For example, if you have a CRUD application, for every mutating action you
probably want to check that the user is allowed to edit. To do this, create an
editor role, and add that role to every user who is allowed to edit.

	sub edit : Local {
		my ( $self, $c ) = @_;
		$c->assert_user_roles( qw/editor/ );
		$c->model("TheModel")->make_changes();
	}


When this plugin checks the roles of a user it will first see if the user
supports the self check method.

When this is not supported the list of roles is extracted from the user using
the C<roles> method.

When this is supported, the C<check_roles> method will be used to delegate the
role check to the user class. Classes like the one provided with
L<Catalyst::Plugin::Authentication::Store::DBIC> optimize the check this way.

=head1 METHODS

=over 4

=item assert_user_roles [ $user ], @roles

Checks that the user (as supplied by the first argument, or, if omitted,
C<< $c->user >>) has the specified roles.

If for any reason (C<< $c->user >> is not defined, the user is missing a role,
etc) the check fails, an error is thrown.

You can either catch these errors with an eval, or clean them up in your C<end>
action.

=item check_user_roles [ $user ], @roles

Takes the same args as C<assert_user_roles>, and performs the same check, but
instead of throwing errors returns a boolean value.

=back

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>

L<http://catalyst.perl.org/calendar/2005/24>

=head1 AUTHOR

Yuval Kogman, C<nothingmuch@woobling.org>

=head1 COPYRIGHT & LICENSE

        Copyright (c) 2005 the aforementioned authors. All rights
        reserved. This program is free software; you can redistribute
        it and/or modify it under the same terms as Perl itself.

=cut



