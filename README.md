# Getting-and-Cleaning-Data-Project

This repo holds the R code, readme.md &amp; codebook.md for the tidied version of the UCI HAR dataset that is to be generated as part of the Getting and Cleaning Data Cousera course. The R script is the instruction set for transforming some of the data in the HAR Dataset into one that conforms to the tidy data principles. These transformations are discussed in more detail in the accompanying codebook.md file. 

The following operations are carried out by the instructions in a single file (run_analysis.R): 

 1. Merges the training and the test sets to create one data set.
     
 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
     
 3. Uses descriptive activity names to name the activities in the data set
     
 4. Appropriately labels the data set with descriptive variable names. 
     
 5. From the data set in step 4, creates a second, independent tidy data set With the average of each variable for each activity and each subject.

The script requires the following packages: dplyr and reshape2

It begins by checking that the dataset is in the working directory by checking that the relevant folder (\UCI HAR Dataset) is there; it does not actually check the files or folder structure. This checking routine is based on the code provided in the lectures. If the folder is not there, the data are downloaded and unzipped. Note that if you have downloaded and extracted the data files into your working directory indpendently, the path to the files may in fact be \getdata-projectfiles-UCI HAR Dataset\UCI HAR Dataset\ if the default Windows extract is used, in which case the dataset will be downloaded and unzipped by the script; blame it on differences between Windows' extract command and R's unzip().

We do not use the inertial data files, but only the summary and statistical data provided in the X file, the subject file and the y file (the activity type) for both the test and train sets. 

For Step 1, the two X files, the features list, and the subject and activity identifiers are all are read into separate data frames using read.table. The features vector is used to name the columns of both train and test data sets using a simple assignment, whilst subject and activity columns are added in a similar way. To complete Step 1 the train and test data frames are joined using rbind().

Step 2 is completed by using grep() to select the indices of column names that contain "-mean(" or "-std(" from the complete data set.  In this way we only get pairs of mean and stddev observations, and not observations where only the mean is reported. Initially it was intended to summarise the standard deviations in a different way to the means, so the subsetted means and stddevs are loaded into separate data frames.

Step 3 is achieved by reading in the activity names and using them to define activity factors. Activity, and many of the other variables, are categorical, and so (I think) are best stored as factors

Step 4 essentially involves transforming the data from wide to long format, using melt(). Again, we use grep() to select the column names that we want to keep as identifiers (subject and activity) and the measurement variables, and we continue to keep the mean and std observations in separate data frames. We then combine the mean and std data into one melted data frame (rows in the mean and std frames should be aligned, so we only need to copy the value column into the other data frame).

With a complete data set in long format, we take the extra step of partitioning (separating) the measurement type name (feature) into its component parts using grepl() to select which of the categories is used in each feature. This results in 5 new columns, most of which are 2 level factors except direction, which takes 4 levels (and therefore requires the most complicated of the nested ifelse() statements. Using ifesle() is not ideal, but the feature names are not consistent and difficult to separate. There may, of course, be an easier way to do this, but I haven't found this yet.

For Step 5, note that each observation per subject per activity is split into 2.56s long segments, and the number of segments is variable. To generate the required tidy dataset we need to average the rows corresponding to the entries for each subject. Strictly speaking this is not correct (as discussed in the codebook) but it is what the project instructions have requested. To do this we use the groupby() and summarise() functions in the dplyr package. It seems that as coded, the groupby() has to include very column we wish to keep in to tidy data set; this might not be required if I was to chain the commands. However, it conveniently removes the "variable" (that is, the list of features) column. 

Finally, as a check that everything has worked the script prints a table of subject vs activity; there should be 33 observations per subject per activity, for a total of 33 x 6 x 30 = 5940 observations. The tidy data set is then saved to a .txt file.
