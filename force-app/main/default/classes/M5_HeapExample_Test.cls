// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class M5_HeapExample_Test 
{
	@isTest
	static void heapExampleTest()
	{
		// Given:
		M5_HeapExample heapExample = new M5_HeapExample();

		// When:
		List<Object> results = heapExample.heapReductionExample();

		// Then:
		Integer startingHeapSize = (Integer) results[0];
		Integer heapSizeWithNumbers = (Integer) results[1];
		Integer heapSizeAfterNull = (Integer) results[2];

		System.assert(startingHeapSize < heapSizeAfterNull,
			'Received unexpected heap size');

		System.assert(heapSizeWithNumbers > startingHeapSize,
			'Heap size with numbers should have resulted in larger heap');

		System.assert(heapSizeAfterNull > startingHeapSize,
			'Expected heap size after null to be larger than starting heap');

		System.assert(heapSizeAfterNull < heapSizeWithNumbers,
			'Expected smaller heap after clearing list');
	}
}