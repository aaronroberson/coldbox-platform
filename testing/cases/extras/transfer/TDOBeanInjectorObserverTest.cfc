<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="requestserviceTest" extends="coldbox.testing.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Call the super setup method to setup the app.
		super.setup();
		
		transfer = mockFactory.createMock('transfer.com.Transfer');
		transferEvent = mockFactory.createMock('transfer.com.events.TransferEvent');
		transferObject = mockFactory.createMock('transfer.com.TransferObject');
		transferEvent.mockMethod('getTransferObject').returns(transferObject);
		
		BeanFactory = mockFactory.createMock('coldbox.system.plugins.BeanFactory');
		BeanFactory.mockMethod('autowire');
		
		BeanFactory.autowire(this);
		
		observer = createObject("component","coldbox.system.extras.transfer.TDOBeanInjectorObserver");
		observer.init(transfer=transfer,ColdBoxBeanFactory=BeanFactory,useSetterInjection=true,onDICompleteUDF='onComplete',debugMode=true);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testactionAfterNewTransferEvent" access="public" returntype="void" output="false">
		<cfscript>
			observer.actionAfterNewTransferEvent(transferEvent);			
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>