library(dplyr)

# We create the data directory, download our data and unzip it.
if(!file.exists("data")){dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="data/DataUCI.zip",method="curl")
unzip(zipfile="data/DataUCI.zip",exdir="data")

# we load all the data frames from
subject_test<-read.table("data/UCI HAR Dataset/test/subject_test.txt")
x_test<-read.table("data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("data/UCI HAR Dataset/test/y_test.txt")
subject_train<-read.table("data/UCI HAR Dataset/train/subject_train.txt")
x_train<-read.table("data/UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("data/UCI HAR Dataset/train/y_train.txt")
activities <- read.table ("data/UCI HAR Dataset/activity_labels.txt")
features<-read.table("data/UCI HAR Dataset/features.txt")

## We add the name of variables in both train and test datasets
## and add the variable number of subject and the code of activity type to each. 
## Then we merge both datasets and make a join with the code of acivity to have
## a new column with the actual name of the activity instead of a number.
 
names(x_train) <- features$V2
names(x_test) <- features$V2

train <- bind_cols (subject_train, y_train, x_train)

test <- bind_cols (subject_test, y_test, x_test)

merged_data <- rbind (train, test) %>% 
  full_join (activities, by = c("V1...2"="V1"))

## We tidy the data by selecting only the columns which refer to mean() and std(),
## and teh columns of the number of the subject and the activity label and we rename
## them to a more clear name. Then we use gsub function to change the abbreviated 
## names of the measurements variables to the full and more understandable word.


tidy_data <- merged_data %>% 
  select (V1...1, contains ("mean()"), contains ("std()"), V2) %>%
  rename(Activity = V2, Subject = V1...1) %>%
  relocate (Activity, .after = Subject)

names(tidy_data) <- gsub("-mean()", "Mean", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("-std()", "STD", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("-freq()", "Frequency", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data) <- gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data) <- gsub("BodyBody", "Body", names(tidy_data))
names(tidy_data) <- gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data) <- gsub("^t", "Time", names(tidy_data))
names(tidy_data) <- gsub("^f", "Frequency", names(tidy_data))
names(tidy_data) <- gsub("tBody", "TimeBody", names(tidy_data))

## Finally, with the tidy dataset, we proceed to measure the average of all
## the measurement variables per Subject and Activity, and create the new
## dataset in our directory.

averaged_data <- tidy_data %>% 
  group_by(Subject, Activity) %>%
  summarize (across(1:66, mean), .groups = "keep")
write.table(averaged_data, "averaged_data.txt", row.name=FALSE)
averaged_data
