// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class RBTransactionManager_Test 
{
	public RBTransactionManager_Test(){}

	@isTest
	static void readyUpdateBalances()
	{
		// Given:
		RBTransactionManager manager = new RBTransactionManager();

		Id rewardBalanceId = new MockObjects.IDGenerator(Reward_Balance__c.SObjectType).generate();
		
		Reward_Balance__c rewardBalance = new Reward_Balance__c(
			Id = rewardBalanceId,
			Current_Balance__c = 15
		);
		
		Reward_Balance_Transaction__c rbTransaction = new Reward_Balance_Transaction__c(
			Reward_Balance__c = rewardBalanceId,
			Reward_Points__c = 25
		);
		
		// When:
		manager.rewardBalanceIdToBalance.put(rewardBalanceId, rewardBalance);
		manager.updateRewardBalance(rbTransaction);

		// Then:
		System.assertEquals(1, manager.rewardBalancesToUpdate.size(),
			'Expected population of rewardBalancesToUpdate');
	}

}