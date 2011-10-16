/**
 * This script wil get metrics for a resource by id.
 * 
 * Myee Riri <mriri@redhat.com>
 *
 */
function getResourcesById(resourceId) {

  var resourceCriteria = new ResourceCriteria();
  resourceCriteria.addFilterId(resourceId);
  resourceCriteria.fetchChildResources(true);
  
  var resources = ResourceManager.findResourcesByCriteria(resourceCriteria);
  var resourceArray = null;

  if (resources != null && !resources.isEmpty()) {

   resourceArray = resources.toArray();

  }

  return resourceArray;

}

function getResourceTypes(resource) {

  var resourceTypeName = resource.getResourceType().getName();
  var resourceTypeCriteria = new ResourceTypeCriteria();
  resourceTypeCriteria.addFilterName(resourceTypeName);

  var resourceTypes = ResourceTypeManager.findResourceTypesByCriteria(resourceTypeCriteria);
  var resourceTypeArray = null;

  if (resourceTypes != null && !resourceTypes.isEmpty()) {
 
    resourceTypeArray = resourceTypes.toArray();

  }

  return resourceTypeArray;

}

function getMeasurementDefinitions(resourceType) {

  var measurementDefinitionCriteria = new MeasurementDefinitionCriteria();
  measurementDefinitionCriteria.addFilterResourceTypeId(resourceType.getId());
  measurementDefinitionCriteria.addFilterResourceTypeName(resourceType.getName());
  //measurementDefinitionCriteria.addFilterCategory(MeasurementCategory.AVAILABILITY);
  //measurementDefinitionCriteria.addFilterDataType(DataType.MEASUREMENT);
    
  var measurementDefinitions = MeasurementDefinitionManager.findMeasurementDefinitionsByCriteria(measurementDefinitionCriteria);
  var measurementDefinitionArray = null;

  if (measurementDefinitions != null && !measurementDefinitions.isEmpty()) {

    measurementDefinitionArray = measurementDefinitions.toArray(); 

  }

  return measurementDefinitionArray;
  
}

if(args != null && args.length != 1) {

  println("Usage Error: getLiveMetricsForResource.js $resourceId");
  println("Aborting script.....");

} else {

  var resourceId = java.lang.Integer.parseInt(args[0]);

  var resources = getResourcesById(resourceId); 

  if (resources == null || resources.length == 0) {

    print("No resources for " + pluginName + " plugin found");

  }
  else {

    for (i in resources) {
    
      var resource = resources[i];

      var resourceTypes = getResourceTypes(resource);

      if (resourceTypes == null || resourceTypes.length == 0) {

        print("No resource types for " + resourceCategory.getName() + " found");

      }
      else {

        print("Resource Name, Resource Type Name, Measurement Definition, Value of Measurement \n");
        for (j in resourceTypes) {

          var resourceType = resourceTypes[j];

          var measurementDefinitions = getMeasurementDefinitions(resourceType);

          if (measurementDefinitions != null && measurementDefinitions.length > 0) {

            for (k in measurementDefinitions) {

              var measurementDefinition = measurementDefinitions[k];
              var definitionId = new java.lang.Integer(measurementDefinition.getId());

              var measurementData = MeasurementDataManager.findLiveData(resource.getId(), [definitionId]);

              if (measurementData != null) {

                var iter = measurementData.iterator();

                while (iter.hasNext()) {

                  var measurement = iter.next();
                  print(resource.getName() + "," + resourceType.getName() + "," + measurementDefinition.getName() + "," + measurement.getValue() + "\n");    

                }

              }

            }

          }

        }

      }

    }

  }

}
