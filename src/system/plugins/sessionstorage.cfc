<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	February 16,2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the session scope.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="sessionStorage"
			 hint="Session Storage plugin. It provides the user with a mechanism for permanent data storage using the session scope."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="sessionStorage" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Session Storage");
			setpluginVersion("2.0");
			setpluginDescription("A permanent data storage plugin using the session scope.");
			
			/* Lock Name */
			setLockName( getController().getAppHash() & "_SESSION_STORAGE" );
			
			/* Create Storage */
			createStorage();			
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Set a variable --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true" hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true" hint="The value to set in the variable.">
		<!--- ************************************************************* --->
		<cfset var storage = getStorage()>
		
		<cflock name="#getLockName()#" type="exclusive" timeout="10" throwontimeout="true">
			<cfset storage[arguments.name] = arguments.value>
		</cflock>
	</cffunction>

	<!--- Get A Variable --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var storage = getStorage()>
		
		<cflock name="#getLockName()#" type="readonly" timeout="10" throwontimeout="true">
			<cfscript>
				if ( structKeyExists( storage, arguments.name) )
					return storage[arguments.name];
				else
					arguments.default;
			</cfscript>
		</cflock>
	</cffunction>

	<!--- Delete a variable --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent application var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfset var results = false>
		<cfset var storage = getStorage()>
		
		<cflock name="#getLockName()#" type="exclusive" timeout="10" throwontimeout="true">
			<cfset results = structdelete(storage, arguments.name, true)>
		</cflock>
		
		<cfreturn results>
	</cffunction>

	<!--- Exists check --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists( getStorage(), arguments.name)>
	</cffunction>

	<!--- Clear All From Storage --->
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear the entire coldbox application storage" output="false">
		<cflock name="#getLockName()#" type="exclusive" timeout="10" throwontimeout="true">
			<cfset structClear(getStorage())>
		</cflock>
	</cffunction>
	
	<!--- Get Storage --->
	<cffunction name="getStorage" access="public" returntype="any" hint="Get the entire storage scope" output="false" >
		<cfscript>
			if( not structKeyExists(session, "cbStorage") ){
				createStorage();
			}
			return session.cbStorage;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Create Storage --->
	<cffunction name="createStorage" access="private" returntype="void" hint="Create the session storage scope" output="false" >
		<!--- Create session Storage Scope --->
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset session.cbStorage = structNew()>
		</cflock>
	</cffunction>

	<!--- get/set lockname --->
	<cffunction name="getlockName" access="private" output="false" returntype="string" hint="Get lockName">
		<cfreturn instance.lockName/>
	</cffunction>	
	<cffunction name="setlockName" access="private" output="false" returntype="void" hint="Set lockName">
		<cfargument name="lockName" type="string" required="true"/>
		<cfset instance.lockName = arguments.lockName/>
	</cffunction>

</cfcomponent>