<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a WireBox configuration binder object.  You can use it to configure
	a WireBox injector instance using our WireBox Mapping DSL.
	This binder will hold all your object mappings, injector settings and more.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a WireBox configuration binder object.  You can use it to configure a WireBox injector instance using our WireBox Mapping DSL">

	<cfscript>
		// Available WireBox public scopes
		this.SCOPES = createObject("component","coldbox.system.ioc.Scopes");
		// Available WireBox public types
		this.TYPES = createObject("component","coldbox.system.ioc.Types");
		// Internal Utility class
		utility  	= createObject("component","coldbox.system.core.util.Util");
		// Temp Mapping positional mover
		currentMapping = "";
		// Instance private scope
		instance = {};
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
	<cffunction name="init" output="false" access="public" returntype="Binder" hint="Constructor: You can pass a data CFC instance, data CFC path or nothing at all for purely programmatic configuration">
		<cfargument name="config" type="any" required="false" hint="The WireBox Injector Data Configuration CFC instance or instantiation path to it. Leave blank if using this configuration object programatically"/>
		<cfscript>
			// If sent and a path, then create the data CFC
			if( structKeyExists(arguments, "config") and isSimpleValue(arguments.config) ){
				arguments.config = createObject("component",arguments.config);
			}
			
			// If sent and a data CFC instance
			if( structKeyExists(arguments,"config") and isObject(arguments.config) ){
				// Decorate our data CFC
				arguments.config.getPropertyMixin = utility.getPropertyMixin;
				// Execute the configuration
				arguments.config.configure(this);
				// Load the DSL
				loadDataDSL( arguments.config.getPropertyMixin("wireBox","variables",structnew()) );
			}
			
			return this;
		</cfscript>
	</cffunction>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="any" hint="The main configuration method that must be overriden by a specific WireBox Binder configuration object">
    	<!--- Usually implemented by concrete classes of this Binder --->
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
			// Binding Properties
			instance.properties = {};
			// Stop Recursion classes
			instance.stopRecursion = [];
		</cfscript>
	</cffunction>

<!------------------------------------------- BINDING PROPERTIES ------------------------------------------>

	<!--- getProperties --->
    <cffunction name="getProperties" output="false" access="public" returntype="struct" hint="Get the binded properties structure">
    	<cfreturn instance.properties>
    </cffunction>
	
	<!--- getProperty --->
    <cffunction name="getProperty" output="false" access="public" returntype="any" hint="Get a binded property. If not found it will try to return the default value passed, else it returns a java null">
    	<cfargument name="name" 	type="string" 	required="true" hint="The name of the property"/>
		<cfargument name="default"	type="any" 		required="false" hint="A default value if property does not exist"/>
		<cfscript>
			if( propertyExists(arguments.name) ){
				return instance.properties[arguments.name];
			}
			if( structKeyExists(arguments,"default") ){
				return arguments.default;
			}
		</cfscript>
    </cffunction>
	
	<!--- setProperty --->
    <cffunction name="setProperty" output="false" access="public" returntype="void" hint="Create a new binding property">
    	<cfargument name="name" 	type="string" 	required="true" hint="The name of the property"/>
		<cfargument name="value" 	type="any" 			required="true" hint="The value of the property"/>
		<cfset instance.properties[arguments.name] = arguments.value>
    </cffunction>

	<!--- propertyExists --->
    <cffunction name="propertyExists" output="false" access="public" returntype="boolean" hint="Checks if a property exists">
    	<cfargument name="name" 	type="string" 	required="true" hint="The name of the property"/>
		<cfreturn structKeyExists(instance.properties, arguments.name)>
    </cffunction>

<!------------------------------------------- PARENT INJECTOR ------------------------------------------>
	
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

