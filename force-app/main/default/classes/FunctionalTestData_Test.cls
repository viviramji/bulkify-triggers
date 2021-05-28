// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.


// isParallel required to be false because of Test.getStandardPricebookId()
// for some reason - the wonders of Salesforce! O_O MYSTERIES.
@isTest (isParallel = false) 
private class FunctionalTestData_Test 
{
	public FunctionalTestData_Test(){}

	@isTest
	static void defaultData()
	{
		// Given:
		FunctionalTestData testData = new FunctionalTestData();
		testData.defaultPricebook = new Pricebook2(
			Name = 'Default',
			Id = Test.getStandardPricebookId()
		);

		// When:
		Test.startTest();
		testData.run();
		Test.stopTest();

		// Then:
		// List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE CreatedDate = TODAY];
		List<Product2> products = [SELECT Id FROM Product2 WHERE CreatedDate = TODAY];
		List<Account> accounts = [SELECT Id FROM Account WHERE CreatedDate = TODAY];
		List<Contact> contacts = [SELECT Id FROM Contact WHERE CreatedDate = TODAY];
		List<Order> orders = [SELECT Id FROM Order WHERE CreatedDate = TODAY];
		List<OrderItem> orderProducts = [SELECT Id FROM OrderItem WHERE CreatedDate = TODAY];

		// System.assertEquals(1, pricebooks.size());
		System.assertEquals(4, products.size());
		System.assertEquals(FunctionalTestData.NUMBER_OF_CUSTOMER_RECORDS, accounts.size());
		System.assertEquals(FunctionalTestData.NUMBER_OF_CUSTOMER_RECORDS, contacts.size());
		System.assertEquals(FunctionalTestData.NUMBER_OF_CUSTOMER_RECORDS, orders.size());
		System.assertEquals(FunctionalTestData.NUMBER_OF_CUSTOMER_RECORDS, orderProducts.size());
	}

	@isTest
	static void resetCoverage()
	{
		// Given:
		FunctionalTestData functionalTestData = new FunctionalTestData();

		// When:
		Test.startTest();
		Boolean exceptionFound = false;
		try {
			functionalTestData.reset();
		} catch (Exception resetException) 
		{
			exceptionFound = true;
			String exceptionMessage = resetException.getMessage() + 
				'\n' + resetException.getStackTraceString();
			System.debug(exceptionMessage);
		}
		Test.stopTest();

		// Then:
		System.assertEquals(false, exceptionFound,
			'Expected successful reset');
	}

	@isTest
	static void objectOfTypeExists()
	{
		// Given:
		insert new Account(Name = 'Pluralsight & LIFELONG LEARNING!');

		FunctionalTestData functionalTestData = new FunctionalTestData();
		
		// When:
		Test.startTest();
		Boolean objectExists = functionalTestData.objectOfTypeExists('Account');
		Test.stopTest();

		// Then:
		System.assertEquals(true, objectExists,
			'Expected some Accounts detected to exist in database');
	}

	@isTest
	static void samplePricebook()
	{
		// Given:
		FunctionalTestData functionalTestData = new FunctionalTestData();

		// When:
		Pricebook2 pricebook = functionalTestData.samplePricebook();

		// Then:
		System.assertNotEquals(null, pricebook, 
			'Expected sample pricebook population');
	}
}