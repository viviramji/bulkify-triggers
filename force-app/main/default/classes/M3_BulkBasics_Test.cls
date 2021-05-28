@isTest (isParallel = true)
private class M3_BulkBasics_Test 
{	
	@isTest
	static void usingMaps()
	{
		// Given:
		M3_BulkBasics bulkBasics = new M3_BulkBasics();

		Test.startTest();
		Map<Id, Opportunity> opportunityIdToOpportunity = bulkBasics.usingMaps();
		Test.stopTest();

		// Then:
		System.assertEquals(1, opportunityIdToOpportunity.keySet().size(),
			'Expected one key-value pair');

	}

	@isTest
	static void wrongWaytoAvoidSOQL()
	{
		// Given:
		M3_BulkBasics bulkBasics = new M3_BulkBasics();

		// When:
		Test.startTest();
		Map<Date, List<Account>> accountsByDate = bulkBasics.wrongWaytoAvoidSOQL();
		Integer soqlQueriesConsumed = System.Limits.getQueries();
		Test.stopTest();

		// Then:
		
		// 30 queries are expected because the method, wrongWaytoAvoidSOQL(),
		// executes a query for each day backward on a 30 day period
		Integer expectedNumberOfQueries = 30;

		System.assertEquals(expectedNumberOfQueries, soqlQueriesConsumed,
			'Expected consumption of 30 SOQL queries');
	}

	@isTest
	static void betterWayToUseSOQL()
	{
		// Given:
		M3_BulkBasics bulkBasics = new M3_BulkBasics();

		// When:
		Test.startTest();
		Map<Date, List<Account>> accountsByDate = bulkBasics.betterWayToUseSOQL();
		Integer queriesConsumed = System.Limits.getQueries();
		Test.stopTest();

		// Then:
		Integer expectedNumberOfQueries = 1;
		System.assertEquals(expectedNumberOfQueries, queriesConsumed,	
			'Expected ' + expectedNumberOfQueries + ' SOQL query consumed');
	}
}