// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// This class can perform a count and grand total between two dates.
// By default, you feed in a query date to start with and it will run
// in a chained fashion until it reaches the current date (or today's date).
// For a specific date range, the stopDate refers to a date to stop aggregating
// if not wanting the job to go past that point for its totals.
// 
// Here is an example that can be run from Execute Anonymous:

/*
// Aggregate the past 60 days
Date today = Date.today();
Date sixtyDaysAgo = today - 60;
System.enqueueJob(new OrderAggregator(sixtyDaysAgo));

// Aggregate the totals between 30 and 14 days ago.
Date today = Date.today();
Date thirtyDaysAgo = today - 30;
Date fourteenDaysAgo = today - 14;
OrderAggregator aggregator = new OrderAggregator(thirtyDaysAgo);
aggregator.stopDate = fourteenDaysAgo;

// Provide this configured instance, aggregator, to the 
// system queue
System.enqueueJob(aggregator);
*/

// NOTE: The above examples may result in stack depth exceeded errors in 
// Developer Edition orgs, which do not appear to reliably allow chaining 
// this job more than about 5 times.

public without sharing class OrderAggregator implements Queueable
{
	public Date stopDate;	
	public Decimal grandTotal;
	public Date queryDate;
	public Decimal grandCount;
	public List<Order> orders;

	public Boolean SINGLE_DATE_ONLY = false;
	
	public OrderAggregator(Date queryDate)
	{
		this.queryDate = queryDate;
		this.grandTotal = 0.0;
		this.grandCount = 0.0;
		this.orders = new List<Order>();
	}

	public void execute(QueueableContext context)
	{
		this.run();
	}

	public void run()
	{
		System.debug('this.grandTotal: ' + this.grandTotal + 
			'\nthis.grandCount: ' + this.grandCount);

		if (this.orders.isEmpty())
			this.orders = this.ordersForDate();

		Integer ordersSize = this.orders.size();
		this.grandCount += ordersSize;

		for (Integer i = 0, j = ordersSize; i < j; i++)
			if (this.orders[i].TotalAmount != null)
				this.grandTotal += this.orders[i].TotalAmount;

		if (this.stopDate == null)
			this.stopDate = Date.today();

		if (this.queryDate != this.stopDate && !this.SINGLE_DATE_ONLY)
		{
			this.orders.clear(); // Must be reset for next queryDate
			this.queryDate = queryDate + 1;
			System.enqueueJob(this);
		}
		else
			System.debug('Order average: ' + this.average(this.grandTotal, this.grandCount) + 
				' from total records: ' + this.grandCount);
	}

	public Decimal average(Decimal total, Decimal count)
	{
		if (count > 0) // Avoids division by zero
			return total / count;
		else
			return 0;
	}

	public List<Order> ordersForDate()
	{
		return [SELECT Id, CreatedDate, TotalAmount 
			FROM Order 
			WHERE CreatedDate = :queryDate];
	}
}