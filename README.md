The README that explains the analysis files is clear and understandable.

Getting and Cleaning Data Course Project
---------------------------------------------------------------

##Objective

Companies like *FitBit, Nike,* and *Jawbone Up* are racing to develop the most advanced algorithms to attract new users. The data linked are collected from the accelerometers from the Samsung Galaxy S smartphone. 

A full description is available at the site where the data was obtained:  
<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

The data is available at:
<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

The objective of the project is to clean and extract usable data from the zip file as mentioned above. The R script *run_analysis.R* does the following:
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names.
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In this repository, you find:

1. *run_analysis.R* : the R-code run on the data set
2. *Tidy.txt* : the clean data extracted from the original data using *run_analysis.R*
3. *CodeBook.md* : the CodeBook reference to the variables in *Tidy.txt*
4. *README.md* : the analysis of the code in *run_analysis.R*

## Getting Started

###Libraries Used

The libraries used in this project is `data.table`.

```{r}
library(data.table)
```


###Read Supporting Metadata

The supporting metadata in this data are the name of the features and the name of the activities. They are loaded into variables `dtFeaturesNames` and `activityLabels`.
```{r}
dtFeaturesNames <- read.table("./data/UCI HAR Dataset/features.txt", head=FALSE)
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", header = FALSE)
```

##Format training and test data sets

Both training and test data sets are split up into subject, activity and features.

###Read Activity files
```{r}
dtActivityTest  <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
dtActivityTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header = FALSE)
```
###Read Subject files
```{r}
dtSubjectTest  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
dtSubjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
```
###Read Features files
```{r}
dtFeaturesTest  <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
dtFeaturesTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
```


##Part 1 - Merge the training and the test sets to create one data set
We can use combine the respective data in training and test data sets corresponding to subject, activity and features. The results are stored in `dtActivity`, `dtSubject` and `dtFeatures`.
```{r}
dtActivity<- rbind(dtActivityTest, dtActivityTrain)
dtSubject <- rbind(dtSubjectTest, dtSubjectTrain)
dtFeatures<- rbind(dtFeaturesTest, dtFeaturesTrain)
```
###Naming the columns
The columns in the features data set can be named from the metadata in `featureNames`

```{r}
dtFeaturesNames <- read.table("./data/UCI HAR Dataset/features.txt", head=FALSE)
names(dtFeatures)<- dtFeaturesNames$V2
```

###Merge the data
The data are merged and the complete data is now stored in `completeData`.

```{r}
names(dtSubject)<-c("subject")
names(dtActivity)<- c("activity")
completeData <- cbind(dtActivity,dtSubject,dtFeatures)
```

##Part 2 - Extracts only the measurements on the mean and standard deviation for each measurement

Extract the column indices that have either mean or std in them.
```{r}
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)
```
Add activity and subject columns to the list. 
```{r}
requiredColumns <- c(1,2,columnsWithMeanSTD)
```
We create `extractedData` with the selected columns in `requiredColumns`.
```{r}
extractedData <- completeData[,requiredColumns]
```
##Part 3 - Uses descriptive activity names to name the activities in the data set
The `activity` field in `extractedData` is originally of numeric type. We need to change its type to character so that it can accept activity names. The activity names are taken from metadata `activityLabels`.
```{r}
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", header = FALSE)
activityLabels <- as.character(activityLabels[,2])
```
#Replacing labels of activity in "extractedData" by descriptive strings which come from the file activity_labels.txt.
```{r}
extractedData$activity <- activityLabels[extractedData$activity]
```

##Part 4 - Appropriately labels the data set with descriptive variable names
The following labels can be replaced:

- Character `t` can be replaced with Time
- Character `f` can be replaced with Frequency
- `Acc` can be replaced with Accelerometer
- `Gyro` can be replaced with Gyroscope
- `Mag` can be replaced with Magnitude
- `BodyBody` can be replaced with Body
- `tBody` can be replaced with TimeBody

```{r}
names(extractedData) <- gsub("^t", "Time", names(extractedData))
names(extractedData) <- gsub("^f", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData) <- gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData) <- gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData) <- gsub("Mag", "Magnitude", names(extractedData))
names(extractedData) <- gsub("BodyBody", "Body", names(extractedData))
names(extractedData) <- gsub("tBody", "TimeBody", names(extractedData))
```

Here are the names of the variables in `extractedData` after they are edited
```{r}
names(extractedData)
```

##Part 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

Firstly, let us set `subject` as a factor variable. 
```{r}
extractedData$subject <- as.factor(extractedData$subject)
extractedData <- data.table(extractedData)
```
We create `tidyData` as a data set with average for each activity and subject. Then, we order the enties in `tidyData` and write it into data file `Tidy.txt` that contains the processed data.

```{r}
tidyData <- aggregate(. ~subject + activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
```