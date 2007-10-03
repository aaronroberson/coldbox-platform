<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This methods just traces what plugin points it intercepted.
----------------------------------------------------------------------->
<cfcomponent name="executionTracer"
			 hint="This is a simple tracer"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<!--- Nothing --->
		
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- After Configuration Load --->
	<cffunction name="afterConfigurationLoad" access="public" returntype="void" hint="Executes after the framework and application configuration loads, but before the aspects get configured. " output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<!--- Set the tracing setting --->
		<cfset setSetting("ExecutionTracerStartTime",now())>
	</cffunction>
	
	<!--- After Aspects Load --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" hint="Executes after the application aspects get configured." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the after after aspects load.")>
	</cffunction>
	
	<!--- Pre execution process --->
	<cffunction name="preProcess" access="public" returntype="void" hint="Executes before any event execution occurs" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the pre process method.")>
	</cffunction>
	
	<!--- Pre Event execution --->
	<cffunction name="preEvent" access="public" returntype="void" hint="Executes right before any run event is executed." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 			required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the pre event method. Metadata: #arguments.metadata.toString()#")>
	</cffunction>
	
	<!--- Post Event Execution --->
	<cffunction name="postEvent" access="public" returntype="void" hint="Executes after a run event is executed" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the post event method. Metadata: #arguments.metadata.toString()#")>
	</cffunction>
	
	<!--- Pre Render Execution --->
	<cffunction name="preRender" access="public" returntype="void" hint="Executes before the framework starts the rendering cycle." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the pre render point.")>
	</cffunction>
	
	<!--- Post Rendering Cycle --->
	<cffunction name="postRender" access="public" returntype="void" hint="Executes after the rendering cycle." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the post render point.")>
	</cffunction>
	
	<!--- Post Process --->
	<cffunction name="postProcess" access="public" returntype="void" hint="Executes after executions and renderings." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","I am in the post process point.")>
	</cffunction>
	
	<!--- After an Elemente is inserted in the cache --->
	<cffunction name="afterCacheElementInsert" access="public" returntype="void" hint="Executes after an object is inserted into the cache." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 			required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","Cache element inserted. Metadata: #arguments.metadata.toString()#")>
	</cffunction>
	
	<!--- After an Element is removed from the cache --->
	<cffunction name="afterCacheElementRemoved" access="public" returntype="void" hint="Executes after an object is removed from the cache." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 			required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="metadata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("information","Cache element removed. Metadata: #arguments.metadata.toString()#")>
	</cffunction>

</cfcomponent>