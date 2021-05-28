// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class OrderManager_Test 
{
	public static final Id CUSTOMER_CONTACT_ID_MOCK = new MockObjects.IDGenerator(Contact.SObjectType).generate();

	@isTest
	static void updateRewardBalance()
	{
		// Given:
		// No existing Reward Balance is mapped inside of 
		// orderManager.customerIdtoRewardBalance, so there should
		// be a new Reward_Balance__c custom object instance 
		// ready to insert inside of the orderManager.newRewardBalances
		// list. The list would finally make its way into the database
		// after orderManager.insertNewRewardBalances() is called 
		// from within the Order trigger.
		OrderManager orderManager = new OrderManager();

		Decimal rewardPointsToAdd = 10.0;

		// When:
		orderManager.updateRewardBalance(rewardPointsToAdd, CUSTOMER_CONTACT_ID_MOCK, null);

		// Then:
		System.assertEquals(1, orderManager.newRewardBalances.size(),
			'Expected 1 new Reward Balance');
	}

	@isTest
	static void updateRewardBalanceBelowZero()
	{
		// Given:
		OrderManager orderManager = new OrderManager();

		// Unlike the test above, putting a negative reward point
		// value onto the balance should result in an exception being
		// thrown, as no customer is allowed to have a reward balance
		// below zero!
		Decimal rewardPointsToAdd = -10.0; // 0 - (-10) = -10, which is less than zero

		Order placeholder = new Order();

		// When:
		Boolean exceptionThrown = false;
		String errorMessage = '';
		orderManager.updateRewardBalance(rewardPointsToAdd, CUSTOMER_CONTACT_ID_MOCK, placeholder);

		// Then:
		List<Database.Error> errors = placeholder.getErrors();

		System.assertEquals(1, errors.size(), 'Expected 1 error');

		for (Database.Error error : errors)
			errorMessage = error.getMessage();

		System.assertEquals(orderManager.REWARD_BALANCE_BELOW_ZERO, errorMessage,
			'Expected reason for thrown exception to be reward balance below zero');
	}

	@isTest
	static void insertOrdersBulk()
	{
		// Given:
		Integer numberOfOrdersToInsert = 200;

		List<Account> customerAccounts = new List<Account>();
		for (Integer i = 0, j = numberOfOrdersToInsert; i < j; i++)
			customerAccounts.add(new Account(Name = 'Test ' + i));
		insert customerAccounts;

		List<Order> ordersToInsert = new List<Order>();
		for (Integer i = 0, j = numberOfOrdersToInsert; i < j; i++)
		{
			ordersToInsert.add(
				new Order(AccountId = customerAccounts[i].Id,
					EffectiveDate = Date.newInstance(2021, 01, 01),
					Status = 'Draft'
				)
			);
		}

		// When:
		Test.startTest();
		Boolean exceptionEncountered = false;
		try {
			insert ordersToInsert;
		} catch (Exception insertException) 
		{
			System.debug(insertException.getMessage() + '\n' + insertException.getStackTraceString());
			exceptionEncountered = true;
		}
		
		Test.stopTest();

		// Then:
		System.assertEquals(false, exceptionEncountered,
			'Expected successful insert of 200 Order records');
	}

	// This test can be uncommented to reveal test for the unoptimized
	// version of updateRewardBalance().

	/*
	@isTest
	static void updateRewardBalanceNotOptimized()
	{
		// Given:
		OrderManager manager = new OrderManager();
		
		// These IDGenerator instances allow for stubbing in fake IDs
		// on to different sObject types. The MockObjects.IDGenerator
		// class provides exact 18 character patterns for the different
		// sObjectType IDs, directly from the Salesforce database, but
		// these IDs cannot be used for record insert without receiving
		// an error. 
		MockObjects.IDGenerator productIdGen = new MockObjects.IDGenerator(Product2.SObjectType);
		MockObjects.IDGenerator orderIdGen = new MockObjects.IDGenerator(Order.SObjectType);
		MockObjects.IDGenerator contactIdGen = new MockObjects.IDGenerator(Contact.SObjectType);
		
		FunctionalTestData testData = new FunctionalTestData();
		List<Reward_Lookup__c> rewardLookups = testData.sampleRewardLookups();
		List<OrderItem> orderProducts = new List<OrderItem>();
		List<Reward_Balance__c> rewardBalances = new List<Reward_Balance__c>();
		List<Order> orders = new List<Order>();

		Integer rewardLookupsSize = rewardLookups.size();
		List<Id> productIds = new List<Id>();
		List<Id> contactIds = new List<Id>();
		
		// The below multiplier values can be altered to change 
		// the performance impact, with higher numbers obviously 
		// nudging the code closer to governor limits.
		// 
		// At some point, even with optimized code, high enough 
		// numbers could cause a failure.
		Integer orderProductMultiplier = 100; // (Multiplied by 4 due to 4 Reward Lookups)
		Integer orderMultiplier = 50;
		for (Integer i = 0, j = rewardLookupsSize; i < j; i++) // 4 Reward Lookups
		{
			Id productId = productIdGen.generate();
			Id orderId = orderIdGen.generate();
			Id contactId = contactIdGen.generate();

			productIds.add(productId);

			for (Integer x = 0, y = orderProductMultiplier; x < y; x++)
				orderProducts.add(
					new OrderItem(
						Product2Id = productId,
						OrderId = orderId,
						UnitPrice = FunctionalTestData.DRIP_BREW_COFFEE_PRICE
					)
				);

			rewardBalances.add(
				new Reward_Balance__c(
					Customer_Contact__c = contactId,
					Current_Balance__c = 0
				)
			);

			for (Integer x = 0, y = orderMultiplier; x < y; x++)
				orders.add(
					new Order(
						Id = orderId,
						BillToContactId = contactId
					)
				);
		}

		Integer orderCount = orders.size();
		Integer rewardBalanceCount = rewardBalances.size();
		Integer orderProductsCount = orderProducts.size();
		Integer rewardLookupCount = rewardLookups.size();

		Integer totalLoad = orderCount * 
			rewardBalanceCount * 
			orderProductsCount * 
			rewardLookupCount;

		System.debug('orders.size(): ' + orderCount + // 200
			'\nrewardBalances.size(): ' + rewardBalanceCount + // 4
			'\norderProducts.size(): ' + orderProductsCount + // 400
			'\nrewardLookups.size(): ' + rewardLookupCount + // 4
			'\ntotalLoad: ' + totalLoad); // 1,280,000
		

		// When:
		Test.startTest();
		manager.updateRewardBalance(orderProducts, rewardBalances, rewardLookups, orders);
		Test.stopTest();

		// Then:
		// This test is designed to ALWAYS fail.
	}
	*/
	

	@isTest
	static void updateRewardBalanceBulk()
	{
		// Given:
		OrderManager manager = new OrderManager();

		// Test load quantities
		Integer numberOfOrders = 400;
		Integer numberOfRewardBalances = 4;
		Integer numberOfOrderProducts = 400;
		Integer numberOfRewardLookups = 4;

		// Lists that will be plugged in to the OrderManager
		// class instance for simulating the actions of the 
		// Apex trigger.
		List<Order> orders = new List<Order>();
		List<Reward_Balance__c> rewardBalances = new List<Reward_Balance__c>();
		List<OrderItem> orderProducts = new List<OrderItem>();
		List<Reward_Lookup__c> rewardLookups = new FunctionalTestData().sampleRewardLookups();

		MockObjects.IDGenerator contactIdGen = new MockObjects.IDGenerator(Contact.SObjectType);
		MockObjects.IDGenerator orderIdGen = new MockObjects.IDGenerator(Order.SObjectType);

		List<Id> contactIds = new List<Id>();
		
		// ORDER BALANCES
		for (Integer i = 0, j = numberOfOrders; i < j; i++)
		{
			Id contactId = contactIdGen.generate();
			contactIds.add(contactId);
			orders.add(
				new Order(
					Id = orderIdGen.generate(),
					BillToContactId = contactId
				)
			);
		}

		// REWARD BALANCES
		for (Integer i = 0, j = numberOfRewardBalances; i < j; i++)
		{
			rewardBalances.add(
				new Reward_Balance__c(
					Customer_Contact__c = contactIds[i],
					Current_Balance__c = 0
				)
			);
		}

		// ORDER PRODUCTS
		Integer currentProductIndex = 0;
		for (Integer i = 0, j = numberOfOrderProducts; i < j; i++)
		{
			Id productId = rewardLookups[currentProductIndex].Product__c;

			orderProducts.add(
				new OrderItem(
					Product2Id = productId,
					OrderId = orders[i].Id,
					UnitPrice = FunctionalTestData.DRIP_BREW_COFFEE_PRICE
				)
			);

			currentProductIndex += 1;

			if (currentProductIndex == rewardLookups.size() - 1)
				currentProductIndex = 0;
		}

		// When:
		Test.startTest();
		Integer startTime = System.Limits.getCpuTime();
		manager.existingRewardBalances = rewardBalances;
		manager.orderProducts = orderProducts;
		manager.rewardLookups = rewardLookups;
		manager.manageRelatedCollections(orders);
		manager.manageRewardLookup();
		for (Integer i = 0, j = numberOfOrders; i < j; i++)
		{
			Order order = orders[i];
			manager.checkReward(order);
		}
		Integer endTime = System.Limits.getCpuTime();
		Integer totalTime = endTime - startTime;
		Test.stopTest();

		System.debug('totalTime: ' + totalTime + ' milliseconds');
		
		// Then:
		Integer maxCPUTime = System.Limits.getLimitCpuTime();
		Decimal fortyPercentOfCpuTime = (Decimal.valueOf(maxCPUTime) * 0.4).setScale(0, System.RoundingMode.HALF_UP);
		Integer efficiencyStandardCpuTime = Integer.valueOf(fortyPercentOfCpuTime);
		System.assert(totalTime < efficiencyStandardCpuTime, 
			'Expected less than 40% of CPU time maximum');
	}
}