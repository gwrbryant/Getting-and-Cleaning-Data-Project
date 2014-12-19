Study Design
============
- how the data were collected
Information about the summary choices
Information about the experimental study design
raw data

tidy data

Code Book
=========
Coding for each of the variables is outlined below.

There are only two numeric variables in the dataset

Variables
=========
subject

    An integer in [1, 30] denoting the person wearing the smartphone

activity
    A factor with 6 levels obtained from the "activity_labels.txt" file in the dataset
        "WALKING"
        "WALKING UPSTAIRS"
        "WALKING_DOWNSTAIRS"
        "SITTING"
        "STANDING" and
        "LAYING"


domain
    A 2-level factor denoting whether the observation is in the 
        "time" or 
        "frequency" domain

location
    A 2-level factor denoting whether the measurement relates to motion of the
        "Body" or the (relatively) static 
        "Gravity"

sensor
    A 2-level factor inidcting whether the observation is derived from the smartphone's 
        "Acceleromenter" or 
        "Gyroscope"

derivative
    A 2-level factor indicating whether the observation is made on the 
        "0th" order data or its
        "1st" derivative

direction
    A 4-level factor indicating the direction of the observation vector in Cartesian axes:
        "X" 
        "Y"
        "Z"  
        "Magnitude"

mean
    A continuous variable on [-1,1] representing the mean of the normalised mean of all observations
    for each subject and activity
    Units: none (normalised)

stddev
    A continuous variable on [-1,1] representing the mean of the normalised standard deviation of all observations
    for each subject and activity 
    Units: none (normalised)
