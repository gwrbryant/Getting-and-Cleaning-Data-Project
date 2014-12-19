# This script is designed to transform some of the data in the HAR Dataset
# into one that conforms to the tidy data principles. It does this by carrying out 
# the following operations: 
#     1. Merges the training and the test sets to create one data set.
#     2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#     3. Uses descriptive activity names to name the activities in the data set
#     4. Appropriately labels the data set with descriptive variable names. 
#     5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Note that the script is the instruction list - the collection of commands that
# would be used at the R console in order to complete steps 1-5. It is quite 
# specific to the dataset, and is provided as a record of how the tidy data were
# obtained and a means to reproduce this.

# First make sure the required libraries are loaded
    library(dplyr)
    library(reshape2)

# See if the data are there (CAUTION: - this only checks that the folder is there;
# it doesn't check the files or folder structure).
# If its not there, then download it
# Note that we store the download date but have yet to figure out where to put it
    if(!file.exists(".//UCI HAR Dataset")){
        fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
        setInternet2(TRUE)    # this is required on a Windows system to access the https:// protocol
        tmpfile=tempfile()
        download.file(fileUrl,tmpfile)
        unzip(tmpfile)
        unlink(tmpfile)
        downloaddate<-date()
    }

# We need the X file, the subject file and the y file (the activity type) 
# for both the test and train sets. We assume the file structure is known 
# and constant and as described in the accompanying readme and info files

# Now we have the data, lets begin Step 1

# First read the test and train datasets into two data tables "test" and "train"
    test<-read.table(".//UCI HAR Dataset//test//X_test.txt")
    train<-read.table(".//UCI HAR Dataset//train//X_train.txt")

# Now read in the labels for the dataset features
    features<-read.table(".//UCI HAR Dataset//features.txt")

# Use these labels to name the columns in the two datasets for now
    names(test)<-features[,2]
    names(train)<-features[,2]

# Now read in the subject identifiers for each dataset
    subject_test<-read.table(".//UCI HAR Dataset//test//subject_test.txt")
    subject_train<-read.table(".//UCI HAR Dataset//train//subject_train.txt")

# Do the same for the activity identifiers for each dataset
    activity_test<-read.table(".//UCI HAR Dataset//test//y_test.txt")
    activity_train<-read.table(".//UCI HAR Dataset//train//y_train.txt")

# OK, now join up the test and train data with the subject and activity list
    test[,"subject"]<-subject_test
    test[,"activity"]<-activity_test
    train[,"subject"]<-subject_train
    train[,"activity"]<-activity_train

# Finally, join up the two datasets into one 
    alldata<-rbind(test,train)

# End Step 1 - alldata contains the merged data set with subject and activity 
# identifiers and "feature" (column) labels

# Lets begin Step 2

# Select the mean and std columns from the data, and rearrange things at the same time, putting subject and activity leftmost
# Note that the "features" include entries for means that don't have accompanying
# standard deviations - the meanFreq() and angle variables. We will exclude these
# from the tidy data set on the basis that we want a mean and std for every observation
# We do this by looking for feature labels that have "-mean(" or "-std(" in them
# Note that Windows doesn't like parentheses in quotes, so we have to include an escape (\\) in the string
# Create separate mean and std data tables
    indices<-c(grep("subject",names(alldata)), grep("activity",names(alldata)),grep("-mean\\(",names(alldata)))
    mean_dat<-alldata[,indices]
    indices<-c(grep("subject",names(alldata)), grep("activity",names(alldata)),grep("-std\\(",names(alldata)))
    std_dat<-alldata[,indices]

# That's Step 2 done

# Lets start Step 3 by redaing in the activity names and using them to define 
# activity factors; not sure that using factors is absolutely necessary, but I
# like what it does to the str(data.frame) output
    activity_labels<-read.table(".//UCI HAR Dataset//activity_labels.txt")
    mean_dat$activity<-factor(mean_dat$activity,labels=activity_labels[,2])
    std_dat$activity<-factor(std_dat$activity,labels=activity_labels[,2])

# Step 3 complete

# Begin Step 4

# We need to sort out variables and their descriptions
# We have two (wide) datasets that have columns that represent observations 
# associated with more than one variable (refer to the accompanying readme.md and codebook.md)
# To tidy this up and name things properly, we'll start by melting to datasets into 
# the long form. 
    indices<-grep("subject|activity", names(mean_dat), invert=TRUE)
    mean_dat_melt<-melt(mean_dat,id=c("subject","activity"),measure.vars=names(mean_dat[indices]))
    std_dat_melt<-melt(std_dat,id=c("subject","activity"),measure.vars=names(std_dat[indices]))

# Now combine the mean and std data sets by placing the std value column in the
# and the mean_dat set in a new data frame.
    all_dat_melt<-mean_dat_melt
    all_dat_melt$stddev <-std_dat_melt$value

# Now lets start splitting up the observation variables; this would be easy
# if the feature names were uniform and had separators between variables
# However, this is not the case, so we've resorted to sorting each of them out
# one at a time; not exactly vectorized, but still looking for a better way.
# Refer to the codebook.md file for why we're doing this 
    all_dat_melt$domain<-ifelse(grepl("tB|tG", all_dat_melt$variable),"time","frequency")
    all_dat_melt$movement<-ifelse(grepl("Body", all_dat_melt$variable)>0,"Body","Gravity")
    all_dat_melt$sensor<-ifelse(grepl("Acc", all_dat_melt$variable),"Accelerometer","Gyroscope")
    all_dat_melt$derivative<-ifelse(grepl("Jerk", all_dat_melt$variable),"1st","0th")
    all_dat_melt$direction<-ifelse(grepl("Mag", all_dat_melt$variable),"Magnitude",ifelse(grepl("-X", all_dat_melt$variable),"X",ifelse(grepl("-Y",all_dat_melt$variable),"Y","Z")))

# Make these columns of factors (for reasons mentioned above)
    all_dat_melt$derivative<-factor(all_dat_melt$derivative,c("0th","1st"))
    all_dat_melt$direction<-factor(all_dat_melt$direction,c("Magnitude","X", "Y", "Z"))
    all_dat_melt$sensor<-factor(all_dat_melt$sensor,c("Accelerometer","Gyroscope"))
    all_dat_melt$movement<-factor(all_dat_melt$movement,c("Body","Gravity"))
    all_dat_melt$domain<-factor(all_dat_melt$domain,c("frequency","time"))

# That's Step 4 done.

# Finally to Step 5
# There is more than one observation per subject per activity. To generate the
# required tidy dataset we need to average the rows corresponding to the 
# entries for each subject, but make sure we include everything except 
# the "variable" column. We'll include rather than delete...

# Note that despite being technically incorrect, we're just averaging the mean and
# taking the median of stddev (again, refer to the codebook.md) 
    subject_mean<-group_by(all_dat_melt,subject,activity,domain,movement,sensor,derivative,direction)
    tidydata<-summarise(subject_mean, mean=mean(value), stddev=mean(stddev))

# If everything has worked, there should be 33 observations per
# subject per activity, for a total of 33 x 6 x 30 = 5940 observations
    print(table(tidydata$subject,tidydata$activity))

# Last step - write the tidy data out to a .txt file
    write.table(tidydata,"tidyHARdataset.txt", row.name=FALSE) 

# Phew! Step 5 done!