// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// Check out the documentation on Apex change data capture event triggers:
// https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_subscribe_apex_triggers.htm

@isTest (isParallel = true)
public without sharing class RewardBalanceChangeEvents_Test
{
	@isTest
	static void basic()
	{
		// Given:
		Test.enableChangeDataCapture(); // Required for simulating Eventbus

		// When:
		Reward_Balance__c rewardBalance = new Reward_Balance__c();
		insert rewardBalance;

		System.debug('DML statements from within test: ' + 
			Limits.getDmlStatements());

		System.assertEquals(0, RewardBalanceChangeEvents.CHANGE_COUNT,
			'Expected 0 change yielded from RewardBalanceChangeEvents');

		// Allows the simulated delivery of events from the event bus
		Test.getEventBus().deliver();

		// Then:
		System.assertEquals(1, RewardBalanceChangeEvents.CHANGE_COUNT,
			'Expected 1 change yielded from RewardBalanceChangeEvents');
	}

	@isTest
	static void basicBulk()
	{
		// Given:
		Test.enableChangeDataCapture();
		Integer numberOfRewardBalances = 200;
		List<Reward_Balance__c> rewardBalances = new List<Reward_Balance__c>();
		for (Integer i = 0, j = numberOfRewardBalances; i < j; i++)
			rewardBalances.add(new Reward_Balance__c());

		// When:
		insert rewardBalances;

		System.assertEquals(0, RewardBalanceChangeEvents.CHANGE_COUNT,
			'Expected 0 on the change count');

		Test.getEventBus().deliver();

		// Then:
		System.assertEquals(numberOfRewardBalances, RewardBalanceChangeEvents.CHANGE_COUNT,
			'Expected ' + numberOfRewardBalances + 'on the change count');
	}
}