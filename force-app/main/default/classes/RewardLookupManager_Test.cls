// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class RewardLookupManager_Test 
{
	@isTest
	static void maxSizeExceedError()
	{
		// Given:
		RewardLookupManager manager = new RewardLookupManager();
		manager.triggerSize = StaticConfiguration.MAX_REWARD_LOOKUPS + 1;
		manager.rewardLookupCount = StaticConfiguration.MAX_REWARD_LOOKUPS;

		// When:
		Boolean exceptionFound = false;
		try 
		{
			manager.preventExceedMaximum();
		} 
		catch (Exception maximumException) 
		{
			String errorMessage = maximumException.getMessage() + '\n' + maximumException.getStackTraceString();
			System.debug(errorMessage);
			exceptionFound = true;	
		}
		

		// When:
		System.assertEquals(true, exceptionFound, 
			'Expected exception upon exceeding maximum');
	}

	@isTest
	static void regularInsert()
	{
		// Given:
		Reward_Lookup__c rewardLookup = new Reward_Lookup__c();

		// When:
		Test.startTest();
		insert rewardLookup;
		Test.stopTest();

		// Then:
		System.assertNotEquals(null, rewardLookup.Id, 
			'Expected Id after insert');
	}
}