<!------------------------------------------- MAPPING METHODS ------------------------------------------>
	
	<!--- getMappings --->
    <cffunction name="getMappings" output="false" access="public" returntype="struct" hint="Get all the registered object mappings">
    	<cfreturn instance.mappings>
    </cffunction>
	
	<!--- getMapping --->
    <cffunction name="getMapping" output="false" access="public" returntype="any" hint="Get a specific object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfargument name="name" type="string" required="true" hint="The name of the mapping to retrieve"/>
    	
		<cfif NOT structKeyExists(instance.mappings, arguments.name)>
    		<cfthrow message="Mapping #arguments.name# has not been registered"
					 detail="Registered mappings are: #structKeyList(instance.mappings)#"
					 type="Binder.MappingNotFoundException" >
    	</cfif>
		
		<cfreturn instance.mappings[arguments.name]>
    </cffunction>

	<!--- mappingExists --->
    <cffunction name="mappingExists" output="false" access="public" returntype="boolean" hint="Check if an object mapping exists">
    	<cfargument name="name" type="string" required="true" hint="The name of the mapping to verify"/>
    	<cfreturn structKeyExists(instance.mappings, arguments.name)>
    </cffunction>

<!------------------------------------------- MAPPING DSL ------------------------------------------>

	<!--- mapPath --->
    <cffunction name="mapPath" output="false" access="public" returntype="any" hint="Directly map to a path by using the last part of the path as the alias. This is equivalent to map('MyService').to('model.MyService'). Only use if the name of the alias is the same as the last part of the path.">
    	<cfargument name="path" type="string" required="true" hint="The class path to the object to map"/>
		<cfscript>
			// directly map to a path
			return map( listlast(arguments.path,".") ).to(arguments.path);
		</cfscript>
    </cffunction>
	
	<!--- mapDirectory --->
    <cffunction name="mapDirectory" output="false" access="public" returntype="any" hint="Map an entire instantiation path directory, please note that the unique name of each file will be used.">
    	<cfargument name="packagePath" type="string" required="true" hint="The instantiation packagePath to map"/>
    </cffunction>
	
	<!--- map --->
    <cffunction name="map" output="false" access="public" returntype="any" hint="Create a mapping to an object">
    	<cfargument name="alias" type="any" required="true" hint="A single alias or a list or an array of aliases for this mapping. Remember an object can be refered by many names"/>
		<cfscript>
			// generate mapping entry for this dude.
			var name 	= "";
			var x		= 1;
			var cAlias	= "";
			
			// unflatten list
			if( isSimpleValue( arguments.alias ) ){ arguments.alias = listToArray(arguments.alias); }
			
			// first entry
			name = arguments.alias[1];
			
			// generate the mapping for the first name passed
			instance.mappings[ name ] = createObject("component","coldbox.system.ioc.config.Mapping").init( name );
			
			// set the current mapping
			currentMapping = instance.mappings[ name ];
			
			// Set aliases
			instance.mappings[ name ].setAlias( arguments.alias );
			
			// Loop and create alias references
			for(x=2;x lte arrayLen(arguments.alias); x++){
				instance.mappings[ arguments.alias[x] ] = instance.mappings[ name ];
			}
			
			return this;
		</cfscript>    	
    </cffunction>
	
	<!--- to --->
    <cffunction name="to" output="false" access="public" returntype="any" hint="Map to a destination CFC class path.">
    	<cfargument name="path" type="string" required="true" hint="The class path to the object to map"/>
		<cfscript>
			currentMapping.setPath( arguments.path ).setType( this.TYPES.CFC );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toJava --->
    <cffunction name="toJava" output="false" access="public" returntype="any" hint="Map to a java destination class path.">
    	<cfargument name="path" type="string" required="true" hint="The class path to the object to map"/>
		<cfscript>
			currentMapping.setPath( arguments.path ).setType( this.TYPES.JAVA );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toWebservice --->
    <cffunction name="toWebservice" output="false" access="public" returntype="any" hint="Map to a webservice destination class path.">
    	<cfargument name="path" type="string" required="true" hint="The class path to the object to map"/>
		<cfscript>
    		currentMapping.setPath( arguments.path ).setType( this.TYPES.WEBSERVICE );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toRSS --->
    <cffunction name="toRSS" output="false" access="public" returntype="any" hint="Map to a rss destination class path.">
    	<cfargument name="path" type="string" required="true" hint="The class path to the object to map"/>
		<cfscript>
    		currentMapping.setPath( arguments.path ).setType( this.TYPES.RSS );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- toDSL --->
    <cffunction name="toDSL" output="false" access="public" returntype="any" hint="Map to a dsl that will be used to create the mapped object">
    	<cfargument name="dsl" type="string" required="true" hint="The DSL string to use"/>
		<cfscript>
			currentMapping.setDSL( arguments.dsl ).setType( this.TYPES.DSL );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- constructor --->
    <cffunction name="constructor" output="false" access="public" returntype="any" hint="You can choose what method will be treated as the constructor. By default the value is 'init', so don't call this method if that is the case.">
    	<cfargument name="constructor" type="string" required="true" hint="The constructor method to use for the mapped object"/>
   		<cfscript>
    		currentMapping.setConstructor( arguments.constructor );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- initWith --->
    <cffunction name="initWith" output="false" access="public" returntype="any" hint="Positional or named value arguments to use when initializing the mapping. (CFC-only)">
    	<cfscript>
    		var key = "";
    		for(key in arguments){
				currentMapping.addDIConstructorArgument(name=key,value=arguments[key]);
			}
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- noInit --->
    <cffunction name="noInit" output="false" access="public" returntype="any" hint="If you call this method on an object mapping, the object's constructor will not be called. By default all constructors are called.">
    	<cfscript>
    		instance.mappings[ currentMapping ].noInit = true;
			return this;
    	</cfscript>
    </cffunction>

	<!--- asEagerInit --->
    <cffunction name="asEagerInit" output="false" access="public" returntype="any" hint="If this method is called, the mapped object will be created once the injector starts up. Basically, not lazy loaded">
    	<cfscript>
    		instance.mappings[ currentMapping ].asEagerInit = true;
			return this;
    	</cfscript>
    </cffunction>

	<!--- noAutowire --->
    <cffunction name="noAutowire" output="false" access="public" returntype="any" hint="If you call this method on an object mapping, the object will NOT be inspected for injection/wiring metadata, it will use ONLY whatever you define in the mapping.">
    	<cfscript>
    		instance.mappings[ currentMapping ].autowire = false;
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- with --->
    <cffunction name="with" output="false" access="public" returntype="any" hint="Used to set the current working mapping name in place for the maping DSL. An exception is thrown if the mapping does not exist yet.">
    	<cfargument name="alias" type="string" required="true" hint="The name of the maping to set as current for working with it via the mapping DSL"/>
		<cfscript>
			if( mappingExists(arguments.alias) ){
				currentMapping = arguments.alias;
				return this;
			}
			utility.throwit(message="The mapping '#arguments.alias# has not been initialized yet.'",
							detail="Please use the map('#arguments.alias#') first to start working with a mapping",
							type="Binder.InvalidMappingStateException");
		</cfscript>
    </cffunction>
	
	<!--- initArg --->
    <cffunction name="initArg" output="false" access="public" returntype="any" hint="Map a constructor argument to a mapping">
    	<cfargument name="name" 	type="string" 	required="false" hint="The name of the constructor argument. NA: JAVA-WEBSERVICE"/>
		<cfargument name="ref" 		type="string" 	required="false" hint="The reference mapping id this constructor argument maps to"/>
		<cfargument name="dsl" 		type="string" 	required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	type="any" 		required="false" hint="The value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" type="string" 	required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		var cArgs = getMapping(currentMapping).DIConstructorArgs;
    		cArgs[ arguments.name ] = {};
    		processDIArgs(cArgs[ arguments.name ], arguments);
    	</cfscript>
    </cffunction>
	
	<!--- setter --->
    <cffunction name="setter" output="false" access="public" returntype="any" hint="Map a setter function to a mapping">
    	<cfargument name="name" 	type="string" 	required="true"  hint="The name of the constructor argument."/>
		<cfargument name="ref" 		type="string" 	required="false" hint="The reference mapping id this constructor argument maps to"/>
		<cfargument name="dsl" 		type="string" 	required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	type="any" 		required="false" hint="The value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" type="string" 	required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		var cArgs = getMapping(currentMapping).DISetters;
    		cArgs[ arguments.name ] = {};
    		processDIArgs(cArgs[ arguments.name ], arguments);
    	</cfscript>
    </cffunction>
		
	<!--- property --->
    <cffunction name="property" output="false" access="public" returntype="any" hint="Map a cfproperty to a mapping">
    	<cfargument name="name" 	type="string" 	required="true"  hint="The name of the constructor argument."/>
		<cfargument name="ref" 		type="string" 	required="false" hint="The reference mapping id this constructor argument maps to"/>
		<cfargument name="dsl" 		type="string" 	required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	type="any" 		required="false" hint="The value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" type="string" 	required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfargument name="scope" 	type="string" 	required="false" default="variables" hint="The scope in the CFC to inject the property to. By default it will inject it to the variables scope"/>
    	<cfscript>
    		var cArgs = getMapping(currentMapping).DIProperties;
    		cArgs[ arguments.name ] = {};
    		processDIArgs(cArgs[ arguments.name ], arguments);
    	</cfscript>
    </cffunction>

	<!--- processDIArgs --->
    <cffunction name="processDIArgs" output="false" access="private" returntype="void" hint="Process incoming DI arguments">
    	<cfargument name="target" 	type="struct" 	required="true" hint="The target structure to place the arguments in"/>
		<cfargument name="args" 	type="any" 		required="true" hint="The arguments to process"/>
    	<cfscript>
    		var key = "";
			// loop over arguments and only set the ones that are sent that are not name;
			for(key in arguments.args){
				if( structKeyExists(arguments.args,key) AND key neq "name"){
					arguments.target[ key ] = arguments.args[key]; 
				}
			}
    	</cfscript>
    </cffunction>
	
	<!--- onDIComplete --->
    <cffunction name="onDIComplete" output="false" access="public" returntype="any" hint="Tell us what methods to execute once DI completes on the mapping">
    	<cfargument name="methods" type="any" required="true" hint="A list or an array of methods to execute once the mapping is created, inited and DI has happened."/>
    	<cfscript>
    		//inflate list
			if( isSimpleValue(arguments.methods) ){ arguments.methods = listToArray(arguments.methods); }
			// store list
			instance.mappings[ currentMapping ].onDIComplete = arguments.methods;
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- STOP RECURSIONS ------------------------------------------>

	<!--- getStopRecursions --->
    <cffunction name="getStopRecursions" output="false" access="public" returntype="array" hint="Get all the stop recursion classes">
    	<cfreturn instance.stopRecursions>
    </cffunction>
	
	<!--- stopRecursions --->
    <cffunction name="stopRecursions" output="false" access="public" returntype="any" hint="Configure the stop recursion classes">
    	<cfargument name="classes" type="any" required="true" hint="A list or array of classes to use so the injector can stop when looking for dependencies in inheritance chains"/>
   		<cfscript>
    		// inflate incoming locations
   			if( isSimpleValue(arguments.classes) ){ arguments.classes = listToArray(arguments.classes); }
			// Save them
			instance.stopRecursions = arguments.classes;
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- SCOPE REGISTRATION ------------------------------------------>
	
	<!--- scopeRegistration --->
    <cffunction name="scopeRegistration" output="false" access="public" returntype="any" hint="Use to define injector scope registration">
    	<cfargument name="enabled" 	type="boolean" 	required="false" default="#DEFAULTS.scopeRegistration.enabled#" hint="Enable registration or not (defaults=false)"/>
		<cfargument name="scope" 	type="string" 	required="false" default="#DEFAULTS.scopeRegistration.scope#" hint="The scope to register on, defaults to application scope"/>
		<cfargument name="key" 		type="string" 	required="false" default="#DEFAULTS.scopeRegistration.key#" hint="The key to use in the scope, defaults to wireBox"/>
		<cfset structAppend( instance.scopeRegistration, arguments, true)>
		<cfreturn this>
    </cffunction>

	<!--- getScopeRegistration --->
    <cffunction name="getScopeRegistration" output="false" access="public" returntype="struct" hint="Get the scope registration details">
    	<cfreturn instance.scopeRegistration>
    </cffunction>
				
