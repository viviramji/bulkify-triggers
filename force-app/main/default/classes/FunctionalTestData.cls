// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// WHAT'S THIS?
//
// The run method can be executed from this class to create test data in a 
// scratch org, sandbox, or developer edition org where this code has been 
// installed. This includes everything needed to work with the Order object,
// including adding reward points from reward table lookups, which means
// adding some sample orders, fake products & a price book, and other objects.
//
// In Execute Anonymous, the following code can be used to insert all new
// test records and replace all object types included here:
// FunctionalTestData functionalTestData = new FunctionalTestData();
// functionalTestData.reset();
// functionalTestData.run();

public without sharing class FunctionalTestData 
{
	public FunctionalTestData(){}

	public static final Decimal DEFAULT_DRINK_POINTS = 10.0;
	public static final Decimal DEFAULT_DRINK_CHARGE = -100.0;
	public static final Integer NUMBER_OF_CUSTOMER_RECORDS = 10;

	public static final Decimal ICED_COFFEE_PRICE = 4.59;
	public static final Decimal DRIP_BREW_COFFEE_PRICE = 1.99;
	public static final Decimal HOT_CHOCOLATE_PRICE = 1.89;

	public static final String ACCOUNT_OBJECT_TYPE = 'Account';
	public static final String CONTACT_OBJECT_TYPE = 'Contact';
	public static final String PRODUCT_OBJECT_TYPE = 'Product2';
	public static final String PRICEBOOK_OBJECT_TYPE = 'Pricebook2';
	public static final String ORDER_OBJECT_TYPE = 'Order';
	public static final String ORDER_PRODUCT_OBJECT_TYPE = 'OrderItem';
	public static final String PRICEBOOK_ENTRY_OBJECT_TYPE = 'PricebookEntry';
	public static final String REWARD_LOOKUP_OBJECT_TYPE = 'Reward_Lookup__c';

	public List<Product2> products;
	public Pricebook2 defaultPricebook;
	public Product2 icedCoffee;
	public Product2 hotChocolate;
	public Product2 dripBrewCoffee;
	public Product2 drinkCharge; // Deducts points while the rest add points

	public List<Account> accounts;
	public List<Contact> contacts;
	public List<Order> orders;
	public List<PricebookEntry> pricebookEntries;
	
	public class InsertJob implements Queueable
	{
		public FunctionalTestData testDataState;

		public InsertJob(FunctionalTestData testDataState)
		{
			this.testDataState = testDataState;
		}

		public void insertRecords()
		{
			testDataState.defaultPartTwo();
		}
		
		public void execute(QueueableContext context)
		{
			this.insertRecords();
		}
	}

	public Boolean objectOfTypeExists(String objectType)
	{
		if (Database.query('SELECT Id FROM ' + objectType + ' LIMIT 1').size() > 0)
			return true;
		return false;
	}

	public List<Account> customerAccounts()
	{
		accounts = new List<Account>();
		for (Integer i = 0, j = NUMBER_OF_CUSTOMER_RECORDS; i < j; i++)
			accounts.add(new Account(Name = 'Test Customer ' + String.valueOf(i)));
		System.debug('accounts.size(): ' + accounts.size());

		return accounts;
	}

	public List<Contact> customerContacts()
	{
		contacts = new List<Contact>();
		for (Integer i = 0, j = NUMBER_OF_CUSTOMER_RECORDS; i < j; i++)
			contacts.add(new Contact(
				FirstName = 'Test',
				LastName = 'Contact ' + String.valueOf(i)
			));
		System.debug('contacts.size(): ' + contacts.size());

		return contacts;
	}

	public Pricebook2 samplePricebook()
	{
		if (this.defaultPricebook == null)
			this.defaultPricebook = new Pricebook2(
				Name = 'Default'
			);

		return defaultPricebook;
	}

	public List<PricebookEntry> samplePricebookEntries()
	{
		pricebookEntries = new List<PricebookEntry>();

		PricebookEntry icedCoffeePrice = new PricebookEntry(
			Product2Id = icedCoffee.Id,
			UnitPrice = ICED_COFFEE_PRICE,
			Pricebook2Id = defaultPricebook.Id,
			IsActive = true
		);

		PricebookEntry dripBrewCoffeePrice = new PricebookEntry(
			Product2Id = dripBrewCoffee.Id,
			UnitPrice = DRIP_BREW_COFFEE_PRICE,
			Pricebook2Id = defaultPricebook.Id,
			IsActive = true
		);

		PricebookEntry hotChocolatePrice = new PriceBookEntry(
			Product2Id = hotChocolate.Id,
			UnitPrice = HOT_CHOCOLATE_PRICE,
			Pricebook2Id = defaultPricebook.Id,
			IsActive = true
		);

		pricebookEntries.add(icedCoffeePrice);
		pricebookEntries.add(dripBrewCoffeePrice);
		pricebookEntries.add(hotChocolatePrice);

		return pricebookEntries;
	}

	public List<Product2> sampleProducts()
	{
		icedCoffee = new Product2(Name = 'Iced Coffee', IsActive = true);
		dripBrewCoffee = new Product2(Name = 'Drip Brew Coffee', IsActive = true);
		hotChocolate = new Product2(Name = 'Hot Chocolate', IsActive = true);
		drinkCharge = new Product2(Name = 'Drink Redemption', IsActive = true);

		products = new List<Product2>
		{
			icedCoffee,
			dripBrewCoffee,
			hotChocolate,
			drinkCharge
		};

		return products;
	}

	public List<Reward_Lookup__c> sampleRewardLookups()
	{
		List<Reward_Lookup__c> rewardLookups = new List<Reward_Lookup__c>();

		Reward_Lookup__c icedCoffeeReward = new Reward_Lookup__c(
			Product__c = icedCoffee?.Id,
			Reward_Points__c = DEFAULT_DRINK_POINTS
		);

		Reward_Lookup__c dripBrewCoffeeReward = new Reward_Lookup__c(
			Product__c = dripBrewCoffee?.Id,
			Reward_Points__c = DEFAULT_DRINK_POINTS
		);

		Reward_Lookup__c hotChocolateReward = new Reward_Lookup__c(
			Product__c = hotChocolate?.Id,
			Reward_Points__c = DEFAULT_DRINK_POINTS
		);

		Reward_Lookup__c drinkDeduction = new Reward_Lookup__c(
			Product__c = drinkCharge?.Id,
			Reward_Points__c = DEFAULT_DRINK_CHARGE
		);

		rewardLookups.add(icedCoffeeReward);
		rewardLookups.add(dripBrewCoffeeReward);
		rewardLookups.add(hotChocolateReward);
		rewardLookups.add(drinkDeduction);

		return rewardLookups;
	}

	public List<Order> sampleOrders()
	{
		this.orders = new List<Order>();
		for (Integer i = 0, j = NUMBER_OF_CUSTOMER_RECORDS; i < j; i++)
			this.orders.add(
				new Order(
					BillToContactId = contacts[i].Id,
					AccountId = accounts[i].Id,
					Pricebook2Id = this.defaultPricebook.Id
				)
			);

		return this.orders;
	}
	
	public List<OrderItem> sampleOrderProducts()
	{
		List<OrderItem> orderProducts = new List<OrderItem>();
		Integer currentProduct = 0;
		for (Integer i = 0, j = NUMBER_OF_CUSTOMER_RECORDS; i < j; i++)
		{
			orderProducts.add(
				new OrderItem(
					OrderId = orders[i].Id,
					Product2Id = products[currentProduct].Id,
					PricebookEntryId = pricebookEntries[currentProduct].Id,
					UnitPrice = pricebookEntries[currentProduct].UnitPrice,
					Quantity = 1					
				)
			);

			currentProduct += 1;

			if (currentProduct == 2)
				currentProduct = 0;
		}
		
		return orderProducts;
	}

	public void defaultPartOne()
	{
		Integer startTime = System.Limits.getCpuTime();
		if (this.defaultPricebook == null)
			insert this.samplePricebook();

		if (!this.objectOfTypeExists(PRODUCT_OBJECT_TYPE))
			insert this.sampleProducts();

		System.enqueueJob(new InsertJob(this));
		Integer endTime = System.Limits.getCpuTime();

		Integer totalRuntime = endTime - startTime;
		System.debug('CPU time from defaultPartOne: ' + totalRuntime + ' milliseconds');
	}

	public void defaultPartTwo()
	{
		Integer startTime = System.Limits.getCpuTime();
		
		if (!this.objectOfTypeExists(PRICEBOOK_ENTRY_OBJECT_TYPE))	
			insert this.samplePricebookEntries();

		if (!this.objectOfTypeExists(ACCOUNT_OBJECT_TYPE))
			insert this.customerAccounts();

		if (!this.objectOfTypeExists(CONTACT_OBJECT_TYPE))
			insert this.customerContacts();

		if (!this.objectOfTypeExists(ORDER_OBJECT_TYPE))
			insert this.sampleOrders();

		if (!this.objectOfTypeExists(ORDER_PRODUCT_OBJECT_TYPE))
			insert this.sampleOrderProducts();

		if (!this.objectOfTypeExists(REWARD_LOOKUP_OBJECT_TYPE))
			insert this.sampleRewardLookups();

		Integer endTime = System.Limits.getCpuTime();

		Integer totalRuntime = endTime - startTime;
		Integer queriesConsumed = System.Limits.getQueries();
		Integer maxQueries = System.Limits.getLimitQueries();
		Integer dmlConsumed = System.Limits.getDmlStatements();
		Integer maxDML = System.Limits.getLimitDmlStatements();

		System.debug('CPU time from defaultPartTwo: ' + totalRuntime + ' milliseconds' + 
			'\nQueries from defaultPartTwo: ' + queriesConsumed + ' out of ' + maxQueries + 
			'\nDML statements from defaultPartTwo: ' + dmlConsumed + ' out of ' + maxDML);
	}

	public void reset()
	{
		List<List<SObject>> deleteLoads = new List<List<SObject>>();
		List<String> objectTypesToDelete = new List<String>
		{
			ACCOUNT_OBJECT_TYPE,
			CONTACT_OBJECT_TYPE,
			PRICEBOOK_OBJECT_TYPE,
			PRODUCT_OBJECT_TYPE,
			PRICEBOOK_ENTRY_OBJECT_TYPE,
			ORDER_PRODUCT_OBJECT_TYPE,
			ORDER_OBJECT_TYPE
		};
		
		Integer objectTypesSize = objectTypesToDelete.size();
		for (Integer i = 0, j = objectTypesSize; i < j; i++)
			deleteLoads.add(
				Database.query('SELECT Id FROM ' + objectTypesToDelete[i] 
					+ ' LIMIT 5000')
			);

		Integer deleteLoadsSize = deleteLoads.size();
		for (Integer i = 0, j = deleteLoadsSize; i < j; i++)
			if (deleteLoads[i].size() > 0)
			{
				Boolean allOrNone = false;
				Database.DeleteResult[] deleteResults = Database.delete(deleteLoads[i], false);
			}	
	}
	
	public void run()
	{
		this.defaultPartOne();
	}
}