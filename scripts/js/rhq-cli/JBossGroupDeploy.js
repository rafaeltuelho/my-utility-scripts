/*
#############################################################
# JBoss Group Deploy
# descricao: Realizar deploy/redeploy de pacotes WAR/EAR em 
#            um grupo de instancias de JBoss 
#            atraves da interface remota do JON/RHQ.
# autor: Rafael Soares
# data de criacao: 28/09/2010
# fonte: http://docs.redhat.com/docs/en-US/JBoss_Operations_Network/2.4/html/CLI_Guide/Scripted_Group_Deployments_using_the_CLI_API.html
#############################################################
*/

// Global variables
//   Lista de recursos agrupados e monitorados pelo JON
var resourcesArray = null;

//TODO DEBUG
/*
for( i in args ) {
   println('args[' + i + ']: [' + args[i] + ']');
}
*/

if (operation.equals("deploy")){
      println("Entrei no DEPLOY");
      createNewAppOnJBossGroup(groupName, fileName, appTypeName, packageVersion, packageName, deployDIR);
}
if (operation.equals("redeploy")){
      redeployOnJBossGroup(fileName, groupName, packageName);
}
else if (operation.equals("stop")){
      println("call stop func");
}
else if (operation.equals("start")){
      println("call start func");
}
else if (operation.equals("status")){
      status(groupName);
}
else if (operation.equals("fetchGroups")){
      fetchGroups();
}
else if (operation.equals("createNewJBossGroup")){
      createNewJBossGroup(groupName, pluginName, recursive);
}
else if (operation.equals("addNewJBossInstanceInGroup")){
      addNewJBossInstanceInGroup(groupName, searchPattern);
}
else {
		usage();
}

function fetchGroups(){
   // find resource group
   var rgc = new ResourceGroupCriteria();
   rgc.addFilterGroupCategory(GroupCategory.COMPATIBLE); //TODO: receber como param.
   rgc.fetchExplicitResources(true);
   var groupList = ResourceGroupManager.findResourceGroupsByCriteria(rgc);

   for(var i=0; i < groupList.size(); i++ ) {
       var group = groupList.get(i);
       println(group.name);   
   }
}

function createNewJBossGroup(pGroupName, pPluginName, isRecursive){
  
   var resType = ResourceTypeManager.getResourceTypeByNameAndPlugin("JBossAS Server", pPluginName) 
   var rg = new ResourceGroup(pGroupName, resType);

   rg.setRecursive(java.lang.Boolean.valueOf(isRecursive).booleanValue());
   rg.setDescription("Created via groupcontrol scripts on " + new java.util.Date().toString());

   ResourceGroupManager.createResourceGroup(rg);
}

function addNewJBossInstanceInGroup(pGroupName, pSearchPattern){

   var rgc = new ResourceGroupCriteria();
   rgc.addFilterName(pGroupName);
   rgc.fetchExplicitResources(true);
   var groupList = ResourceGroupManager.findResourceGroupsByCriteria(rgc);

   //Check if there is a group found:
   if( groupList == null || groupList.size() != 1 ) {
       println("Can't find a resource group named " + pGroupName);
       usage();
   }

   var group = groupList.get(0);

   // Add resources to the blank group as follows:
   // now, search for EAP resources based on criteria
   criteria = new ResourceCriteria();
   criteria.addFilterName(pSearchPattern);

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

}

function groupCommonOperation(pGroupName){
   //Verify that the group really exists on my JBoss ON server:

   // find resource group
   var rgc = new ResourceGroupCriteria();
   rgc.addFilterName(pGroupName);
   rgc.fetchExplicitResources(true);
   var groupList = ResourceGroupManager.findResourceGroupsByCriteria(rgc);

   //The important part here is the call the resources.
   rgc.fetchExplicitResources(true);

   //Check if there is a group found:
   if( groupList == null || groupList.size() != 1 ) {
       println("Can't find a resource group named " + pGroupName);
       usage();
   }

   var group = groupList.get(0);
				
   println("  Found group: " + group.name );
   println("  Group ID   : " + group.id );
   println("  Description: " + group.description);

   //After validating that there is a group with the specified name, check if the group contains explicit resources:
   if( group.explicitResources == null || group.explicitResources.size() == 0 ) {
       println("  Group does not contain explicit resources --> exiting!" );
       usage();
   }
   
   // JBoss Groups
   resourcesArray = group.explicitResources.toArray();
}

function status(pGroupName){
   // obtem o grupo de instancias de JBoss
   groupCommonOperation(pGroupName);

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
       var avail  = AvailabilityManager.getCurrentAvailabilityForResource(server.id);
				
       println("  " + server.name );
       println("    - Availability: " + avail.availabilityType.getName());
       println("    - Started     : " + avail.startTime.toGMTString());
       println("");  
   }
}

