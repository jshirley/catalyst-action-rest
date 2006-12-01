use inc::Module::Install;

perl_version '5.8.1';

name 'Catalyst-Action-REST';
all_from 'lib/Catalyst/Action/REST.pm';

requires('Catalyst'                  => '5.7001');
requires('Params::Validate'          => '0.76');
requires('YAML::Syck'                => '0.67');
requires('Module::Pluggable::Object' => undef);
requires('LWP::UserAgent'            => '2.033');
requires('Data::Serializer'          => '0.36');
requires('Class::Inspector'          => '1.13');

auto_include;
auto_install;

WriteAll;

