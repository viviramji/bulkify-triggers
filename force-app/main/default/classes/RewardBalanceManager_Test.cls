// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class RewardBalanceManager_Test 
{
	public RewardBalanceManager_Test(){}

	@isTest
	static void addTransactions()
	{
		// Given: 
		RewardBalanceManager manager = new RewardBalanceManager();

		Id rewardBalanceId = new MockObjects.IDGenerator(Reward_Balance__c.SObjectType).generate();
		Reward_Balance__c rewardBalance = new Reward_Balance__c(
			Id = rewardBalanceId,
			Current_Balance__c = 100
		);

		System.assertEquals(0, manager.transactionsToInsert.size(),
			'Expected zero transactions, nothing done yet!');

		// When:
		manager.addTransactionsToInsert(rewardBalance);

		// Then:
		System.assertEquals(1, manager.transactionsToInsert.size(),
			'Expected 1 transaction added');
	}

	@isTest
	static void mapRewardBalanceTransactions()
	{
		// Given:
		RewardBalanceManager manager = new RewardBalanceManager();

		Reward_Balance__c rewardBalance = new Reward_Balance__c(
			Current_Balance__c = 10
		);

		List<Reward_Balance__c> rewardBalances = new List<Reward_Balance__c>
		{
			rewardBalance
		};
		insert rewardBalances;

		List<Reward_Balance_Transaction__c> existingTransactions = [
			SELECT Id, Reward_Balance__c 
			FROM Reward_Balance_Transaction__c 
			WHERE Reward_Balance__c = :rewardBalance.Id];

		System.assertEquals(1, existingTransactions.size(),
			'Expected an existing Reward Balance Transaction following insert');

		// When:
		manager.mapRewardBalanceTransactions(rewardBalances);

		// Then:
		Integer rewardBalanceTransactionCount = manager.rewardBalanceToTransactionCount.get(rewardBalance.Id);
		System.assertEquals(1, rewardBalanceTransactionCount,
			'Expected a count of 1 for test Reward Balance');
	}

	@isTest
	static void regularDelete()
	{
		// Given:
		RewardBalanceManager manager = new RewardBalanceManager();

		Reward_Balance__c rewardBalance = new Reward_Balance__c();
		insert rewardBalance;

		System.assertNotEquals(null, rewardBalance.Id, 
			'Expected Reward Balance Id after insert');

		// When:
		Test.startTest();
		Boolean exceptionThrown = false;
		try {
			delete rewardBalance;
		} catch (Exception deleteException) 
		{
			String exceptionMessage = deleteException.getMessage() + '\n' + deleteException.getStackTraceString();
			System.debug(exceptionMessage);
		}
		Test.stopTest();

		// Then:
		System.assertEquals(false, exceptionThrown,
			'No exception should be thrown upon simple delete');

		List<Reward_Balance__c> rewardBalances = [SELECT Id FROM Reward_Balance__c];
		System.assertEquals(0, rewardBalances.size(),
			'No Reward Balance records expected after delete');
	}
}