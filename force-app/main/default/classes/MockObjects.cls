// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// WHAT'S THIS?
// The magic behind the ID generation in this class is accomplished
// by use of the Apex describe methods. This is out-of-the-box 
// functionality provided by Salesforce for things like ID pattern
// validation, or stubbing in tests.
// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_sobject_describe.htm
// 
// They key prefix is of particular importance because it is returned
// based on the SObjectType being described. So, the getKeyPrefix()
// method allows for returning a pattern that is relevant to say,
// the Account object, which has a different pattern than the Contact,
// or different than that of the Reward_Balance__c custom object, and 
// so on. For more information, see the getKeyPrefix() documentation:
// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_sobject_describe.htm#apex_Schema_DescribeSObjectResult_getKeyPrefix
public without sharing class MockObjects {
	
	public MockObjects(){}

	private static final String FAKE_ID_PATTERN = '000000000000';
	
	public class IDGenerator
    {
        public Integer idCount;

        Schema.SObjectType schemaType;

        public IDGenerator()
        {
            this.idCount = 0;
            this.schemaType = null;
        }

        public IDGenerator(Schema.SObjectType schemaType)
        {
            this.idCount = 0;
            this.schemaType = schemaType;
        }

        public Id generate()
        {
            String keyPrefix = schemaType.getDescribe().getKeyPrefix();
            idCount++;

            String fakeIDPrefix = FAKE_ID_PATTERN.substring(0, 12 - idCount.format().length());

            return Id.valueOf(keyPrefix + fakeIDPrefix + idCount);
        }
	}
}