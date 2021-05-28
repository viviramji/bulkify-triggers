// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class M5_ReducingSOQL_Test {

	@isTest
	static void rawSOQL()
	{
		System.assertEquals(3, new M5_ReducingSOQL().rawSOQLCalls());
	}

	@isTest
	static void managedSOQL()
	{
		System.assertEquals(1, new M5_ReducingSOQL().managedSOQLCalls());
	}

	@isTest
	static void exampleString()
	{
		System.assertEquals('Example', new M5_ReducingSOQL().getExampleString());
	}
}