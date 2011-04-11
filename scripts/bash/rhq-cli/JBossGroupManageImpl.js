
#######
## create: Create a new group
#######

// Now just create the group
// First find resourceType specified by pluginName                                 //@TODO definir pluginName (???)

//pluginName = JBossAS|JBossAS5
var resType = ResourceTypeManager.getResourceTypeByNameAndPlugin("JBossAS Server", pluginName) 
                           //@TODO receber via param.
var rg = new ResourceGroup(groupName, resType);
rg.setRecursive(true);
rg.setDescription("Created via groupcontrol scripts on " + new java.util.Date().toString());
				
ResourceGroupManager.createResourceGroup(rg);

####### @TODO
## delete: Delete an existing group
#######

#######
## add   : Add a new EAP instance to the specified group
#######
// Add resources to the blank group as follows:
// now, search for EAP resources based on criteria
criteria = new ResourceCriteria();
criteria.addFilterName(searchPattern); //@TODO receber via param.
/* @TODO
   This means that JBoss AS Server instances should be based on the given searchPattern. For example:
   tolnedra.belgariad JBoss EAP 4.3.0.GA_CP03 node1 (192.168.100.50:1099)
   tolnedra.belgariad JBoss EAP 4.3.0.GA_CP03 node2 (192.168.100.51:1099)
*/

criteria.addFilterResourceTypeName("JBossAS Server");
				
var resources = ResourceManager.findResourcesByCriteria(criteria);

if( resources != null ) {
  if( resources.size() > 1 ) {
	println("Found more than one JBossAS Server instance. Try to specialize.");
     for( i =0; i < resources.size(); ++i) {
	  var resource = resources.get(i);
          println("  found " + resource.name );
     }
  }
  else if( resources.size() == 1 ) {
     resource = resources.get(0);
     println("Found one JBossAS Server instance. Trying to add it.");
     println("  " + resource.name );
        ResourceGroupManager.addResourcesToGroup(group.id, [resource.id]);
     println("  Added to Group!");
  }
  else {
        println("Did not find any JBossAS Server instance matching your pattern. Try again.");
  }
}

####### @TODO
## remove: Remove an existing EAP instance from the specified group
#######

#######
## status: Print the status of all resources of a group
#######
//Now, create a group and add resources to it. The inventory information is available by using the AvailabilityManager call:

// get server resource to start/stop it and to redeploy application
var server = ProxyFactory.getResource(res.id);
var avail  = AvailabilityManager.getCurrentAvailabilityForResource(server.id);
				
println("  " + server.name );
println("    - Availability: " + avail.availabilityType.getName());
println("    - Started     : " + avail.startTime.toGMTString());
println("");


#######
##   deploy: Deploys an application to all AS instances specified by group nam
#######
/*
Deploying new or existing applications was explained in Chapter 4, Example: Scripting Resource Deployments.
This method is similar, but it doesn't require stopping and restarting the server:
*/
// we need check to see if the given server is up and running
var avail = AvailabilityManager.getCurrentAvailabilityForResource(server.id);
				
// unfortunately, we can only proceed with deployment if the server is running. Why?
if( avail.availabilityType.toString() == "DOWN" ) {
	   println("  Server is DOWN. Please first start the server and run this script again!");
	   println("");
	   continue;
}


#######
##   start : start all EAP instances specified by group name
##   stop  : stop all EAP instances specified by group name
#######
/*
JBoss ON servers can be started and stopped by iterating through all the resources in a specific group and issuing the corresponding operation (shutdown(), start(), or restart()) on it:
*/

var resourcesArray = group.explicitResources.toArray();
				
for( i in resourcesArray ) {
     var res = resourcesArray[i];
     var resType = res.resourceType.name;
     println("  Found resource " + res.name + " of type " + resType + " and ID " + res.id);
				
     if( resType != "JBossAS Server") {
	  println("    ---> Resource not of required type. Exiting!");
	  usage();
     }
				
     // get server resource to start/stop it and to redeploy application
     var server = ProxyFactory.getResource(res.id);
     println("    Starting " + server.name + "....");
     try {
	  server.start();
     }
     catch( ex ) {
	  println("   --> Caught " + ex );
     }
}


