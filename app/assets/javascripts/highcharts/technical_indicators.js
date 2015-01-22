(function (H) {

	// create shortcuts
	var defaultOptions = H.getOptions(),
		defaultPlotOptions = defaultOptions.plotOptions,
		seriesTypes = H.seriesTypes;

	// Trendline functionality and default options.
	defaultPlotOptions.trendline = H.merge(defaultPlotOptions.line, {

		marker: {
			enabled: false
		},

		tooltip: {
			valueDecimals: 2
		}
	});

	seriesTypes.trendline = H.extendClass(seriesTypes.line, {
		
		type: 'trendline',
		animate: null,
		requiresSorting: false,
		processData: function() {
			var data;

			if (this.linkedParent) {
				data = [].concat(this.linkedParent.options.data)
				this.setData(this.runAlgorithm(), false);
			}

			H.Series.prototype.processData.call(this);
		},
		runAlgorithm: function () {

			var xData = this.linkedParent.xData,
				yData = this.linkedParent.yData,
				periods = this.options.periods || 100,		// Set this to what default? should be defaults for each algorithm.
				algorithm = this.options.algorithm || 'linear';

			return this[algorithm](xData, yData, periods);
		},


		/* Function that uses the calcMACD function to return the MACD line.
		 * 
		 * @return : the first index of the calcMACD return, the MACD.
		**/
		MACD: function (xData, yData, periods) {

			return calcMACD(xData, yData, periods)[0];
		},

		/* Function that uses the global calcMACD.
		 * 
		 * @return : the second index of the calcMACD return, the signalLine.
		**/
		signalLine: function (xData, yData, periods) {

			return calcMACD(xData, yData, periods)[1];
		},

		/* Function using the global SMA function.
		 * 
		 * @return : an array of SMA data.
		**/
		SMA: function (xData, yData, periods) {

			return SMA(xData, yData, periods);
		},

    MA: function (xData, yData, periods) {

			return MA(xData, yData, periods);
    },


		/* Function using the global EMA function.
		 * 
		 * @return : an array of EMA data.
		**/
		EMA: function (xData, yData, periods) {

			return EMA(xData, yData, periods);
		}, 

		/* Function that uses the global linear function.
		 *
		 * @return : an array of EMA data
		**/
		linear: function (xData, yData, periods) {

			return linear(xData, yData, periods);
		}

	});

	// Setting default options for the Histogram type.
	defaultPlotOptions.histogram = H.merge(defaultPlotOptions.column, {

		borderWidth : 0,

		tooltip: {
			valueDecimals: 2
		}

	});


	seriesTypes.histogram = H.extendClass(seriesTypes.column, {
		
		type: 'histogram',
		animate: null,
		requiresSorting: false,
		processData: function() {
			var data;

			if (this.linkedParent) {
				data = [].concat(this.linkedParent.options.data)
				this.setData(this.runAlgorithm(), false);
			}

			H.Series.prototype.processData.call(this);
		},

		runAlgorithm: function () {

			var xData = this.linkedParent.xData,
				yData = this.linkedParent.yData,
				periods = this.options.periods || 100,		// Set this to what default? should be defaults for each algorithm.
				algorithm = this.options.algorithm || 'histogram';

			return this[algorithm](xData, yData, periods);
		},


		histogram: function (xData, yData, periods) {

			return calcMACD(xData, yData, periods)[2];
		},

	});


	// Global functions.

	/* Function that calculates the MACD (Moving Average Convergance-Divergence).
	 *
	 * @param yData : array of y variables.
	 * @param xData : array of x variables.
	 * @param periods : The amount of "days" to average from.
	 * @return : An array with 3 arrays. (0 : macd, 1 : signalline , 2 : histogram) 
	**/
	function calcMACD (xData, yData, periods) {

		var chart = this,
			shortPeriod = 12,
			longPeriod = 26,
			signalPeriod = 9,
			shortEMA,
			longEMA,
			MACD = [], 
			xMACD = [],
			yMACD = [],
			signalLine = [],
			histogram = [];


		// Calculating the short and long EMA used when calculating the MACD
		shortEMA = EMA(xData, yData, 12);
		longEMA = EMA(xData, yData, 26);

		// subtract each Y value from the EMA's and create the new dataset (MACD)
		for (var i = 0; i < shortEMA.length; i++) {

			if (longEMA[i][1] == null) {

				MACD.push( [xData[i] , null]);

			} else {
				MACD.push( [ xData[i] , (shortEMA[i][1] - longEMA[i][1]) ] );
			}
		}

		// Set the Y and X data of the MACD. This is used in calculating the signal line.
		for (var i = 0; i < MACD.length; i++) {
			xMACD.push(MACD[i][0]);
			yMACD.push(MACD[i][1]);
		}

		// Setting the signalline (Signal Line: X-day EMA of MACD line).
		signalLine = EMA(xMACD, yMACD, signalPeriod);

		// Setting the MACD Histogram. In comparison to the loop with pure MACD this loop uses MACD x value not xData.
		for (var i = 0; i < MACD.length; i++) {

			if (MACD[i][1] == null) {

				histogram.push( [ MACD[i][0], null ] );
			
			} else {

				histogram.push( [ MACD[i][0], (MACD[i][1] - signalLine[i][1]) ] );

			}
		}

		return [MACD, signalLine, histogram];
	}

	/**
	 * Calculating a linear trendline.
	 * The idea of a trendline is to reveal a linear relationship between 
	 * two variables, x and y, in the "y = mx + b" form.
	 * @param yData : array of y variables.
	 * @param xData : array of x variables.
	 * @param periods : Only here for overloading purposes.
	 * @return an array containing the linear trendline. 
	**/
	function linear (xData, yData, periods) {

		var		lineData = [],
				step1,
				step2 = 0,
				step3 = 0,
				step3a = 0,
				step3b = 0,
				step4 = 0,
				step5 = 0,
				step5a = 0,
				step6 = 0,
				step7 = 0,
				step8 = 0,
				step9 = 0;


		// Step 1: The number of data points.
		step1 = xData.length;

		// Step 2: "step1" times the summation of all x-values multiplied by their corresponding y-values.
		// Step 3: Sum of all x-values times the sum of all y-values. 3a and b are used for storing data.
		// Step 4: "step1" times the sum of all squared x-values.
		// Step 5: The squared sum of all x-values. 5a stores data.
		// Step 6: Equation to calculate the slope of the regression line.
		// Step 7: The sum of all y-values.
		// Step 8: "step6" times the sum of all x-values (step5).
		// Step 9: The equation for the y-intercept of the trendline.
		for ( var i = 0; i < step1; i++) {
			step2 = (step2 + (xData[i] * yData[i]));
			step3a = (step3a + xData[i]);
			step3b = (step3b + yData[i]);
			step4 = (step4 + Math.pow(xData[i], 2));
			step5a = (step5a + xData[i]);
			step7 = (step7 + yData[i]);
		}
		step2 = (step1 * step2);
		step3 = (step3a * step3b);
		step4 = (step1 * step4);
		step5 = (Math.pow(step5a, 2));
		step6 = ((step2 - step3) / (step4 - step5));
		step8 = (step6 * step5a);
		step9 = ((step7 - step8) / step1);

		// Step 10: Plotting the trendline. Only two points are calulated.
		// The starting point.
		// This point will have values equal to the first X and Y value in the original dataset.
		lineData.push([xData[0] , yData[0]]);

		// Calculating the ending point.
		// The point X is equal the X in the original dataset.
		// The point Y is calculated using the function of a straight line and our variables found.
		step10 = ( ( step6 * xData[step1 - 1] ) + step9 );
		lineData.push([ ( xData[step1 - 1] ), step10 ]);

		return lineData;
	}

	function MA (xData, yData, periods) {
    var maLine = [],
        periodArr = [],
        length = yData.length;

		for (var i = 0; i < length; i++) {
      periodArr.push(yData[i]);

      if (i >= periods) {
				maLine.push([xData[i] , arrayAvg(periodArr)]);
        periodArr.shift();
      }
      else {
				maLine.push([xData[i] , null]);
      }
    }

    return maLine;
  }


	/* Function based on the idea of an exponential moving average.
	 * 
	 * Formula: EMA = Price(t) * k + EMA(y) * (1 - k)
	 * t = today, y = yesterday, N = number of days in EMA, k = 2/(2N+1)
	 *
	 * @param yData : array of y variables.
	 * @param xData : array of x variables.
	 * @param periods : The amount of "days" to average from.
	 * @return an array containing the EMA.	
	**/
	function EMA (xData, yData, periods) {
		var t,
			y = false,
			n = periods,
			k = (2 / (n + 1)),
			ema,	// exponential moving average.
			emLine = [],
			periodArr = [],
			length = yData.length,
			pointStart = xData[0];

		// loop through data
		for (var i = 0; i < length; i++) {


			// Add the last point to the period arr, but only if its set.
			if (yData[i-1]) {
				periodArr.push(yData[i]);
			}
			

			// 0: runs if the periodArr has enough points.
			// 1: set currentvalue (today).
			// 2: set last value. either by past avg or yesterdays ema.
			// 3: calculate todays ema.
			if (n == periodArr.length) {


				t = yData[i];

				if (!y) {
					y = arrayAvg(periodArr);
				} else {
					ema = (t * k) + (y * (1 - k));
					y = ema;
				}

				emLine.push([xData[i] , y]);

				// remove first value in array.
				periodArr.splice(0,1);

			} else {

				emLine.push([xData[i] , null]);
			}

		}

		return emLine;
	}

	/* Function based on the idea of a simple moving average.
	 * @param yData : array of y variables.
	 * @param xData : array of x variables.
	 * @param periods : The amount of "days" to average from.
	 * @return an array containing the SMA.	
	**/
	function SMA (xData, yData, periods) {
		var periodArr = [],
			smLine = [],
			length = yData.length,
			pointStart = xData[0];

		// Loop through the entire array.
		for (var i = 0; i < length; i++) {

			// add points to the array.
			periodArr.push(yData[i]);

			// 1: Check if array is "filled" else create null point in line.
			// 2: Calculate average.
			// 3: Remove first value.
			if (periods == periodArr.length) {

				smLine.push([ xData[i] , arrayAvg(periodArr)]);
				periodArr.splice(0,1);

			}  else {
				smLine.push([ xData[i] , null]);
			}
		}
		return smLine;
	}

	/* Function that returns average of an array's values.
	 *
	**/
	function arrayAvg (arr) {
		var sum = 0,
			arrLength = arr.length,
			i = arrLength;

		while (i--) {
			sum = sum + arr[i];
		}

		return (sum / arrLength);
	}

}(Highcharts));
