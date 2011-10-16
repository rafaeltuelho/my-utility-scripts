/*
  * RHQ Management Platform
  * Copyright (C) 2005-2008 Red Hat, Inc.
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, version 2, as
  * published by the Free Software Foundation, and/or the GNU Lesser
  * General Public License, version 2.1, also as published by the Free
  * Software Foundation.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  * GNU General Public License and the GNU Lesser General Public License
  * for more details.
  *
  * You should have received a copy of the GNU General Public License
  * and the GNU Lesser General Public License along with this program;
  * if not, write to the Free Software Foundation, Inc.,
  * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
  */
package org.rhq.plugins.seleniumclient;

import groovy.lang.GroovyClassLoader;
import groovy.lang.GroovyObject;
import groovy.lang.Script;

import java.io.File;
import java.util.Date;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.rhq.core.domain.configuration.Configuration;
import org.rhq.core.domain.measurement.AvailabilityType;
import org.rhq.core.domain.measurement.MeasurementDataNumeric;
import org.rhq.core.domain.measurement.MeasurementReport;
import org.rhq.core.domain.measurement.MeasurementScheduleRequest;
import org.rhq.core.pluginapi.inventory.InvalidPluginConfigurationException;
import org.rhq.core.pluginapi.inventory.ResourceComponent;
import org.rhq.core.pluginapi.inventory.ResourceContext;
import org.rhq.core.pluginapi.measurement.MeasurementFacet;

/**
 * Resource Service Component
 * 
 * @author Rafael Soares - rsoares@redhat.com
 *
 */
public class TestCaseServiceComponent implements ResourceComponent, MeasurementFacet {

    private final Log log = LogFactory.getLog(this.getClass());
    private boolean isLastStausOk = true;
    private Script testCaseScript = null;
    private long lastExecutionTime = 0;
    private ResourceContext resourceContext = null;
    private String scriptFileName = null;

    public static final String NAME_PROP = "testCaseName";
    public static final String VERSION_PROP = "testCaseVersion";
    public static final String LANG_PROP = "scriptLang";
    public static final String DESCRIPTION_PROP = "testCaseDescription";
    public static final String SCRIPT_SRC_PROP = "testCaseScript";
    public static final String EXECUTION_TIME_METRIC = "executionTime";
    public static final String STATUS_METRIC = "status";
    public static final String SCRIPT_FILENAME_PROP = "scriptFileName";

    /**
     * Return availability of this resource
     *  @see org.rhq.core.pluginapi.inventory.ResourceComponent#getAvailability()
     */
    public AvailabilityType getAvailability() {

        if (isLastStausOk)
            return AvailabilityType.UP;
        else
            return AvailabilityType.DOWN;
    }

    /**
     * Start the resource connection
     * @see org.rhq.core.pluginapi.inventory.ResourceComponent#start(org.rhq.core.pluginapi.inventory.ResourceContext)
     */
    public void start(ResourceContext context) throws InvalidPluginConfigurationException, Exception {

        this.resourceContext = context;

        Configuration conf = context.getPluginConfiguration();
        log.info("Starting Selenium Test Case Plugin");

        if (!context.getDataDirectory().exists()) {
            log.info("Trying to create the Plugin data dir [" + context.getDataDirectory().getAbsolutePath() + "]...");

            if (context.getDataDirectory().mkdir())
                log.info("Plugin data dir [" + context.getDataDirectory().getAbsolutePath() + "] created.");
        } else
            log.info("Plugin data dir [" + context.getDataDirectory().getAbsolutePath() + "] already exists.");

        /*        if (scriptSrcCode != null && scriptSrcCode.length() > 0) {
                    GroovyShell shell = new GroovyShell(Thread.currentThread().getContextClassLoader());

                    try {
                        
                        this.testCaseScript = shell.parse(scriptSrcCode);
                        
                    } catch (CompilationFailedException cfe) {
                        isLastStausOk = false;

                        log.error("Error during the script compilation ", cfe);
                        throw new InvalidPluginConfigurationException("Error during the script compilation: "
                            + cfe.getMessage(), cfe);
                    }
                }
        */
        log.info("Selenium Test Case Plugin started!");
    }

    /**
     * Tear down the resource connection
     * @see org.rhq.core.pluginapi.inventory.ResourceComponent#stop()
     */
    public void stop() {
        log.info("Selenium Test Case Plugin stopped!");
    }

