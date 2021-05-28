// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// These concepts are based on 'Faster Apex Loops', originally started by
// Paul Battisson and then expanded by contributors Steven Herod, Andy Mahood,
// and Andrew Fawcett:
// https://gist.github.com/pbattisson/288f1d539211b32d84eb
public without sharing class M5_FastCPU 
{
	public List<Account> setupAccounts()
	{
		Integer numberOfAccounts = 200;
		Integer currentAccount = 0;
		List<Account> accounts = new List<Account>();
		while (currentAccount < numberOfAccounts)
		{
			accounts.add(new Account(Name = 'Test ' + currentAccount));
			currentAccount += 1;
		}
		return accounts;
	}

	public Integer whileLoop()
	{
		List<Account> accounts = setupAccounts();
		Integer startTime = Limits.getCpuTime();
		Integer accountCount = 0;
		Integer currentAccount = 0;
		while (currentAccount < accounts.size())
		{
			accountCount += 1;
			currentAccount += 1;
		}

		Integer endTime = Limits.getCpuTime();
		Integer totalTime = endTime - startTime;
		System.debug('while loop totalTime: ' + totalTime);
		return totalTime;
	}

	public Integer standardForLoop()
	{
		List<Account> accounts = setupAccounts();
		Integer startTime = Limits.getCpuTime();
		Integer accountCount = 0;
		// Calling accounts.size() here has a hidden cost,
		// as it has to be reinitialized each loop iteration
		for (Integer i = 0; i < accounts.size(); i++)
			accountCount += 1;
		
		Integer endTime = Limits.getCpuTime();
		Integer totalTime = endTime - startTime;
		System.debug('standard for totalTime: ' + totalTime);
		return totalTime;
	}
	
	public Integer optimizedLoop()
	{
		List<Account> accounts = setupAccounts();
		Integer startTime = Limits.getCpuTime();
		Integer accountCount = 0;
		Integer accountsSize = accounts.size(); // Initializing here and as "j" below saves time!
		for (Integer i = 0, j = accountsSize; i < j; i++)
			accountCount += 1;
		
		Integer endTime = Limits.getCpuTime();
		Integer totalTime = endTime - startTime;
		System.debug('optimized for totalTime: ' + totalTime);
		return totalTime;
	}
}