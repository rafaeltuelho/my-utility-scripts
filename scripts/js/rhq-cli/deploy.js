function createNewAppOnJBossGroup(){
   println("starting createNewAppOnJBossGroup() func...");

   /*
       First, get the resource type for the application. This depends on several parameters:
         1. The type of the application (e.g., WAR or EAR)
         2. The type of the container the app needs to be deployed on (such as Tomcat or JBoss AS) 
   */

   // Verifica se o arquivo existe
   var file = new java.io.File(fileName);
   //var packageName = "store.war";
   var packageName = "test.war";
   var packageVersion = "1.0.0";

   if( !file.exists() ) {
       println(fileName + " nao existe!");
       usage();
   }
				
   if( !file.canRead() ) {
       println(fileName + " nao pode ser lido!");
       usage();
   }

   appTypeName = "Web Application (WAR)";
	var appType = ResourceTypeManager.getResourceTypeByNameAndPlugin(appTypeName, "JBossAS");
   if( appType == null ) {
       println("  Could not find application type. Exit.");
       usage();
   }

   //Then get the package type of the application.
   var realPackageType = ContentManager.findPackageTypes(appTypeName, "JBossAS");
				
   if(realPackageType == null) {
       println("  Could not find JBoss ON's packageType. Exit.");
       usage();
   }

   // create deployConfig 
   var deployConfig = new Configuration();                 //@TODO ler da console 
   deployConfig.put( new PropertySimple("deployDirectory", "deploy"));
   deployConfig.put( new PropertySimple("deployZipped", "true"));
   deployConfig.put( new PropertySimple("createBackup", "true"));

   //The property names can be retrieved by calling a list of supported properties by the package type by calling this method:
   //var deployConfigDef = ConfigurationManager.getPackageTypeConfigurationDefinition(realPackageType.getId());

   //Provide the package bits as a byte array:
   //var inputStream = new java.io.FileInputStream(file);
   var fileLength = file.length();

   /*
   var fileBytes = java.lang.reflect.Array.newInstance(java.lang.Byte.TYPE, fileLength);

   println(fileLength);

   for (numRead=0, offset=0; ((numRead >= 0) && (offset < fileBytes.length)); offset += numRead ) {
       print(offset);
       numRead = inputStream.read(fileBytes, offset, fileBytes.length - offset); 	
   }

   // Ensure all the bytes have been read in
   if (offset < fileBytes.length) {
       println("Could not completely read file "+file.getName());
   }

   // obtem o grupo de instancias de JBoss
   groupCommonOperation();
   */
   var fileBytes = getFileBytes(fileName);

   var criteria = ResourceCriteria();
   criteria.addFilterId(10003);
   resources = ResourceManager.findResourcesByCriteria(criteria);

   var resourcesArray = [resources.get(0)];

   for( i in resourcesArray ) {
       var res = resourcesArray[i];
       var resType = res.resourceType.name;
       println("  Found resource " + res.name + " of type " + resType + " and ID " + res.id);
				
       // get server resource to start/stop it and to redeploy application
       var server = ProxyFactory.getResource(res.id);
       var avail  = AvailabilityManager.getCurrentAvailabilityForResource(server.id);
				
       println("  " + server.name );
       println("    - Availability: " + avail.availabilityType.getName());
       println("    - Started     : " + avail.startTime.toGMTString());
       println("");  

       println("creating the " + appTypeName + "inside " + server.name + " ...");

       //Then, create the resource:
       ResourceFactoryManager.createPackageBackedResource(
           server.id,
           appType.id,
           packageName,
           null,  // pluginConfiguration
           packageName,
           packageVersion,
           null, // architectureId        
           deployConfig,
           fileBytes
      );
   }

   //inputStream.close();
}

