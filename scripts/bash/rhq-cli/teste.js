println("Oi Mundo!");
/*
 var criteria = new ResourceCriteria()
 criteria.addFilterResourceTypeName('JBossAS Server')
 criteria.fetchChildResources(true)
 var resources = ResourceManager.findResourcesByCriteria(criteria)
 resource = resources.get(0)
 if (resource.childResources == null) print('no child resources'); else pretty.print(resource.childResources)
*/

/*
var console = new java.util.Scanner(java.lang.System["in"]);

// Prints name and age to the console
println("Name :" + console.nextLine());
println("Age :" + console.nextInt());
console.close(); 
*/

/*
var br = new java.io.BufferedReader(new java.io.InputStreamReader(java.lang.System["in"]));

while( (strLine = br.readLine()) != null){
   if(strLine.equals("exit"))
      break;
   
   println("Line entered : "  + strLine);
}

br.close();
*/

var file = scriptUtil.getFileBytes("/home/rsoares/tmp/store.war");
var newFile = new java.io.FileOutputStream("/tmp/teste.war");

for (var i=0; i<file.length; i++){
   newFile.write(file[i]);
}

newFile.close();
