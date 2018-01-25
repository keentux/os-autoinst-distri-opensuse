# SUSE's openQA tests
#
# Copyright © 2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: SAP Pattern test
# Maintainer: Alvaro Carvajal <acarvajal@suse.de>

use base "sles4sap";
use testapi;
use strict;

sub run {
    my ($self)      = @_;
    my @sappatterns = qw(sap-nw sap-b1 sap-hana);
    my $output      = '';

    select_console 'root-console';

    # First check pattern sap_server which is installed by default in SLES4SAP
    # when 'SLES for SAP Applications' system role is selected
    $output = script_output("zypper info -t pattern sap_server");
    if ($output !~ /i\+\s\|\spatterns-server-enterprise-sap_server\s+\|\spackage\s\|\sRequired/) {
        # Pattern sap_server is not installed. Could either be a bug or caused by
        # the use of the 'textmode' system role
        die "Pattern sap_server not installed by default"
          unless (check_var('SYSTEM_ROLE', 'textmode'));
        record_info('install sap_server', 'Installing sap_server pattern and starting sapconf');
        assert_script_run("zypper in -y -t pattern sap_server");
        assert_script_run("sapconf start");
    }

    foreach my $pattern (@sappatterns) {
        assert_script_run("zypper in -y -t pattern $pattern", 100);
        $output = script_output "zypper info -t pattern $pattern";
        die "SAP zypper pattern [$pattern] info check failed"
          unless ($output =~ /i\+\s\|\spatterns-$pattern\s+\|\spackage\s\|\sRequired/);
    }
}

sub test_flags {
    return {milestone => 1};
}

1;
# vim: set sw=4 et:
