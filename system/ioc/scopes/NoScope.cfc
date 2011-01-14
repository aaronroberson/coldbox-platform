<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am the NoScope Scope of Scopes
	
----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.ioc.scopes.IScope" hint="I am the NoScope Scope of Scopes">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
    	<cfreturn this>
    </cffunction>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="Configure the scope for operation">
    	<cfargument name="wirebox" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				wirebox = arguments.wirebox
			};
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" type="any" required="true" hint="The object mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfscript>
			// create and return the no scope instance, no locking needed.
			var object = wirebox.constructInstance(arguments.mapping);
			// wire it
			instance.wireBox.autowire( object );
			// send it back
			return object;
		</cfscript>
    </cffunction>
	
</cfcomponent>