// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = false) // Required to be false due to grabbing standard Pricebook
public without sharing class OrderAggregator_Test 
{
	public OrderAggregator_Test() {}

	@isTest
	static void run()
	{
		// Given:
		Date startDate = Date.today();
		FunctionalTestData testData = new FunctionalTestData();
		
		testData.defaultPricebook = new Pricebook2(
			Name = 'Default',
			Id = Test.getStandardPricebookId() // Required because of Salesforcey reasons
		);

		testData.defaultPartOne();
		testData.defaultPartTwo();

		Decimal orderTotal = 0.0;
		Integer ordersSize = testData.orders.size();
		for (Integer i = 0, j = ordersSize; i < j; i++)
			if (testData.orders[i].TotalAmount != null)
				orderTotal += testData.orders[i].TotalAmount;

		Map<Id, Id> productIdToPricebookEntryId = new Map<Id, Id>();
		Integer pricebookEntriesSize = testData.pricebookEntries.size();
		for (Integer i = 0, j = pricebookEntriesSize; i < j; i++)
		{
			PricebookEntry entry = testData.pricebookEntries[i];
			productIdToPricebookEntryId.put(entry.Product2Id, entry.Id);
		}
		System.debug('productIdToPricebookEntryId.keySet().size(): ' + 
			productIdToPricebookEntryId.keySet().size());
		
		OrderAggregator orderAggregator = new OrderAggregator(startDate);
		orderAggregator.orders = testData.orders;
		orderAggregator.SINGLE_DATE_ONLY = true;

		// When:
		Test.startTest();
		orderAggregator.run();
		Test.stopTest();

		// Then:
		System.assertEquals(FunctionalTestData.NUMBER_OF_CUSTOMER_RECORDS, orderAggregator.grandCount,
			'Expected ' + FunctionalTestData.NUMBER_OF_CUSTOMER_RECORDS + ' record included in count');

		System.assertEquals(orderTotal, orderAggregator.grandTotal,
			'Expected test Order amount in grandTotal value');

		System.assertEquals(orderAggregator.grandCount, testData.orders.size(),
			'Grand count should reflect order list size');
	}

	@isTest
	static void ordersForDateCoverage()
	{
		// Given:
		Date dateToRun = Date.newInstance(2021, 01, 20);
		OrderAggregator aggregator = new OrderAggregator(dateToRun);
		aggregator.SINGLE_DATE_ONLY = true; // Do not chain to the next job

		// When:
		Boolean exceptionThrown = false;
		try {
			aggregator.ordersForDate(); // Done for coverage
		} catch (Exception ordersForDateException) {
			exceptionThrown = true;
			System.debug('ordersForDateException: ' + ordersForDateException.getMessage() + 
				'\n' + ordersForDateException.getStackTraceString());
		}

		// Then:
		System.assertEquals(false, exceptionThrown,
			'No exception should be thrown when running the query method');
	}
}