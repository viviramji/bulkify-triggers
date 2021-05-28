// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class RewardBalanceChangeEvents
{
	public static Integer CHANGE_COUNT = 0;

	public RewardBalanceChangeEvents() {}

	public List<Reward_Balance__ChangeEvent> changes;

	public void run()
	{
		changes = Trigger.new;
		for (Reward_Balance__ChangeEvent change : changes)
			CHANGE_COUNT += 1;

		System.debug('DML statements from event trigger: ' + 
			Limits.getDmlStatements());
	}
}