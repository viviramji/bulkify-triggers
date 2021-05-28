// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class OrderManager 
{
	// Across the trigger logic, these variables are meant to
	// house how many records exist in the trigger, with the 
	// Trigger.new list reflected in triggerSize, and the 
	// Trigger.old list reflected in oldTriggerSize.
	public Integer triggerSize = 0;
	public Integer oldTriggerSize = 0;
	
	// If after calculation of a new reward balance amount falls below zero,
	// it means reward points have been applied inaccurately, and this error
	// message should be returned for the record.
	public String REWARD_BALANCE_BELOW_ZERO = 'This customer does not have enough reward points to apply to this order';
	
	// To determine what existing reward balances exist vs which
	// ones need to be created, the query returned results into this
	// list for any that it finds.
	public List<Reward_Balance__c> existingRewardBalances;

	// When there is not an existing Reward Balance record tied to the current customer,
	// then it may be necessary to create one, which is held in this list.
	public List<Reward_Balance__c> newRewardBalances = new List<Reward_Balance__c>();

	// When a Reward Balance record for the customer associated with the order already
	// exists, then it is necessary to create a new Reward Balance Transaction that is 
	// tied to the customer's Reward Balance record, which doubles as an auditable
	// ledger of all reward balance changes based on customer purchases.
	public List<Reward_Balance_Transaction__c> rewardBalanceTransactions;

	// Precedes the construction of customerIdtoRewardBalance, receives the total of
	// newly applicable reward additions or deductions based on the Order Product (OrderItem)
	// records associated with the given Order.
	public Map<Id, Decimal> orderIdToRewardPoints;

	// Map for pointing to a current reward balance from a given customer
	// for when it is required to update the Reward Balance record associated
	// with the customer... this map allows reference back to the balance so 
	// a new balance can be put back into the same map, then updated as a part
	// of the activity in the collections above.
	public Map<Id, Reward_Balance__c> customerIdtoRewardBalance;

	// Required for determining reward point calculations,
	// or adding reward points based on which products 
	// are added to a completed Order.
	public List<Reward_Lookup__c> rewardLookups; // How many reward points applied for each product?
	public List<OrderItem> orderProducts; // Also known as: the order line items

	public Set<Id> orderIds;

	public OrderManager()
	{
		this.rewardBalanceTransactions = new List<Reward_Balance_Transaction__c>();
		this.customerIdtoRewardBalance = new Map<Id, Reward_Balance__c>();
		this.existingRewardBalances = new List<Reward_Balance__c>();
	}

	// This only works by having a hard cap on Reward Lookup records, which should never
	// exceed its configured maximum. Otherwise, the lack of a WHERE clause means that 
	// there is some risk of lacking query selectivity here.
	// 
	// Documentation from Salesforce on query selectivity:
	// https://help.salesforce.com/articleView?id=000325257&type=1&mode=1
	public List<Reward_Lookup__c> getRewardLookups()
	{
		return [SELECT Id, Reward_Points__c, Product__c 
			FROM Reward_Lookup__c
			LIMIT :StaticConfiguration.MAX_REWARD_LOOKUPS];
	}

	public List<OrderItem> getOrderProducts(Set<Id> orderIds)
	{
		return [SELECT Id, Product2Id, OrderId 
			FROM OrderItem 
			WHERE OrderId IN :orderIds];
	}

	public List<Reward_Balance__c> getRewardBalances(Set<Id> customerContactIds)
	{
		return [SELECT Id, Name, Current_Balance__c, Customer_Contact__c 
			FROM Reward_Balance__c 
			WHERE Customer_Contact__c IN :customerContactIds];
	}

	public List<Reward_Balance_Transaction__c> getRewardBalanceTransactions(Set<Id> rewardBalanceTransactionIds)
	{
		return [SELECT Id, Name, Reward_Balance__c, Reward_Points__c 
			FROM Reward_Balance_Transaction__c 
			WHERE Reward_Balance__c IN :rewardBalanceTransactionIds];
	}

	public void manageRelatedCollections(List<Order> orders)
	{
		Set<Id> customerContactIds = new Set<Id>();
		orderIds = new Set<Id>();
		Integer ordersSize = orders.size();
		for (Integer i = 0, j = ordersSize; i < j; i++)
		{
			Order order = orders[i];
			orderIds.add(order.Id);
			Id customerContactId = order.BillToContactId;
			customerContactIds.add(customerContactId);
		}
		System.debug('customerContactIds.size(): ' + customerContactIds.size());

		if (this.existingRewardBalances.isEmpty())
			this.existingRewardBalances = this.getRewardBalances(customerContactIds);

		Integer rewardBalancesSize = this.existingRewardBalances.size();
		for (Integer i = 0, j = rewardBalancesSize; i < j; i++)
		{
			Reward_Balance__c rewardBalance = this.existingRewardBalances[i];
			this.customerIdToRewardBalance.put(rewardBalance.Customer_Contact__c, rewardBalance);
		}
		System.debug('customerIdToRewardBalance.keySet().size(): ' + 
			this.customerIdtoRewardBalance.keySet().size());
	}

	public void checkReward(Order order)
	{
		if (this.orderIdToRewardPoints.containsKey(order.Id))
			updateRewardBalance(orderIdToRewardPoints.get(order.Id), order.BillToContactId, order);
	}

	// Unoptimized - this solution has 4 different nested loops!
	// Without the ability to directly reference pairs via maps,
	// this requires a scan through multiple related objects to 
	// reach a conclusion regarding reward point balances.
	/*
	public void updateRewardBalance(List<OrderItem> orderProducts, 
		List<Reward_Balance__c> rewardBalances,
		List<Reward_Lookup__c> rewardLookups,
		List<Order> orders)
	{
		Integer startTime = System.Limits.getCpuTime();

		for (Order order : orders)
		{
			for (Reward_Lookup__c rewardLookup : rewardLookups)
			{
				for (OrderItem orderProduct : orderProducts)
				{
					for (Reward_Balance__c rewardBalance : rewardBalances) 
					{
						if (rewardBalance.Customer_Contact__c == order.BillToContactId
							&& orderProduct.Product2Id == rewardLookup.Product__c)
						{
							this.rewardBalanceTransactions.add(
								new Reward_Balance_Transaction__c(
									Reward_Balance__c = rewardBalance.Id,
									Reward_Points__c = rewardLookup.Reward_Points__c
								)
							);
						}
					}
				}
			}
		}

		Integer endTime = System.Limits.getCpuTime();

		Integer duration = endTime - startTime;
		System.debug('updateRewardBalance CPU time wrong way: ' + duration);			
	}
	*/

	// Optimized - this is a solution closer to the ideal
	// in alignment with the basics of bulkification
	public void updateRewardBalance(Decimal rewardPoints, Id customerContactId, Order order)
	{
		Reward_Balance__c rewardBalance = this.customerIdToRewardBalance.containsKey(customerContactId) ? 
			this.customerIdToRewardBalance.get(customerContactId) :
			new Reward_Balance__c(Current_Balance__c = 0, Customer_Contact__c = customerContactId);

		rewardBalance.Current_Balance__c += rewardPoints;

		if (rewardBalance.Current_Balance__c < 0.0)
			order.addError(this.REWARD_BALANCE_BELOW_ZERO);
		
		if (rewardBalance.Id == null)
		{
			newRewardBalances.add(rewardBalance);
			return;
		}
	
		this.rewardBalanceTransactions.add(
			new Reward_Balance_Transaction__c(
				Reward_Points__c = rewardPoints,
				Reward_Balance__c = rewardBalance.Id
			)
		);
	}

	public Map<Id, Decimal> manageRewardLookup()
	{
		if (orderIds.isEmpty())
			return new Map<Id, Decimal>();

		if (rewardLookups == null)
			rewardLookups = this.getRewardLookups();

		Integer rewardLookupsSize = rewardLookups.size();
		Map<Id, Decimal> productIdToRewardPoints = new Map<Id, Decimal>();
		for (Integer i = 0, j = rewardLookupsSize; i < j; i++)
			productIdToRewardPoints.put(rewardLookups[i].Product__c, rewardLookups[i].Reward_Points__c);
		System.debug('productIdToRewardPoints.keySet().size(): ' + 
			productIdToRewardPoints.keySet().size());

		if (orderProducts == null)
			orderProducts = this.getOrderProducts(orderIds);

		this.orderIdToRewardPoints = new Map<Id, Decimal>();
		Integer orderProductsSize = orderProducts.size();
		for (Integer i = 0, j = orderProductsSize; i < j; i++)
		{
			String orderId = orderProducts[i].OrderId;
			String productId = orderProducts[i].Product2Id;

			if (this.orderIdToRewardPoints.containsKey(orderId))
			{
				Decimal rewardPointsToAdd = productIdToRewardPoints.get(productId);
				Decimal rewardPoints = orderIdToRewardPoints.get(orderId);
				Decimal newTotal = rewardPointsToAdd + rewardPoints;
				this.orderIdToRewardPoints.put(orderId, newTotal);
			}
			else
			{
				this.orderIdToRewardPoints.put(orderId, productIdToRewardPoints.get(productId));
			}
		}
		System.debug('orderIdToRewardPoints.keySet().size: ' + 
			this.orderIdToRewardPoints.keySet().size());
			
		return this.orderIdToRewardPoints;
	}

	public Order setDefaultFields(Order order)
	{
		// The only other field aside from these two that 
		// is required is the AccountId field, which cannot
		// have an Id assigned in the before context because
		// that would require inserting an Account immediately, 
		// which would not be good for limits. Instead, just 
		// allow the transaction to fail here with the required
		// field error that naturally generates on the Order
		// as a standard object.

		if (order.Status == null)
			order.Status = 'Draft';

		if (order.EffectiveDate == null)
			order.EffectiveDate = Date.today();

		return order;
	}

	public void insertNewRewardBalances()
	{
		if (!this.newRewardBalances.isEmpty())
			insert newRewardBalances;
	}

	public void insertRewardBalanceTransactions()
	{
		if (!this.rewardBalanceTransactions.isEmpty())
			insert rewardBalanceTransactions;
	}

	public void preprocessBefore()
	{
		if (Trigger.isBefore)
		{
			this.manageRelatedCollections((List<Order>) Trigger.new);
			this.manageRewardLookup();
		}
	}

	public void preprocessAfter()
	{
		if (Trigger.isAfter)
		{
			this.insertNewRewardBalances();
			this.insertRewardBalanceTransactions();
		}
	}

	// Remove the return statement for the 
	public void postprocessBefore()
	{
		if (Trigger.isBefore)
			return;
	}

	public void postprocessAfter()
	{
		if (Trigger.isAfter)
			return;
	}

	public void setTriggerSize()
	{
		if (!(Trigger.new == null))
			this.triggerSize = Trigger.new.size();

		if (!(Trigger.old == null))
			this.oldTriggerSize = Trigger.old.size();
	}
	
	public void run()
	{
		Integer startTime = System.Limits.getCpuTime();

		this.setTriggerSize();
		this.preprocessBefore();
		this.preprocessAfter();

		Integer operationSize = this.triggerSize == 0 ? this.oldTriggerSize : this.triggerSize;
		for (Integer i = 0, j = operationSize; i < j; i++)
		{
			Order order = this.triggerSize == 0 ? null : (Order) Trigger.new[i];
			Order oldOrder = this.oldTriggerSize == 0 ? null : (Order) Trigger.old[i];

			switch on Trigger.operationType
			{
				when BEFORE_INSERT, BEFORE_UPDATE
				{
					order = this.setDefaultFields(order);
					this.checkReward(order);
				}
				when BEFORE_DELETE
				{

				}
				when AFTER_INSERT, AFTER_UPDATE
				{

				}
				when AFTER_DELETE
				{

				}
			}
		}

		this.postprocessBefore();
		this.postprocessAfter();

		Integer endTime = System.Limits.getCpuTime();
		Integer totalCpuTime = endTime - startTime;
		System.debug('Order trigger ran in ' + totalCpuTime + 
			' milliseconds with context: ' + (Trigger.isBefore ? 'before': 'after'));
	}

	public class OrderException extends Exception{}
}