    /**
     * Gather measurement data
     *  @see org.rhq.core.pluginapi.measurement.MeasurementFacet#getValues(org.rhq.core.domain.measurement.MeasurementReport, java.util.Set)
     */
    public void getValues(MeasurementReport report, Set<MeasurementScheduleRequest> metrics) throws Exception {

        log.info("Collecting new metrics...");

        for (MeasurementScheduleRequest req : metrics) {
            if (req.getName().equals(EXECUTION_TIME_METRIC)) {

                this.executeScript();
                MeasurementDataNumeric res = new MeasurementDataNumeric(req, Double.valueOf(this.lastExecutionTime));
                report.addData(res);
            }
        }
    }

    /**
     * Execute Test Case Script
     */
    private void executeScript() {

        File scriptSrcCodeFile = new File(this.scriptFileName);
        GroovyClassLoader loader = new GroovyClassLoader(Thread.currentThread().getContextClassLoader());

        if (scriptSrcCodeFile.exists()) {
            try {
                Class groovyClass = loader.parseClass(scriptSrcCodeFile);

                // let's call some method on an instance
                GroovyObject groovyObject = (GroovyObject) groovyClass.newInstance();
                Object[] vars = {};

                long startTime = new Date().getTime();
                Object scriptResult = testCaseScript.run();

                this.lastExecutionTime = (new Date().getTime() - startTime);
                this.isLastStausOk = true;

                if (scriptResult != null)
                    log.info("Script result [" + scriptResult.toString() + "]");

                log.info("Teste Case executed in " + this.lastExecutionTime + " ms");
            } catch (Exception e) {

                this.isLastStausOk = false;
                log.error("Error executing Groovy script.", e);
            }
        } else {
            this.isLastStausOk = false;
            log.error("Script File doesn't exists in File System: " + scriptSrcCodeFile.getAbsolutePath());
        }

    }

    /**
     * Returns a list of installation steps that will take place when installing the specified package. When the request
     * to install the package is actually placed, the response from that call should contain a reference to the steps
     * specified here, along with the result (success/failure) of each step. If they cannot be determined, this method
     * will return <code>null</code>.
     *
     * @param  packageDetails describes the package to be installed
     *
     * @return steps that will be taken and reported on when deploying this package; <code>null</code> if they cannot be
     *         determined
    public List<DeployPackageStep> generateInstallationSteps(ResourcePackageDetails packageDetails){
        return null;
    }
     */

    /**
     * Requests that the content for the given packages be deployed to the resource. After the facet completes its work,
     * the facet should update each installed package object with the new status and any error message that is
     * appropriate (in the case where the installation failed). This method should not throw exceptions - any errors
     * that occur should be stored in the {@link ResourcePackageDetails} object.
     *
     * @param  packages        the packages to install
     * @param  contentServices a proxy object that allows the facet implementation to be able to request things from the
     *                         plugin container (such as being able to pull down a package's content from an external
     *                         source).
     *
     * @return Contains a reference to each package to be installed. Each reference should describe the results of
     *         attempting to install the package (success/failure).
    public DeployPackagesResponse deployPackages(Set<ResourcePackageDetails> packages, ContentServices contentServices){
        
        DeployPackagesResponse deployPackagesResponse = null;

        if (packages.size() != 1){
            deployPackagesResponse = new DeployPackagesResponse(ContentResponseResult.FAILURE);

            deployPackagesResponse.setOverallRequestErrorMessage("Just one file can be deployed per time.");
        }
        else{
            ResourcePackageDetails packageDetails = packages.iterator().next();
            try {
                
                File scriptFile = writeScriptBitsToFileSystem(contentServices, packageDetails);
                this.scriptFileName = scriptFile.getAbsolutePath();

                deployPackagesResponse = new DeployPackagesResponse(ContentResponseResult.SUCCESS);
                DeployIndividualPackageResponse packageResponse = new DeployIndividualPackageResponse(packageDetails.getKey(),
                    ContentResponseResult.SUCCESS);
                
                deployPackagesResponse.addPackageResponse(packageResponse);
            } catch (Exception e) {
                log.error("an error ocurred during deploy package process: " + e.getMessage());

                deployPackagesResponse = new DeployPackagesResponse(ContentResponseResult.FAILURE);
                deployPackagesResponse.setOverallRequestErrorMessage(e.getMessage());
            }
        }
        
        return deployPackagesResponse;
    }

    private File writeScriptBitsToFileSystem(ContentServices contentServices,
        ResourcePackageDetails packageDetails) throws Exception {
        
        String plugingDataDirPath = resourceContext.getDataDirectory().getAbsolutePath();
        File scriptFile = new File (plugingDataDirPath, packageDetails.getFileName());

        // The temp file shouldn't be there, but check and delete it if it is
        if (scriptFile.exists()) {
            log.warn("Existing script file found and will be deleted at: " + scriptFile);
            scriptFile.delete();
        }
        else
            scriptFile.createNewFile();
        
        OutputStream tempOutputStream = null;
        try {
            tempOutputStream = new BufferedOutputStream(new FileOutputStream(scriptFile));
            contentServices.downloadPackageBits(this.resourceContext.getContentContext(), packageDetails.getKey(),
                tempOutputStream, true);
        } finally {
            if (tempOutputStream != null) {
                try {
                    tempOutputStream.close();
                } catch (IOException e) {
                    log.error("Error closing temporary output stream", e);
                }
            }
        }
        
        if (!scriptFile.exists()) {
            log.error("Script file for test case update not written to: " + scriptFile);
            throw new Exception("Script file for test case update not written to: " + scriptFile);
        }
        
        return scriptFile;
    }    
     */

