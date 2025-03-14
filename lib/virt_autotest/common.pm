# SUSE's openQA tests
#
# Copyright 2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Helper package for common virt operations
# Maintainer: qe-virt <qe-virt@suse.de>

package virt_autotest::common;

use base 'consoletest';
use strict;
use warnings;
use testapi;
use utils;
use version_utils 'is_sle';

# Supported guest configuration
#   * location of the installation tree
#   * autoyast profile
#   * extra parameters for virsh create / xl create
# By default, our guests will be installed via `virt-install`. If "method => 'import'" is set, the virtual machine will
# be imported instead of installed.

our %guests = ();
if (get_var("REGRESSION", '') =~ /xen/) {
    %guests = (
        sles12sp4PV => {
            name => 'sles12sp4PV',
            autoyast => 'autoyast_xen/sles12sp4PV_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --paravirt --os-variant sles12sp4',
            macaddress => '52:54:00:78:73:a9',
            ip => '192.168.122.104',
            distro => 'SLE_12_SP4',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP4-Server-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.104/24,192.168.122.1,192.168.122.1"',
        },
        sles12sp4HVM => {
            name => 'sles12sp4HVM',
            autoyast => 'autoyast_xen/sles12sp4HVM_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --hvm --os-variant sles12sp4',
            macaddress => '52:54:00:78:73:aa',
            ip => '192.168.122.103',
            distro => 'SLE_12_SP4',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP4-Server-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.103/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp1HVM => {
            name => 'sles15sp1HVM',
            autoyast => 'autoyast_xen/sles15sp1HVM_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --hvm --os-variant sle15sp1',
            macaddress => '52:54:00:78:73:ab',
            ip => '192.168.122.111',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP1-Installer-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.111/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp1PV => {
            name => 'sles15sp1PV',
            autoyast => 'autoyast_xen/sles15sp1PV_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --paravirt --os-variant sle15sp1',
            macaddress => '52:54:00:78:73:ac',
            ip => '192.168.122.112',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP1-Installer-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.112/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp2HVM => {
            name => 'sles15sp2HVM',
            autoyast => 'autoyast_xen/sles15sp2HVM_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --hvm --os-variant sle15sp1',    # sle15sp2 is unknown on 12.3
            macaddress => '52:54:00:78:73:b0',
            ip => '192.168.122.116',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP2-Full-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.116/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp2PV => {
            name => 'sles15sp2PV',
            autoyast => 'autoyast_xen/sles15sp2PV_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --paravirt --os-variant sle15sp1',    # sle15sp2 is unknown on 12.3
            macaddress => '52:54:00:78:73:af',
            ip => '192.168.122.115',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP2-Full-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.115/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp3PV => {
            name => 'sles15sp3PV',
            autoyast => 'autoyast_xen/sles15sp3PV_PRG.xml',
            extra_params => '--os-variant sle15-unknown',
            macaddress => '52:54:00:78:73:b1',
            ip => '192.168.122.117',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP3-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.117/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp3HVM => {
            name => 'sles15sp3HVM',
            autoyast => 'autoyast_xen/sles15sp3HVM_PRG.xml',
            extra_params => '--os-variant sle15-unknown',
            macaddress => '52:54:00:78:73:b2',
            ip => '192.168.122.118',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP3-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.118/24,192.168.122.1,192.168.122.1"',
        },
        sles12sp5HVM => {
            name => 'sles12sp5HVM',
            autoyast => 'autoyast_xen/sles12sp5HVM_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --hvm --os-variant sles12sp4',    # old system compatibility
            macaddress => '52:54:00:78:73:ad',
            ip => '192.168.122.113',
            distro => 'SLE_12_SP5',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP5-Server-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.113/24,192.168.122.1,192.168.122.1"',
        },
        sles12sp5PV => {
            name => 'sles12sp5PV',
            autoyast => 'autoyast_xen/sles12sp5PV_PRG.xml',
            extra_params => '--connect xen:/// --virt-type xen --paravirt --os-variant sles12sp4',    # old system compatibility
            macaddress => '52:54:00:78:73:ae',
            ip => '192.168.122.114',
            distro => 'SLE_12_SP5',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP5-Server-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.114/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp4PV => {
            name => 'sles15sp4PV',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:a5',
            ip => '192.168.122.110',
            distro => 'SLE_15_SP4',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP4-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.110/24,192.168.122.1,192.168.122.1"'
        },
        sles15sp4HVM => {
            name => 'sles15sp4HVM',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:a6',
            ip => '192.168.122.108',
            distro => 'SLE_15_SP4',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP4-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.108/24,192.168.122.1,192.168.122.1"'
        },
        sles15sp5PV => {
            name => 'sles15sp5PV',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:a7',
            ip => '192.168.122.119',
            distro => 'SLE_15_SP5',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP5-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.119/24,192.168.122.1,192.168.122.1"'
        },
        sles15sp5HVM => {
            name => 'sles15sp5HVM',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:a8',
            ip => '192.168.122.120',
            distro => 'SLE_15_SP5',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP5-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.120/24,192.168.122.1,192.168.122.1"'
        }
    );
    # Filter out guests not allowed for the detected SLE version
    if (is_sle('=12-SP5')) {
        my @allowed_guests = qw(sles12sp5HVM sles12sp5PV sles15sp1HVM sles15sp1PV sles15sp5HVM sles15sp5PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=12-SP4')) {
        my @allowed_guests = qw(sles12sp4HVM sles12sp4PV sles12sp5HVM sles12sp5PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP1')) {
        my @allowed_guests = qw(sles15sp1HVM sles15sp1PV sles15sp2HVM sles15sp2PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP2')) {
        my @allowed_guests = qw(sles15sp2HVM sles15sp2PV sles15sp3HVM sles15sp3PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP3')) {
        my @allowed_guests = qw(sles15sp3HVM sles15sp3PV sles15sp4HVM sles15sp4PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP4')) {
        my @allowed_guests = qw(sles12sp5HVM sles12sp5PV sles15sp4HVM sles15sp4PV sles15sp5HVM sles15sp5PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP5')) {
        my @allowed_guests = qw(sles12sp5HVM sles12sp5PV sles15sp5HVM sles15sp5PV);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } else {
        %guests = ();
    }
} elsif (get_var("REGRESSION", '') =~ /kvm|qemu/) {
    %guests = (
        sles12sp3 => {
            name => 'sles12sp3',
            autoyast => 'autoyast_kvm/sles12sp3_PRG.xml',
            extra_params => '--os-variant sles12sp3',
            macaddress => '52:54:00:78:73:a2',
            ip => '192.168.122.102',
            distro => 'SLE_12_SP3',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP3-Server-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.102/24,192.168.122.1,192.168.122.1"',
        },
        sles12sp4 => {
            name => 'sles12sp4',
            autoyast => 'autoyast_kvm/sles12sp4_PRG.xml',
            extra_params => '--os-variant sles12sp4',
            macaddress => '52:54:00:78:73:aa',
            ip => '192.168.122.103',
            distro => 'SLE_12_SP4',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP4-Server-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.103/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp1 => {
            name => 'sles15sp1',
            autoyast => 'autoyast_kvm/sles15sp1_PRG.xml',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:ab',
            ip => '192.168.122.111',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP1-Installer-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.111/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp2 => {
            name => 'sles15sp2',
            autoyast => 'autoyast_kvm/sles15sp2_PRG.xml',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade (originally sle15sp2)
            macaddress => '52:54:00:78:73:af',
            ip => '192.168.122.115',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP2-Full-GM/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.115/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp3 => {
            name => 'sles15sp3',
            autoyast => 'autoyast_kvm/sles15sp3_PRG.xml',
            extra_params => '--os-variant sle15-unknown',
            macaddress => '52:54:00:78:73:b1',
            ip => '192.168.122.117',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP3-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.117/24,192.168.122.1,192.168.122.1"',
        },
        sles12sp5 => {
            name => 'sles12sp5',
            autoyast => 'autoyast_kvm/sles12sp5_PRG.xml',
            extra_params => '--os-variant sles12sp4',    # old system compatibility
            macaddress => '52:54:00:78:73:ad',
            ip => '192.168.122.113',
            distro => 'SLE_12_SP5',
            location => 'http://mirror.suse.cz/install/SLP/SLE-12-SP5-Server-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.113/24,192.168.122.1,192.168.122.1"',
        },
        sles15sp4 => {
            name => 'sles15sp4',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:a6',
            ip => '192.168.122.108',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP4-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.108/24,192.168.122.1,192.168.122.1"'
        },
        sles15sp5 => {
            name => 'sles15sp5',
            extra_params => '--os-variant sle15-unknown',    # problems after kernel upgrade
            macaddress => '52:54:00:78:73:a7',
            ip => '192.168.122.109',
            distro => 'SLE_15',
            location => 'http://mirror.suse.cz/install/SLP/SLE-15-SP5-Full-LATEST/x86_64/DVD1/',
            linuxrc => 'ifcfg="eth0=192.168.122.109/24,192.168.122.1,192.168.122.1"'
        }
    );
    # Filter out guests not allowed for the detected SLE version
    if (is_sle('=12-SP3')) {
        my @allowed_guests = qw(sles12sp3);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=12-SP4')) {
        my @allowed_guests = qw(sles12sp4 sles12sp5);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=12-SP5')) {
        my @allowed_guests = qw(sles12sp5 sles15sp1 sles15sp5);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP1')) {
        my @allowed_guests = qw(sles15sp1 sles15sp2);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP2')) {
        my @allowed_guests = qw(sles15sp2 sles15sp3);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP3')) {
        my @allowed_guests = qw(sles15sp3 sles15sp4);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP4')) {
        my @allowed_guests = qw(sles12sp5 sles15sp4 sles15sp5);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } elsif (is_sle('=15-SP5')) {
        my @allowed_guests = qw(sles12sp5 sles15sp5);
        foreach my $guest (keys %guests) {
            delete $guests{$guest} unless grep { $_ eq $guest } @allowed_guests;
        }
    } else {
        %guests = ();
    }
} elsif (get_var("REGRESSION", '') =~ /vmware/) {
    %guests = (
        sles12sp3 => {
            name => 'sles12sp3',
        },
        sles12sp4 => {
            name => 'sles12sp4',
        },
        sles12sp5 => {
            name => 'sles12sp5',
        },
        sles15sp1 => {
            name => 'sles15sp1',
        },
        sles15sp2 => {
            name => 'sles15sp2',
        },
        sles15sp3 => {
            name => 'sles15sp3',
        },
        sles15sp4 => {
            name => 'sles15sp4',
        },
        sles15sp5 => {
            name => 'sles15sp5',
        },
    );

    delete($guests{sles12sp3}) if (!is_sle('=12-SP3'));
    delete($guests{sles12sp4}) if (!is_sle('=12-SP4'));
    delete($guests{sles12sp5}) if (!is_sle('=12-SP5'));
    delete($guests{sles15sp1}) if (!is_sle('=15-SP1'));
    delete($guests{sles15sp2}) if (!is_sle('=15-SP2'));
    delete($guests{sles15sp3}) if (!is_sle('=15-SP3'));
    delete($guests{sles15sp4}) if (!is_sle('=15-SP4'));
    delete($guests{sles15sp5}) if (!is_sle('=15-SP5'));
} elsif (get_var("REGRESSION", '') =~ /hyperv/) {
    %guests = (
        sles12sp3 => {
            vm_name => 'sles-12.3_openQA-virtualization-maintenance',
        },
        sles12sp4 => {
            vm_name => 'sles-12.4_openQA-virtualization-maintenance',
        },
        sles12sp5 => {
            vm_name => 'sles-12.5_openQA-virtualization-maintenance',
        },
        sles15sp1 => {
            vm_name => 'sles-15.1_openQA-virtualization-maintenance',
        },
        sles15sp2 => {
            vm_name => 'sles-15.2_openQA-virtualization-maintenance',
        },
        sles15sp3 => {
            vm_name => 'sles-15.3_openQA-virtualization-maintenance',
        },
        sles15sp4 => {
            vm_name => 'sles-15.4_openQA-virtualization-maintenance',
        },
        sles15sp5 => {
            vm_name => 'sles-15.5_openQA-virtualization-maintenance',
        },
    );

    delete($guests{sles12sp3}) if (!is_sle('=12-SP3'));
    delete($guests{sles12sp4}) if (!is_sle('=12-SP4'));
    delete($guests{sles12sp5}) if (!is_sle('=12-SP5'));
    delete($guests{sles15sp1}) if (!is_sle('=15-SP1'));
    delete($guests{sles15sp2}) if (!is_sle('=15-SP2'));
    delete($guests{sles15sp3}) if (!is_sle('=15-SP3'));
    delete($guests{sles15sp4}) if (!is_sle('=15-SP4'));
    delete($guests{sles15sp5}) if (!is_sle('=15-SP5'));
} else {
    %guests = ();
}

our %imports = ();    # imports are virtual machines that we don't install but just import. We test those separately.
if (get_var("REGRESSION", '') =~ /xen/) {
    %imports = (
        win2k19 => {
            name => 'win2k19',
            extra_params => '--connect xen:/// --hvm --os-type windows --os-variant win2k8',    # --os-variant win2k19 not supported in older versions
            disk => '/var/lib/libvirt/images/win2k19.raw',
            source => '/mnt/virt_images/xen/win2k19.raw',
            macaddress => '52:54:00:78:73:66',
            ip => '192.168.122.66',
            version => 'Microsoft Windows Server 2019',
            memory => 4096,
            vcpus => 4,
            network_model => "e1000",
        },
    );
} elsif (get_var("REGRESSION", '') =~ /kvm|qemu/) {
    %imports = (
        win2k19 => {
            name => 'win2k19',
            extra_params => '--os-type windows --os-variant win2k8',    # --os-variant win2k19 not supported in older versions
            disk => '/var/lib/libvirt/images/win2k19.raw',
            source => '/mnt/virt_images/kvm/win2k19.raw',
            macaddress => '52:54:00:78:73:66',
            ip => '192.168.122.66',
            version => 'Microsoft Windows Server 2019',
            memory => 4096,
            vcpus => 4,
            network_model => "e1000",
        },
    );
} else {
    %imports = ();
}

1;
