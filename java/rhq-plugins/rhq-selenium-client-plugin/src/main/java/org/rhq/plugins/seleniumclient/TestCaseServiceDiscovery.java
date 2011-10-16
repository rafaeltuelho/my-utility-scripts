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

import java.util.Collections;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.rhq.core.domain.configuration.Configuration;
import org.rhq.core.domain.resource.ResourceType;
import org.rhq.core.pluginapi.inventory.DiscoveredResourceDetails;
import org.rhq.core.pluginapi.inventory.InvalidPluginConfigurationException;
import org.rhq.core.pluginapi.inventory.ManualAddFacet;
import org.rhq.core.pluginapi.inventory.ResourceDiscoveryComponent;
import org.rhq.core.pluginapi.inventory.ResourceDiscoveryContext;

/**
 * Resource Discovery class
 * 
 * @author Rafael Soares - rsoares@redhat.com
 */
public class TestCaseServiceDiscovery implements ResourceDiscoveryComponent,
    ManualAddFacet {

    private final Log log = LogFactory.getLog(this.getClass());

    /**
     * This method is an empty dummy, as you have selected manual addition
     * in the plugin generator.
     * If you want to have auto discovery too, remove the "return emptySet"
     * and implement the auto discovery logic.
     */
    public Set<DiscoveredResourceDetails> discoverResources(
        ResourceDiscoveryContext discoveryContext) throws Exception {
        return Collections.emptySet();
    }

    /**
     * 
     */
    public DiscoveredResourceDetails discoverResource(Configuration resourceConfiguration,
        ResourceDiscoveryContext resDiscoveryContext) throws InvalidPluginConfigurationException {

        ResourceType resourceType = resDiscoveryContext.getResourceType();
        String fileName = resourceConfiguration.getSimpleValue(TestCaseServiceComponent.SCRIPT_FILENAME_PROP, "TestScript.script");
        String version = resourceConfiguration.getSimpleValue(TestCaseServiceComponent.VERSION_PROP, "1.0");
        String lang = resourceConfiguration.getSimpleValue(TestCaseServiceComponent.LANG_PROP, "UnknownLang");
        String description = resourceConfiguration.getSimpleValue(TestCaseServiceComponent.DESCRIPTION_PROP, null);

        String key = fileName + "::" + version + "::" + lang;

        DiscoveredResourceDetails detail = new DiscoveredResourceDetails(resourceType, key, fileName, version, description,
            resourceConfiguration, null);

        return detail;
    }

}