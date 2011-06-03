/* tests on rhq-cli console to undestand the API...

jmxServerPluginConfigurationDefinition.getPropertyDefinitions() 
Key                        Value                                                    
------------------------------------------------------------------------------------
principal                  SimpleProperty[principal] (Type: STRING)                 
credentials                SimpleProperty[credentials] (Type: PASSWORD)             
additionalClassPathEntries SimpleProperty[additionalClassPathEntries] (Type: STRING)
type                       SimpleProperty[type] (Type: STRING)                      
connectorAddress           SimpleProperty[connectorAddress] (Type: STRING)          
installURI                 SimpleProperty[installURI] (Type: STRING)

jmxServerPluginConfigurationDefinition.getTemplates();
Key        Value                                                              
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
default    ConfigurationTemplate[id=10037, name=default, config=JMX Server]   
Weblogic 9 ConfigurationTemplate[id=10035, name=Weblogic 9, config=JMX Server]
JBoss AS   ConfigurationTemplate[id=10034, name=JBoss AS, config=JMX Server]  
WebSphere  ConfigurationTemplate[id=10036, name=WebSphere, config=JMX Server] 
JDK 5      ConfigurationTemplate[id=10033, name=JDK 5, config=JMX Server]
*/

println("START! ");

var rtc = new ResourceTypeCriteria();
rtc.addFilterName("JMX Server");
var jmxResourceType = ResourceTypeManager.findResourceTypesByCriteria(rtc).getValues().get(0);
var jmxServerPluginConfigurationDefinition = ConfigurationManager.getPluginConfigurationDefinitionForResourceType(jmxResourceType.id);

// Get the Resource Group by its Name
var rgc = new ResourceGroupCriteria();
rgc.addFilterName("DynaGroup - ALL Linux Servers hosting JBossAS");
rgc.fetchExplicitResources(true);

var linuxGroupList = ResourceGroupManager.findResourceGroupsByCriteria(rgc);
rgc.fetchExplicitResources(true);

var linuxGroup = linuxGroupList.get(0);
var linuxResourcesArray = linuxGroup.explicitResources.toArray();

// for each Linux Platform found in the Group
for( i in linuxResourcesArray ) {
   try {
      var linuxServer = linuxResourcesArray[i];
      
      println(">>> " + linuxServer.name);
      // skip JON Server Platform
      if (linuxServer.name.contains("JON"))
         continue;

      var jmxServerResource = null;
      var jmxServerConfig = new Configuration();

      jmxServerConfig.put(new PropertySimple("principal", "monitorRole"));
      jmxServerConfig.put(new PropertySimple("credentials", "xxxxxx"));
      jmxServerConfig.put(new PropertySimple("additionalClassPathEntries", null));
      jmxServerConfig.put(new PropertySimple("type", "org.mc4j.ems.connection.support.metadata.J2SE5ConnectionTypeDescriptor"));
      jmxServerConfig.put(new PropertySimple("installURI", null));
      jmxServerConfig.put(new PropertySimple("connectorAddress", "service:jmx:rmi:///jndi/rmi://0.0.0.0:9001/jmxrmi"));
         
      /*
      Resource manuallyAddResource(Subject subject,
                                           int resourceTypeId,
                                           int parentResourceId,
                                           Configuration pluginConfiguration) throws Exception */
      jmxServerResource = DiscoveryBoss.manuallyAddResource(jmxResourceType.id, linuxServer.id, jmxServerConfig);

      // method not available for JON 2.4.1
      //jmxServerResource.setName("JBossAS JVM - mte-cbo");
      //ResourceFactory.updateResourceName(jmxServerResource.id, jmxServerResource.getName());
   }
   catch ( ex ) {
      println("   --> Caught " + ex );
   }
}

println("FINISH!");