    /**
     * Requests that the given installed packages be deleted from the resource. After the facet completes its work, the
     * facet should update each installed package object with the new status and any error message that is appropriate
     * (in the case where the installation failed). This method should not throw exceptions - any errors that occur
     * should be stored in the {@link ResourcePackageDetails} object.
     *
     * @param  packages the packages to remove
     *
     * @return Contains a reference to each package that was requested to be removed. Each reference should describe the
     *         results of attempting to remove the package (success/failure).
    public RemovePackagesResponse removePackages(Set<ResourcePackageDetails> packages){
        throw new UnsupportedOperationException("Cannot remove the package backing a Selenium Test Case resource.");
    }
     */

    /**
     * Asks that the component run a discovery and return information on all currently installed packages of the
     * specified type.
     *
     * @param  type the type of packaged content that should be discovered
     *
     * @return information on all discovered content of the given package type
    public Set<ResourcePackageDetails> discoverDeployedPackages(PackageType type){
        Set<ResourcePackageDetails> packages = new HashSet<ResourcePackageDetails>();

        Configuration pluginConfiguration = this.resourceContext.getPluginConfiguration();
        String fullFileName = pluginConfiguration.getSimpleValue(SCRIPT_FILENAME_PROP, null);
        String version = pluginConfiguration.getSimpleValue(VERSION_PROP, null);

        if (fullFileName == null) {
            throw new IllegalStateException("Plugin configuration does not contain the full file name of the Test Case Script file.");
        }

        // If the parent WAR resource was found, this file should exist
        File file = new File(fullFileName);
        if (file.exists()) {
            // Package name and file name of the application are the same
            String fileName = new File(fullFileName).getName();
            String sha256 = getSHA256(file);

            PackageDetailsKey key = new PackageDetailsKey(fileName, version, "script", "noarch");
            ResourcePackageDetails details = new ResourcePackageDetails(key);
            details.setFileName(fileName);
            details.setLocation(file.getPath());
            if (!file.isDirectory())
                details.setFileSize(file.length());
            details.setFileCreatedDate(null); // TODO: get created date via SIGAR
            details.setInstallationTimestamp(System.currentTimeMillis()); 
            details.setSHA256(sha256);

            packages.add(details);
        }

        return packages;
    }
     */

    /** 
     * TODO: if needed we can speed this up by looking in the ResourceContainer's installedPackage
     * list for previously discovered packages. If there use the sha256 from that record. We'd have to
     * get access to that info by adding access in org.rhq.core.pluginapi.content.ContentServices
    private String getSHA256(File file) {

        String sha256 = null;

        try {
            File app = new File(file.getPath());
            sha256 = new MessageDigestGenerator(MessageDigestGenerator.SHA_256).calcDigestString(app);
        } catch (IOException iex) {
            //log exception but move on, discovery happens often. No reason to hold up anything.
            if (log.isDebugEnabled()) {
                log.debug("Problem calculating digest of package [" + file.getPath() + "]." + iex.getMessage());
            }
        }

        return sha256;
    }
     */

    /**
     * Asks that a stream of data containing the installed package contents be returned.
     *
     * @param  packageDetails the package whose contents should be streamed back to the caller
     *
     * @return stream containing the full content of the package
    public InputStream retrievePackageBits(ResourcePackageDetails packageDetails){
        Configuration pluginConfiguration = this.resourceContext.getPluginConfiguration();
        File packageFile = new File(pluginConfiguration.getSimpleValue(SCRIPT_FILENAME_PROP, null));

        try {
            return new BufferedInputStream(new FileInputStream(packageFile));
        } catch (IOException e) {
            throw new RuntimeException("Failed to retrieve package bits for " + packageDetails, e);
        }
    }
     */

}
