use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Authorization::Roles',
    requires           => {
        'Catalyst'                         => '5.49',
        'Catalyst::Plugin::Authentication' => '0.03',
        'Set::Object'                      => '1.14',
        'Test::MockObject'                 => '1.01',
        'Test::Exception'                  => 0,
        'UNIVERSAL::isa'                   => '0.05',
    },
    create_readme => 1,
    sign          => 1,
);
$build->create_build_script;

