use inc::Module::Install;

name 'jsref';

abstract_from 'jsref';
author_from 'jsref';
license_from 'jsref';
perl_version_from 'jsref';
version_from 'jsref';

readme_from 'jsref';
distribution_type 'script';

no_index directory => 'orig';
no_index directory => 'tools';

requires_external_bin 'w3m';
configure_requires 'Module::Install::ReadmeFromPod';
configure_requires 'File::Slurp';
requires 'File::ShareDir';

install_script 'jsref';

mkdir 'doc';
do 'tools/tidy.pl';

install_share 'doc';

auto_include;
auto_install;

WriteAll;