<!------------------------------------------- SCAN LOCATIONS ------------------------------------------>
		
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

<!------------------------------------------- CACHEBOX INTEGRATION ------------------------------------------>
		
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
	
	<!--- inCacheBox --->
    <cffunction name="inCacheBox" output="false" access="public" returntype="any" hint="Map an object into CacheBox">
    	<cfargument name="key" 					type="string" 	required="false" default="" hint="You can override the key it will use for storing in cache. By default it uses the name of the mapping."/>
    	<cfargument name="timeout" 				type="any" 		required="false" default="" hint="Object Timeout, else defaults to whatever the default is in the choosen cache"/>
		<cfargument name="lastAccessTimeout" 	type="any" 		required="false" default="" hint="Object Timeout, else defaults to whatever the default is in the choosen cache"/>
		<cfargument name="provider" 			type="string" 	required="false" default="default" hint="Uses the 'default' cache provider by default"/>
		<cfscript>
			// if key not passed, use the same mapping name
			if( NOT len(arguments.key) ){ arguments.key = currentMapping; }
			// store the mappings scope as cacheBox
			instance.mappings[ currentMapping ].scope = this.SCOPES.CACHEBOX;
			// Store the cache information on the mapping
    		instance.mappings[ currentMapping ].cache = {
				provider = arguments.provider,
				key      = arguments.key,
				timeout  = arguments.timeout,
				lastAccessTimeout = arguments.lastAccessTimeout
			};
			return this;
    	</cfscript>
    </cffunction>


