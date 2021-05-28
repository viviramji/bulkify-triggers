// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

public without sharing class M5_HeapExample 
{
	public List<Object> heapReductionExample()
	{
		Integer startingHeapSize = Limits.getHeapSize();
		System.debug('startingHeapSize: ' + startingHeapSize);

		// To increase heap size, put some data into a list
		List<Integer> someNumbers = new List<Integer>{5, 15, 23, 1, 7, 84, 29, 87, 24, 12};
	
		Integer heapSizeWithIntegers = Limits.getHeapSize();
		System.debug('heapSizeWithIntegers: ' + heapSizeWithIntegers);

		// Clear List (but this still keeps the list initialized as 
		// an object - there's no fully getting rid of it)
		someNumbers = null;

		Integer heapSizeAfterNull = Limits.getHeapSize();
		System.debug('heapSizeAfterNull: ' + heapSizeAfterNull);

		return new List<Object>{startingHeapSize, 
			heapSizeWithIntegers, 
			heapSizeAfterNull};
	}
}