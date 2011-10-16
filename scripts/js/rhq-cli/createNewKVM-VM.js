
// Create a new Virtual Machine

//VirtualGuest res type
//ResourceType[id=10292, category=Service, name=Virtual Guest, plugin=Virtualization]

// Better aproach
//Ref: http://johnsanda.blogspot.com/2011/06/manually-add-resources-to-inventory.html
//DiscoveryBoss.manuallyAddResource(int resourceTypeId, int parentResourceId, Configuration pluginConfiguration)


/*
  ResourceConfiguration
   type = kvm
   name = jbossinbossa
   uid = x
   cpus = 1
   memory = 512000
   currentMemory = 512000

   Networking
      interfaces
         source = 
         target = 
         macAddress
         type = bridge|network
         script

   storage
      disks
         targetBus
         drivertype
         sourceFile
         device
         type  = file|block
         driverName
         sourceDevice
         targetDevice
*/

  var config = new Configuration();

/*
                <c:simple-property name="type" type="string" readOnly="true" description="The type of virtual machine"
                                   default="xen">
                    <c:property-options>
                        <c:option value="xen" name="xen"/>
                        <c:option value="kvm" name="kvm"/>
                        <c:option value="qemu" name="qemu"/>
                        <c:option value="lxc" name="lxc"/>
                        <c:option value="kqemu" name="kqemu"/>
                    </c:property-options>
                </c:simple-property>
*/
   config.put(new PropertySimple('type', 'kvm'));

/*
                <c:simple-property name="name" type="string" readOnly="true" description="The name of the domain"/>
                <c:simple-property name="uuid" type="string" readOnly="true" required="false"
                                   description="The universally unique identifier of the domain"/>
                <c:simple-property name="vcpu" displayName="CPUs" type="integer" default="1"
                                   description="How many virtual CPUs should be allocated for this machine?"/>
                <c:simple-property name="memory" type="integer" units="kilobytes" default="512000"
                                   description="The maximum memory available to this domain in kilobytes"/>
                <c:simple-property name="currentMemory" type="integer" units="kilobytes" default="512000"
                                   description="How much memory should be allocated for this machine in kilobytes"/>
*/

   config.put(new PropertySimple('name', 'vm-JBossInBossa'));
   config.put(new PropertySimple('uuid', ''));
   config.put(new PropertySimple('vcpu', '1'));
   config.put(new PropertySimple('memory', '512000'));
   config.put(new PropertySimple('currentMemory', '512000'));

/*
                <c:group name="Lifecycle Actions">
                    <c:simple-property name="on_poweroff" displayName="On Power Off" type="string" default="destroy"
                                       description="What should happen when the machine is powered off?">
                        <c:property-options>
                            <c:option value="destroy"/>
                            <c:option value="restart"/>
                            <c:option value="preserve"/>
                            <c:option value="rename-restart"/>
                        </c:property-options>
                    </c:simple-property>
                    <c:simple-property name="on_reboot" displayName="On Reboot" type="string" default="restart"
                                       description="What should happen when the machine is rebooted?">
                        <c:property-options>
                            <c:option value="destroy"/>
                            <c:option value="restart"/>
                            <c:option value="preserve"/>
                            <c:option value="rename-restart"/>
                        </c:property-options>
                    </c:simple-property>
                    <c:simple-property name="on_crash" displayName="On Crash" type="string" default="restart"
                                       description="What should happen when the machine crashes?">
                        <c:property-options>
                            <c:option value="destroy"/>
                            <c:option value="restart"/>
                            <c:option value="preserve"/>
                            <c:option value="rename-restart"/>
                        </c:property-options>
                    </c:simple-property>
                </c:group>
*/
   config.put(new PropertySimple('on_poweroff', 'destroy'));
   config.put(new PropertySimple('on_reboot', 'restart'));
   config.put(new PropertySimple('on_crash', 'restart'));

/*
                <c:group name="Networking">
                    <c:list-property name="interfaces">
                        <c:map-property name="interface">
                            <c:simple-property name="type">
                                <c:property-options>
                                    <c:option value="network" name="network"/>
                                    <c:option value="bridge" name="bridge"/>
                                </c:property-options>
                            </c:simple-property>
                            <c:simple-property name="source"/>
                            <c:simple-property name="target"/>
                            <c:simple-property name="script"/>
                            <c:simple-property name="macAddress" displayName="MAC Address"/>
                        </c:map-property>
                    </c:list-property>
                </c:group>
*/
   var netIfcsList = new PropertyList('interfaces');
   var netIfcMap = new PropertyMap('interface');
   netIfcMap.put(new PropertySimple('type', 'network'));
   netIfcMap.put(new PropertySimple('source', null));
   netIfcMap.put(new PropertySimple('target', 'vtnet'));
   netIfcMap.put(new PropertySimple('script', null));
   netIfcMap.put(new PropertySimple('macAddress', '52:54:00:5f:44:9b'));
   netIfcsList.add(netIfcMap);
   config.put(netIfcsList);

/*
                <c:group name="Storage">
                    <c:list-property name="disks">
                        <c:map-property name="disk">
                            <c:simple-property name="type" default="file">
                                <c:property-options>
                                    <c:option value="file" name="file"/>
                                    <c:option value="block" name="block"/>
                                </c:property-options>
                            </c:simple-property>
                            <c:simple-property name="device" required="false"/>                            
                            <c:simple-property name="driverName" required="false"/>
                            <c:simple-property name="driverType" required="false"/>
                            <c:simple-property name="sourceFile" required="false"/>
                            <c:simple-property name="sourceDevice" required="false"/>
                            <c:simple-property name="targetDevice" required="false"/>
                            <c:simple-property name="targetBus" required="false"/>                            
                        </c:map-property>
                    </c:list-property>
                </c:group> 
*/
   var disksList = new PropertyList('disks');
   var diskMap = new PropertyMap('disk');
   diskMap.put(new PropertySimple('type', 'file'));
   diskMap.put(new PropertySimple('device', 'disk'));
   diskMap.put(new PropertySimple('driverName', 'qemu'));
   diskMap.put(new PropertySimple('driverType', 'raw'));
   diskMap.put(new PropertySimple('sourceFile', '/var/lib/libvirt/images/vm-JBossInBossa.img'));
   diskMap.put(new PropertySimple('sourceDevice', null   ));
   diskMap.put(new PropertySimple('targetDevice', 'vda'));
   diskMap.put(new PropertySimple('targetBus', 'virtio'));
   disksList.add(netIfcMap);
   config.put(disksList);

   // Add a new Virtual Guest
   DiscoveryBoss.manuallyAddResource(10292, 10851, config);
   

