package org.rhq.plugins.seleniumclient

import groovy.util.GroovyTestCase
import java.util.regex.Pattern
import java.util.concurrent.TimeUnit

import com.gargoylesoftware.htmlunit.BrowserVersion;

import org.openqa.selenium.By
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.htmlunit.HtmlUnitDriver

class SeleniumGroovyTestCase extends GroovyTestCase {


    def Map<String, String> testLoginCSPRedHat() throws Exception {

        TreeMap results = new TreeMap<String, String>();
        
        def baseUrl = "https://www.redhat.com/wapps/sso/login.html"
        def driver = new HtmlUnitDriver(BrowserVersion.FIREFOX_3)
//        def driver = new FirefoxDriver(new FirefoxProfile())
//        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        
        try {
            driver.get("https://access.redhat.com/home")
            driver.findElement(By.id("accountLogin")).click();
            driver.findElement(By.id("username")).sendKeys("rafael.soares");
            driver.findElement(By.id("password")).sendKeys("Tuelho2918@RH");
            driver.findElement(By.id("_eventId_submit")).click();
            driver.findElement(By.linkText("Support Cases")).click();
            driver.findElement(By.id("allCasesGroupLink")).click();
            driver.findElement(By.linkText("Closed Cases")).click();
            driver.findElement(By.id("caseListForm:supportCasesList:0:viewCaseDetails")).click();
            driver.findElement(By.id("accountLogout")).click();
        }
        finally{
            results.put("lastURL", driver.getCurrentUrl())    
            results.put("lastURLTitle", driver.getTitle())
            results.put("lastPageStatusCode", driver.lastPage().getWebResponse().getStatusCode())    
            results.put("lastPageStatusMsg", driver.lastPage().getWebResponse().getStatusMessage())  
            results.put("lastPageLoadTime", driver.lastPage().getWebResponse().getLoadTime())
            results.put("lastHttpMethod", driver.lastPage().getWebResponse().getRequestSettings().getHttpMethod().toString())
            driver.quit()
        }
        
        return results
    }
}
