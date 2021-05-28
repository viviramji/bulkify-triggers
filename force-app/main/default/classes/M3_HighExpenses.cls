// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class M3_HighExpenses 
{
	public M3_HighExpenses(){}

	// This example is slightly different than the example shown
	// on the slide. The reason is to demonstrate, if needed, 
	// that the lowestOrder variable, which holds the lowest Order
	// decimal amount, can be returned in a map for testing.
	// This didn't really fit neatly onto the slide, so it was 
	// omitted during the explanation.
	public Map<Id, Decimal> lowestAmountTheBadWay(List<Account> accounts)
	{
		// Collect each account's related orders, find the lowest amount (The wrong way!)
		Map<Id, Decimal> accountIdToLowest = new Map<Id, Decimal>();
		for (Account account : accounts)
		{
			List<Order> orders = [SELECT Id, Amount__c, AccountId
				FROM Order
				WHERE AccountId = :account.Id];
			
			if (orders.isEmpty())
				continue;

			Decimal lowestOrder = null;
			for (Order order : orders)
			{
				if (lowestOrder == null)
					lowestOrder = order.Amount__c;

				if (order.Amount__c < lowestOrder)
					lowestOrder = order.Amount__c;

				if (lowestOrder != 0)
					accountIdToLowest.put(order.AccountId, lowestOrder);
			}
		}

		return accountIdToLowest;
	}

	public Map<Id, Decimal> lowestAmountTheRightWay(List<Account> accounts)
	{
		Set<Id> accountIds = new Set<Id>();
		for (Account account : accounts)
			accountIds.add(account.Id);

		List<Order> orders = [SELECT Id, Amount__c, AccountId
			FROM Order WHERE AccountId IN :accountIds];

		if (orders.isEmpty())
			return new Map<Id, Decimal>();

		Map<Id, Decimal> accountIdToLowest = new Map<Id, Decimal>();
		for (Order order : orders)
		{
			if (accountIdToLowest.containsKey(order.AccountId))
			{
				Decimal mappedAmount = accountIdToLowest.get(order.AccountId);
				if (order.Amount__c < mappedAmount)
					accountIdToLowest.put(order.AccountId, order.Amount__c);
			}
			else
			{
				accountIdToLowest.put(order.AccountId, order.Amount__c);
			}
		}

		return accountIdToLowest;
	}
}