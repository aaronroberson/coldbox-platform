<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a WireBox configuration object.  You can use it to configure
	a WireBox injector instance.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a WireBox configuration object.  You can use it to configur a WireBox injector instance">

	<cfscript>
		// Utility class
		utility  = createObject("component","coldbox.system.core.util.Util");
		
		// Instance private scope
		instance = structnew();
		
		// WireBox Defaults
		DEFAULTS = {
			//LogBox Defaults
			logBoxConfig = "coldbox.system.ioc.config.LogBox",
			// Scope Defaults
			scopeRegistration = {
				enabled = false,
				scope = "application",
				key = "wireBox"
			},
			// CacheBox Integration Defaults
			cacheBox = {
				enabled = false,
				configFile = "",
				cacheFactory = "",
				classNamespace = "coldbox.system.cache"
			}
		};
		
		// Startup the configuration
		reset();
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="WireBoxConfig" hint="Constructor">
		<cfargument name="CFCConfig" 		type="any" 		required="false" hint="The cacheBox Data Configuration CFC"/>
		<cfargument name="CFCConfigPath" 	type="string" 	required="false" hint="The cacheBox Data Configuration CFC path to use"/>
		<cfscript>
			var wireBoxDSL = "";
			
			// Test and load via Data CFC Path
			if( structKeyExists(arguments, "CFCConfigPath") ){
				arguments.CFCConfig = createObject("component",arguments.CFCConfigPath);
			}
			
			// Test and load via Data CFC
			if( structKeyExists(arguments,"CFCConfig") and isObject(arguments.CFCConfig) ){
				// Decorate our data CFC
				arguments.CFCConfig.getPropertyMixin = utility.getPropertyMixin;
				// Execute the configuration
				arguments.CFCConfig.configure();
				// Get Data
				wireBoxDSL = arguments.CFCConfig.getPropertyMixin("wireBox","variables",structnew());
				// Load the DSL
				loadDataDSL( wireBoxDSL );
			}
			
			// Just return, most likely programmatic config
			return this;
		</cfscript>
	</cffunction>

	<!--- reset --->
	<cffunction name="reset" output="false" access="public" returntype="void" hint="Reset the configuration back to the defaults">
		<cfscript>
			// logBox File
			instance.logBoxConfig = DEFAULTS.logBoxConfig;
			// CacheBox integration
			instance.cacheBox = DEFAULTS.cacheBox;
			// Listeners
			instance.listeners = [];
			// Scope Registration
			instance.scopeRegistration = DEFAULTS.scopeRegistration;
			// Custom DSL namespaces
			instance.customDSL = {};
			// Custom Storage Scopes
			instance.customScopes = {};
			// Package Scan Locations
			instance.scanLocations = createObject("java","java.util.LinkedHashMap").init(5);
			// Object Mappings
			instance.mappings = {};
			// Parent Injector Mapping
			instance.parentInjector = "";
		</cfscript>
	</cffunction>
	
	<!--- getParentInjector --->
    <cffunction name="getParentInjector" output="false" access="public" returntype="any" hint="Get a parent injector if linked">
    	<cfreturn instance.parentInjector>
    </cffunction>
	
	<!--- parentInjector --->
    <cffunction name="parentInjector" output="false" access="public" returntype="any" hint="Link a parent injector to the configuration">
    	<cfargument name="injector" type="any" required="true" hint="A parent injector to configure link"/>
		<cfset instance.parentInjector = arguments.injector>
		<cfreturn this>
    </cffunction>
	
	<!--- getMappings --->
    <cffunction name="getMappings" output="false" access="public" returntype="struct" hint="Get all the registered object mappings">
    	<cfreturn instance.mappings>
    </cffunction>
	
	<!--- getMapping --->
    <cffunction name="getMapping" output="false" access="public" returntype="any" hint="Get a specific object mapping">
    	<cfargument name="name" type="string" required="true" hint="The name of the mapping to retrieve"/>
    	<cfreturn instance.mappings[arguments.name]>
    </cffunction>

	<!--- mappingExists --->
    <cffunction name="mappingExists" output="false" access="public" returntype="boolean" hint="Check if an object mapping exists">
    	<cfargument name="name" type="string" required="true" hint="The name of the mapping to retrieve"/>
    	<cfreturn structKeyExists(instance.mappings, arguments.name)>
    </cffunction>
	
	<!--- getScanLocations --->
    <cffunction name="getScanLocations" output="false" access="public" returntype="any" hint="Get the linked map of package scan locations for CFCs" colddoc:generic="java.util.LinkedHashMap">
    	<cfreturn instance.scanLocations>
    </cffunction>
	
	<!--- scanLocations --->
    <cffunction name="scanLocations" output="false" access="public" returntype="any" hint="Register one or more package scan locations for CFC lookups">
    	<cfargument name="locations" type="any" required="true" hint="A list or array of locations to add to package scanning.e.g.: ['coldbox','com.myapp','transfer']"/>
   		<cfscript>
   			var x = 1;
			
   			// inflate incoming locations
   			if( isSimpleValue(arguments.locations) ){ arguments.locations = listToArray(arguments.locations); }
			
			// Prepare Locations
			for(x=1; x lte arrayLen(arguments.locations); x++){
				// Validate it is not registered already
				if ( NOT structKeyExists(instance.scanLocations, arguments.locations[x]) ){
					// Process creation path & Absolute Path
					instance.scanLocations[ arguments.locations[x] ] = expandPath( "/" & replace(arguments.locations[x],".","/","all") & "/" );
				}
			}
			
			return this;
		</cfscript>
    </cffunction>
	
	<!--- removeScanLocations --->
	<cffunction name="removeScanLocations" output="false" access="public" returntype="void" hint="Try to remove all the scan locations passed in">
		<cfargument name="locations" type="any" required="true" hint="Locations to remove from the lookup. A list or array of locations"/>
		<cfscript>
			var x = 1;
			
			// inflate incoming locations
   			if( isSimpleValue(arguments.locations) ){ arguments.locations = listToArray(arguments.locations); }
			
			// Loop and remove
			for(x=1;x lte arraylen(arguments.locations); x++ ){
				structDelete(instance.scanLocations, arguments.locations[x]);
			}
		</cfscript>
	</cffunction>
		
	<!--- cacheBox --->
    <cffunction name="cacheBox" output="false" access="public" returntype="any" hint="Integrate with CacheBox">
    	<cfargument name="configFile" 		type="string" 	required="false" default="" hint="The configuration file to use for loading CacheBox if creating it."/>
		<cfargument name="cacheFactory" 	type="any" 		required="false" default="" hint="The CacheBox cache factory instance to link WireBox to"/>
		<cfargument name="enabled" 			type="boolean" 	required="false" default="true" hint="Enable or Disable CacheBox Integration, if you call this method then enabled is set to true as most likely you are trying to enable it"/>
    	<cfargument name="classNamespace" 	type="string" 	required="false" default="#DEFAULTS.cachebox.classNamespace#" hint="The package namespace to use for creating or connecting to CacheBox. Defaults to: coldbox.system.cache"/>
		<cfset structAppend(instance.cacheBox, arguments, true)>
		<cfreturn this>
	</cffunction>
	
	<!--- getCacheBoxConfig --->
    <cffunction name="getCacheBoxConfig" output="false" access="public" returntype="struct" hint="Get the CacheBox Configuration Integration structure">
    	<cfreturn instance.cacheBox>
    </cffunction>
	
	<!--- dsl --->
    <cffunction name="registerDSL" output="false" access="public" returntype="any" hint="Register a new custom dsl namespace">
    	<cfargument name="namespace" 	type="string" required="true" hint="The namespace you would like to register"/>
		<cfargument name="mapping" 		type="string" required="true" hint="The name of the mapping or CFC that implements this custom DSL."/>
		<cfset instance.customDSL[arguments.namespace] = arguments.mapping>
		<cfreturn this>
    </cffunction>
	
	<!--- getCustomDSL --->
    <cffunction name="getCustomDSL" output="false" access="public" returntype="struct" hint="Get the custom dsl namespace registration">
    	<cfreturn instance.customDSL>
    </cffunction>

	<!--- registerScope --->
    <cffunction name="registerScope" output="false" access="public" returntype="any" hint="Register a new WireBox custom scope">
    	<cfargument name="scope" 		type="string" required="true" hint="The unique scope name to register. This translates to an annotation value on CFCs"/>
    	<cfargument name="mapping" 		type="string" required="true" hint="The name of the mapping or CFC that implements this custom scope."/>
	</cffunction>

	<!--- getCustomScopes --->
    <cffunction name="getCustomScopes" output="false" access="public" returntype="struct" hint="Get the registered custom scopes">
    	<cfreturn instance.customScopes>
    </cffunction>	

	<!--- getDefaults --->
    <cffunction name="getDefaults" output="false" access="public" returntype="struct" hint="Get the default WireBox settings">
    	<cfreturn variables.DEFAULTS>
    </cffunction>
	
	<!--- logBoxConfig --->
    <cffunction name="logBoxConfig" output="false" access="public" returntype="any" hint="Set the logBox Configuration to use">
    	<cfargument name="config" type="string" required="true" hint="The configuration file to use"/>
		<cfset instance.logBoxConfig = arguments.config>
		<cfreturn this>
    </cffunction>
	
	<!--- getLogBoxConfig --->
    <cffunction name="getLogBoxConfig" output="false" access="public" returntype="string" hint="Get the logBox Configuration file to use">
    	<cfreturn instance.logBoxConfig>
    </cffunction>
	
	<!--- loadDataCFC --->
    <cffunction name="loadDataDSL" output="false" access="public" returntype="void" hint="Load a data configuration CFC data DSL">
    	<cfargument name="rawDSL" type="struct" required="true" hint="The data configuration DSL structure"/>
    	<cfscript>
			var wireBoxDSL  = arguments.rawDSL;
			var key 		= "";
			
			// Register LogBox Configuration
			if( structKeyExists( wireBoxDSL, "logBoxConfig") ){
				logBoxConfig(wireBoxDSL.logBoxConfig);
			}
			
			// Register Server Scope Registration
			if( structKeyExists( wireBoxDSL, "scopeRegistration") ){
				scopeRegistration(argumentCollection=wireBoxDSL.scopeRegistration);
			}
			
			// Register CacheBox
			if( structKeyExists( wireBoxDSL, "cacheBox") ){
				cacheBox(argumentCollection=wireBoxDSL.cacheBox);
			}
			
			// Register Custom DSL
			if( structKeyExists( wireBoxDSL, "customDSL") ){
				instance.customDSL = wireBoxDSL.customDSL;
			}
			
			// Register Custom Scopes
			if( structKeyExists( wireBoxDSL, "customScopes") ){
				instance.customScopes = wireBoxDSL.customScopes;
			}
			
			// Register Scan Locations
			if( structKeyExists( wireBoxDSL, "scanLocations") ){
				scanLocations( wireBoxDSL.scanLocations );
			}

			// Register listeners
			if( structKeyExists( wireBoxDSL, "listeners") ){
				for(key=1; key lte arrayLen(wireBoxDSL.listeners); key++ ){
					listener(argumentCollection=wireBoxDSL.listeners[key]);
				}
			}	
			
			// Register Mappings	
		</cfscript>
    </cffunction>
		
	<!--- Get Memento --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false" hint="Get the instance data">
		<cfreturn instance>
	</cffunction>
	
	<!--- validate --->
	<cffunction name="validate" output="false" access="public" returntype="void" hint="Validates the configuration. If not valid, it will throw an appropriate exception.">
		<cfscript>
					
		</cfscript>
	</cffunction>
	
	<!--- scopeRegistration --->
    <cffunction name="scopeRegistration" output="false" access="public" returntype="any" hint="Use to define injector scope registration">
    	<cfargument name="enabled" 	type="boolean" 	required="false" default="#DEFAULTS.scopeRegistration.enabled#" hint="Enable registration or not (defaults=false)"/>
		<cfargument name="scope" 	type="string" 	required="false" default="#DEFAULTS.scopeRegistration.scope#" hint="The scope to register on, defaults to application scope"/>
		<cfargument name="key" 		type="string" 	required="false" default="#DEFAULTS.scopeRegistration.key#" hint="The key to use in the scope, defaults to wireBox"/>
		<cfset structApend( instance.scopeRegistration, arguments, true)>
		<cfreturn this>
    </cffunction>

	<!--- getScopeRegistration --->
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="struct" hint="Get the scope registration details">
    	<cfreturn instance.scopeRegistration>
    </cffunction>
				
	<!--- listener --->
	<cffunction name="listener" output="false" access="public" returntype="any" hint="Add a new listener configuration.">
		<cfargument name="class" 		type="string" required="true"  hint="The class of the listener"/>
		<cfargument name="properties" 	type="struct" required="false" default="#structNew()#" hint="The structure of properties for the listner"/>
		<cfargument name="name" 		type="string" required="false" default=""  hint="The name of the listener"/>
		<cfscript>
			// Name check?
			if( NOT len(arguments.name) ){
				arguments.name = listLast(arguments.class,".");
			}
			// add listener
			arrayAppend(instance.listeners, arguments);
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getListener --->
	<cffunction name="getListener" output="false" access="public" returntype="struct" hint="Get a specifed listener definition">
		<cfargument name="name" type="string" required="true" hint="The listener configuration to retrieve"/>
		<cfreturn instance.listeners[arguments.name]>
	</cffunction>
	
	<!--- listenerExists --->
	<cffunction name="listenerExists" output="false" access="public" returntype="boolean" hint="Check if a listener definition exists">
		<cfargument name="name" type="string" required="true" hint="The listener to check"/>
		<cfreturn structKeyExists(instance.listeners, arguments.name)>
	</cffunction>
	
	<!--- getListeners --->
	<cffunction name="getListeners" output="false" access="public" returntype="array" hint="Get the configured listeners">
		<cfreturn instance.listeners>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
</cfcomponent>