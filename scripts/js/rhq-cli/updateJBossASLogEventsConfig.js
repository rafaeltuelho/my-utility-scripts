/**
 * RHQ-CLI script to update the log events properties from a set of JBossAS resources on RHQ inventory
 * This is useful to automate some tasks in a big group of resources that using the web UI would take a lot of time...
 *
 * Refs:
 *    - RHQ Project site: http://www.rhq-project.org/
 *    - Motivation: https://fedorahosted.org/pipermail/rhq-devel/2011-May/000820.html
 *    - JON-CLI docs: http://docs.redhat.com/docs/en-US/JBoss_Operations_Network/2.4/html/CLI_Guide/index.html
 *    - JON API Guides: http://docs.redhat.com/docs/en-US/JBoss_Operations_Network/2.4/html/API_Guides/index.html
 *    - John Sanda's blog with a lot of cli examples: http://johnsanda.blogspot.com/search/label/cli
 *
 * Running the script:
 *    RHQ-CLI_HOME/bin/rhq-cli.sh -u rhqadmin -p rhqadmin -s 127.0.0.1 -t 7080 -f /<full path to this script>/script.js
 *
 * Author: rafaelcba at gmail dot com
 * TODO: parameterize the data entry: Group Name, new PropertySimple values, etc 
 */


println("START! ");

// Get the Resource Group by its Name
var rgc = new ResourceGroupCriteria();
rgc.addFilterName("DynaGroup - ALL-JBossAS4");
rgc.fetchExplicitResources(true);

var jbossGroupList = ResourceGroupManager.findResourceGroupsByCriteria(rgc);
rgc.fetchExplicitResources(true);

var jbossGroup = jbossGroupList.get(0);
var jbossResourcesArray = jbossGroup.explicitResources.toArray();

// util vars
// only Y|y|N|n is accepted as answer 
var ASN_REGEX = java.util.regex.Pattern.compile("^[YynN]$");

// for each JBossAS resource instance foud in the Group
for( i in jbossResourcesArray ) {

   try {
      var res = jbossResourcesArray[i];
      var jboss = ProxyFactory.getResource(res.id);
      var avail  = AvailabilityManager.getCurrentAvailabilityForResource(jboss.id);

      println("");
      println("");
      println("  " + jboss.name );
      println("    - Availability: " + avail.availabilityType.getName());
      println("    - Started     : " + avail.startTime.toGMTString());
      println("");

      // test if the resource is UP
      if (avail.availabilityType.equals(AvailabilityType.UP)) {      
       
         var jbossConfig = ConfigurationManager.getPluginConfiguration(jboss.id);
         var jbossConfigPropList = jbossConfig.getList("logEventSources");

         // if there is one or more server log defined
         println(" ---> " + jbossConfigPropList.list.size());
         if (jbossConfigPropList.list.size() > 0) {
            println(" UPDATING [" + jboss.name + "] ...");

            // for each log defined fors this JBossAS instance
            for ( l in jbossConfigPropList.list.toArray() ) {
               var jbossConfigLogEventSourcesMap = jbossConfigPropList.list.get(l);
               var jbossConfigLogEventSourcesMapPropertySimpleLogPath = jbossConfigLogEventSourcesMap.getSimple("logFilePath");
               println("   >>>  enabling [" + jbossConfigLogEventSourcesMapPropertySimpleLogPath.getStringValue() + "] <<<");

               var jbossConfigLogEventSourcesMapPropertySimpleEnabled = jbossConfigLogEventSourcesMap.getSimple("enabled");
               jbossConfigLogEventSourcesMapPropertySimpleEnabled.setBooleanValue(true);

               var jbossConfigLogEventSourcesMapPropertySimpleIncludesPattern = jbossConfigLogEventSourcesMap.getSimple("includesPattern");
               jbossConfigLogEventSourcesMapPropertySimpleIncludesPattern.setStringValue(".*SQLException*|.*ORA-\d{4,5}|.*PSQLException|.*JBossResourceException: Could not create connection|.*Caused by: java.net.ConnectException: Connection timed out|.*javax.resource.ResourceException: Unable to get managed connection for*|.*java.io.IOException:*|.*UnknownHostException*");

               var jbossConfigLogEventSourcesMapPropertySimpleMinimumSeverity = jbossConfigLogEventSourcesMap.getSimple("minimumSeverity");
               jbossConfigLogEventSourcesMapPropertySimpleMinimumSeverity.setStringValue("error");

               ConfigurationManager.updatePluginConfiguration(jboss.id, jbossConfig);

               var latestPluginConfigurations = ConfigurationManager.getLatestPluginConfigurationUpdate(jboss.id);
               println("   latestPluginConfigurations: " + latestPluginConfigurations.toString());
            }
         }
      }
      else {
         continue;
      }
   } 
   catch ( ex ) {
      println("   --> Caught " + ex );
   }
   finally {
      
      println(" "); 
      // println(" >>> [" + jboss.name  + "] log events config UPDATED! <<<");
      println(" Do you want to continue? (Y/n)");

      var console = new java.util.Scanner(java.lang.System["in"]);
      if ( console.hasNext(ASN_REGEX) && console.next().equalsIgnoreCase("Y") )
         continue;
      else
         break;

      console.close();

   }
}

println("FINISH! ");