<!------------------------------------------- MAP DSL ------------------------------------------>
	
	<!--- mapDSL --->
    <cffunction name="mapDSL" output="false" access="public" returntype="any" hint="Register a new custom dsl namespace">
    	<cfargument name="namespace" 	type="string" required="true" hint="The namespace you would like to register"/>
		<cfargument name="path" 		type="string" required="true" hint="The path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.dsl.IDSLNamespace"/>
		<cfset instance.customDSL[arguments.namespace] = arguments.path>
		<cfreturn this>
    </cffunction>
	
	<!--- getCustomDSL --->
    <cffunction name="getCustomDSL" output="false" access="public" returntype="struct" hint="Get the custom dsl namespace registration">
    	<cfreturn instance.customDSL>
    </cffunction>

<!------------------------------------------- MAP SCOPES ------------------------------------------>

	<!--- mapScope --->
    <cffunction name="mapScope" output="false" access="public" returntype="any" hint="Register a new WireBox custom scope">
    	<cfargument name="annotation"	type="string" required="true" hint="The unique scope name to register. This translates to an annotation value on CFCs"/>
    	<cfargument name="path" 		type="string" required="true" hint="The path to the CFC that implements this scope, it must have an init() method and implement: coldbox.system.ioc.scopes.IScope"/>
		<cfset instance.customScopes[arguments.annotation] = arguments.path>
		<cfreturn this>
	</cffunction>

	<!--- getCustomScopes --->
    <cffunction name="getCustomScopes" output="false" access="public" returntype="struct" hint="Get the registered custom scopes">
    	<cfreturn instance.customScopes>
    </cffunction>	