function createNewAppOnJBossGroup(pGroupName, pFileName, pAppTypeName, pPackageVersion, pPackageName, pDeployDIR){

   //Then get the package type of the application.
   var appTypeName = pAppTypeName;
   if (pAppTypeName.equals("WAR"))
      appTypeName = "Web Application (WAR)";
   else if (pAppTypeName.equals("EAR"))
      appTypeName = "Enterprise Application (EAR)"; 
      
	var appType = ResourceTypeManager.getResourceTypeByNameAndPlugin(appTypeName, "JBossAS");
   if(appType == null) {
       println("  Could not find application type. Exit.");
       println("  Could not find applicationType [" + appTypeName + "]. Exit.");
       usage();
   }

   // create deployConfig 
   //The property names can be retrieved by calling a list of supported properties by the package type by calling this method:
   //var deployConfigDef = ConfigurationManager.getPackageTypeConfigurationDefinition(realPackageType.getId());
   var deployConfig = new Configuration();
   deployConfig.put( new PropertySimple("deployDirectory", "deploy"));
   deployConfig.put( new PropertySimple("deployZipped", "true"));
   deployConfig.put( new PropertySimple("createBackup", "true"));

   // Converte o arquivo no disco em bytes[]
   var fileBytes = scriptUtil.getFileBytes(pFileName);

   // obtem o grupo de instancias de JBoss
   groupCommonOperation(pGroupName);

   for( i in resourcesArray ) {
       var res = resourcesArray[i];
       var resType = res.resourceType.name;
       println("  Found resource " + res.name + " of type " + resType + " and ID " + res.id);
				
       // get server resource to start/stop it and to redeploy application
       // var server = ProxyFactory.getResource(12304); //LOCALHOST JBoss EAP 4.3 instance
       var server = ProxyFactory.getResource(res.id);
       var avail  = AvailabilityManager.getCurrentAvailabilityForResource(server.getId());

       println("  " + server.name );
       println("    - Availability: " + avail.availabilityType.getName());
       println("    - Started     : " + avail.startTime.toGMTString());
       println(" ");  
       println("creating the " + appTypeName + " inside " + server.name + " ...");

       //Then, create the resource:

/*
       println("server.getId(): "  + server.getId());
       println("appType.getId(): " + appType.getId());
       println("pPackageName: "    + pPackageName);
       println("pPackageVersion: " + pPackageVersion);
       println("deployConfig: "    + deployConfig.toString());
       println("fileBytes: "       + fileBytes.length);
*/
/*
    parentResourceId - parent resource under which the new resource should be created
    newResourceTypeId - identifies the type of resource being created
    newResourceName - Ignored, pass null. This is determined from the package.
    pluginConfiguration - optional plugin configuration that may be needed in order to create the new resource
    packageName - name of the package that will be created as a result of this resource create
    packageVersion - The string version of the package. If null will be set to system timestamp (long)
    architectureId - Id of the target architecture of the package, null indicates NoArch (any).
    deploymentTimeConfiguration - dictates how the package will be deployed
    packageBits - content of the package to create
*/
       ResourceFactoryManager.createPackageBackedResource(
           server.getId(),  // parentResourceId
           appType.getId(), // newResourceTypeId
           null,            // newResourceName
           null,            // pluginConfiguration
           pPackageName,    // packageName
           pPackageVersion, // packageVersion
           null,            // architectureId        
           deployConfig,    // resourceConfiguration
           fileBytes);      // packageBits
/**/

/*
       ResourceFactoryManager.createPackageBackedResource(
           server.getId(),  // parentResourceId
           appType.getId(), // newResourceTypeId
 	        null,            // newResourceName
           null,            // pluginConfiguration
           "store.war",    // packageName
           "2.0", // packageVersion
           null,            // architectureId        
           deployConfig,    // resourceConfiguration
           fileBytes);      // packageBits
*/
   }
}

function redeployOnJBossGroup(pFileName, pGroupName, pPackageName){
   /* 
      RresourceArray now contains all resources which are part of the group. 
      Next, check if there are JBoss AS Server instances which need to be restarted 
      before the application is deployed. 
   */

   // obtem o grupo de instancias de JBoss
   groupCommonOperation(pGroupName);

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

       //Next, traverse all the children of the server instance and find the resource name of the application:
       var children = server.children;
       for( c in children ) {
           var child = children[c];
	        println("child name: " + child.name);
           if( child.name.contains(pPackageName) ) {
               /*
                PackageName is the name of the application without version 
                information and path as shown in the JBoss ON GUI as deployed applications.
                Create a backup of the original version of the application:
               */
               println("    download old app to /tmp/bkp");
               child.retrieveBackingContent("/tmp/" + packageName + "_old");
 
               println("    uploading new application code");
               child.updateBackingContent(pFileName);

               //TODO: invoke a operation restart...
		 
               println("sleep 10sec to wait for redeploy process...");
               java.lang.Thread.sleep(10000);
              // println("    restarting " + server.name + "....." );
			 
               //try {
                  // server.restart();
              // }
              // catch( ex ) {
               //    println("   --> Caught " + ex );
              // }
           } //if
       } // for
   } //for
}

function usage(){
   println("rhq-cli.sh -f JBossGroupDeploy.js 'FileName(EAR/WAR)' 'GroupName'");
}


/*
 Lang Syntax
   Assert.assertTrue(channels.size() == 0, "test channel should not exist.");
   Assert.assertNotNull(testChannel, "test channel should exist");
   Assert.assertEquals("test-channel-0", testChannel.getName());
   Assert.assertNumberEqualsJS( wars.size(), 1, "Found more than 1 test-channel-war");
*/
