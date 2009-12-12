<cfcomponent output="false" hint="My App Configuration">
<cfscript>
/**
structures to create for configuration

- coldbox
- settings
- conventions
- environments
- ioc
- models
- debugger
- mailSettings
- i18n
- bugTracers
- webservices
- datasources
- layoutSettings
- layouts
- cacheEngine
- interceptorSettings
- interceptors

Available objects in variable scope
- controller
- logBoxConfig
- appMapping (auto calculated by ColdBox)

Required Methods
- configure() : The method ColdBox calls to configure the application.
Optional Methods
- detectEnvironment() : If declared the framework will call it and it must return the name of the environment you are on.
- {environment}() : The name of the environment found and called by the framework.

*/
	
	// Configure ColdBox Application
	function configure(){
	
		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Your app name here",
			eventName 				= "event",
			
			//Development Settings
			debugMode				= true,
			debugPassword			= "",
			reinitPassword			= "",
			handlersIndexAutoReload = true,
			configAutoReload		= false,
			
			//Implicit Events
			defaultEvent			= "General.index",
			requestStartHandler		= "Main.onRequestStart",
			requestEndHandler		= "",
			applicationStartHandler = "Main.onAppInit",
			applicationEndHandler	= "",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",
			
			//Extension Points
			UDFLibraryFile 			= "includes/helpers/ApplicationHelper.cfm",
			coldboxExtensionsLocation = "",
			pluginsExternalLocation = "",
			viewsExternalLocation	= "",
			layoutsExternalLocation = "",
			handlersExternalLocation  = "",
			requestContextDecorator = "",
			
			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate		= "",
				
			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= false,
			proxyReturnCollection 	= false,
			flashURLPersistScope	= "session"	
		};
	
		// custom settings
		settings = {
			
		};
		
		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		// the value of the environment is a list of regex patterns to match the cgi.http_host.
		environments = {
			//development = "^cf8.,^railo."
		};
		
		//LogBox
		logBoxConfig.appender(name="coldboxTracer",class="coldbox.system.logging.appenders.ColdboxTracerAppender");
		logBoxConfig.root(levelMax=logBoxConfig.logLevels.INFO,appenders="*");
		logBoxConfig.info("coldbox.system");
		
		//Layout Settings
		layoutSettings = {
			defaultLayout = "Layout.Main.cfm",
			defaultView   = ""
		};
		
		//cacheEngine
		cacheEngine = {
			objectDefaultTimeout = 60,
			objectDefaultLastAccessTimeout = 30,
			reapFrequency = 1,
			freeMemoryPercentageThreshold = 0,
			useLastAccessTimeouts = true,
			evictionPolicy = "LRU",
			evictCount = 1,
			maxObjects = 100
		};
	
		//Interceptor Settings
		interceptorSettings = {
			throwOnInvalidStates = false,
			customInterceptors = ""
		};
		
		//Register interceptors as an array, we need order
		interceptors = [
			//Autowire
			{class="coldbox.system.interceptors.Autowire"},
			//SES
			{class="coldbox.system.interceptors.SES"}
		];
		
		
		/*
		//Register Layouts
		layouts = {
			login = {
				file = "Layout.tester.cfm",
				views = "vwLogin,test",
				folders = "tags,pdf/single"
			}
		};
		
		//Model Integration
		models = {
			objectCaching = true,
			definitionFile = "config/modelMappings.cfm",
			externalLocation = "coldbox.testing.testmodel",
			SetterInjection = false,
			DICompleteUDF = "onDIComplete",
			StopRecursion = "",
			parentFactory 	= {
				framework = "coldspring",
				definitionFile = "config/parent.xml.cfm"
			}
		};
		
		//Conventions
		conventions = {
			handlersLocation = "handlers",
			pluginsLocation = "plugins",
			viewsLocation = "views",
			layoutsLocation = "layouts",
			modelsLocation = "model",
			eventAction = "index"
		};
		
		//IOC Integration
		ioc = {
			framework 		= "lightwire",
			reload 	  	  	= true,
			objectCaching 	= false,
			definitionFile  = "config/coldspring.xml.cfm",
			parentFactory 	= {
				framework = "coldspring",
				definitionFile = "config/parent.xml.cfm"
			}
		};
		
		//Debugger Settings
		debugger = {
			enableDumpVar = false,
			persistentRequestProfilers = true,
			maxPersistentRequestProfilers = 10,
			maxRCPanelQueryRows = 50,
			//Panels
			showTracerPanel = true,
			expandedTracerPanel = true,
			showInfoPanel = true,
			expandedInfoPanel = true,
			showCachePanel = true,
			expandedCachePanel = true,
			showRCPanel = true,
			expandedRCPanel = true
		};
		
		//Mailsettings
		mailSettings = {
			server = "",
			username = "",
			password = "",
			port = 25
		};
		
		//i18n & Localization
		i18n = {
			defaultResourceBundle = "includes/main",
			defaultLocale = "en_US",
			localeStorage = "session",
			unknownTranslation = "**NOT FOUND**"		
		};
		
		//bug tracers
		bugTracers = {
			enabled = false,
			bugEmails = "",
			mailFrom = "",
			customEmailBugReport = ""
		};
		
		//webservices
		webservices = {
			testWS = "http://www.test.com/test.cfc?wsdl",
			AnotherTestWS = "http://www.coldboxframework.com/distribution/updatews.cfc?wsdl"	
		};
		
		//Datasources
		datasources = {
			mysite   = {name="mySite", dbType="mysql", username="root", password="pass"},
			blog_dsn = {name="myBlog", dbType="oracle", username="root", password="pass"}
		};
		*/

	}
	
</cfscript>
</cfcomponent>