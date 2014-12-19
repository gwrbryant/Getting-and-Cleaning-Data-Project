# Study Design

## Raw data
The study makes use of the data provided in the Human Activity Recognition database provided by UCI
(http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) 

These data are built from the recordings of 30 subjects performing activities of daily living while carrying a waist-mounted smartphone with embedded inertial sensors. The data collection and procesing algorithms are described in the readme.txt and features_info.txt files that accompany the dataset.

Each subject has a number of observations recorded from two sensors on the smartphone. These are split into 2.56 second subset timeseries for which several statistical parameters are calcluated in bothe the time and frequency domains. The number of subsets per subject and activity is not fixed. In addition, the subsets are partitioned such that each overlaps the previous by 50% (that is half of the subset inertial signals appear in the next subset).

The inertial signals are grouped as "features" in the dataset. Each feature represents a combination of the following parameters, and is labelled accordingly:
* t or f: time or frequency domain
* Body or Gravity: dynamic or static (or slowly varying) signals
* Data or its rate of change (that is, derivative)
* The direction of the measurement vector (presumably in the smartphone's frame of reference)

The nature of the signals means that of the 64 possible combinations of these parameters, only 33 are calculated.  For example, frequency domain transforms are not calculated for the Gravity data.

## Tidy data
One interpretation of the data is that the features represent values taken by a "type of measurement" variable. This requires reshaping the data into a long format. An extension of this interpretation is that each of the features represents the combination of a number of measurement variables (sensor, direction, etc.) and we should split the "type of measurement" variable into its constituent parts. This is the approach taken here.

For each subject, activity and measurement type the data will be summarised as the mean of the mean and the standard deviation statistics provided in the raw dataset. Strictly speaking, this is not a true representation of the complete observation, for a number of reasons:
* The observation subsets overlap, so the mean of the means of the subsets will not necessarily represent the mean of the complete observation time series; all of the complete observation, except the first or last 1.28s, gets counted twice. The result will be close, but not exact.
* The standard deviation of the complete observation should be calculated as a pooled variance; this is further complicated by the fact that the standard deviations are normalised over [-1,1], meaning the subset standard deviations can be (counter-intuitively) both negative and positive. The mean of the standard deviation of the subsets is potentially unrepresentative, but we use this as required by Step 5 of the project outline.

Correctly calculating the mean and standard deviation would require assembly of the intertial data into complete observations and carrying out the addition domain transforms and statistics, which is considered beyond the scope of the Coursera project.

Note there are a number of other mean data in the features (such as the angle data and meanFreq features); these do not have accompanying standard deviations and so are not included in the summary provided in the tidy data.

# Code Book

Coding for each of the variables follows the partitioning of the measurement type variable as described above.

## Variables

*subject*

An integer in [1, 30] denoting the person wearing the smartphone

*activity*

A factor with 6 levels obtained from the "activity_labels.txt" file in the dataset
  * "WALKING"
  * "WALKING UPSTAIRS"
  * "WALKING_DOWNSTAIRS"
  * "SITTING"
  * "STANDING" and
  * "LAYING"


*domain*

A 2-level factor denoting whether the observation is in the 
* "time" or 
* "frequency" domain

*movement*

A 2-level factor denoting whether the measurement relates to motion of the
* "Body" or the (relatively) static 
* "Gravity"

*sensor*

A 2-level factor inidcating whether the observation is derived from the smartphone's 
* "Acceleromenter" or 
* "Gyroscope"

*derivative*

A 2-level factor indicating whether the observation is made on the 
* "0th" order data or its
* "1st" derivative

*direction*

A 4-level factor indicating the direction of the observation vector in Cartesian axes:
* "X" 
* "Y"
* "Z"  
* "Magnitude"

*mean*

A continuous variable on [-1,1] representing the mean of the normalised mean of all observations
    for each subject and activity
    
  Units: none (normalised)

*stddev*

A continuous variable on [-1,1] representing the mean of the normalised standard deviation of all observations
    for each subject and activity 
    
  Units: none (normalised)
 
