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
requires('URI::Find'                 => undef);
requires('Data::Dump'                => undef);

feature 'JSON (application/json) support',
    -default   => 0,
    'JSON'     => '2.12';
    'JSON::XS' => '2.2222';

feature 'Data::Denter (text/x-data-denter) support',
    -default => 0,
    'Data::Denter' => undef;

feature 'Data::Taxi (text/x-data-taxi) support',
    -default => 0,
    'Data::Taxi' => undef;

feature 'Config::General (text/x-config-general) support',
    -default => 0,
    'Config::General' => undef;

feature 'PHP::Serialization (text/x-php-serialization) support',
    -default => 0,
    'PHP::Serialization' => undef;

feature 'FreezeThaw (application/x-freezethaw) support',
    -default => 0,
    'FreezeThaw' => undef;

feature 'XML::Simple (text/xml) support',
    -default => 0,
    'XML::Simple' => undef;

auto_include;
auto_install;

WriteAll;

