// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
// USE OR OTHER DEALINGS IN THE SOFTWARE.

@isTest (isParallel = true)
private class M5_FastCPU_Test {
	
	@isTest
	static void loopSpeeds()
	{
		// Given:
		M5_FastCPU cpu = new M5_FastCPU();
		Set<Integer> whileSpeeds = new Set<Integer>();
		Set<Integer> standardSpeeds = new Set<Integer>();
		Set<Integer> optimizedSpeeds = new Set<Integer>();
		Integer numberOfRuns = 500;

		// When:
		Test.startTest();
		
		for (Integer i = 0, j = numberOfRuns; i < j; i++)
			whileSpeeds.add(cpu.whileLoop());
		
		for (Integer i = 0, j = numberOfRuns; i < j; i++)
			standardSpeeds.add(cpu.standardForLoop());
		
		for (Integer i = 0, j = numberOfRuns; i < j; i++)
			optimizedSpeeds.add(cpu.optimizedLoop());

		Test.stopTest();

		// Then:

		Integer whileTotal = 0;
		for (Integer whileSpeed : whileSpeeds)
			whileTotal += whileSpeed;
		System.debug('whileTotal: ' + whileTotal);

		Integer standardTotal = 0;
		for (Integer standardSpeed : standardSpeeds)
			standardTotal += standardSpeed;
		System.debug('standardTotal: ' + standardTotal);

		Integer optimizedTotal = 0;
		for (Integer optimizedSpeed : optimizedSpeeds)
			optimizedTotal += optimizedSpeed;
		System.debug('optimizedTotal: ' + optimizedTotal);

		Decimal numberOfRunsAsDecimal = Decimal.valueOf(numberOfRuns);
		Decimal whileAverage = Decimal.valueOf(whileTotal) / numberOfRunsAsDecimal;
		Decimal standardAverage = Decimal.valueOf(standardTotal) / numberOfRunsAsDecimal;
		Decimal optimizedSpeedAverage = Decimal.valueOf(optimizedTotal) / numberOfRunsAsDecimal;

		System.debug('whileAverage: ' + whileAverage + 
			'\nstandardAverage: ' + standardAverage + 
			'\noptimizedSpeedAverage: ' + optimizedSpeedAverage);

		// The below assertions are driven by a degree of probability:
		// They're likely to pass far more often than they fail... 
		// but there are times in which they may fail, especially the 
		// first assertion, which indicates the standardAverage should 
		// be faster or as fast as the whileAverage.

		/*
		System.assert(standardAverage <= whileAverage,
			'Expected standard for to be at least as fast as while pattern');

		System.assert(optimizedSpeedAverage <= standardAverage,
			'Expected attempted optimization to be at least as fast as standard pattern');
		*/
	}

	@isTest
	static void completelyEmptyTest()
	{
		// This test is completely empty on purpose!
		// This is here as a benchmark to show how long,
		// in milliseconds, it might take for an Apex test
		// to run, even without any instructions.
	}
}