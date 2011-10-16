package org.rhq.plugins.seleniumclient;

import groovy.lang.GroovyClassLoader;
import groovy.lang.GroovyObject;
import groovy.lang.GroovyShell;
import groovy.lang.Script;

import java.io.File;
import java.util.Date;

import org.codehaus.groovy.control.CompilationFailedException;

public class MyPluginTest {

    /**
     * @param args
     */
    public static void main(String[] args) {
        try {
//            GroovyShell shell = new GroovyShell(Thread.currentThread().getContextClassLoader());

//            StringBuffer scriptSrc = new StringBuffer();
//
//            scriptSrc.append("package org.rhq.plugins.seleniumclient;\n");
//
//            scriptSrc.append("import groovy.util.GroovyTestCase;\n");
//            scriptSrc.append("import java.util.regex.Pattern;\n");
//            scriptSrc.append("import java.util.concurrent.TimeUnit;\n");
//
//            scriptSrc.append("import org.openqa.selenium.By;\n");
//            scriptSrc.append("import org.openqa.selenium.htmlunit.HtmlUnitDriver\n");
//
//            scriptSrc.append("class SeleniumGroovyTestCase extends GroovyTestCase {\n");
//
////            scriptSrc.append("def driver;\n");
//
////            scriptSrc.append("def testLoginCSPRedHat() throws Exception {\n");
//            scriptSrc.append("static main() throws Exception {\n");
//
//            scriptSrc.append("def baseUrl = \"https://access.redhat.com/\";\n");
//            scriptSrc.append("def driver = new HtmlUnitDriver(true);\n");
//            scriptSrc.append("driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);\n");
//            // open | /home | 
//            scriptSrc.append(" driver.get(By.id(\"/home\"));\n");
//            // click | id=accountLogin | 
//            scriptSrc.append("driver.findElement(By.id(\"accountLogin\")).click();\n");
//            // type | id=username | rafael.soares
//            scriptSrc.append("driver.findElement(By.id(\"username\")).clear();\n");
//            scriptSrc.append("driver.findElement(By.id(\"username\")).sendKeys(\"rafael.soares\");\n");
//            // type | id=password | senha
//            scriptSrc.append("driver.findElement(By.id(\"password\")).clear();\n");
//            scriptSrc.append(" driver.findElement(By.id(\"password\")).sendKeys(\"Tuelho2918@RH\");\n");
//            // click | id=_eventId_submit | 
//            scriptSrc.append("  driver.findElement(By.id(\"_eventId_submit\")).click();\n");
//            // click | link=View Support Cases | 
//            scriptSrc.append("  driver.findElement(By.linkText(\"View Support Cases\")).click();\n");
//            // click | id=accountLogout | 
//            scriptSrc.append("   driver.findElement(By.id(\"accountLogout\")).click();\n");
//            scriptSrc.append("  }\n");
//            scriptSrc.append("}\n");

//            Script testCaseScript = shell.parse(scriptSrc.toString());

            
            
            String scriptPath = "/home/rsoares/projects/github/tuelhosrepo/java/rhq-plugins/user-experience/SeleniumClient/src/main/java/org/rhq/plugins/seleniumclient/SeleniumGroovyTestCase.groovy";

//            ClassLoader parent = getClass().getClassLoader();
            GroovyClassLoader loader = new GroovyClassLoader(Thread.currentThread().getContextClassLoader());
            Class groovyClass = loader.parseClass(new File(scriptPath));

            // let's call some method on an instance
            GroovyObject groovyObject = (GroovyObject) groovyClass.newInstance();
            Object[] vars = {};

            
            long startTime = new Date().getTime();
//            Object scriptResult = testCaseScript.run();
            
            Object scriptResult = groovyObject.invokeMethod("testLoginCSPRedHat", args);
            
            long lastExecutionTime = (new Date().getTime() - startTime);

            if (scriptResult != null)
                System.out.println("Script result [" + scriptResult.toString() + "]");

            System.out.println("Teste Case executed in " + lastExecutionTime + " ms");
        } catch (CompilationFailedException cfe) {
            System.out.println("Error during the script compilation ");
            cfe.printStackTrace();
        } catch (Exception e) {

            e.printStackTrace();
        }
    }

}
