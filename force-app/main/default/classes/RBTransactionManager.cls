// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class RBTransactionManager
{
	public Integer triggerSize = 0;
	public Integer oldTriggerSize = 0;
	
	public List<Reward_Balance__c> rewardBalancesToUpdate = new List<Reward_Balance__c>();

	public List<Reward_Balance__c> rewardBalances
	{
		get
		{
			if (rewardBalances == null)
				rewardBalances = [
						SELECT Id, Current_Balance__c 
						FROM Reward_Balance__c 
						WHERE Id IN :rewardBalanceIdToBalance.keySet()
						];
			return rewardBalances;
		}
		set;
	}

	public Map<Id, Reward_Balance__c> rewardBalanceIdToBalance = new Map<Id, Reward_Balance__c>();
	
	public RBTransactionManager(){}

	public void initializeRewardBalanceMapping(List<Reward_Balance_Transaction__c> rbTransactions)
	{
		Integer rbTransactionsSize = rbTransactions.size();
		for (Integer i = 0, j = rbTransactionsSize; i < j; i++)
			rewardBalanceIdToBalance.put(rbTransactions[i].Id, null);

		Integer rewardBalancesSize = rewardBalances.size();
		for (Integer i = 0, j = rewardBalancesSize; i < j; i++)
			rewardBalanceIdToBalance.put(rewardBalances[i].Id, rewardBalances[i]);
	}
	
	public void updateRewardBalance(Reward_Balance_Transaction__c rbTransaction)
	{
		if (rewardBalanceIdToBalance.containsKey(rbTransaction.Reward_Balance__c))
		{
			Decimal currentBalance = rewardBalanceIdToBalance.get(rbTransaction.Reward_Balance__c)?.Current_Balance__c;
			if (currentBalance != null)
			{
				Decimal newBalance = currentBalance + rbTransaction.Reward_Points__c;
			
				rewardBalancesToUpdate.add(
					new Reward_Balance__c(
						Id = rbTransaction.Reward_Balance__c,
						Current_Balance__c = newBalance
					)
				);
			}
		}
	}

	public void updateBalances()
	{
		if (!this.rewardBalancesToUpdate.isEmpty())
			update this.rewardBalancesToUpdate;
	}

	public void preprocessBefore()
	{
		if (Trigger.isBefore)
			this.initializeRewardBalanceMapping((List<Reward_Balance_Transaction__c>) Trigger.new);
	}


	public void preprocessAfter(){}

	public void postprocessBefore()
	{
		this.updateBalances();
	}

	public void postprocessAfter(){}
	
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
			Reward_Balance_Transaction__c rbTransaction = (Reward_Balance_Transaction__c) Trigger.new[i];
			switch on Trigger.operationType
			{
				when BEFORE_INSERT, BEFORE_UPDATE
				{
					this.updateRewardBalance(rbTransaction);
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
		System.debug('RBTransaction (Reward Balance Transaction) trigger ran in ' + 
			totalCpuTime + ' milliseconds with context: ' + 
			(Trigger.isBefore ? 'before': 'after'));
	}
}