// Averages the numbers in an array.
function average(numbers) {
	var total = 0.0;
	for (var i=0; i < numbers.length; i++) {
		total += numbers[i];
	}
	return total / numbers.length;
}

// Averages the numbers in an array and rounds to the nearest whole number.
function average_and_round(numbers) {
	var averaged = average(numbers);
  return Math.round(averaged);
}

// Sums the numbers in an array.
function sum(numbers) {
	var total = 0.0;
	for (var i=0; i < numbers.length; i++) {
		total += numbers[i];
	}
	return total;
}

