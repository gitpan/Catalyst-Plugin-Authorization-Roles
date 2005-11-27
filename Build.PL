use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Authorization::Roles',
    requires           => {
        'Catalyst'                         => '5.49',
        'Catalyst::Plugin::Authentication' => '0.01',
        'Set::Object'                      => 0,
        'Test::MockObject'                 => '1.01',
        'Test::Exception'                  => 0,
    },
    create_readme => 1,
    sign          => 1,
);
$build->create_build_script;

