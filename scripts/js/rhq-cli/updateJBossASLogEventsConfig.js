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
 */


var rgc = new ResourceGroupCriteria();
rgc.addFilterName("JBossAS5-Instances");
rgc.fetchExplicitResources(true);
var jbossGroupList = ResourceGroupManager.findResourceGroupsByCriteria(rgc);
rgc.fetchExplicitResources(true);
var jbossGroup = jbossGroupList.get(0);
var jbossResourcesArray = jbossGroup.explicitResources.toArray();

for( i in jbossResourcesArray ) {
   var res = jbossResourcesArray[i];
   var jboss = ProxyFactory.getResource(res.id);
   var avail  = AvailabilityManager.getCurrentAvailabilityForResource(jboss.id);

   println("");
   println("");
   println("  " + jboss.name );
   println("    - Availability: " + avail.availabilityType.getName());
   println("    - Started     : " + avail.startTime.toGMTString());
   println("");

   var jbossConfig = ConfigurationManager.getPluginConfiguration(jboss.id);
   var jbossConfigPropList = jbossConfig.getList("logEventSources");
   var jbossConfigLogEventSourcesMap = jbossConfigPropList.list.get(0);

   var jbossConfigLogEventSourcesMapPropertySimpleEnabled = jbossConfigLogEventSourcesMap.getSimple("enabled");
   jbossConfigLogEventSourcesMapPropertySimpleEnabled.setBooleanValue(true);

   var jbossConfigLogEventSourcesMapPropertySimpleIncludesPattern = jbossConfigLogEventSourcesMap.getSimple("includesPattern");
   jbossConfigLogEventSourcesMapPropertySimpleIncludesPattern.setStringValue(".*SQLException.*");

   var jbossConfigLogEventSourcesMapPropertySimpleMinimumSeverity = jbossConfigLogEventSourcesMap.getSimple("minimumSeverity");
   jbossConfigLogEventSourcesMapPropertySimpleMinimumSeverity.setStringValue("error");

   ConfigurationManager.updatePluginConfiguration(jboss.id, jbossConfig);

   var latestPluginConfigurations = ConfigurationManager.getLatestPluginConfigurationUpdate(jboss.id);
   println("latestPluginConfigurations: " + latestPluginConfigurations.toString());
}

