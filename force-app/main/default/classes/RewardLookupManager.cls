// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class RewardLookupManager 
{
	public Integer triggerSize = 0;
	public Integer oldTriggerSize = 0;
	
	public static final String MAX_EXCEEDED_MESSAGE = '';

	public Integer rewardLookupCount;

	public RewardLookupManager(){}

	public Integer queryRewardLookupCount()
	{
		return [SELECT count() FROM Reward_Lookup__c];
	}

	public void preventExceedMaximum()
	{
		if (this.rewardLookupCount == null)
			queryRewardLookupCount();
			
		if ( + this.triggerSize > StaticConfiguration.MAX_REWARD_LOOKUPS)
			throw new RewardLookupException(MAX_EXCEEDED_MESSAGE);
	}
	
	public void preprocessBefore()
	{
		if (Trigger.isBefore)
			this.preventExceedMaximum();
	}

	public void preprocessAfter()
	{
		if (Trigger.isAfter)
			return;		
	}
	
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
		this.postprocessBefore();
		this.postprocessAfter();

		Integer endTime = System.Limits.getCpuTime();
		Integer totalCpuTime = endTime - startTime;
		System.debug('Reward Lookup trigger ran in ' + totalCpuTime + 
			' milliseconds with context: ' + (Trigger.isBefore ? 'before': 'after'));
	}

	public class RewardLookupException extends Exception{}
}