<!------------------------------------------- LOGBOX INTEGRATION ------------------------------------------>

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

<!------------------------------------------- DSL METHODS ------------------------------------------>

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
			
			// Register Stop Recursions
			if( structKeyExists( wireBoxDSL, "stopRecursions") ){
				stopRecursions( wireBoxDSL.stopRecursions );
			}

			// Register listeners
			if( structKeyExists( wireBoxDSL, "listeners") ){
				for(key=1; key lte arrayLen(wireBoxDSL.listeners); key++ ){
					listener(argumentCollection=wireBoxDSL.listeners[key]);
				}
			}	
			
			// Register Mappings	
			if( structKeyExists( wireBoxDSL, "mappings") ){
				// iterate and register
				for(key in wireboxDSL.mappings){
					// create mapping & process its memento
					//map(key).processMemento( wireBoxDSL.mappings[key] );
				}
			}
		</cfscript>
    </cffunction>
	
	<!--- getDefaults --->
    <cffunction name="getDefaults" output="false" access="public" returntype="struct" hint="Get the default WireBox settings">
    	<cfreturn variables.DEFAULTS>
    </cffunction>
		
	<!--- Get Memento --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false" hint="Get the instance data">
		<cfreturn instance>
	</cffunction>

<!------------------------------------------- LISTENER METHODS ------------------------------------------>

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
	
	<!--- getListeners --->
	<cffunction name="getListeners" output="false" access="public" returntype="array" hint="Get the configured listeners">
		<cfreturn instance.listeners>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
</cfcomponent>