@isTest (isParallel = true)
private class M3_HighExpenses_Test
{
	public static final String TEST_ACCOUNT_NAME = 'Test Account';
	public static final String DRAFT = 'Draft';

	public static Account accountOne = new Account(Name = TEST_ACCOUNT_NAME + '1');
	public static Account accountTwo = new Account(Name = TEST_ACCOUNT_NAME + '2');
	public static List<Account> accounts;
	public static List<Order> orders;
	public static final List<Decimal> orderAmounts = new List<Decimal>{43.98, 24.97, 14.98};

	static void initialization()
	{
		accounts = new List<Account>{accountOne, accountTwo};
		insert accounts;

		orders = new List<Order>();

		Integer orderAmountsSize = orderAmounts.size();
		for (Integer i = 0, j = orderAmountsSize; i < j; i++)
			orders.add(
				new Order(
					Amount__c = orderAmounts[i],
					AccountId = i == 2 ? accountTwo.Id : accountOne.Id,
					EffectiveDate = Date.newInstance(2021, 01, 01), // Required field
					Status = DRAFT
				)
			);
		insert orders;
	}
	
	public static void assertAmounts(Map<Id, Decimal> accountIdToLowest)
	{
		System.assertEquals(orderAmounts[2], accountIdToLowest.get(accountTwo.Id),
			'Expected ' + orderAmounts[2]);

		System.assertEquals(orderAmounts[1], accountIdToLowest.get(accountOne.Id),
			'Expected ' + orderAmounts[1]);
	}
	
	@isTest
	static void lowestAmountTheRightWay()
	{
		// Given:
		initialization();
		M3_HighExpenses expensesMethods = new M3_HighExpenses();

		// When:
		Test.startTest();
		Map<Id, Decimal> accountIdToLowest = expensesMethods.lowestAmountTheRightWay(accounts);
		Integer numberOfQueries = System.Limits.getQueries();
		Test.stopTest();

		// Then:
		assertAmounts(accountIdToLowest);
		System.assertEquals(1, numberOfQueries, 'Expected 1 and only 1 query');
	}

	@isTest
	static void lowestAmountTheWrongWay()
	{
		// Given:
		initialization();
		M3_HighExpenses expensesMethods = new M3_HighExpenses();

		// When:
		Test.startTest();
		Map<Id, Decimal> accountIdToLowest = expensesMethods.lowestAmountTheBadWay(accounts);
		Integer numberOfQueries = System.Limits.getQueries();		
		Test.stopTest();

		// Then:
		assertAmounts(accountIdToLowest);
		System.assertEquals(2, numberOfQueries, 'Expected 2 queries');		
	}
}