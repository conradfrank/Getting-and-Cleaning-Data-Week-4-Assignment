library(purrr)
library(tidyr)
library(dplyr)

#Downloading and unzipping the file
if(!file.exists("UCR HAR Dataset") | !file.exists("getdata_Dataset.xip")){
path_file<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(path_file, "getdata_Dataset.zip", method="curl")
}
if(!file.exists("UCI HAR Dataset")){
   unzip("getdata_Dataset.zip")
 }

#Loading First Level Data
label_activity<-read.delim("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep="", col.names=c("ID", "ACTIVITY"))
features<- read.delim("UCI HAR Dataset/features.txt", header=FALSE, sep="", col.names=c("featureID", "featureName"), stringsAsFactors = FALSE)

#Loading the Dataset Train
training_set<-read.delim("UCI HAR Dataset/train/X_train.txt", header=FALSE, sep="", col.names=features$featureName)
training_labels<-read.delim("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep="", col.names= c("ID"))
training_subject<-read.delim("UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep="", col.names=c("SID"))
train_data<- tbl_df(cbind(training_subject, training_labels, training_set))

#Loading the Dataset Test
test_subject<-read.delim("UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep="", col.names=c("SID"))
test_labels<-read.delim("UCI HAR Dataset/test/y_test.txt", header=FALSE, sep="", col.names=c("ID"))
test_set<-read.delim("UCI HAR Dataset/test/X_test.txt", header=FALSE, sep="", col.names=features$featureName)
test_data<-tbl_df(cbind(test_subject, test_labels, test_set))

#Merging Data
All_Data<-rbind(train_data, test_data)
All_colNames<-colnames(All_Data)
ALL_Data<-All_Data%>%select(SID, ID, contains("mean.."), contains("std.."))

#Descriptive names to name activities
All_Data <- ALL_Data %>% inner_join(label_activity)
ALL_Data <- All_Data %>% select(SID, ACTIVITY, contains("mean.."), contains("std.."))
All_Data <- All_Data %>% setNames(gsub("^f", "FrequencyDomain", names(.)))
All_Data <- All_Data %>% setNames(gsub("^t", "TimeDomain", names(.)))
All_Data <- All_Data %>% setNames(gsub("Acc", "Accelerometer", names(.)))
All_Data <- All_Data %>% setNames(gsub("Gyro", "Gyroscope", names(.)))
All_Data <- All_Data %>% setNames(gsub("Mag", "Magnitude", names(.)))
All_Data <- All_Data %>% setNames(gsub("mean\\.\\.", "Mean", names(.)))
All_Data <- All_Data %>% setNames(gsub("std\\.\\.", "Std", names(.)))
All_Data <- All_Data %>% setNames(gsub("\\.", "", names(.)))
All_Data <- All_Data %>% select(-starts_with("angle"))


#Second independent tidy data set with average of each variable & Writing Data
summary_all_data <- All_Data %>% group_by(SID, ACTIVITY)
summary_all_data <- summary_all_data %>% summarize_each(funs(mean))
write.table(summary_all_data, file = "tidy_data.txt", row.name = FALSE)
print(summary_all_data)
