use inc::Module::Install;

perl_version '5.8.1';

name 'Catalyst-Action-REST';
all_from 'lib/Catalyst/Action/REST.pm';

'Catalyst'                  => '5.7001',
'Params::Validate'          => '0.76',
'YAML::Syck'                => '0.67',
'Module::Pluggable::Object' => undef,
'LWP::UserAgent'            => '2.033',
'Data::Serializer'          => '0.36',
'Class::Inspector'          => '1.13',

WriteAll;

