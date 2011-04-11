#!/usr/bin/env python
#
# -*- Mode: Python; coding: iso-8859-1 -*-
# vi:si:et:sw=4:sts=4:ts=4

##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
## USA.
##
## Author(s): Cleber Rodrigues <cleber.gnu@gmail.com>
##

import os
import sys
import time
import libvirt
import libxml2
import logging 

#
# CONFIGURE THIS: Hypervisor choice, choose either 'xen' or 'kvm'
#
HYPERVISOR = 'xen'

#
# CONFIGURE THIS: Where to save backup files to
#
BKP_BASE_PATH = '/bkp'

URIS = {'xen' : 'xen://',
        'kvm' : 'qemu:///system' }

URI = URIS[HYPERVISOR]


if len(sys.argv) < 2:
    print "Usage: %s <vm_name>" % sys.argv[0]
    raise SystemExit

VM_NAME = sys.argv[1]

#
# Initialize logging
#
logging.basicConfig(format='%(asctime)-15s %(message)s',
                    filename='/var/log/bkp_vm.log',
                    level=logging.DEBUG)
log = logging.getLogger('bkp_vm')

def domain_is_active(domain_name, connection):
    virdomain = connection.lookupByName(domain_name)
    return virdomain.ID() in connection.listDomainsID()

def backup(virdomain, connection):
    global URI
    global VM_NAME
    global BKP_BASE_PATH
    global log

    log.debug('New backup job for domain name "%s"' % virdomain.name())

    # Create a directory structure to hold this backup
    dirname = os.path.join(BKP_BASE_PATH, virdomain.name())
    if not os.path.exists(dirname):
        log.info('Backup directory "%s" does not exit' % dirname)
        try:
            os.mkdir(dirname)
            log.info('Success creating directory "%s"' % dirname)
        except OSError:
            log.info('Failed creating directory "%s"' % dirname)
            raise SystemExit

    # Save a XML dump of this domain
    xmldump = open(os.path.join(dirname, "%s.xml" % virdomain.name()), 'w')
    xmldump.write(virdomain.XMLDesc(0))
    xmldump.close()

    # Shutdown this domain
    if domain_is_active(VM_NAME, connection):
        try:
            log.info('Shutting down domain %s' % VM_NAME)
            virdomain.shutdown()
            log.info('Success shutting down domain %s' % VM_NAME)
        except:
            log.info('Failed shutting down domain %s' % VM_NAME)
            raise SystemExit

    #
    # sleep while the domain shutsdown (maximum of 5 minutes)
    #
    for i in xrange(60 * 5):
        if not domain_is_active(VM_NAME, connection):
            log.info('Domain %s is now completely shutdown' % VM_NAME)
            break
        else:
            time.sleep(1)
            log.info('Slept %s seconds waiting for domain %s to shutdown' % (i, VM_NAME))

    # Lookup disks for this domain
    xml_doc = libxml2.parseDoc(virdomain.XMLDesc(0))
    xpath_ctx = xml_doc.xpathNewContext()
    source_devices = xpath_ctx.xpathEval("/domain/devices/disk/source[@dev]")

    for device in source_devices:
        device_path = device.prop('dev')
        if os.path.exists(device_path):
            # Disk exists, back it up
            bkp_path = os.path.join(dirname, "%s.img.bz2" % device_path.split(os.path.sep)[-1])
            cmd = "dd if=%(device_path)s bs=4M | bzip2 > %(bkp_path)s" % locals()
            log.debug('Executing command: "%s"' % cmd)
            os.system(cmd)

    # Start the vm
    if not domain_is_active(VM_NAME, connection):
        log.debug('Domain "%s" is not active' % VM_NAME)
        log.debug('Starting domain "%s"' % VM_NAME)
        cmd = 'xm create %s' % VM_NAME
        log.debug('Executing command: "%s"' % cmd)
        os.system(cmd)

def main():
    global URI
    
    connection = libvirt.open(URI)
    try:
        virdomain = connection.lookupByName(VM_NAME)
    except libvirt.libvirtError:
        print "Could not find virtual machine named %s" % VM_NAME;
        raise SystemExit
    
    backup(virdomain, connection)

if __name__ == '__main__':
    main()
