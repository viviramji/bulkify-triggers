// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class M5_ReducingSOQL 
{
	// The singleton ensures that an object can
	// only ever return a single instance, and 
	// is never re-initialized unintentionally.
	public String exampleSingleton;
	public String getExampleString()
	{
		if (exampleSingleton == null)
			exampleSingleton = 'Example';
		return exampleSingleton;
	}

	public List<Account> rawCollection
	{ get { return getRawAccounts(); } set; }

	public List<Account> managedCollection
	{
		get
		{
			if (managedCollection == null)
				managedCollection = getRawAccounts();
			return managedCollection;
		}
		set;
	}

	public List<Account> getRawAccounts()
	{ return [SELECT Id FROM Account]; }

	public Integer rawSOQLCalls()
	{
		// Results in 3 queries
		System.debug('rawCollection.size(): ' + rawCollection.size());
		System.debug('rawCollection.size(): ' + rawCollection.size());
		System.debug('rawCollection.size(): ' + rawCollection.size());
		Integer queries = Limits.getQueries();
		System.debug('Queries: ' + queries);
		return queries;
	}

	public Integer managedSOQLCalls()
	{
		// Results in 1 query
		System.debug('managedCollection.size(): ' + managedCollection.size());
		System.debug('managedCollection.size(): ' + managedCollection.size());
		System.debug('managedCollection.size(): ' + managedCollection.size());
		Integer queries = Limits.getQueries();
		System.debug('Queries: ' + queries);
		return queries;
	}
}