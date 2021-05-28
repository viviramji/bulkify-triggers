// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class M3_BulkBasics 
{
	public M3_BulkBasics(){}
	
	// Slide: 'Using Maps In Apex'
	public Map<Id, Opportunity> usingMaps()
	{
		// Here is an example list of Opportunity records...
		List<Opportunity> opportunities = new List<Opportunity>
		{
			new Opportunity(Name = 'Truckloads of Coffee',
				Amount = 15000.00,
				StageName = 'Prospecting'
				)
		};
		System.debug('opportunities.size(): ' + opportunities.size());

		// Map an Opportunity record based on its Id
		Map<Id, Opportunity> opportunityIdToOpportunity = new Map<Id, Opportunity>();
		for (Opportunity opportunity : opportunities)
			opportunityIdToOpportunity.put(opportunity.Id, opportunity);

		System.debug('opportunityIdToOpportunity.keySet().size(): ' + 
			opportunityIdToOpportunity.keySet().size());

		return opportunityIdToOpportunity;
	}

	// Slide: 'Wrong Way to SOQL'
	public Map<Date, List<Account>> wrongWaytoAvoidSOQL()
	{
		// Do not put SOQL queries inside of loops!
		// here is a bad way to get 30 days of Accounts, broken apart by day
		Map<Date, List<Account>> createdDateToAccounts = new Map<Date, List<Account>>();
		Integer numberOfDaysBack = 30;
		Date dateToGet = Date.today() - numberOfDaysBack;
		for (Integer i = 0; i < numberOfDaysBack; i++)
		{
			createdDateToAccounts.put(dateToGet, 
				[SELECT Id, CreatedDate 
				FROM Account 
				WHERE CreatedDate = :dateToGet]);
			dateToGet += 1;
		}

		return createdDateToAccounts;
	}

	// Slide: 'Avoiding Too Many SOQL Queries'
	public Map<Date, List<Account>> betterWayToUseSOQL()
	{
		// Optional: Uncomment and run the method with
		// this line in order insert an Account if none
		// exist in the org currently. 
		// insert new Account(Name = 'Test Account');

		// Here is a better way...
		Integer numberOfDaysBack = 30;
		Date startDate = Date.today() - numberOfDaysBack;
		List<Account> accounts = [SELECT Id, CreatedDate
			FROM Account WHERE CreatedDate >= :startDate
				AND CreatedDate < TODAY];
		System.debug('accounts.size(): ' + accounts.size());

		// This code block is not in the slide but is worth using
		// in the event you run this code and you've not created at 
		// least one Account to be retrieved from the query above.
		Map<Date, List<Account>> dateToListOfAccounts = new Map<Date, List<Account>>();
		if (accounts.isEmpty())
			return dateToListOfAccounts;

		for (Account account : accounts)
		{
			Date createdDate = account.CreatedDate.date();
			if (dateToListOfAccounts.containsKey(createdDate))
				dateToListOfAccounts.get(createdDate).add(account);
			else
				dateToListOfAccounts.put(createdDate, new List<Account>{account});
		}
		System.debug('dateToListOfAccounts.keySet().size(): ' + 
			dateToListOfAccounts.keySet().size());

		return dateToListOfAccounts;
	}
}