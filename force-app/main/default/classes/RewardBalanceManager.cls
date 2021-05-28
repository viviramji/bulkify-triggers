// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class RewardBalanceManager 
{
	public Integer triggerSize = 0;
	public Integer oldTriggerSize = 0;
	
	public List<Reward_Balance_Transaction__c> rewardBalanceTransactions;
	public List<Reward_Balance_Transaction__c> transactionsToInsert;
	public Map<Id, Integer> rewardBalanceToTransactionCount;

	public RewardBalanceManager()
	{
		this.rewardBalanceTransactions = new List<Reward_Balance_Transaction__c>();
		this.rewardBalanceToTransactionCount = new Map<Id, Integer>();
		this.transactionsToInsert = new List<Reward_Balance_Transaction__c>();
	}

	public List<Reward_Balance_Transaction__c> getTransactions(Set<Id> rewardBalanceIds)
	{
		return [SELECT Id, Name, Reward_Balance__c 
			FROM Reward_Balance_Transaction__c
			WHERE Reward_Balance__c IN :rewardBalanceIds];
	}

	public Set<Id> collectRewardBalanceIds(List<Reward_Balance__c> rewardBalances)
	{
		Set<Id> rewardBalanceIds = new Set<Id>();
		if (rewardBalances == null)
			return rewardBalanceIds;

		if (!rewardBalances.isEmpty())
		{
			Integer rewardBalancesSize = rewardBalances.size();
			for (Integer i = 0, j = rewardBalancesSize; i < j; i++)
				rewardBalanceIds.add(rewardBalances[i].Id);
		}
		System.debug('rewardBalances.size(): ' + rewardBalances.size());

		return rewardBalanceIds;
	}

	// Only meant to execute on a new record when no transactions exist yet.
	// Otherwise, the way the Reward Balance gets updated is always done through
	// Transactions going forward, which result in an update to the balance.
	// This is better for program flow, as otherwise you could get into an ugly
	// recursive looping situation.
	public void addTransactionsToInsert(Reward_Balance__c rewardBalance)
	{
		Id rewardBalanceId = rewardBalance.Id;

		if (!this.rewardBalanceToTransactionCount.containsKey(rewardBalanceId)
			&& rewardBalance.Current_Balance__c > 0)
			this.transactionsToInsert.add(
				new Reward_Balance_Transaction__c(
					Reward_Balance__c = rewardBalanceId,
					Reward_Points__c = rewardBalance.Current_Balance__c
				)
			);
		System.debug('transactionsToInsert.size(): ' + this.transactionsToInsert.size());
	}

	public Map<Id, Integer> mapRewardBalanceTransactions(List<Reward_Balance__c> rewardBalances)
	{
		if (this.rewardBalanceToTransactionCount.keySet().size() > 0)
			return this.rewardBalanceToTransactionCount;

		List<Reward_Balance_Transaction__c> rewardBalanceTransactions = this.getTransactions(
			collectRewardBalanceIds(rewardBalances));
			
		this.rewardBalanceToTransactionCount = new Map<Id, Integer>();
		Integer transactionsSize = rewardBalanceTransactions.size();
		for (Integer i = 0, j = transactionsSize; i < j; i++)
		{
			Reward_Balance_Transaction__c rbTransaction = rewardBalanceTransactions[i];
			Id rewardBalanceId = rbTransaction.Reward_Balance__c;
			
			if (rewardBalanceToTransactionCount.containsKey(rewardBalanceId))
			{
				Integer currentCount = rewardBalanceToTransactionCount.get(rewardBalanceId);
				currentCount += 1;
				rewardBalanceToTransactionCount.put(rewardBalanceId, currentCount);
			}
			else 
			{
				rewardBalanceToTransactionCount.put(rewardBalanceId, 1);	
			}
		}
		System.debug('rewardBalanceToTransactionCount.keySet().size(): ' + 
			rewardBalanceToTransactionCount.keySet().size());

		return rewardBalanceToTransactionCount;
	}

	public void insertNewTransactions()
	{
		if (!this.transactionsToInsert.isEmpty())
			insert this.transactionsToInsert;
	}
	
	public void preprocessBefore()
	{
		if (Trigger.isBefore)
			return; // This can be removed if adding logic to before
	}

	public void preprocessAfter()
	{
		if (Trigger.isAfter)
			this.mapRewardBalanceTransactions((List<Reward_Balance__c>) Trigger.new);			
	}
	
	public void postprocessBefore()
	{
		if (Trigger.isBefore)
			this.insertNewTransactions();
	}

	public void postprocessAfter()
	{
		if (Trigger.isAfter)
			this.insertNewTransactions();
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

		for (Integer i = 0, j = triggerSize; i < j; i++)
		{
			Reward_Balance__c rewardBalance = (Reward_Balance__c) Trigger.new[i];

			switch on Trigger.operationType
			{
				when BEFORE_INSERT, BEFORE_UPDATE
				{
					
				}
				when BEFORE_DELETE
				{

				}
				when AFTER_INSERT, AFTER_UPDATE
				{
					this.addTransactionsToInsert(rewardBalance);
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
		System.debug('Reward Balance trigger ran in ' + totalCpuTime + 
			' milliseconds with context: ' + (Trigger.isBefore ? 'before': 'after'));
	}
}