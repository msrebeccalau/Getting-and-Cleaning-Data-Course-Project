if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./data/Dataset.zip")){download.file(fileUrl, destfile="./data/Dataset.zip", method="curl")}
if(!file.exists("./data/UCI HAR Dataset")){unzip(zipfile="./data/Dataset.zip", exdir="./data")}

#folder name "UCI HAR Dataset"
list.files("./data/UCI HAR Dataset", recursive=TRUE)

#Read Activity files
dtActivityTest  <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
dtActivityTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header = FALSE)

#Read Subject files
dtSubjectTest  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
dtSubjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)

#Read Features files
dtFeaturesTest  <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
dtFeaturesTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)


#PART1-Merges the training and the test sets to create one data set
dtActivity<- rbind(dtActivityTest, dtActivityTrain)
dtSubject <- rbind(dtSubjectTest, dtSubjectTrain)
dtFeatures<- rbind(dtFeaturesTest, dtFeaturesTrain)

names(dtActivity)
names(dtSubject)
names(dtFeatures)

names(dtSubject)<-c("subject")
names(dtActivity)<- c("activity")
dtFeaturesNames <- read.table("./data/UCI HAR Dataset/features.txt", head=FALSE)
names(dtFeatures)<- dtFeaturesNames$V2

completeData <- cbind(dtActivity,dtSubject,dtFeatures)

#PART2-Extracts only the measurements on the mean and standard deviation for each measurement.
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)
requiredColumns <- c(1,2,columnsWithMeanSTD)
extractedData <- completeData[,requiredColumns]

#PART3 - Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", header = FALSE)
activityLabels <- as.character(activityLabels[,2])
#Replacing numeric labels of activity in "extractedData" by descriptive strings which come from the file activity_labels.txt.
extractedData$activity <- activityLabels[extractedData$activity]

#PART4-Appropriately labels the data set with descriptive variable names.
names(extractedData) <- gsub("^t", "Time", names(extractedData))
names(extractedData) <- gsub("^f", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData) <- gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData) <- gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData) <- gsub("Mag", "Magnitude", names(extractedData))
names(extractedData) <- gsub("BodyBody", "Body", names(extractedData))
names(extractedData) <- gsub("tBody", "TimeBody", names(extractedData))

names(extractedData)

#PART5-From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
extractedData$subject <- as.factor(extractedData$subject)


library(data.table)
extractedData <- data.table(extractedData)
tidyData <- aggregate(. ~subject + activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)

